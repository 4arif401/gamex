import 'dart:async';
import 'package:flutter/material.dart';
import 'database/database_service.dart'; // Import the database service
import 'game_detail_page.dart';
import 'login_page.dart'; // Import the login page
import 'register_page.dart'; // Import the register page
import 'controller/user_controller.dart'; // Import your user controller
import 'package:get/get.dart';
import 'cart_page.dart';
import 'profile_page.dart'; // Import the profile page

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  final UserController userController = Get.put(UserController()); // Inject UserController
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1b182b), // Background to black
        appBarTheme: const AppBarTheme(
          color: Color(0xFF1b182b), // AppBar to custom color
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginPage()),
        GetPage(name: '/home', page: () => MyHomePage()),
        GetPage(name: '/profile', page: () => ProfilePage()),
        GetPage(name: '/register', page: () => RegisterPage()),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _items = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchGames(); // Fetch data when the widget initializes
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
      _fetchGames(_searchController.text);
    });
  }

  Future<void> _fetchGames([String searchTerm = '']) async {
    try {
      // Fetch data from database using DatabaseSearchGame
      List<Map<String, dynamic>> games = await DatabaseSearchGame.getGames(searchTerm);

      // Format prices to display with 2 decimal places
      games.forEach((game) {
        game['formattedPrice'] = '\RM${double.parse(game['price'].toString()).toStringAsFixed(2)}';
      });

      // Update state with fetched data
      setState(() {
        _items = games;
      });
    } catch (e) {
      print('Error fetching games: $e');
      // Handle error (show message, retry logic, etc.)
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/profile'); // Navigate to profile page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(image: AssetImage('assets/titleText.png')),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, size: 35),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(),
                ),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Color.fromARGB(255, 146, 106, 173), // Set search bar color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.white, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                // Use dummy image if imageurl is null
                String imageUrl = _items[index]['imageurl'] ?? 'https://via.placeholder.com/50';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailPage(
                            imageUrl: imageUrl,
                            name: _items[index]['name'],
                            price: _items[index]['price'].toString(),
                            gameid: _items[index]['id'].toString(), // Pass the parameters
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: Color.fromARGB(255, 48, 33, 56), // Background color of the row
                      child: Column(
                        children: [
                          ListTile(
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
                                        _items[index]['name'],
                                        style: TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                      Text(
                                        _items[index]['formattedPrice'], // Display formatted price
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF1b182b),
        backgroundColor: const Color(0xFFf95353),
        onTap: _onItemTapped,
      ),
    );
  }
}
