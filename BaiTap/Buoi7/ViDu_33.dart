Future<String> TaiDuLieu(){
  return Future.delayed(
    Duration(seconds: 2),
  () => "du lieu da rai xong"
  );
}

void hamChinh1(){
  print("bat dau tai");
  Future<String> f = TaiDuLieu();
  f.then((ketqua){
    print("ket qua : $ketqua");
  });
  print("tiep tuc");
}

void hamChinh2() async{
  print("bat dau tai");//1
  String ketqua = await TaiDuLieu();
  print("tiep tuc : $ketqua");//2
  print("tiep tuc cong viec khac.");//3
}

void main(){
  hamChinh2();
}