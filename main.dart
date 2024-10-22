import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, isDragging) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDragging
                      ? Colors.grey // Color change when dragging
                      : Colors
                          .primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T, bool isDragging) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// Index of the item currently being dragged.
  int? _draggingIndex;

  /// Position offset during drag.
  double _dragOffsetX = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragOffsetX += details.delta.dx;
                int newIndex = _calculateNewIndex(index);
                if (newIndex != index) {
                  _moveItem(index, newIndex);
                }
              });
            },
            onHorizontalDragEnd: (details) {
              setState(() {
                _draggingIndex = null;
                _dragOffsetX = 0.0;
              });
            },
            onHorizontalDragStart: (details) {
              setState(() {
                _draggingIndex = index;
              });
            },
            child: Transform.translate(
              offset: Offset(
                _draggingIndex == index ? _dragOffsetX : 0.0,
                0.0,
              ),
              child: widget.builder(_items[index], _draggingIndex == index),
            ),
          );
        }),
      ),
    );
  }

  /// Calculates the new index based on drag offset and current item index.
  int _calculateNewIndex(int currentIndex) {
    double itemWidth = 64.0; // Approximate width of each icon with margin.
    int newIndex = currentIndex + (_dragOffsetX ~/ itemWidth).toInt();
    newIndex = newIndex.clamp(0, _items.length - 1);
    return newIndex;
  }

  /// Moves the item from the old index to the new index.
  void _moveItem(int oldIndex, int newIndex) {
    if (oldIndex != newIndex) {
      setState(() {
        final item = _items.removeAt(oldIndex);
        _items.insert(newIndex, item);
      });
    }
  }
}
