import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/src/ui/showColorScreen.dart';

class DisplayPictureScreen extends StatefulWidget {

  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  DisplayPictureState createState() => DisplayPictureState();
}

class DisplayPictureState extends State<DisplayPictureScreen> {

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      appBar: AppBar(title: Text('Preview')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Center(
        child: SizedBox.expand(child: Image.file(File(widget.imagePath))),
      ),
      //body: Image.file(a),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("Upload"),
        // Provide an onPressed callback.
        onPressed: () async {
          try {
            // If the picture was taken, display it on a new screen.
            Navigator.push( context,
              MaterialPageRoute(
                builder: (context) => DisplayColorScreen(imagePath: widget.imagePath),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}