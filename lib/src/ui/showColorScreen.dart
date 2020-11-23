import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/jsonParser.dart';
import 'package:flutter_app/src/resources/imagePost.dart';

class DisplayColorScreen extends StatefulWidget {

  final String imagePath;

  const DisplayColorScreen({Key key, this.imagePath}) : super(key: key);

  @override
  DisplayColorState createState() => DisplayColorState();
}


class DisplayColorState extends State<DisplayColorScreen> {
  Future<String> futureString;

  @override
  void initState(){
    super.initState();
    futureString = _genCode();
  }

  Future<String> _genCode() async {
    String json = await postImage(widget.imagePath);

    return json;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('Detected colors')),
        body:
        Column(
            children: <Widget> [
              Image.file(File(widget.imagePath)),
              Expanded(
                  child: FutureBuilder(
                      future: futureString,
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                          String data = snapshot.data;
                          return jsonParser(data, context);
                        }
                        else if (snapshot.connectionState != ConnectionState.done) {
                          return Center(
                              child: CircularProgressIndicator()
                          );
                        }
                        else {
                          return Center(
                              child: Text("There was an error with the server")
                          );
                        }
                      }
                  )
              )
            ]
        )
    );
  }
}
