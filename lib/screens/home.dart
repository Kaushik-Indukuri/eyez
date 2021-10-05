import 'dart:math';
import 'package:eyez/painters/particles.dart';
import 'package:eyez/screens/gallery-ocr.dart';
import 'package:flutter/material.dart';
import 'package:eyez/painters/colors.dart';
import 'package:eyez/painters/generative-dots.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

Color GetRandomColor(Random rgn){
  var a = rgn.nextInt(255);
  var r = rgn.nextInt(255);
  var g = rgn.nextInt(255);
  var b = rgn.nextInt(255);
  return Color.fromARGB(a, r, g, b);
}

double maxRadius = 6;
double maxSpeed = 0.2;
double maxTheta = 2.0*pi;

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  List<Particle> particles;
  Random rgn = Random(DateTime.now().millisecondsSinceEpoch);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(seconds: 10));
    animation = Tween<double>(begin: 0, end: 300).animate(controller)
      ..addListener(() {
        setState(() {

        });
      })
      ..addStatusListener((status){
        if (status == AnimationStatus.completed){
          controller.repeat();
        }
        else if (status == AnimationStatus.dismissed){
          controller.forward();
        }
      });


    controller.forward();

    this.particles = List.generate(120, (index) {
      var p = Particle();
      p.color = GetRandomColor(rgn);
      p.position = Offset(-1,-1);
      p.speed = rgn.nextDouble() *maxSpeed; //0-0.2
      p.theta = rgn.nextDouble() *maxTheta;//0-2pi radians
      p.radius = rgn.nextDouble() * maxRadius;
      return p;
    });

  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: size.height-(size.height/1.25)),
              child: Container(
                width: size.width,
                height: size.height,
                child: CustomPaint(
                  painter: Generative(particles, animation.value),
                ),
              ),
            ),
          ),
          Container(
            width: size.width,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 25),
                    child: Text("Welcome to EyeZ", style: TextStyle(
                      color: dBlack,
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                    ),),
                  ),
                  SizedBox(height: 55,),
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      //color: Colors.blue,
                      image: DecorationImage(
                        image: AssetImage("assets/imgs/eye1.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: BlueClipper(),
              child: Container(
                width: size.width,
                height: 450,
                color: Color(0xff2a2e32),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: YellowClipper(),
              child: Container(
                width: size.width,
                height: 450,
                color: Color(0xff212529),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: size.height/3,
              //color: Colors.blue,
              child: Column(
                children: [
                  SizedBox(height: size.height/15),
                  Container(
                    //margin: EdgeInsets.only(bottom: size.height/16),
                    child: MaterialButton(
                      elevation: 20,
                      onPressed:(){
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => SelectionPage()));
                      },
                      padding: EdgeInsets.all(3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Container(
                        width: size.width-90,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            gradient: new LinearGradient(
                                colors: [
                                  Color(0xff56CCF2),
                                  Color(0xff2F80ED)
                                ]
                            )
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                //margin: EdgeInsets.only(left: 15),
                                  child: Icon(Icons.camera_alt_outlined, size: 30, color: dBlack,)
                              ),
                              Text('Take Picture', style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: dBlack,
                              ),),
                              Text('   '),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  Container(
                    child: MaterialButton(
                      elevation: 20,
                      onPressed:(){
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SelectScreen()));
                      },
                      padding: EdgeInsets.all(3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)
                      ),
                      child: Container(
                        width: size.width-90,
                        padding: EdgeInsets.symmetric(vertical:15),
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            gradient: new LinearGradient(
                                colors: [
                                  Color(0xff56CCF2),
                                  Color(0xff2F80ED)
                                ]
                            )
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                //margin: EdgeInsets.only(left: 15),
                                  child: Icon(Icons.image_search, size: 30, color: dBlack,)
                              ),
                              Text('Select Image', style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: dBlack,
                              ),),
                              Text('   '),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlueClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0,size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height-400);
    path.lineTo(0, size.height-250);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}

class YellowClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0,size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height-50);
    path.lineTo(size.width/3, size.height-300);
    path.lineTo(0, size.height-250);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}


