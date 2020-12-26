import 'dart:io';
import 'dart:ui' as ui;
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

const Color _color = Colors.cyan;
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
  static ui.Image _image;
  static final List<Rect> _rectArr = [];
  static bool _backPressCounter = false;

  Future _getImage() async {
    final imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (imageFile != null) {
      final listOfFaces = await FirebaseVision.instance
          .faceDetector()
          .processImage(FirebaseVisionImage.fromFile(File(imageFile.path)));
      _rectArr.clear();
      for (final _face in listOfFaces) {
        _rectArr.add(_face.boundingBox);
      }
      await decodeImageFromList(File(imageFile.path).readAsBytesSync())
          .then((_img) {
        setState(() {
          _image = _img;
        });
      });
    }
  }

  Future<bool> _onWillPop() {
    if (!_backPressCounter) {
      Fluttertoast.showToast(
        msg: 'Press again to exit app',
        backgroundColor: Colors.black,
      );
      setState(() {
        _backPressCounter = true;
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    final _width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _color,
          title: Text('TritoneTech Face Detection'),
        ),
        body: Container(
          child: Center(
            child: FittedBox(
              child: SizedBox(
                height: _image == null ? _height : _image.height.toDouble(),
                width: _image == null ? _width : _image.width.toDouble(),
                child: CustomPaint(
                  painter: _Painter(
                    rect: _rectArr,
                    image: _image,
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _color,
          onPressed: () {
            _getImage();
          },
          child: Icon(Icons.camera_alt),
        ),
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
    final paint = Paint()
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
