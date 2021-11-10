import 'dart:developer';

import 'package:example/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:material_you/material_you.dart';
import 'package:flutter_monet_theme/flutter_monet_theme.dart';

void main() => runPlatformThemedApp(
      MyApp(),
      initialOrFallback: () => PlatformPalette(
        primaryColor: Color(0xff12295b),
        secondaryColor: Color(0xff33507c),
        tertiaryColor: Color(0xff8caaa5),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themes = themesFromPlatform(context.palette);
    return InheritedMonetTheme(
      theme: themes.monetTheme,
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: themes.lightTheme,
        darkTheme: themes.darkTheme,
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _counter = 0;
  static final _borders = [
    WobblyBorder(vertices: 6),
    WobblyBorder(vertices: 12),

    //PillBorder.tiltedRight(),
    //DiamondBorder.all(radius: Radius.circular(80.0)),
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
    WobblyBorder.square(),
    RoundedTriangleBorder(),
    WobblyBorder(),
    TearBorder(topLeft: Radius.circular(80.0))
  ];
  OutlinedBorder border = _borders[0];

  void _incrementCounter() {
    setState(() {
      _counter++;
      border = _borders[_counter % _borders.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Material(
            child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text("Material You"),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0)),
                      color: context.colorScheme.tertiary,
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'You have pushed the button this many times:',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline5!
                                    .copyWith(
                                      letterSpacing: 1.05,
                                      color: context.colorScheme.onTertiary,
                                    ),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            SizedBox(
                              height: 86,
                              width: 86,
                              child: Material(
                                shape: MorphableBorder.toBorder(
                                    WobblyBorder.triangle()),
                                color: context.colorScheme.primaryContainer,
                                child: Center(
                                  child: Text(
                                    '$_counter',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                          color: context
                                              .colorScheme.onPrimaryContainer,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 56.0,
                      child: InkWell(
                        onTap: () => null,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.black.withAlpha(40),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 16.0,
                            ),
                            Padding(
                              padding: EdgeInsets.all(
                                4.0,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.person,
                                  color: context.colorScheme.onSecondary,
                                ),
                                decoration: BoxDecoration(
                                    color: context.colorScheme.secondary,
                                    shape: BoxShape.circle),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                "Contas e usuários",
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(letterSpacing: 1.1),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox.fromSize(
                      size: Size(400, 400),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Material(
                            animationDuration: Duration(milliseconds: 500),
                            shape: MorphableBorder.toBorder(border),
                            color: context.colorScheme.primary,
                            child: InkWell(
                                onTap: () => null,
                                customBorder: MorphableBorder.toBorder(border),
                                highlightColor: Colors.transparent,
                                splashColor: Colors.black.withAlpha(40),
                                child: SizedBox.expand()),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Ink(
                        color: context.colorScheme.primary,
                        child: SizedBox(
                          height: 86,
                          child: InkWell(
                            onTap: () => showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            ),
                            highlightColor: Colors.transparent,
                            splashColor: Colors.black.withAlpha(40),
                            child: SizedBox.expand(),
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Ink(
                      color: context.colorScheme.primary,
                      child: SizedBox(
                        height: 86,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CurrentMonetThemePage())),
                          highlightColor: Colors.transparent,
                          splashColor: Colors.black.withAlpha(40),
                          child: SizedBox.expand(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        materialTapTargetSize: MaterialTapTargetSize.padded,
        icon: Icon(Icons.add),
        label: Text('Incrementar'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class CurrentMonetThemePage extends StatelessWidget {
  const CurrentMonetThemePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Themes'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monet themes', style: context.theme.textTheme.headline3),
              SizedBox(height: 16.0),
              Text('Light theme', style: context.theme.textTheme.headline5),
              SizedBox(height: 8.0),
              MonetColorSchemeWidget(scheme: context.monetTheme.light),
              SizedBox(height: 24.0),
              Text('Dark theme', style: context.theme.textTheme.headline5),
              SizedBox(height: 8.0),
              MonetColorSchemeWidget(scheme: context.monetTheme.dark),
              SizedBox(height: 24.0)
            ],
          ),
        ),
      ),
    );
  }
}
