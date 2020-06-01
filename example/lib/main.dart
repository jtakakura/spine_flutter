import 'package:flutter/material.dart';
import 'package:flutter_spine/flutter_spine.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MyHomePage(title: 'Flutter + Spine'),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SkeletonAnimation _skeleton;

  @override
  void initState() {
    super.initState();
    _loadSkeleton();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(children: <Widget>[
        Positioned.fill(
            child: SkeletonRenderObjectWidget(
                skeleton: _skeleton,
                alignment: Alignment.center,
                fit: BoxFit.contain,
                playState: PlayState.Playing)),
        Positioned.fill(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(5.0),
                child: FlatButton(
                    child: const Text('Jump'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      _skeleton.state
                        ..setAnimation(0, 'jump', false)
                        ..addAnimation(0, 'walk', true, 0.0);
                    })),
            Container(
                margin: const EdgeInsets.all(5.0),
                child: FlatButton(
                    child: const Text('Shoot'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        _skeleton.state
                          ..setAnimation(0, 'shoot', false)
                          ..addAnimation(0, 'walk', true, 0.0);
                      });
                    })),
            Container(
                margin: const EdgeInsets.all(5.0),
                child: FlatButton(
                    child: const Text('Death'),
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      setState(() {
                        _skeleton.state
                          ..setAnimation(0, 'death', false)
                          ..addAnimation(0, 'walk', true, 0.0);
                      });
                    })),
          ],
        ))
      ]));

  void _loadSkeleton() {
    SkeletonAnimation.createWithFiles('spineboy.atlas', 'spineboy.json',
            'spineboy.png', 'assets/spineboy/')
        .then((SkeletonAnimation skeleton) {
      skeleton.state.setAnimation(0, 'walk', true);
      setState(() => _skeleton = skeleton);
    });
  }
}
