import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const String apiKey =
      'YOUR_GROQ_API_KEY_HERE';
  static const String endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String model = 'llama-3.3-70b-versatile';

  Future<String> sendMessage(List<Map<String, String>> messages) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': messages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'I apologize, but I\'m having trouble connecting right now. '
            'Please try again in a moment. (Error: ${response.statusCode})';
      }
    } catch (e) {
      return 'I\'m sorry, I couldn\'t process your request. '
          'Please check your internet connection and try again.';
    }
  }
}
