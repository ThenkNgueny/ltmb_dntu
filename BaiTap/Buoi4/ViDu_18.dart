void main(){

  List<String> list1= ['a','b','c'];//Taoj list truc tiep
  var list2 = [1,2,3];
  List<String> list3 = [];//list rong
  var list4 = List<int>.filled(3,0);// List cos kich thuoc co dinh
  print(list4);

  //1. Them phan tu
  list1.add('d');//them 1 phan tu
  list1.addAll(['a','b']);//them nhieu phan tu
  list1.insert(0,'z');//chen vao vi tri cu the
  list1.insertAll(1,['1','0']);
  print(list1);

  //2. Xoa phan tu ben trong list
  list1.remove('a');//Xoa phan tu co gia tri a , Xoa dung chi 1 phan tu dau tien khi gap
  list1.removeAt(0);// Xoa phan tu tai vi tri cu the 0
  list1.removeLast;// Xoa phan tu tai vi tri cuoi
  list1.removeWhere((e)=> e == 'b');//Xoa theo dieu kien
  list1.clear();
  print(list1);

  //3. Truy xuat du lieu
  print(list2[0]); //Lay phan tu tai vi tri o;
  print(list2.first); //Lay phan tu dau tien;
  print(list2.last); // Lay phan tu cuoi cung;
  print(list2.length); //Lay do dai cua list

  //4.kiem tra
  print(list2.isEmpty); //Kiem tra rong
  print('list 3: ${list3.isNotEmpty?'khong rong' : 'rong'}');
  print(list4.contains(1));
  print(list4.contains(0));
  print(list4.lastIndexOf(0));
  print(list4.indexOf(0));

  //5.Bien đổi
  list4 = [2,1,3,9,0,10];
  print(list4);
  list4.sort(); // Sap xep tang dan
  print(list4);
  list4.reversed; // Đảo nguoc
  list4 = list4.reversed.toList();
  print(list4);

  //6.Cat va noi
  var  subList = list4.sublist(1,3); // cat list tu 1 den 3
  print(subList);
  var str_joined = list4.join(",");
  print(str_joined);

  //7. Duyet cac phan tu ben trong List
  list4.forEach((element){ //forEach lay tung phan tu ((dat ten))
    print(element);
  });
}