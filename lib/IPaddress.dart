import 'dart:convert';
import 'package:http/http.dart' as http;

class Constants {
  static const String IPAddress = "192.168.108.234";
  Future<String?> sendRequst(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
          Uri.parse('http://$IPAddress:5050/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
      if (response.statusCode == 200) {
        print('Response from server : ${response.body}');
        return response.body;
      } else {
        print('Failed to send request: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception : $e');
      return null;
    }
  }
}
