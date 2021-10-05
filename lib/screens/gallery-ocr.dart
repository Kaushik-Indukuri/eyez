import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Img;
import 'package:image_picker/image_picker.dart';
import 'package:opencv/core/core.dart';
import 'package:permission/permission.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../colors.dart';
import 'home.dart';
import 'package:opencv/opencv.dart';
import 'package:path_provider/path_provider.dart';
import 'photo_resizing.dart';

class SelectScreen extends StatefulWidget {
  @override
  _SelectScreenState createState() => _SelectScreenState();
}


class _SelectScreenState extends State<SelectScreen> {
  bool _scanning = false;
  String _extractText = '';
  File _pickedImage;
  dynamic res;
  Image imageNew = Image.asset('assets/image.png');
  bool loaded = false;
  File imageFile;
  String tempPath = '';
  Img.Image img;
  TextEditingController _regTextCtrl = TextEditingController();


  Future<void> runAFunction(String functionName) async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      switch (functionName) {
        case 'threshold':
          res = await ImgProc.threshold(
              await _pickedImage.readAsBytes(), 80, 255, ImgProc.threshBinary);
          break;
        case 'adaptiveThreshold':
          res = await ImgProc.adaptiveThreshold(await _pickedImage.readAsBytes(), 125,
              ImgProc.adaptiveThreshMeanC, ImgProc.threshBinary, 11, 12);
          break;
        case 'sobel':
          res = await ImgProc.sobel(await _pickedImage.readAsBytes(), -1, 1, 1);
          break;
        case 'scharr':
          res = await ImgProc.scharr(
              await _pickedImage.readAsBytes(), ImgProc.cvSCHARR, 0, 1);
          break;
        case 'laplacian':
          res = await ImgProc.laplacian(await _pickedImage.readAsBytes(), 10);
          break;
        case 'resize':
          res = await ImgProc.resize(
              await _pickedImage.readAsBytes(), [500, 500], 0, 0, ImgProc.interArea);
          break;
        case 'applyColorMap':
          res = await ImgProc.applyColorMap(
              await _pickedImage.readAsBytes(), ImgProc.colorMapHot);
          break;
        default:
          print("No function selected");
          break;
      }

      setState(() {
        imageNew = Image.memory(res);
        loaded = true;
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    Img.Image _img = Img.decodeImage(res);
    File(_pickedImage.path)..writeAsBytesSync(Img.encodeJpg(_img));

    if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.only(left: 20),
            child: IconButton(
              onPressed: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
              },
                icon: Icon(Icons.arrow_back_ios, color: dBlack,)
            ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('EyeZ', style: TextStyle(
          color: dBlack,
        ),),
      ),
      body: ListView(
        children: [
          loaded == false
              ? Container(
            height: size.height*0.3,
            //color: lBlack,
            child: Center(
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: lBlack.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  MdiIcons.imageOutline,
                  size: 100,
                  color: hblue,
                ),
              ),
            ),
          )
              : Container(
            height: 300,
              child: imageNew,
//            decoration: BoxDecoration(
//                color: Colors.grey[300],
//                image: DecorationImage(
//                  image: AssetImage('txtimage.png'),
//                  fit: BoxFit.fill,
//                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 20, right: 20, top: 15),
            child: RaisedButton(
              onPressed: () async {
                setState(() {
                  _scanning = true;
                });
                _pickedImage =
                await ImagePicker.pickImage(source: ImageSource.gallery);
                runAFunction('threshold');
                _performOCR();
//                _extractText =
//                await TesseractOcr.extractText(_pickedImage.path);
//                bool exists = await File('$tempPath/image.png').exists();
//                exists == true ? _extractText =
//                await TesseractOcr.extractText('$tempPath/image.png') :
//                    print('ERROR');
                setState(() {
                  _scanning = false;
                });
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
              textColor: Colors.white,
              padding: const EdgeInsets.all(0),
              child: Container(
                alignment: Alignment.center,
                height: 60.0,
                width: size.width*0.9,
                decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: new LinearGradient(
                        colors: [
                          Color(0xff56CCF2),
                          Color(0xff2F80ED)
                        ]
                    )
                ),
                padding: const EdgeInsets.all(0),
                child: Text(
                  "GET STARTED",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          _scanning
              ? Center(child: CircularProgressIndicator())
              : Icon(
            Icons.done,
            size: 40,
            color: Colors.green,
          ),
          SizedBox(height: 15),
          Center(
            child: TextField(
              controller: _regTextCtrl,
              enabled: false,
              minLines: 5,
              maxLines: 1000,
            ),
//            child: Padding(
//              padding: const EdgeInsets.only(bottom: 40),
//              child: Text(
//                _extractText,
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  fontSize: 25,
//                  fontWeight: FontWeight.bold,
//                ),
//              ),
//            ),
          )
        ],
      ),
    );
  }

  _performOCR() async {
    // Approach: optimization based on resizing the photo.
    //await PhotoOptimizerForOCR.optimizeByResize(_pickedImage.path);

    if (_pickedImage != null && _pickedImage.path != "") {
      // "   " = \n delimiter
      // To use a dedicated delimiter instead of "   ",
      // provide the delimiter parameter => delimiter: " *** " now the blocks recognized would be separated by " *** " instead
      try {
        String _resultString = await TesseractOcr.extractText(_pickedImage.path);
        setState(() {
          _regTextCtrl.text = _resultString;
        });
      } catch(e) {
        setState(() {
          _regTextCtrl.text = "error in recognizing the image / photo => ${e.toString()}";
        });
      } // End -- try
    }
  }
}