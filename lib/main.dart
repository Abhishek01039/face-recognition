import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final Color color = Colors.cyan;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FaceDetect(),
    );
  }
}

class FaceDetect extends StatefulWidget {
  @override
  _FaceDetectState createState() => _FaceDetectState();
}

class _FaceDetectState extends State<FaceDetect> {
  ui.Image image;
  List<Rect> rectArr = [];

  Future getImage() async {
    PickedFile imageFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    print("image file type ${imageFile.runtimeType}");
    FirebaseVisionImage fbVisionImage =
        FirebaseVisionImage.fromFile(File(imageFile.path));
    FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
    List<Face> listOfFaces = await faceDetector.processImage(fbVisionImage);
    rectArr.clear();
    for (Face face in listOfFaces) {
      rectArr.add(face.boundingBox);
    }
    var bytesFromImageFile = File(imageFile.path).readAsBytesSync();
    decodeImageFromList(bytesFromImageFile).then((img) {
      setState(() {
        image = img;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        title: Text("TritoneTech Face Detection"),
      ),
      body: Container(
        child: Center(
          child: FittedBox(
            child: SizedBox(
              height: image == null ? height : image.height.toDouble(),
              width: image == null ? width : image.width.toDouble(),
              child: CustomPaint(
                painter: _Painter(
                  rect: rectArr,
                  image: image,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        onPressed: () {
          getImage();
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  const _Painter({@required this.rect, @required this.image});

  final List<Rect> rect;
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    if (image != null) {
      canvas.drawImage(image, Offset.zero, paint);
    }
    for (var i = 0; i <= rect.length - 1; i++) {
      canvas.drawRect(rect[i], paint);
    }
  }

  @override
  bool shouldRepaint(oldDelegate) {
    return true;
  }
}
