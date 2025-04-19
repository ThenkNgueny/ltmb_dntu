class Product{
  double price;
  int qunatity;
  String name;

  Product ( this.price, this.qunatity, this.name);

  void showTotal() {
    print("Total price is: ${price * qunatity}");
  }
}

class Table extends Product{
  double width = 0;
  double height = 0;
  Table( this.width, this.height, double price, int qunatity, String name)
  : super (price, qunatity, name);

  @override
  void showTotal() {
    print("name of Table : $name");
    super.showTotal();
  }
}

void main(){
  Product p =Product(6000, 1, "San pham");
  Product p1 = new Table(7, 6, 7000, 10, "Laptop");

  p.showTotal();
  print("\n");
  p1.showTotal();
}
// Nghiem cuu ve lop truu tuonng ( abstract class)