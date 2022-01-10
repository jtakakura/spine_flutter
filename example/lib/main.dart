import 'package:flutter/material.dart';
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
  String name;
  String defaultAnimation;
  List<String> animations;

  SkeletonAnimation skeleton;

  @override
  void initState() {
    super.initState();

    // raccoon
    name = 'raccoon';
    defaultAnimation = 'idle';
    animations = <String>[
      'idle',
    ];

    // raptor
    /*
    name = 'raptor';
    defaultAnimation = 'walk';
    animations = <String>[
      //'gun-grab',
      //'gun-holster',
      'jump',
      'roar',
      'walk',
    ];
    */

    // spineboy
    /*
    name = 'spineboy';
    defaultAnimation = 'walk';
    animations = <String>[
      'death',
      'idle',
      'jump',
      'hit',
      'run',
      'shoot',
      'walk',
    ];
    */
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<SkeletonAnimation>(
        future: loadSkeleton(),
        builder:
            (BuildContext context, AsyncSnapshot<SkeletonAnimation> snapshot) {
          if (snapshot.hasData) {
            skeleton = snapshot.data;
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

  Future<SkeletonAnimation> loadSkeleton() async =>
      await SkeletonAnimation.createWithFiles(
        '$name.atlas',
        '$name.json',
        '$name.png',
        pathPrefix: 'assets/$name/',
      );
}
