import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherChatbot extends StatefulWidget {
  @override
  _WeatherChatbotState createState() => _WeatherChatbotState();
}

class _WeatherChatbotState extends State<WeatherChatbot> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String openCageApiKey = '726936cd527f4d038ecaa096508832da'; // Replace with your OpenCage API Key
  bool _hasUserInteracted = false; // Track if the user has sent a message

  // Function to fetch coordinates from OpenCage API
  Future<Map<String, double>?> _getCoordinates(String city) async {
    final url = 'https://api.opencagedata.com/geocode/v1/json?q=$city&key=$openCageApiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        double lat = data['results'][0]['geometry']['lat'];
        double lon = data['results'][0]['geometry']['lng'];
        return {'latitude': lat, 'longitude': lon};
      }
    }
    return null;
  }

  // Function to fetch weather data from Open Meteo API
  Future<void> _fetchWeather(String city) async {
    final coordinates = await _getCoordinates(city);
    String responseMessage;

    if (coordinates != null) {
      double latitude = coordinates['latitude']!;
      double longitude = coordinates['longitude']!;
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';

      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          responseMessage = 'Current temperature in $city: ${data['current_weather']['temperature']}°C\n'
              'Wind speed: ${data['current_weather']['windspeed']} km/h';
        } else {
          responseMessage = 'Sorry, could not fetch weather for $city.';
        }
      } catch (error) {
        responseMessage = 'Sorry, something went wrong. Please try again.';
      }
    } else {
      responseMessage = 'City not found. Please try another.';
    }

    // Add the bot response to the chat
    setState(() {
      _messages.add({'text': responseMessage, 'sender': 'bot'});
    });
  }

  // Function to send user message
  void _sendMessage() {
    String userMessage = _controller.text.trim();
    if (userMessage.isNotEmpty) {
      setState(() {
        _messages.add({'text': userMessage, 'sender': 'user'});
        _hasUserInteracted = true; // User has interacted, hide the initial screen
      });

      // Clear the input field
      _controller.clear();

      // Fetch weather information
      _fetchWeather(userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather Chatbot'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context); // Pop the current screen
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _hasUserInteracted
                  ? ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUserMessage = message['sender'] == 'user';
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Material(
                          borderRadius: BorderRadius.circular(12.0),
                          elevation: 2,
                          color: isUserMessage ? Colors.blue : Colors.grey[300],
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Text(
                              message['text']!,
                              style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          isUserMessage ? 'You' : 'Bot',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.android, size: 100, color: Colors.blue),
                    SizedBox(height: 20),
                    Text(
                      "I'm your weather bot, get all your weather queries solved",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type your city name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0), // Rounded corners
                        ),
                        prefixIcon: Icon(Icons.android), // Bot icon before the text field
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Colors.blue, // Send button color
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
