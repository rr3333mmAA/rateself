import 'package:flutter/material.dart';

void main() {
  runApp(RateSelfApp());
}

class RateSelfApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rateself',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        colorScheme: ColorScheme.dark(),
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rating added: $value'),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              entries.remove(entry);
              totalScore -= value;
            });
          },
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('rateself'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
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
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text(
                    '${entry.value >= 0 ? '+' : ''}${entry.value}',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _formatTime(entry.time),
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingButton(int value) {
    return ElevatedButton(
      onPressed: () => _addRating(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: CircleBorder(),
        padding: EdgeInsets.all(24),
      ),
      child: Text('$value', style: TextStyle(fontSize: 24)),
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
