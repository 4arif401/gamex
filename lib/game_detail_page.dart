import 'package:flutter/material.dart';
import 'dart:math';
import 'database/database_service.dart';
import 'controller/user_controller.dart'; // Import your user controller
import 'package:get/get.dart';

class GameDetailPage extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String price;
  final String gameid;

  GameDetailPage({
    required this.imageUrl,
    required this.name,
    required this.price,
    required this.gameid,
  });

  @override
  _GameDetailPageState createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  List<Map<String, dynamic>> _relatedGames = [];
  String _currentPrice = ''; // Track the current displayed price

  @override
  void initState() {
    super.initState();
    _currentPrice = widget.price; // Initialize current price with widget.price
    _fetchRelatedGames(); // Fetch related games when the widget initializes
  }

  Future<void> _fetchRelatedGames() async {
    try {
      // Fetch data from database using DatabaseSearchGame
      List<Map<String, dynamic>> games = await DatabaseSearchGame.getGames('');

      // Remove the currently displayed game and shuffle the list
      games.removeWhere((game) => game['name'] == widget.name);
      games.shuffle(Random());

      // Update state with fetched data
      setState(() {
        _relatedGames = games;
      });
    } catch (e) {
      print('Error fetching related games: $e');
      // Handle error (show message, retry logic, etc.)
    }
  }

  void _navigateToGameDetail(Map<String, dynamic> game) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameDetailPage(
          imageUrl: game['imageurl'] ?? 'https://via.placeholder.com/200',
          name: game['name'],
          price: game['price'],
          gameid: game['id'],
        ),
      ),
    );
  }

  String formatPrice(String price) {
    // Parse the price as double
    double parsedPrice = double.tryParse(price) ?? 0.0;

    // Format the price to have 2 decimal places
    return '\RM${parsedPrice.toStringAsFixed(2)}';
  }

  void _addToCart() async {
    try {
      // Get userId from UserController
      String userId = Get.find<UserController>().userId.value;

      // Ensure userId is not null or empty
      if (userId.isEmpty) {
        throw Exception('User ID is not available');
      }

      // Call DatabaseAddCart.addToCart to add the game to the cart
      Map<String, dynamic> result = await DatabaseAddCart.addToCart(
        int.parse(userId), // Parse userId to int if necessary
        int.parse(widget.gameid), // Parse gameid to int
        widget.name,
        widget.price,
        widget.imageUrl,
      );

      // Handle the result accordingly
      if (result['status'] == 'success') {
        // Successful request
        print('Game added to cart successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Game added to cart successfully')),
        );
      } else {
        // Request failed
        print('Failed to add game to cart: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add game to cart: ${result['message']}')),
        );
      }
    } catch (e) {
      // Exception during HTTP request or missing userId
      print('Exception adding game to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exception adding game to cart: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), // Change back icon color to white
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.white), // Change title text color to white
        ),
        backgroundColor: const Color(0xFF1b182b), // Background color of AppBar
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
        children: [
          Container(
            width: double.infinity,
            height: 250.0, // Set fixed height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Color.fromARGB(255, 146, 106, 173),
                width: 5.0, // Make the border wider
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain, // Ensure the image fits within the border
                errorBuilder: (context, error, stackTrace) {
                  return Image.network('https://via.placeholder.com/200');
                },
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding to the left
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price: ${formatPrice(_currentPrice)}', // Display current price
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: _addToCart,
                  child: Text('Add to Cart'),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Related Games',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _relatedGames.length,
              itemBuilder: (context, index) {
                String imageUrl = _relatedGames[index]['imageurl'] ?? 'https://via.placeholder.com/50';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: GestureDetector(
                    onTap: () => _navigateToGameDetail(_relatedGames[index]),
                    child: Container(
                      color: Color.fromARGB(255, 48, 33, 56), // Background color of the row
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
                                padding: const EdgeInsets.all(4.0), // Add margin inside the border
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6.0),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.scaleDown, // Adjust the fit as needed
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network('https://via.placeholder.com/50'); // Handle broken link
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
                                    _relatedGames[index]['name'],
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  Text(
                                    formatPrice(_relatedGames[index]['price']),
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
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
