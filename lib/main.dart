import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:path/path.dart' show basename, join;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:date_time_format/date_time_format.dart';

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
      appBar: AppBar(title: Text('Take a picture'),
       actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add_photo_alternate_outlined),
          tooltip: 'Open Gallery',
          onPressed: () async {
              var image = await ImagePickerGC.pickImage(
                  context: context,
                  source: ImgSource.Gallery,
                  cameraIcon: Icon(
                    Icons.camera_alt,
                    color: Colors.red,
                  )
              );

              if (image != null)
                Navigator.push(context,MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: image.path)));
              else
                return;
          }
        ),
       ],
      ),
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
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 240.0,
        ),
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
              (await getTemporaryDirectory()).path,'${DateTimeFormat.format(DateTime.now(), format: 'j-n-Y_H:i:s:v')}.png');

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Post')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
      //body: Image.file(a),
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


Future<String> postImage(String imagePath) async{

  File imageFile = new File(imagePath);

  // print(imagePath);
  // print(imageFile);

  // ignore: deprecated_member_use
  var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
  var length = await imageFile.length();
  print(length);
  Map<String, String> headers = { HttpHeaders.authorizationHeader: 'Basic YWNjXzAzMzMxYWFmNmE3ZDFiMjpjN2MwMzcyNDZmMTdkNmNlZmM1OWVjYjFjMzY1ZDU0OA=='};
  int timeout = 10;

  var request = new http.MultipartRequest("POST", Uri.parse('https://api.imagga.com/v2/colors'));
  request.headers.addAll(headers);

  var multipartFile = new http.MultipartFile('image', stream, length, filename: basename(imageFile.path));

  request.fields['extract_overall_colors '] = "1"; //Default: 1
  request.fields['extract_object_colors '] = "0"; //Default: 1
  request.fields['overall_count'] = "5"; //Default: 5
  request.fields['separated_count '] = "1"; //Default: 3
  request.fields['deterministic'] = "0"; //Default: 0
  //request.fields['features_type'] = "overall"; //overall or object

  request.files.add(multipartFile);

  var streamedResponse = await request.send().timeout(Duration(seconds: timeout));

  if(streamedResponse.statusCode == HttpStatus.ok) {
    var responseStream = await streamedResponse.stream.toBytes();
    var responseString = String.fromCharCodes(responseStream);
    // print(responseString);
    return responseString;

  } else {
    throw Exception('Failed HTTP');
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
  Future<String> futureAlbum;

  @override
  void initState(){
    super.initState();
    futureAlbum = _genCode();
  }

  Future<String> _genCode() async {
    String json = await postImage(widget.imagePath);
    // Map data = jsonDecode(json);
    // print(data['result']['colors']['image_colors'][0].keys.toList());
    // print(data['result']['colors']['image_colors'][0].values.toList());
    return json;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: Text('Fetch Data Example'),
    ),
    body: Center(
      child: FutureBuilder(
        future: futureAlbum,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
            String data = snapshot.data;

            return jsonParser(data, context);

          }
          else if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Image.asset('images/snoopy-penalty-box.gif'),
                    Text(snapshot.error),
                  ],
                ),
              ),
            );
          }
        }
    )
      )
    );
  }
}

ListView jsonParser( String snapdata, BuildContext context) {
  Map data = jsonDecode(snapdata);

  var length = data['result']['colors']['image_colors'].length;

  List values;

  List<String> result = [];
  List<Color> colors = [];

  for (var i = 0; i < length; i++) {
    values = data['result']['colors']['image_colors'][i].values.toList();

    result.add(values[1].toString().toUpperCase());
    result.add('R: ' + values[8].toString());
    result.add('G: ' + values[5].toString());
    result.add('B: ' + values[0].toString());
    result.add('HTML -> ' + values[6].toString());
    result.add('Percentage of this color -> ' + values[7].toStringAsFixed(2) + '%');
    result.add(' ');

    colors.add(Color.fromARGB(255, values[8], values[5], values[0]));

  }

  return ListView.builder(
    itemCount: 7 * length,
    itemBuilder: (BuildContext context, int n) =>
        Ink(
          color: colors[(n~/7)],
          child: ListTile(leading: Text(result[n])),
        )
  );
}

int getColor(String color){
  String aux;
  int result;
  try {
    aux = color.substring(3);
    result = int.parse(aux);
    return result;
  } catch (e){
    return 0;
  }
}