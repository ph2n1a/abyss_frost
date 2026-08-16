import 'package:flutter/material.dart';

class GestureDiagnosticsWidget extends StatefulWidget {
  const GestureDiagnosticsWidget({super.key});

  @override
  State<GestureDiagnosticsWidget> createState() =>
      _GestureDiagnosticsWidgetState();
}

class _GestureDiagnosticsWidgetState extends State<GestureDiagnosticsWidget> {
  int _activePointers = 0;
  final Map<int, PointerEvent> _pointerPositions = {};
  final List<String> _logs = [];
  static const int _maxLogs = 50;

  bool _isInScaleGesture = false;
  bool _isInPanGesture = false;
  bool _scaleRecognized = false;

  double _initialScale = 1.0;
  Offset _initialFocal = Offset.zero;
  int _scalePointerCount = 0;

  void _log(String event) {
    final time = DateTime.now().millisecondsSinceEpoch % 100000;
    setState(() {
      _logs.insert(0, '[${time.toString().padLeft(5, '0')}] $event');
      if (_logs.length > _maxLogs) {
        _logs.removeLast();
      }
    });
    debugPrint('[GESTURE-DIAG] $event');
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _pointerPositions.clear();
      _activePointers = 0;
    });
  }

  void _onPointerDown(PointerDownEvent e) {
    _activePointers++;
    _pointerPositions[e.pointer] = e;
    _log('DOWN ptr=${e.pointer} total=$_activePointers pos=(${e.localPosition.dx.toStringAsFixed(0)},${e.localPosition.dy.toStringAsFixed(0)})');
  }

  void _onPointerMove(PointerMoveEvent e) {
    _pointerPositions[e.pointer] = e;
    if (e.timeStamp.inMilliseconds % 5 == 0) {
      _log('MOVE ptr=${e.pointer} pos=(${e.localPosition.dx.toStringAsFixed(0)},${e.localPosition.dy.toStringAsFixed(0)}) delta=(${e.delta.dx.toStringAsFixed(1)},${e.delta.dy.toStringAsFixed(1)})');
    }
  }

  void _onPointerUp(PointerUpEvent e) {
    _activePointers--;
    _pointerPositions.remove(e.pointer);
    _log('UP ptr=${e.pointer} total=$_activePointers');
    setState(() {});
  }

  void _onPointerCancel(PointerCancelEvent e) {
    _activePointers--;
    _pointerPositions.remove(e.pointer);
    _log('CANCEL ptr=${e.pointer} total=$_activePointers');
  }

  void _onScaleStart(ScaleStartDetails d) {
    setState(() {
      _isInScaleGesture = true;
      _scaleRecognized = true;
      _initialFocal = d.localFocalPoint;
      _scalePointerCount = d.pointerCount;
    });
    _log('SCALE START pointers=${d.pointerCount} focal=${d.localFocalPoint}');
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    setState(() {
      _initialScale = d.scale;
    });
    _log('SCALE UPDATE scale=${d.scale.toStringAsFixed(2)} pointers=${d.pointerCount} focal=${d.localFocalPoint}');
  }

  void _onScaleEnd(ScaleEndDetails d) {
    setState(() {
      _isInScaleGesture = false;
    });
    _log('SCALE END velocity=${d.velocity.pixelsPerSecond}');
  }

  void _onPanStart(DragStartDetails d) {
    setState(() => _isInPanGesture = true);
    _log('PAN START ${d.localPosition}');
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _log('PAN UPDATE delta=${d.delta}');
  }

  void _onPanEnd(DragEndDetails d) {
    setState(() => _isInPanGesture = false);
    _log('PAN END');
  }

  void _onTapDown(TapDownDetails d) {
    _log('TAP DOWN ${d.localPosition}');
  }

  void _onTap() {
    _log('TAP');
  }

  void _onDoubleTap() {
    _log('DOUBLE TAP');
  }

  void _onLongPress() {
    _log('LONG PRESS');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gesture Diagnostics')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active pointers: $_activePointers',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text('Scale gesture: $_isInScaleGesture (recognized: $_scaleRecognized)'),
                Text('Pan gesture: $_isInPanGesture'),
                Text('Current scale: ${_initialScale.toStringAsFixed(2)}'),
                Text('Scale started with: $_scalePointerCount pointers'),
                const Divider(),
                Text('Pointer positions:'),
                ..._pointerPositions.entries.map((e) {
                  final ev = e.value;
                  return Text(
                    '  ptr ${e.key}: (${ev.localPosition.dx.toStringAsFixed(0)}, ${ev.localPosition.dy.toStringAsFixed(0)})',
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _clearLogs,
                child: const Text('Clear logs'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInScaleGesture = false;
                    _isInPanGesture = false;
                    _scaleRecognized = false;
                    _initialScale = 1.0;
                  });
                },
                child: const Text('Reset state'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Контент ПЕРЕД тестовой зоной\n(прокрути вниз)',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  Container(
                    height: 300,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: _onPointerDown,
                      onPointerMove: _onPointerMove,
                      onPointerUp: _onPointerUp,
                      onPointerCancel: _onPointerCancel,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onScaleEnd: _onScaleEnd,
                        onTapDown: _onTapDown,
                        onTap: _onTap,
                        onDoubleTap: _onDoubleTap,
                        onLongPress: _onLongPress,
                        child: const Center(
                          child: Text(
                            'TEST ZONE\n\n1 палец - tap/drag\n2 пальца - pinch zoom\n\nПопробуй:\n• Тап\n• Скролл вертикально (1 палец)\n• Pinch zoom (2 пальца)\n• Pan горизонтально (1 палец)',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Контент ПОСЛЕ тестовой зоны',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  ...List.generate(
                    5,
                        (i) => Container(
                      height: 80,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text('Item ${i + 1}')),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 200,
            color: Colors.black87,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _logs.length,
              itemBuilder: (ctx, i) {
                return Text(
                  _logs[i],
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}