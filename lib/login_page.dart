import 'package:flutter/material.dart';
import 'database/database_service.dart'; // Import the DatabaseLogin class
import 'controller/user_controller.dart'; // Import your user controller
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
  String email = _emailController.text;
  String password = _passwordController.text;

  try {
    final response = await DatabaseLogin.login(email, password);
    print(response); // Debug print

    if (response['status'] == 'success') {
      // Extract user data from the response
      String userId = response['user_id'];
      String email = response['email'];
      String displayName = response['display_name'];
      String rank = response['rank'];
      String phone = response['phone'];

      // Update UserController with user data
        Get.find<UserController>().updateUser({
          'user_id': userId,
          'email': email,
          'display_name': displayName,
          'rank': rank,
          'phone': phone,
          'password': password
        });
      
      // Navigate to home page and pass user data
      Navigator.pushReplacementNamed(
          context,
          '/home',
        );
    } else {
      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(response['message']),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    print(e); // Debug print
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Failed to login: $e'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 100.0), // Padding above the image
              Image.asset(
                'assets/titleText.png',
                height: 35, // Reduce the size of the image
                fit: BoxFit.contain,
              ),
              
              SizedBox(height: 120), // Padding above the "Login" text
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 24),
                  children: [
                    TextSpan(text: 'LOG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    TextSpan(text: 'IN', style: TextStyle(color: Color(0xFFf95353), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(height: 20), // Reduce the space between "Login" text and email field
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
                obscureText: true,
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity, // Make the button's width match the text fields
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text('LOGIN'),
                ),
              ),
              SizedBox(height: 90), // Space between Login button and OR divider
              Center(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10), // Space between OR divider and "CREATE NEW ACCOUNT" button
              SizedBox(
                width: double.infinity, // Make the button's width match the text fields
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to create account page
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('CREATE NEW ACCOUNT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
