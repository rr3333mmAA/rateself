import 'package:flutter/cupertino.dart';
import 'main.dart';

class RatingEntryTile extends StatelessWidget {
  final RatingEntry entry;

  const RatingEntryTile({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    final formattedTime = '${entry.time.hour.toString().padLeft(2, '0')}:${entry.time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.value}',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}
