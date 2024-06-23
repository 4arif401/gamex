import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  static Future<List<Map<String, dynamic>>> getGames() async {
    const url = 'http://10.0.2.2/gamex/lib/database/connection/view_game.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching games: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCartItems(String userId) async {
    const url = 'http://10.0.2.2/gamex/lib/database/connection/view_cart.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching cart games: $e');
      throw e;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchOwnedItems(String userId) async {
    const url = 'http://10.0.2.2/gamex/lib/database/connection/view_owned.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'user_id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching cart games: $e');
      throw e;
    }
  }

}

class DatabaseSearchGame {
  static Future<List<Map<String, dynamic>>> getGames([String searchTerm = '']) async {
    final response = await http.get(Uri.parse('http://10.0.2.2/gamex/lib/database/connection/search_game.php?searchTerm=$searchTerm'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Failed to load games');
    }
  }
}

class DatabaseLogin {
  static const String _url = 'http://10.0.2.2/gamex/lib/database/connection/login.php';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(_url),
      body: {'email': email, 'password': password},
    );

    // Debug: Print the response body
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Failed to parse response: $e\nResponse body: ${response.body}');
      }
    } else {
      throw Exception('Failed to login: ${response.statusCode}\nResponse body: ${response.body}');
    }
  }
}

class DatabaseRegister {
  static const String _url = 'http://10.0.2.2/gamex/lib/database/connection/register.php';

  static Future<Map<String, dynamic>> register(
      String email, String displayName, String password, int rank) async {
      //final url = Uri.parse('http://10.0.2.2/gamex/lib/database/connection/register.php');

      final response = await http.post(
        Uri.parse(_url),
        body: {
          'email': email,
          'display_name': displayName,
          'password': password,
          'rank': rank.toString(), // Convert rank to String
        },
      );

      // Debug: Print the response body
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Failed to parse response: $e\nResponse body: ${response.body}');
      }
    } else {
      throw Exception('Failed to register: ${response.statusCode}\nResponse body: ${response.body}');
    }
  }
}

class DatabaseAddCart {
  static Future<Map<String, dynamic>> addToCart(int userId, int gameId, String name, String price, String imageurl) async {
    try {
      print('Adding to cart: userId: $userId, gameId: $gameId, name: $name, price: $price');
      
      final response = await http.post(
        Uri.parse('http://10.0.2.2/gamex/lib/database/connection/add_cart.php'),
        body: {
          'user_id': userId.toString(),
          'game_id': gameId.toString(),
          'game_name': name,
          'price': price,
          'imageurl' : imageurl,
        },
      );

      // Log the raw response for debugging
      print('Raw response: ${response.body}');

      // Decode the response to a Map
      Map<String, dynamic> result = jsonDecode(response.body);

      // Return the decoded result
      return result;
    } catch (e) {
      print('Error adding to cart: $e');
      // Return an error message in a Map
      return {'status': 'error', 'message': 'Error adding to cart: $e'};
    }
  }
}

class DatabaseDeleteCart {
  static Future<Map<String, dynamic>> deleteFromCart(int userId, int gameId) async {
    try {
      print('Deleting from cart: userId: $userId, gameId: $gameId');

      final response = await http.post(
        Uri.parse('http://10.0.2.2/gamex/lib/database/connection/delete_cart.php'),
        body: {
          'user_id': userId.toString(),
          'game_id': gameId.toString(),
        },
      );

      // Log the raw response for debugging
      print('Raw response: ${response.body}');

      // Decode the response to a Map
      Map<String, dynamic> result = jsonDecode(response.body);

      // Return the decoded result
      return result;
    } catch (e) {
      print('Error deleting from cart: $e');
      // Return an error message in a Map
      return {'status': 'error', 'message': 'Error deleting from cart: $e'};
    }
  }

  static Future<Map<String, dynamic>> payFromCart(int userId, String gameId) async {
    try {
      print('Paying from cart: userId: $userId, gameId: $gameId');

      final response = await http.post(
        Uri.parse('http://10.0.2.2/gamex/lib/database/connection/pay_cart.php'),
        body: {
          'user_id': userId.toString(),
          'game_id': gameId.toString(),
        },
      );

      // Log the raw response for debugging
      print('Raw response: ${response.body}');

      // Decode the response to a Map
      Map<String, dynamic> result = jsonDecode(response.body);

      // Return the decoded result
      return result;
    } catch (e) {
      print('Error paying from cart: $e');
      // Return an error message in a Map
      return {'status': 'error', 'message': 'Error paying from cart: $e'};
    }
  }
}

class DatabaseAlterUser {
  static const String _url = 'http://10.0.2.2/gamex/lib/database/connection/alter_user.php';

  static Future<Map<String, dynamic>> alterUser({
    required String userId,
    required String displayName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(_url),
      body: {
        'user_id': userId,
        'display_name': displayName,
        'email': email,
        'phone': phone,
        'password': password,
      },
    );

    // Debug: Print the response body
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Failed to parse response: $e\nResponse body: ${response.body}');
      }
    } else {
      throw Exception('Failed to alter user details: ${response.statusCode}\nResponse body: ${response.body}');
    }
  }
}