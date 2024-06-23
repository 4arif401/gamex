import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/user_controller.dart';
import 'database/database_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 1; // Initially selected index for profile
  UserController userController = Get.find<UserController>(); // Get instance of UserController
  List<Map<String, dynamic>> _gameList = [];
  TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController; // Controller for password

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchGames();
    _nameController = TextEditingController(text: userController.displayName.value);
    _emailController = TextEditingController(text: userController.email.value);
    _phoneController = TextEditingController(text: userController.phone.value);
    _passwordController = TextEditingController(); // Initialize password controller
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose(); // Dispose password controller
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchGames();
    });
  }

  Future<void> _fetchGames() async {
    try {
      List<Map<String, dynamic>> games = await DatabaseService.fetchOwnedItems(userController.userId.value);
      games.forEach((game) {
        game['formattedPrice'] = '\RM${double.parse(game['price'].toString()).toStringAsFixed(2)}';
      });

      setState(() {
        _gameList = games;
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
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // No need to navigate to '/profile' again since we're already on the profile page
        break;
    }
  }

  Future<void> _updateUserDetails() async {
    try {
      final response = await DatabaseAlterUser.alterUser(
        userId: userController.userId.value,
        displayName: _nameController.text.isEmpty ? 'No name' : _nameController.text,
        email: _emailController.text.isEmpty ? 'No email' : _emailController.text,
        phone: _phoneController.text.isEmpty ? 'No phone' : _phoneController.text,
        password: _passwordController.text.isEmpty ? 'No password' : _passwordController.text,
      );

      if (response['status'] == 'success') {
        // Update UserController with new data
        userController.afterUpdate(
          _nameController.text,
          _emailController.text,
          _phoneController.text,
        );
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User details updated successfully.')),
        );

        // Update UserController with user data
          Get.find<UserController>().updateUser({
            'email': _emailController.text,
            'display_name': _nameController.text,
            'phone': _phoneController.text,
          });

      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user details: $e')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(image: AssetImage('assets/titleText.png')),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text(
                'Profile',
                style: TextStyle(fontSize: 23, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() => _buildUserProfile()), // Obx to listen for changes in UserController
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Owned Games',
                style: TextStyle(fontSize: 23, color: Colors.white),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(), // Disable scrolling for ListView
              itemCount: _gameList.length,
              itemBuilder: (context, index) {
                String imageUrl = _gameList[index]['imageurl'] ?? 'https://via.placeholder.com/50';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
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
                                  _gameList[index]['game_name'] ?? 'Unknown Game',
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                Text(
                                  _gameList[index]['formattedPrice'] ?? '\RM0.00',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
          ],
        ),
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

  Widget _buildUserProfile() {
  if (userController.userId.value.isEmpty) {
    // User data not loaded yet
    return Center(child: CircularProgressIndicator());
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Name: ${userController.displayName.value}',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Email: ${userController.email.value}',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Phone: ${userController.phone.value}',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              // Perform logout action and navigate to LoginPage
              Get.offAllNamed('/');
            },
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Edit Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Display Name',
            labelStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            labelStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                obscureText: true, // Hide the password input
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _updateUserDetails,
              child: Text('Update'),
              style: ElevatedButton.styleFrom(
                iconColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

}
