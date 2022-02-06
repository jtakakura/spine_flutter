import 'dart:convert';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spine_flutter/spine_flutter.dart';

void main() {
  Fimber.plantTree(DebugTree.elapsed(useColors: true));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Spine Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String pathPrefix = 'assets/';

  late String name;
  late Set<String> animations;
  late SkeletonAnimation skeleton;

  String defaultAnimation = '';

  @override
  void initState() {
    super.initState();

    // cauldron
    //name = 'cauldron';
    //defaultAnimation = 'idle_1';

    // girl_and_whale_polygons
    name = 'girl_and_whale_polygons';
    defaultAnimation = 'idle_offset';

    // girl_and_whale_rectangles
    //name = 'girl_and_whale_rectangles';
    //defaultAnimation = 'idle_offset';

    // raccoon
    //name = 'raccoon';
    //defaultAnimation = 'idle_4';

    // raptor
    //name = 'raptor';
    //defaultAnimation = 'walk';

    // spineboy
    //name = 'spineboy';
    //defaultAnimation = 'walk';
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: load(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (defaultAnimation.isEmpty && animations.isNotEmpty) {
              defaultAnimation = animations.first;
            }
            skeleton.state.setAnimation(0, defaultAnimation, true);

            return _buildScreen();
          }

          return Container();
        },
      );

  Widget _buildScreen() {
    final SkeletonRenderObjectWidget skeletonWidget =
        SkeletonRenderObjectWidget(
      skeleton: skeleton,
      alignment: Alignment.center,
      fit: BoxFit.contain,
      playState: PlayState.playing,
      debugRendering: false,
      triangleRendering: true,
    );

    final List<Widget> buttons = <Widget>[];
    for (final String animation in animations) {
      buttons.add(
        TextButton(
          child: Text(animation.toUpperCase()),
          onPressed: () {
            skeleton.state
              ..setAnimation(0, animation, false)
              ..addAnimation(0, defaultAnimation, true, 0.0);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(name)),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          skeletonWidget,
          Positioned.fill(
            child: Wrap(
              runAlignment: WrapAlignment.end,
              children: buttons,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> load() async {
    animations = await loadAnimations();
    skeleton = await loadSkeleton();

    return true;
  }

  Future<Set<String>> loadAnimations() async {
    final String skeletonFile = '$name.json';
    final String s =
        await rootBundle.loadString('$pathPrefix$name/$skeletonFile');
    final Map<String, dynamic> data = json.decode(s);

    return ((data['animations'] ?? <String, dynamic>{}) as Map<String, dynamic>)
        .keys
        .toSet();
  }

  Future<SkeletonAnimation> loadSkeleton() async =>
      SkeletonAnimation.createWithFiles(
        name,
        pathBase: pathPrefix,
      );
}
