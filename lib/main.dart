import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

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
  List<_RatingEntry> entries = [];
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
        entries = decoded.map((e) => _RatingEntry.fromJson(e)).toList();
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

    final entry = _RatingEntry(value, DateTime.now());

    setState(() {
      entries.add(entry);
      totalScore += value;
    });
    _saveData();

    _showUndoOverlay(context, entry);
  }

  void _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final entryJson = entries.map((e) => e.toJson()).toList();
    prefs.setString('entries', jsonEncode(entryJson));
    prefs.setInt('totalScore', totalScore);
    prefs.setString('lastDate', DateTime.now().toIso8601String().split('T')[0]);
  }

  void _showUndoOverlay(BuildContext context, _RatingEntry entry) {
    _currentUndoOverlay?.remove();

    final overlay = Overlay.of(context, rootOverlay: true)!;
    late OverlayEntry overlayEntry;

    final animationController = AnimationController(
      vsync: Navigator.of(context),
      duration: Duration(milliseconds: 250),
    );

    final animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    final slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(animation);

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: animation,
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rating ${entry.value} added'),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      setState(() {
                        entries.remove(entry);
                        totalScore -= entry.value;
                      });
                      animationController.reverse();
                      Future.delayed(Duration(milliseconds: 200), () {
                        if (overlayEntry.mounted) overlayEntry.remove();
                        animationController.dispose();
                        if (_currentUndoOverlay == overlayEntry) {
                          _currentUndoOverlay = null;
                        }
                      });
                    },
                    child: Text(
                      'Undo',
                      style: TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    _currentUndoOverlay = overlayEntry;
    animationController.forward();

    Future.delayed(Duration(seconds: 3)).then((_) {
      if (overlayEntry.mounted) {
        animationController.reverse();
        Future.delayed(Duration(milliseconds: 200), () {
          if (overlayEntry.mounted) overlayEntry.remove();
          animationController.dispose();
          if (_currentUndoOverlay == overlayEntry) {
            _currentUndoOverlay = null;
          }
        });
      }
    });
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
                  final entry = entries[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.value}',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          _formatTime(entry.time),
                          style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ratingButton(-1),
                _ratingButton(0),
                _ratingButton(1),
              ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingButton(int value) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: CupertinoColors.white,
      minSize: 64,
      onPressed: () => _addRating(value),
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            color: CupertinoColors.black,
            fontFeatures: [FontFeature.tabularFigures()], // monospaced numbers
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _RatingEntry {
  final int value;
  final DateTime time;

  _RatingEntry(this.value, this.time);

  Map<String, dynamic> toJson() => {
    'value': value,
    'time': time.toIso8601String(),
  };

  static _RatingEntry fromJson(Map<String, dynamic> json) {
    return _RatingEntry(
      json['value'],
      DateTime.parse(json['time']),
    );
  }
}
