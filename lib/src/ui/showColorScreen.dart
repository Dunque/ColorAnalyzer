import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/blocs/postBloc.dart';
import 'package:flutter_app/src/models/jsonParser.dart';

class DisplayColorScreen extends StatefulWidget {

  final String imagePath;

  const DisplayColorScreen({Key key, this.imagePath}) : super(key: key);

  @override
  DisplayColorState createState() => DisplayColorState();
}


class DisplayColorState extends State<DisplayColorScreen> {

  @override
  void initState(){
    super.initState();
    bloc.fetchJson(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    bool isScreenWide = MediaQuery.of(context).size.width >= MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
            title: Text('Detected colors')),
        body: Flex(
            direction: isScreenWide ? Axis.horizontal : Axis.vertical,
            children: <Widget> [
              Image.file(File(widget.imagePath)),
              Expanded(child: StreamBuilder(
                  stream: bloc.json,
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      return jsonParser(snapshot.data, context);
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return Center(child: CircularProgressIndicator());
                  }
              )
              )
            ]
        )
    );
  }
}