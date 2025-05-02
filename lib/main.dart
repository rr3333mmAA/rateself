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

  void _addRating(int value) {
    final entry = _RatingEntry(value, DateTime.now());

    setState(() {
      entries.add(entry);
      totalScore += value;
    });

    _showUndoOverlay(context, entry);
  }

  void _showUndoOverlay(BuildContext context, _RatingEntry entry) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 20,
        right: 20,
        child: CupertinoPopupSurface(
          child: Container(
            color: CupertinoColors.systemGrey.withOpacity(0.95),
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
                    overlayEntry.remove();
                  },
                  child: Text('Undo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3)).then((_) {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('rateself'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ratingButton(-1),
                _ratingButton(0),
                _ratingButton(1),
              ],
            ),
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
          ],
        ),
      ),
    );
  }

  Widget _ratingButton(int value) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: CupertinoColors.black,
      borderRadius: BorderRadius.circular(30),
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
            color: CupertinoColors.white,
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
}
