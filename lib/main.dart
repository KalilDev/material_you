import 'dart:math';

import 'package:flutter_material_palette/flutter_material_palette.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';
import 'color.dart';
//import 'material.dart';
import 'shapes.dart';
import 'package:flutter/material.dart';

ColorScheme colorSchemeFromPlatformPalette(
    PlatformPalette? palette, bool isDark) {
  final hasSec = palette?.secondaryColor != null,
      hasTer = palette?.tertiaryColor != null;
  final main =
      MaterialColors.deriveFrom(palette?.primaryColor ?? Colors.deepPurple);
  final primary = main.primary;
  final secondary =
      hasSec ? deriveMaterialColor(palette!.secondaryColor!) : main.triadicL;
  final tertiary =
      hasTer ? deriveMaterialColor(palette!.tertiaryColor!) : main.triadicR;
  if (isDark)
    return TertiaryColorScheme(
      ColorScheme.dark(
        primary: primary[kDesaturatedSwatch]!,
        primaryVariant: primary[kVariantSwatch]!,
        onPrimary: primary[kDesaturatedSwatch]!.textColor,
        secondary: secondary[kDesaturatedSwatch]!,
        secondaryVariant: secondary[kVariantSwatch]!,
        onSecondary: secondary[kDesaturatedSwatch]!.textColor,
      ),
      tertiary: tertiary[kDesaturatedSwatch]!,
      tertiaryVariant: tertiary[kVariantSwatch]!,
      onTertiary: tertiary[kDesaturatedSwatch]!.textColor,
    );
  return TertiaryColorScheme(
    ColorScheme.light(
      primary: primary[kLightSwatch]!,
      primaryVariant: primary[kVariantSwatch]!,
      onPrimary: primary[kLightSwatch]!.textColor,
      secondary: secondary[kLightSwatch]!,
      secondaryVariant: secondary[kVariantSwatch]!,
      onSecondary: secondary[kLightSwatch]!.textColor,
    ),
    tertiary: tertiary[kLightSwatch]!,
    tertiaryVariant: tertiary[kVariantSwatch]!,
    onTertiary: tertiary[kLightSwatch]!.textColor,
  );
}

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
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: context.palette.colorHints != null
          ? (context.palette.colorHints! &
                      PlatformPalette.HINT_SUPPORTS_DARK_THEME ==
                  PlatformPalette.HINT_SUPPORTS_DARK_THEME)
              ? ThemeMode.dark
              : null
          : null,
      theme: ThemeData.from(
          colorScheme: colorSchemeFromPlatformPalette(
        context.palette,
        false,
      )).copyWith(
        //splashFactory: MaterialYouInkSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.black.withAlpha(40),
      ),
      darkTheme: ThemeData.from(
          colorScheme: colorSchemeFromPlatformPalette(
        context.palette,
        true,
      )).copyWith(
        //splashFactory: MaterialYouInkSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.black.withAlpha(40),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
    PillBorder.tiltedRight(),
    DiamondBorder.all(radius: Radius.circular(80.0)),
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
    WobblyBorder.square(),
    RoundedTriangleBorder(),
    WobblyBorder(vertices: 6),
    WobblyBorder(vertices: 12),
    WobblyBorder(),
    TearBorder(topLeft: Radius.circular(80.0))
  ];
  ShapeBorder border = _borders[0];

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
              //backgroundColor: Theme.of(context).colorScheme.primary,
              //foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backwardsCompatibility: false,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Material(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0)),
                      color: Theme.of(context).colorScheme.secondary,
                      child: Padding(
                        padding: EdgeInsets.all(16),
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary),
                              ),
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            SizedBox(
                              height: 86,
                              width: 86,
                              child: Material(
                                shape: PillBorder.tiltedRight(),
                                color: Color.alphaBlend(
                                  Theme.of(context)
                                      .colorScheme
                                      .tertiaryVariant
                                      .textColor
                                      .withOpacity(
                                          Theme.of(context).brightness ==
                                                      Brightness.dark ||
                                                  kDesaturatedLightTheme
                                              ? 0
                                              : 0.35),
                                  Theme.of(context)
                                      .colorScheme
                                      .tertiary
                                      .withOpacity(0.6),
                                ),
                                child: Center(
                                  child: Text(
                                    '$_counter',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiaryVariant,
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
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
                            shape: border,
                            color: Theme.of(context).colorScheme.primary,
                            child: InkWell(
                                onTap: () => null,
                                customBorder: border,
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
                        color: Theme.of(context).colorScheme.primary,
                        child: SizedBox(
                          height: 86,
                          child: InkWell(
                            onTap: () => null,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.black.withAlpha(40),
                            child: SizedBox.expand(),
                          ),
                        )),
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
        icon: Icon(Icons.add),
        label: Text('Incrementar'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
