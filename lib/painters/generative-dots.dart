import 'dart:math';
import 'package:eyez/painters/particles.dart';
import 'package:flutter/material.dart';
import 'package:eyez/painters/colors.dart';

Offset PolarToCartesian(double speed, double theta){
  return Offset(speed*cos(theta), speed*sin(theta));
}

class Generative extends CustomPainter{
  List<Particle> particles;
  double animValue;
  Generative(this.particles,  this.animValue);
  Random rgn = Random(100);

  Color GetRandomColor(Random rgn){
    var a = rgn.nextInt(255);
    var r = rgn.nextInt(255);
    var g = rgn.nextInt(255);
    var b = rgn.nextInt(255);
    return Color.fromARGB(a, r, g, b);
  }

  @override
  void paint(Canvas canvas, Size size){
    this.particles.forEach((p) {
      var velocity = PolarToCartesian(p.speed, p.theta);
      var dx = p.position.dx + velocity.dx;
      var dy = p.position.dy + velocity.dy;

      if(p.position.dx<0 || p.position.dx > size.width){
        dx = rgn.nextDouble() * size.width;
      }
      if(p.position.dy<0 || p.position.dy > size.height){
        dy = rgn.nextDouble() * size.height;
      }
      p.position = Offset(dx, dy);
    });

    Color c = GetRandomColor(rgn);

    //painting
    this.particles.forEach((p) {
      var paint = Paint();
      paint.color = hblue;
      canvas.drawCircle(p.position, p.radius, paint);
    });


  }

  @override
  bool shouldRepaint(CustomPainter customPainter){
    return true;
  }

}