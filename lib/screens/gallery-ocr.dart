import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../colors.dart';
import 'home.dart';

class SelectScreen extends StatefulWidget {
  @override
  _SelectScreenState createState() => _SelectScreenState();
}


class _SelectScreenState extends State<SelectScreen> {
  bool _scanning = false;
  String _extractText = '';
  File _pickedImage;

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
          _pickedImage == null
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
            decoration: BoxDecoration(
                color: Colors.grey[300],
                image: DecorationImage(
                  image: FileImage(_pickedImage),
                  fit: BoxFit.fill,
                )),
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
                _extractText =
                await TesseractOcr.extractText(_pickedImage.path);
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Text(
                _extractText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}