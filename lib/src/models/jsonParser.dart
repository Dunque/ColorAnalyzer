import 'dart:convert';
import 'package:flutter/material.dart';

ListView jsonParser(String snapdata, BuildContext context) {
  Map data = jsonDecode(snapdata);

  var length = data['result']['colors']['image_colors'].length;

  List values;

  List<String> result = [];
  List<Color> colors = [];

  for (var i = 0; i < length; i++) {
    values = data['result']['colors']['image_colors'][i].values.toList();

    result.add(values[1].toString().toUpperCase());
    result.add('R: ' + values[8].toString() + '  G: ' + values[5].toString() + '  B: ' + values[0].toString());
    result.add('HTML -> ' + values[6].toString());
    result.add('Percentage of this color -> ' + values[7].toStringAsFixed(2) + '%');

    colors.add(Color.fromARGB(255, values[8], values[5], values[0]));

  }

  return ListView.builder(
      itemCount: 4 * length,
      itemBuilder: (BuildContext context, int n) =>
          Ink(
            color: colors[(n~/4)],
            child: ListTile(leading: Text(result[n])),
          )
  );
}