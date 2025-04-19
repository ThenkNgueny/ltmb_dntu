// khai niem mixin

mixin M{
  int? a;
  void ShowSomeThing(){
    print("Print massage...");// khong the su dung rieng le duoc
  }
}

class B{
  String name = "Class B";
  void displayInfomation(){
    print("Infomation fron B");
  }
}

class C extends B with M{
  @override
  void displayInfomation() {
   ShowSomeThing();
    a = 100;
  } 
}

void main(){
  var c = C();
  c.displayInfomation();
}
