import 'dart:convert';

import 'package:allen/constant.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
 static final List<Map<String, String>> messages=[];
 static  Future<String> isArtPromptApi(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAISecretKey'
        },
        body: json.encode(
          {
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                'role': 'user',
                'content':
                    'Does this message want to generate an AI picture, image art or anything similar? $prompt. Simply answer with a yes or no'
              }
            ]
          },
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('yay!');
        var content =json.decode(response.body)['choices'][0]['message']['content'].trim();
        switch(content){
          case 'Yes':
          case 'yes':
          case 'YES.':
          case 'yes.':
          final res = await dallEApi(prompt);
          return res;
          default:
          final res = await chatGPTApi(prompt);
          return res;
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> chatGPTApi(String prompt) async {
    messages.add({
      "role":"user",
      "content":prompt
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAISecretKey'
        },
        body: json.encode(
          {
            "model": "gpt-3.5-turbo",
            "messages": messages
          },
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('yay!');
        var content =json.decode(response.body)['choices'][0]['message']['content'].trim();
        messages.add({
          'role':'assistant',
          'content':content
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String> dallEApi(String prompt) async {
     messages.add({
      "role":"user",
      "content":prompt
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAISecretKey'
        },
        body: json.encode(
          {
            'prompt':prompt,
            'n':1
          },
        ),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('yay!');
        var imageUrl =json.decode(response.body)['data'][0]['url'];
        messages.add({
          'role':'assistant',
          'content':imageUrl
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
