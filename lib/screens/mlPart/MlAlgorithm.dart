import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class MlPart extends StatefulWidget {
  @override
  _MlPartState createState() => _MlPartState();
}

class _MlPartState extends State<MlPart> {
  List _outputs;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Machine Learning'),
      ),
      body: _loading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _imageFile == null ? Container() : Image.file(_imageFile),
                  SizedBox(
                    height: 20,
                  ),
                  _outputs != null
                      ? Text(
                          "${_outputs[0]["label"]}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            background: Paint()..color = Colors.white,
                          ),
                        )
                      : Container()
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => captureImage(ImageSource.gallery),
        child: Icon(Icons.image),
      ),
    );
  }

  File _imageFile;
  final picker = ImagePicker();
  Future<void> captureImage(ImageSource imageSource) async {
    final imageFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (imageFile != null) {
        _imageFile = File(imageFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  classifyImage(File imageFile) async {
    var output = await Tflite.runModelOnImage(
      path: _imageFile.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/a.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
