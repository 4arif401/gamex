import 'dart:convert';
import 'package:http/http.dart' as http;

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
