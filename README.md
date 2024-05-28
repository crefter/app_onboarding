A Flutter package for building simple onboarding with tooltips!

<img alt="Example screenshot" src="/assets/top_screenshot.png" width="300"/>
<img alt="Example how the package works" src="/assets/first_screen_record.gif" width="300"/>

## Features

Use this package in your Flutter app to:
- Build manual onboarding with tooltips
- Build auto onboarding with tooltips

## Getting started

Add this to your package's pubspec.yaml file:
```
dependencies:
  app_onboarding: ^1.0.0
```

## Usage

First, create AppOnboardingController (Don`t forget dispose in dispose method):
```dart
  late final AppOnboardingController controller = AppOnboardingController();

    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }
```

Second, wrap you top-screen widget by AppOnboarding and set controller:
```dart
    AppOnboarding (
        controller: controller,
        child: Scaffold(
          body:...
    );
```

Third, wrap your widgets (buttons, text and all you want) by AppOnboardingEntry:
```dart
    AppOnboardingEntry(
        index: 0,
        tooltipSettings: TooltipSettings(backgroundColor: Colors.red.shade400),
        child: Text(widget.title),
    ),
```

Fourth, start onboarding:
```dart
    @override
    void initState() {
      super.initState();
      Future.delayed(
        const Duration(seconds: 2),
        controller.start,
      );
    }
```

That`s all, you created basic onboarding with tooltips!

For more info see <a href="https://github.com/crefter/app_onboarding/blob/master/example/lib/main.dart">example</a>
