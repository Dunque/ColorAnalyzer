import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' show basename, join;
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path, '${DateTime.now()}.png');
            await ImageGallerySaver.saveFile(path);
            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: path),
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

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  _savePhoto() async {
    final result = await ImageGallerySaver.saveFile(imagePath);
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    _savePhoto();
    return Scaffold(
      appBar: AppBar(title: Text('Display the Post')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        // Provide an onPressed callback.
        onPressed: () async {
          try {
            // If the picture was taken, display it on a new screen.
            Navigator.push( context,
              MaterialPageRoute(
                builder: (context) => DisplayPost(imagePath: imagePath),
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

//--------------------------------------------------------------------------------------


Future<String> postImage(String imagePath) async {

  File imageFile = new File(imagePath);

  print(imagePath);
  print(imageFile);

  var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
  var length = await imageFile.length();
  Map<String, String> headers = { HttpHeaders.authorizationHeader: 'Basic YWNjXzAzMzMxYWFmNmE3ZDFiMjpjN2MwMzcyNDZmMTdkNmNlZmM1OWVjYjFjMzY1ZDU0OA=='};
  int timeout = 10;

  var request = new http.MultipartRequest("POST", Uri.parse('https://api.imagga.com/v2/colors'));
  request.headers.addAll(headers);

  var multipartFile = new http.MultipartFile('image', stream, length, filename: basename(imageFile.path));

  request.fields['extract_overall_colors '] = "1"; //Default: 1
  request.fields['extract_object_colors '] = "1"; //Default: 1
  request.fields['overall_count'] = "5"; //Default: 5
  request.fields['separated_count '] = "3"; //Default: 3
  request.fields['deterministic'] = "0"; //Default: 0

  request.files.add(multipartFile);

  try{
    var response = await request.send().timeout(Duration(seconds: timeout));

    if(response.statusCode == HttpStatus.ok){
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      Map<String, dynamic> respuesta = jsonDecode(responseString);
      if(respuesta['status']['type']=="success"){
        if(respuesta['result']['faces'].length==1){
          var faceId=respuesta['result']['faces'][0]['face_id'];
          print(faceId);
          return faceId;
        }else if(respuesta['result']['faces'].length==0){
          return "0";//ninguna cara
        }else{
          return "2";//demasiadas caras
        }
      }else{
        return "Error Servidor";
      }
    }else{
      return response.statusCode.toString();
    }
  }on Exception catch(e){
    return "Error $e";
  }
}

class DisplayPost extends StatefulWidget {
  //final File file;
  final String imagePath;

  const DisplayPost({Key key, this.imagePath}) : super(key: key);

  @override
  DisplayPostState createState() => DisplayPostState();
}


class DisplayPostState extends State<DisplayPost> {
  Future<String> futureString;

  @override
  void initState() {
    super.initState();
    futureString = postImage(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fetch Data Example'),
      ),
      body: Center(
        child: FutureBuilder<String>(
          future: futureString,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.toString());
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}