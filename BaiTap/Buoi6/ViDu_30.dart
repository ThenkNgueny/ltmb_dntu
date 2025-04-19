import 'dart:ffi';
import 'dart:math';

class Point{
  double x,y;
  Point(this.x, this.y);
  double DistanceTo(Point other){
    var dx = x - other.x;
    var dy = y - other.y;
    return sqrt(dx*dy + dy*dy);
  }
}

//=================
class Point2{
  double? x;// Thuoc tinh instance x , ban dau mac dinh la null
  double z = 0;// Thuoc tinhs instance z , ban dau co gia tru bang 0
}

//===============
double X_ = 1.5;
class Point3{
  double? x = X_;// Co the truy khai baos khong thuoc this

  // double? y = this.x ; => Error
  double? y;
  late double? z = this.x;

  Point3(this.x, this.y, this.z);
}

//Phuongg thuc getters , Setter

class Rectangle{
  double left, top , width, heigt;
  late double _Z;
  
  Rectangle(this. left ,this.top , this .width, this.heigt);

  double get z =>_Z;
  set z(double value) => _Z = value;
  
  @override
  String toString() {
    // TODO: implement toString
    return left.toString()+ ", "+ top.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Rectangle) return false;

    // TODO: implement ==
    return left == other.left && 
    top == other.top && width == other.width && heigt == other.heigt;

  }
}

//Thuoc tinh va phuonng thuc Static
class Mymath{
  static const double PI = 3.14;

  static double sqr( double x){
    return x*x;
  }
}





void main(){
  // khoi tao doi tuong
  Point p1 = Point(0, 0);
  var p2 = Point(3, 3);

  double d = p1.DistanceTo(p2);
  print(d.toStringAsFixed(2));

  //=====
  Point2 p2_1 = Point2();
  print(p2_1.x);

  //====
  print(Mymath.PI);
  print(Mymath.sqr(5));

  //=====
  Rectangle r =Rectangle(0, 0, 15, 25);
  r.z = 100;
  print(r._Z);
  print(r.toString());

  //=====
  Rectangle r2 = Rectangle(1, 0, 15, 20);
  print(r==r2);
}