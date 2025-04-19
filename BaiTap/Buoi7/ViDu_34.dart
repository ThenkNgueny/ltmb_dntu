/*
Stream là gi? 

Nếu Future giống như đợi một món ăn, thì Stream giống như xem một kênh YouTube: 

Bạn đăng ký kênh (lăng nghe stream) 
Video mới liêu cục được đăng tải (stream phát ra dữ liệu) 
Bạn xem từng video khi nó xuất hiện (xử lý dữ liệu từ stream) 
Kênh có thể đăng tải nhiều video theo thời gian (stream phát nhiều giá trị) 

Stream trong Dart là chuỗi các sự kiện hoặc dữ liệu theo thời gian, 
không chỉ một lần như Future.
*/

import 'dart:async';

void ViDuStreamDemSo(){
  print("=== vi du 1 : stream tro choi 5 10 =====");
  // Tao ra stream dem so ( phat ra con so 0,5,10...), moi gia 1 con so;
  Stream<int> stream = Stream.periodic(Duration( seconds: 1),(x)=>x+1).take(21);

  //Lang nghe
  stream.listen(
    (x) => print("Nghe duoc so : ${x*5} - danng chay tron!"),
    onDone: () => print("Nguoi bi : bat dau di tim!!"),
    onError: (loi) => print("Co can de , nhung cuoc choi ($loi)")
  );
  
}

  void ViDuStreamController(){
    print("=== vi du 2====");

    // tao bo dieu khien
    StreamController<String> controller = StreamController<String>();

    //Lang nghe stream
    controller.stream.listen(
      (TinNhan) => print("Tin nhan moi :$TinNhan"),
      onDone: () => print("Khong con tin nao"),
    );

    // Gui tin nhan vao Stream
    print("Dang gui tin nhan dau tien ///");
    controller.add("Xin chao !");

    //Gui them tin nhan sau 2 giay
    Future.delayed(Duration(seconds: 2), (){
      print("Dang gui tin nhan thu hai...");
      controller.add("ban khoe hok?");
    }
    );

    //Gui tin nhann cuoi cung va dong Stream sau 4 giay
    Future.delayed(Duration(seconds: 4), (){
      print("Dang gui tin nhan cuoi ...");
      controller.add("Tam biet");
      controller.close();
    });
  }

void main(){
  ViDuStreamController();
}