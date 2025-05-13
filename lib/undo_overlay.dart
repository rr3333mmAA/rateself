import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'dart:async';
import 'main.dart';

class UndoOverlay {
  static OverlayEntry? _current;

  static void show(
    BuildContext context,
    RatingEntry entry, {
    required VoidCallback onUndo,
  }) {
    _current?.remove();
    bool disposed = false;
    bool tapped = false;

    final overlay = Overlay.of(context, rootOverlay: true)!;
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

    late OverlayEntry overlayEntry;

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
                      if (tapped) return;
                      tapped = true;

                      onUndo();

                      animationController.reverse();

                      Future.delayed(Duration(milliseconds: 200), () {
                        if (overlayEntry.mounted) overlayEntry.remove();
                        if (!disposed) {
                          disposed = true;
                          if (_current == overlayEntry) _current = null;
                          animationController.dispose();
                        }
                      });
                    },
                    child: Text(
                      'Undo',
                      style: TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontFamily: 'JetBrainsMono',
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
    _current = overlayEntry;
    animationController.forward();

    Future.delayed(Duration(seconds: 3)).then((_) {
      if (overlayEntry.mounted) {
        animationController.reverse();
        Future.delayed(Duration(milliseconds: 200), () {
          if (overlayEntry.mounted) overlayEntry.remove();
          if (!disposed) {
            disposed = true;
            if (_current == overlayEntry) _current = null;
            animationController.dispose();
          }
        });
      }
    });
  }
}
