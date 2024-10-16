import 'dart:io';
import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  final String imagePath;
  final String weatherType; // Detected weather type
  final String cloudType; // Cloud type
  final String next8HoursWeather; // Next 8 hours weather conditions

  const ImagePreviewScreen({
    Key? key,
    required this.imagePath,
    required this.weatherType,
    required this.cloudType,
    required this.next8HoursWeather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Preview'),
        centerTitle: true,
        backgroundColor: Colors.white70,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding on left and right
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 30), // Space between AppBar and image
              Image.file(
                File(imagePath),
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              // Displaying the detected weather type
              Text(
                'Detected Weather Type: $weatherType',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Displaying the cloud type description
              Text(
                'Cloud Type: $cloudType\n\n${_getCloudDescription(cloudType)}',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center, // Center align text for better presentation
              ),
              SizedBox(height: 20),
              // Displaying the next 8 hours weather conditions
              Text(
                'Next 8 Hours Weather: $next8HoursWeather',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center, // Center align text for better presentation
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to provide a detailed description of the cloud type
  String _getCloudDescription(String cloudType) {
    switch (cloudType.toLowerCase()) {
      case 'altocumulus':
        return 'Altocumulus clouds are white or gray clouds, often forming a layer of rounded masses or rolls. They usually indicate a change in the weather, often followed by rain or storms.';
      case 'cirrus':
        return 'Cirrus clouds are thin, wispy clouds that are high in the atmosphere. They usually indicate fair weather but can also signal that a change in the weather is coming.';
      case 'cumulonimbus':
        return 'Cumulonimbus clouds are towering clouds associated with thunderstorms and severe weather. They can produce heavy rain, lightning, and even tornadoes.';
    // Add more cases for other cloud types as needed
      default:
        return 'No description available for this cloud type.';
    }
  }
}
