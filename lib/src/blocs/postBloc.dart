import 'package:rxdart/rxdart.dart';
import 'package:flutter_app/src/resources/repository.dart';

class PostBloc {
  final _repository = Repository();
  //final _imagePoster = ImagePoster();
  final _jsonFetcher = PublishSubject<String>();

  Observable<String> get json => _jsonFetcher.stream;

  fetchJson(imagePath) async {
    String json = await _repository.imagePoster.postImage(imagePath);
    //String json = await _imagePoster.postImage(imagePath);
    _jsonFetcher.sink.add(json);
  }

  dispose() {
    _jsonFetcher.close();
  }
}

final bloc = PostBloc();