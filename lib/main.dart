import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'rating_button.dart';
import 'rating_entry_tile.dart';
import 'undo_overlay.dart';

void main() {
  runApp(RateSelfApp());
}

class RateSelfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'rateself',
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: CupertinoColors.black,
        scaffoldBackgroundColor: CupertinoColors.white,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 16,
            color: CupertinoColors.black,
          ),
        ),
      ),
      home: RatePage(),
    );
  }
}

class RatePage extends StatefulWidget {
  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  List<RatingEntry> entries = [];
  int totalScore = 0;
  OverlayEntry? _currentUndoOverlay;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final didReset = await _checkDateReset();

    if (didReset) return;

    final savedEntries = prefs.getString('entries');
    final savedScore = prefs.getInt('totalScore');

    if (savedEntries != null) {
      final decoded = jsonDecode(savedEntries) as List;
      setState(() {
        entries = decoded.map((e) => RatingEntry.fromJson(e)).toList();
        totalScore = savedScore ?? 0;
      });
    }
  }


  Future<bool> _checkDateReset() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getString('lastDate');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastDate != today) {
      setState(() {
        entries.clear();
        totalScore = 0;
      });
      prefs.remove('entries');
      prefs.remove('totalScore');
      prefs.setString('lastDate', today);
      return true;
    }

    return false;
  }

  void _addRating(int value) async {
    await _checkDateReset();

    HapticFeedback.mediumImpact();

    final entry = RatingEntry(value, DateTime.now());

    setState(() {
      entries.add(entry);
      totalScore += value;
    });
    _saveData();

    UndoOverlay.show(context, entry, onUndo: () {
      setState(() {
        entries.remove(entry);
        totalScore -= entry.value;
      });
    });
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final entryJson = entries.map((e) => e.toJson()).toList();
    prefs.setString('entries', jsonEncode(entryJson));
    prefs.setInt('totalScore', totalScore);
    prefs.setString('lastDate', DateTime.now().toIso8601String().split('T')[0]);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              'Total Score: $totalScore',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return RatingEntryTile(entry: entries[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RatingButton(
                  value: -1,
                  onPressed: () => _addRating(-1),
                ),
                RatingButton(
                  value: 0,
                  onPressed: () => _addRating(0),
                ),
                RatingButton(
                  value: 1,
                  onPressed: () => _addRating(1),
                ),
              ]
            ),
          ],
        ),
      ),
    );
  }
}

class RatingEntry {
  final int value;
  final DateTime time;

  RatingEntry(this.value, this.time);

  Map<String, dynamic> toJson() => {
    'value': value,
    'time': time.toIso8601String(),
  };

  static RatingEntry fromJson(Map<String, dynamic> json) {
    return RatingEntry(
      json['value'],
      DateTime.parse(json['time']),
    );
  }
}
