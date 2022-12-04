import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spine_flutter_dart/spine_flutter_dart.dart';

/// \see http://ru.esotericsoftware.com/spine-runtimes-guide
void main() => runApp(const MyApp());

/// All animations. Format: `model_name: defaultAnimation`.
const Map<String, String> all = <String, String>{
  'cauldron': 'idle',
  'fox': 'idle',
  'girl_and_whale_polygons': 'idle',
  'girl_and_whale_rectangles': 'idle',
  'owl': 'idle',
  'raptor': 'walk',
  'spineboy': 'walk',
};

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
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  static const String pathPrefix = 'assets/';

  String name = all.keys.last;

  late Set<String> animations;
  late SkeletonAnimation skeleton;

  @override
  Widget build(BuildContext context) => _buildFuture();

  Widget _buildFuture() => FutureBuilder<bool>(
        future: load(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (animations.isNotEmpty) {
              final String defaultAnimation = all[name]!;
              skeleton.state.setAnimation(0, defaultAnimation, true);
            }

            return _buildScreen();
          }

          return Container();
        },
      );

  Widget _buildScreen() {
    final SkeletonRenderObjectWidget skeletonWidget =
        SkeletonRenderObjectWidget(
      skeleton: skeleton,
      animation: all[name],
      alignment: Alignment.center,
      fit: BoxFit.contain,
      playState: PlayState.playing,
      debugRendering: false,
      triangleRendering: true,
      //frameSizeMultiplier: 0.3,
    );

    final List<Widget> models = <Widget>[];
    for (final String model in all.keys) {
      models.add(
        TextButton(
          child: Text(model.toUpperCase()),
          onPressed: () async {
            name = model;
            await load();
            setState(() {
              final String defaultAnimation = all[name]!;
              skeleton.state.setAnimation(0, defaultAnimation, false);
            });
          },
        ),
      );
    }

    final List<Widget> states = <Widget>[];
    for (final String animation in animations) {
      states.add(
        TextButton(
          child: Text(animation.toLowerCase()),
          onPressed: () {
            final String defaultAnimation = all[name]!;
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
              runAlignment: WrapAlignment.start,
              children: models,
            ),
          ),
          Positioned.fill(
            child: Wrap(
              runAlignment: WrapAlignment.end,
              children: states,
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
      SkeletonAnimation.createWithFiles(name, pathBase: pathPrefix);
}
