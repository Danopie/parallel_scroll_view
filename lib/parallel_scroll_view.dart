import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum ParallelScrollBehavior { Fixed, Interpolate }

class ParallelScrollView extends StatefulWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;
  final ParallelScrollBehavior behavior;

  const ParallelScrollView(
      {Key key,
        this.children,
        this.scrollDirection = Axis.vertical,
        this.crossAxisAlignment = CrossAxisAlignment.start,
        this.padding,
        this.behavior = ParallelScrollBehavior.Fixed})
      : super(key: key);

  @override
  _ParallelScrollViewState createState() => _ParallelScrollViewState();

  static _ParallelScrollViewState of(BuildContext context) {
    return context.findAncestorStateOfType<_ParallelScrollViewState>();
  }
}

class _ParallelScrollViewState extends State<ParallelScrollView> {
  final scrollState = _ParallelScrollController();

  Axis get scrollDirection => widget.scrollDirection;

  ParallelScrollBehavior get behavior => widget.behavior;

  EdgeInsets get padding => widget.padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      padding: _getPadding(),
      child: _buildFlex(),
    );
  }

  Flex _buildFlex() {
    return scrollDirection == Axis.vertical
        ? Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: widget.children,
    )
        : Row(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: widget.children,
    );
  }

  EdgeInsets _getPadding() {
    return widget.scrollDirection == Axis.horizontal
        ? widget.padding?.copyWith(top: 0, bottom: 0)
        : widget.padding?.copyWith(left: 0, right: 0);
  }
}

class _ParallelScrollController extends ChangeNotifier {
  ScrollController _inFocusController;
  double _offset = 0;

  double get offset => _offset;
  set offset(double value) {
    if (value == null) return;
    _offset = value;
    notifyListeners();
  }

  ScrollController get inFocusController => _inFocusController;
  set inFocusController(ScrollController controller) {
    _inFocusController = controller;
    notifyListeners();
  }
}

class ParallelScrollChild extends StatefulWidget {
  final List<Widget> children;
  final double height;
  final double width;

  const ParallelScrollChild({
    Key key,
    this.children,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  _ParallelScrollChildState createState() => _ParallelScrollChildState();
}

class _ParallelScrollChildState extends State<ParallelScrollChild> {
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      listenToScrollStatusChange();
    });

    _scrollController.addListener(() {
      handleOffsetChange();
    });

    listenToScrollStateChange();

    super.didChangeDependencies();
  }

  void listenToScrollStateChange() {
    final parentState = ParallelScrollView.of(context);

    final scrollState = parentState.scrollState;

    scrollState.addListener(() {
      scrollToOffsetIfNotInFocus(scrollState, parentState.behavior);
    });
  }

  void scrollToOffsetIfNotInFocus(
      _ParallelScrollController scrollState, ParallelScrollBehavior behavior) {
    if (scrollControllerIsNotInFocus(scrollState)) {
      if (behavior == ParallelScrollBehavior.Fixed) {
        if (offsetIsWithinBounds(scrollState.offset)) {
          scrollFixedToOffset(scrollState.offset);
        }
      } else {
        scrollInterpolateToOffset(
            scrollState.offset, scrollState.inFocusController);
      }
    }
  }

  void scrollFixedToOffset(double offset) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(offset);
    }
  }

  void scrollInterpolateToOffset(
      double offset, ScrollController focusController) {
    if (_scrollController.hasClients) {
      final scrollPercentage =
          offset / focusController.position.maxScrollExtent;
      final scaledOffset = Tween<double>(
          begin: _scrollController.position.minScrollExtent,
          end: _scrollController.position.maxScrollExtent)
          .lerp(scrollPercentage);
      _scrollController.jumpTo(scaledOffset);
    }
  }

  bool offsetIsWithinBounds(double _offset) {
    return _offset >= _scrollController.position.minScrollExtent &&
        _offset <= _scrollController.position.maxScrollExtent;
  }

  bool scrollControllerIsNotInFocus(_ParallelScrollController scrollState) {
    return scrollState.inFocusController != _scrollController &&
        scrollState.inFocusController != null;
  }

  void handleOffsetChange() {
    final scrollState = ParallelScrollView.of(context).scrollState;
    notifyOffsetIfInFocus(scrollState);
  }

  void notifyOffsetIfInFocus(_ParallelScrollController scrollState) {
    if (scrollState.inFocusController == _scrollController) {
      scrollState.offset = _scrollController.offset;
    }
  }

  void listenToScrollStatusChange() {
    final scrollNotifier = _scrollController.position.isScrollingNotifier;
    final scrollState = ParallelScrollView.of(context).scrollState;

    scrollNotifier.addListener(() {
      if (isScrolling(scrollNotifier)) {
        setAsInFocusController(scrollState);
      } else {
        removeAsInFocusController(scrollState);
      }
    });
  }

  void removeAsInFocusController(_ParallelScrollController scrollState) {
    if (scrollState.inFocusController == _scrollController) {
      scrollState.inFocusController = null;
    }
  }

  void setAsInFocusController(_ParallelScrollController scrollState) {
    if (scrollState.inFocusController == null) {
      scrollState.inFocusController = _scrollController;
    }
  }

  bool isScrolling(ValueNotifier<bool> scrollNotifier) =>
      scrollNotifier.value == true;

  @override
  Widget build(BuildContext context) {
    final parentState = ParallelScrollView.of(context);
    final parentScrollDirection = parentState.scrollDirection;

    final childScrollDirection = parentScrollDirection == Axis.vertical
        ? Axis.horizontal
        : Axis.vertical;

    final padding = childScrollDirection == Axis.vertical
        ? parentState.padding.copyWith(left: 0, right: 0)
        : parentState.padding.copyWith(top: 0, bottom: 0);

    return Container(
      height: childScrollDirection == Axis.vertical ? null : widget.height,
      width: childScrollDirection == Axis.horizontal ? null : widget.width,
      child: ListView(
        padding: padding,
        scrollDirection: childScrollDirection,
        physics: ClampingScrollPhysics(),
        controller: _scrollController,
        children: widget.children,
      ),
    );
  }
}
