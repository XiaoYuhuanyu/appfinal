import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: ShoppingListApp(),
    ),
  );
}

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

class ShoppingListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return authProvider.isLoggedIn ? ShoppingListScreen() : LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登入'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: '帳號'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: '密碼'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // In a real application, perform authentication logic here
                // For simplicity, we'll just check if both fields are not empty
                if (usernameController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  Provider.of<AuthProvider>(context, listen: false).login();
                }
              },
              child: Text('登入'),
            ),
          ],
        ),
      ),
    );
  }
}

class ShoppingListScreen extends StatefulWidget {
  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<Product> products = [];
  String newProductName = '';
  double newProductPrice = 0.0;
  int newProductQuantity = 0;
  double totalPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('即時購物清單'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                newProductName = value;
              },
              decoration: InputDecoration(labelText: '商品名稱'),
            ),
            TextField(
              onChanged: (value) {
                newProductPrice = double.tryParse(value) ?? 0.0;
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: '商品金額'),
            ),
            TextField(
              onChanged: (value) {
                newProductQuantity = int.tryParse(value) ?? 0;
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: '商品數量'),
            ),
            ElevatedButton(
              onPressed: () {
                // 添加新商品
                addProduct();
              },
              child: Text('添加商品'),
            ),
            SizedBox(height: 20),
            Text(
              '購物清單',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${products[index].name}'),
                    subtitle: Text('${products[index].quantity} x \$${products[index].price}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // 刪除商品
                        removeProduct(index);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Text(
              '總價: \$${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void addProduct() {
    if (newProductName.isNotEmpty && newProductPrice > 0 && newProductQuantity > 0) {
      setState(() {
        products.add(Product(name: newProductName, price: newProductPrice, quantity: newProductQuantity));
        calculateTotalPrice();
        newProductName = '';
        newProductPrice = 0.0;
        newProductQuantity = 0;
      });
    }
  }

  void removeProduct(int index) {
    setState(() {
      products.removeAt(index);
      calculateTotalPrice();
    });
  }

  void calculateTotalPrice() {
    totalPrice = products.fold(0, (sum, product) => sum + (product.price * product.quantity));
  }
}

class Product {
  String name;
  double price;
  int quantity;

  Product({required this.name, required this.price, required this.quantity});
}
