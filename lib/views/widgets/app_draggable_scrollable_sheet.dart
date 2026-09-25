import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Widget that measures its child's size and reports changes via callback.
/// Similar to Jetpack Compose's onGloballyPositioned.
class _MeasureSize extends SingleChildRenderObjectWidget {
  final void Function(Size size) onSizeChange;

  const _MeasureSize({
    required this.onSizeChange,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onSizeChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onSizeChange = onSizeChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  void Function(Size size) onSizeChange;
  Size? _oldSize;

  _MeasureSizeRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    final newSize = child?.size ?? Size.zero;
    if (_oldSize != newSize) {
      _oldSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSizeChange(newSize);
      });
    }
  }
}

class AppSheetController extends ChangeNotifier {
  DraggableScrollableController? _draggableController;
  double? _collapsedSize;
  double? _maxSize;

  void _attach(
      DraggableScrollableController controller,
      double collapsedSize,
      double maxSize,
      ) {
    _draggableController = controller;
    _collapsedSize = collapsedSize;
    _maxSize = maxSize;
  }

  void _detach() {
    _draggableController = null;
  }

  bool get isAttached =>
      _draggableController != null && _draggableController!.isAttached;

  double get currentSize {
    if (!isAttached) return 0;
    return _draggableController!.size;
  }

  bool get isExpanded {
    if (!isAttached || _collapsedSize == null || _maxSize == null) {
      return false;
    }
    final midPoint = (_collapsedSize! + _maxSize!) / 2;
    return _draggableController!.size > midPoint;
  }

  Future<void> expand() async {
    if (isAttached && _maxSize != null) {
      await _draggableController!.animateTo(
        _maxSize!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  Future<void> collapse() async {
    if (isAttached && _collapsedSize != null) {
      await _draggableController!.animateTo(
        _collapsedSize!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (isExpanded) {
      await collapse();
    } else {
      await expand();
    }
  }
}

enum AppSheetInitialState { collapsed, expanded }

class AppDraggableScrollableSheet extends StatefulWidget {
  final Widget collapsedContent;
  final Widget expandedContent;
  final double maxChildSize;
  final Color sheetColor;
  final BorderRadius? borderRadius;
  final AppSheetController? controller;
  final AppSheetInitialState initialState;
  final bool isDraggable;
  final ValueChanged<bool>? onStateChanged;

  /// Measured height of the collapsed sheet, in logical pixels. Lets callers
  /// pin floating controls just above it instead of guessing a constant.
  final ValueChanged<double>? onCollapsedHeightChanged;

  const AppDraggableScrollableSheet({
    super.key,
    required this.collapsedContent,
    required this.expandedContent,
    this.maxChildSize = 0.9,
    this.sheetColor = Colors.white,
    this.borderRadius,
    this.controller,
    this.initialState = AppSheetInitialState.collapsed,
    this.isDraggable = true,
    this.onStateChanged,
    this.onCollapsedHeightChanged,
  });

  @override
  State<AppDraggableScrollableSheet> createState() =>
      _AppDraggableScrollableSheetState();
}

class _AppDraggableScrollableSheetState
    extends State<AppDraggableScrollableSheet> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();

  late bool _isExpanded;
  double? _collapsedSize;
  bool _initialExpandDone = false;

  double get _midPoint {
    final collapsed = _collapsedSize ?? 0.3;
    return (collapsed + widget.maxChildSize) / 2;
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialState == AppSheetInitialState.expanded;
    _controller.addListener(_onSheetChanged);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _controller.removeListener(_onSheetChanged);
    _controller.dispose();
    super.dispose();
  }

  /// Called when collapsed content size changes (measured by _MeasureSize)
  void _onCollapsedSizeChanged(Size size) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final bottomPadding = mediaQuery.padding.bottom;
    // 28 = drag handle height (12 + 4 + 12)
    final collapsedHeight = size.height + 28 + bottomPadding;
    final newSize =
        (collapsedHeight / screenHeight).clamp(0.1, widget.maxChildSize - 0.1);

    widget.onCollapsedHeightChanged?.call(collapsedHeight);

    // Only update if size actually changed
    if (_collapsedSize != newSize) {
      setState(() {
        _collapsedSize = newSize;
      });

      // Update controller with new size
      widget.controller?._attach(_controller, newSize, widget.maxChildSize);

      // If sheet is currently collapsed, animate to new collapsed size
      if (!_isExpanded && _controller.isAttached) {
        _controller.animateTo(
          newSize,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }

      // Handle initial expand (only once)
      if (!_initialExpandDone &&
          widget.initialState == AppSheetInitialState.expanded) {
        _initialExpandDone = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.isAttached) {
            _controller.animateTo(
              widget.maxChildSize,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    }
  }

  void _onSheetChanged() {
    if (!_controller.isAttached) return;
    final isExpanded = _controller.size > _midPoint;
    if (isExpanded != _isExpanded) {
      setState(() {
        _isExpanded = isExpanded;
      });
      widget.onStateChanged?.call(isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build collapsed content wrapped in MeasureSize
    final measuredCollapsedContent = _MeasureSize(
      onSizeChange: _onCollapsedSizeChanged,
      child: widget.collapsedContent,
    );

    // Show invisible measurement widget until we have a size
    if (_collapsedSize == null) {
      return Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0,
              child: measuredCollapsedContent,
            ),
          ),
        ],
      );
    }

    final sheetSize = widget.isDraggable
        ? null
        : (widget.initialState == AppSheetInitialState.expanded
            ? widget.maxChildSize
            : _collapsedSize!);

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: sheetSize ?? _collapsedSize!,
      minChildSize: sheetSize ?? _collapsedSize!,
      maxChildSize: sheetSize ?? widget.maxChildSize,
      snap: widget.isDraggable,
      snapSizes:
          widget.isDraggable ? [_collapsedSize!, widget.maxChildSize] : null,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.sheetColor,
            borderRadius: widget.borderRadius ??
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: widget.isDraggable ? null : const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => widget.controller?.toggle(),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: _isExpanded ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: _isExpanded
                      ? const SizedBox.shrink()
                      : measuredCollapsedContent,
                ),
                AnimatedOpacity(
                  opacity: _isExpanded ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _isExpanded
                      ? widget.expandedContent
                      : const SizedBox.shrink(),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }
}
