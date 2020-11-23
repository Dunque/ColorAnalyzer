import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/ui/takePictureScreen.dart';

class App extends StatelessWidget {

  final CameraDescription camera;

  const App({Key key, @required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: TakePictureScreen(camera: camera),
      ),
    );
  }
}