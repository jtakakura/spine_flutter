import 'package:flutter/material.dart';
import 'package:flutter_spine/flutter_spine.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(primarySwatch: Colors.blue),
      home: new MyHomePage(title: 'Flutter + Spine'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SkeletonAnimation _skeleton;

  _MyHomePageState() : super() {
    _loadSkeleton();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.grey,
        appBar: new AppBar(title: new Text(widget.title)),
        body: new Stack(children: <Widget>[
          new Positioned.fill(
              child: SkeletonRenderObjectWidget(
                  skeleton: _skeleton,
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  playState: PlayState.Playing)),
          new Positioned.fill(
              child: new Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                  margin: const EdgeInsets.all(5.0),
                  child: new FlatButton(
                      child: Text('Jump'),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () {
                        _skeleton.state
                          ..setAnimation(0, 'jump', false)
                          ..addAnimation(0, 'walk', true, 0.0);
                      })),
              new Container(
                  margin: const EdgeInsets.all(5.0),
                  child: new FlatButton(
                      child: new Text('Shoot'),
                      textColor: Colors.white,
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          _skeleton.state
                            ..setAnimation(0, 'shoot', false)
                            ..addAnimation(0, 'walk', true, 0.0);
                        });
                      })),
              new Container(
                  margin: const EdgeInsets.all(5.0),
                  child: new FlatButton(
                      child: new Text('Death'),
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
  }

  void _loadSkeleton() {
    SkeletonAnimation.createWithFiles('spineboy.atlas', 'spineboy.json',
            'spineboy.png', 'assets/spineboy/')
        .then((SkeletonAnimation skeleton) {
      skeleton.state.setAnimation(0, 'walk', true);
      setState(() => _skeleton = skeleton);
    });
  }
}
