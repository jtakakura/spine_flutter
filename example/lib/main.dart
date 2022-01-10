import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spine/flutter_spine.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Spine Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String get atlasFile => '$name.atlas';

  String get skeletonFile => '$name.json';

  String get textureFile => '$name.png';

  String get pathPrefix => 'assets/$name/';

  String name;
  String defaultAnimation;
  Set<String> animations;

  SkeletonAnimation skeleton;

  @override
  void initState() {
    super.initState();

    // raccoon
    name = 'raccoon';
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
            if ((defaultAnimation == null || defaultAnimation.isEmpty) &&
                animations.isNotEmpty) {
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
      playState: PlayState.Playing,
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
    final String s = await rootBundle.loadString(pathPrefix + skeletonFile);
    final Map<String, dynamic> data = json.decode(s);

    return ((data['animations'] ?? <String, dynamic>{}) as Map<String, dynamic>)
        .keys
        .toSet();
  }

  Future<SkeletonAnimation> loadSkeleton() async =>
      SkeletonAnimation.createWithFiles(
        atlasFile,
        skeletonFile,
        textureFile,
        pathPrefix: pathPrefix,
      );
}
