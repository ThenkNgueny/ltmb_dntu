void main(){
  Object obj = 'Hello';

  //Kiem tra la kieu int
  if(obj is String){
    print('obj la mot chuoi');
  }

  //Kiem tra khong phai kieu
  if(obj is! int ){
    print(' obj khong phai kieu so nguyen');
  }

  //Ep kieu
  String str = obj as String;
  print(str.toLowerCase());
}