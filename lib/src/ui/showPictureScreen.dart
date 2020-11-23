import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/ui/showColorScreen.dart';


class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preview')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
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
                builder: (context) => DisplayColorScreen(imagePath: imagePath),
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
}