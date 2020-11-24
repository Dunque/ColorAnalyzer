import 'dart:async';
import 'package:flutter_app/src/resources/imagePoster.dart';

class Repository {
  final imagePoster = ImagePoster();

  Future<String> postImage(imagePath) => imagePoster.postImage(imagePath);
}