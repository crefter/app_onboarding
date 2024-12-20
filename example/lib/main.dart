import 'package:app_onboarding/app_onboarding.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final AppOnboardingController controller = AppOnboardingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 2),
      controller.start,
    );
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle =
        Theme.of(context).elevatedButtonTheme.style ?? const ButtonStyle();
    return AppOnboarding(
      controller: controller,
      onDone: () => showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          title: Text(
            'Onboarding finished!\n(onDone)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      onStart: () => showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          title: Text(
            'Onboarding started!\n(onStart)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      onAutoHiddenDone: () => showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          title: Text(
            'Auto Onboarding done!\n(onAutoHiddenDone)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      onAutoHiddenStart: () => showDialog(
        context: context,
        builder: (BuildContext context) => const AlertDialog(
          title: Text(
            'Auto Onboarding started!\n(onAutoHiddenStart)',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: AppOnboardingEntry(
            index: 0,
            tooltipSettings:
                TooltipSettings(backgroundColor: Colors.red.shade400),
            child: Text(widget.title),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppOnboardingEntry(
                index: 2,
                customTooltipBuilder: (context, index) {
                  return SizedBox(
                    height: 150,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Custom tooltip!',
                            textAlign: TextAlign.center,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  controller.showPrev();
                                },
                                child: const Text('Prev'),
                              ),
                              ElevatedButton(
                                onPressed: controller.hide,
                                child: const Text('Skip'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  controller.showNext();
                                },
                                child: const Text('Next'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                tooltipSettings: const TooltipSettings(
                  tooltipDirection: AppOnboardingTooltipDirection.bottom,
                ),
                child: const Text(
                  'You have pushed the button this many times:',
                ),
              ),
              AppOnboardingEntry(
                index: 1,
                tooltipSettings: TooltipSettings(
                  tooltipTextSettings: TooltipTextSettings(
                    text: 'Custom text',
                    textStyle: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.yellow),
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.red.shade300,
                  skipButtonSettings: ButtonSettings(
                    buttonStyle: buttonStyle.copyWith(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Colors.blue.shade500,
                      ),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                    ),
                  ),
                  nextButtonSettings: ButtonSettings(
                    buttonStyle: buttonStyle.copyWith(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Colors.pink.shade400,
                      ),
                    ),
                  ),
                ),
                child: Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.start();
                },
                child: const Text('Start Onboarding'),
              ),
              const SizedBox(height: 20),
              AppOnboardingEntry(
                index: 5,
                isAutoHidden: true,
                tooltipOffset: Offset(0, 10),
                tooltipSettings: TooltipSettings(
                  tooltipTextSettings: TooltipTextSettings(
                    text: 'SECOND AUTO TOOLTIP!',
                    textAlign: TextAlign.center,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    controller.startAutoHidden();
                  },
                  child: const Text('Start Auto onboarding'),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: AppOnboardingEntry(
          index: 3,
          tooltipOffset: const Offset(-113, -20),
          tooltipSettings: const TooltipSettings(
            arrowPosition: AppOnboardingTooltipArrowPosition.right,
            tooltipDirection: AppOnboardingTooltipDirection.bottom,
            completeText: 'Complete!',
          ),
          holeBorderRadius: 100,
          holeInnerPadding: 12,
          backgroundColor: Colors.blue.withOpacity(0.4),
          customOverlayBuilder: (context, index) {
            return Center(
              child: ColoredBox(
                color: Colors.red.shade300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Custom Background!'),
                    const FlutterLogo(
                      size: 150,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.red.shade200,
                              child: const Column(
                                children: [
                                  SizedBox(height: 50),
                                  Text('You can do all!'),
                                  SizedBox(height: 50),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: const Text(
                        'Click me',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: AppOnboardingEntry(
            index: 4,
            isAutoHidden: true,
            tooltipOffset: const Offset(-113, -15),
            tooltipSettings: const TooltipSettings(
              tooltipTextSettings:
                  TooltipTextSettings(text: 'THIS IS AUTO TOOLTIP!'),
              tooltipDirection: AppOnboardingTooltipDirection.bottom,
              arrowPosition: AppOnboardingTooltipArrowPosition.right,
            ),
            child: FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
