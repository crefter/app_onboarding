import 'package:flutter/material.dart';

class AppOnboardingController {
  AppOnboardingController();

  int currentIndex = 0;
  final Map<int, OverlayPortalController> _overlayControllers = {};

  void start({int startIndex = 0}) {
    currentIndex = startIndex;
    show();
  }

  void next() {
    if (currentIndex < _overlayControllers.length - 1) {
      currentIndex++;
    }
  }

  void prev() {
    if (currentIndex > 0) {
      currentIndex--;
    }
  }

  void show() {
    _overlayControllers[currentIndex]?.show();
  }

  void hide() {
    _overlayControllers[currentIndex]?.hide();
  }

  void showNext() {
    hide();
    next();
    show();
  }

  void showPrev() {
    hide();
    prev();
    show();
  }

  void add(int index) {
    _overlayControllers[index] =
        OverlayPortalController(debugLabel: 'AppOnboardingController  $index');
  }

  OverlayPortalController get(int index) {
    final controller = _overlayControllers[index];
    if (controller == null) {
      throw Exception('No OverlayPortalController by $index');
    }
    return controller;
  }

  void dispose() {
    _overlayControllers.clear();
  }
}

class AppOnboarding extends StatefulWidget {
  const AppOnboarding({
    super.key,
    required this.child,
    required this.controller,
    this.onDone,
  });

  final AppOnboardingController controller;
  final Widget child;
  final VoidCallback? onDone;

  static AppOnboardingState of(BuildContext context) {
    final state = context.findAncestorStateOfType<AppOnboardingState>();
    if (state == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'AppOnboarding.of() called with a context that does not contain a AppOnboarding.',
        ),
        ErrorDescription(
          'No AppOnboarding ancestor could be found starting from the context that was passed to AppOnboarding.of(). '
          'This usually happens when the context provided is from the same StatefulWidget as that '
          'whose build function actually creates the AppOnboarding widget being sought.',
        ),
        context.describeElement('The context used was'),
      ]);
    }
    return state;
  }

  @override
  State<AppOnboarding> createState() => AppOnboardingState();
}

class AppOnboardingState extends State<AppOnboarding> {
  int get stepsLength => widget.controller._overlayControllers.length;

  int get currentIndex => widget.controller.currentIndex;

  OverlayPortalController getOverlayController(int index) {
    return widget.controller.get(index);
  }

  void show() {
    widget.controller.show();
  }

  void hide({bool isDone = false}) {
    widget.controller.hide();
    if (isDone || currentIndex == stepsLength - 1) {
      widget.onDone?.call();
    }
  }

  void next() {
    widget.controller.next();
  }

  void prev() {
    widget.controller.prev();
  }

  void add(int index) {
    widget.controller.add(index);
  }

  void start({int startIndex = 0}) {
    widget.controller.start(startIndex: startIndex);
  }

  void showNext() {
    widget.controller.showNext();
  }

  void showPrev() {
    widget.controller.showPrev();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
