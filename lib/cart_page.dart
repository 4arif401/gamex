import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'database/database_service.dart';
import 'controller/user_controller.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchCartItems();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchCartItems();
    });
  }

  Future<void> _fetchCartItems() async {
    try {
      String userId = Get.find<UserController>().userId.value;
      List<Map<String, dynamic>> cartItems = await DatabaseService.fetchCartItems(userId);

      // Format prices to display with 2 decimal places
      cartItems.forEach((item) {
        item['formattedPrice'] = '\RM${double.parse(item['price'].toString()).toStringAsFixed(2)}';
      });

      setState(() {
        _cartItems = cartItems;
      });
    } catch (e) {
      print('Error fetching cart items: $e');
      // Handle error (show message, retry logic, etc.)
    }
  }

  Future<void> _deleteCartItem(int? gameId) async {
    if (gameId == null) {
      print('Game ID is null, cannot delete item.');
      return;
    }

    try {
      int userId = int.parse(Get.find<UserController>().userId.value); // Convert to int

      Map<String, dynamic> result = await DatabaseDeleteCart.deleteFromCart(userId, gameId);

      if (result['status'] == 'success') {
        print('Item deleted successfully');
        _fetchCartItems(); // Refresh the cart items after deletion
      } else {
        print('Failed to delete item: ${result['message']}');
        // Handle deletion failure (show message, retry logic, etc.)
      }
    } catch (e) {
      print('Error deleting item: $e');
      // Handle error (show message, retry logic, etc.)
    }
  }

  Future<void> _payCartItem(String gameId) async {
    try {
      int userId = int.parse(Get.find<UserController>().userId.value); // Convert to int

      Map<String, dynamic> result = await DatabaseDeleteCart.payFromCart(userId, gameId);

      if (result['status'] == 'success') {
        print('Item paid successfully');
        _fetchCartItems(); // Refresh the cart items after deletion
      } else {
        print('Failed to pay item: ${result['message']}');
        // Handle deletion failure (show message, retry logic, etc.)
      }
    } catch (e) {
      print('Error paying item: $e');
      // Handle error (show message, retry logic, etc.)
    }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF1b182b),
        title: Text(
          'Games Cart',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                String imageUrl = _cartItems[index]['imageurl'] ?? 'https://via.placeholder.com/50';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Dismissible(
                    key: Key(_cartItems[index]['game_id'].toString()), // Ensure 'game_id' is cast to String
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      if (_cartItems[index]['game_id'] != null) {
                        _deleteCartItem(int.parse(_cartItems[index]['game_id'].toString())); // Parse as int
                      } else {
                        print('Invalid game ID, unable to delete item.');
                      }
                    },
                    child: Container(
                      color: Color.fromARGB(255, 48, 33, 56),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                        title: Row(
                          children: <Widget>[
                            Container(
                              width: 125,
                              height: 71.3125,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: Color.fromARGB(255, 146, 106, 173),
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.scaleDown,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network('https://via.placeholder.com/50');
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _cartItems[index]['game_name'] ?? 'Unknown Game',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  Text(
                                    _cartItems[index]['formattedPrice'] ?? '\RM0.00',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _payCartItem(_cartItems[index]['game_id'].toString());
                              },
                              child: Text('Pay'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
