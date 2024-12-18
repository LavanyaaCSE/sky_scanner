import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'weather_service.dart';
import 'location_service.dart';
import 'auth_methods.dart';
import 'login_screen.dart';
import 'weatherbot_screen.dart';
import 'image_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();
  String location = 'Fetching location...';
  double? temperature;
  double? windSpeed;
  bool isLoading = true;
  String errorMessage = '';
  File? _image;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(); // Fetch weather data when the screen loads
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      Position? position = await _locationService.getCurrentLocation(); // Get current location

      if (position != null) {
        final weatherData = await _weatherService.fetchWeather(position.latitude, position.longitude); // Fetch weather data

        if (weatherData != null) {
          setState(() {
            location = 'Lat: ${position.latitude}, Lon: ${position.longitude}'; // Update with actual location
            temperature = weatherData['current_weather']['temperature']; // Extracted temperature
            windSpeed = weatherData['current_weather']['windspeed']; // Extracted wind speed
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Unable to fetch weather data';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Unable to determine location';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  String _getBackgroundImage() {
    if (temperature == null) {
      return 'assets/bg_mild.jpg'; // Default background
    } else if (temperature! < 0) {
      return 'images/bg_cold.png';
    } else if (temperature! >= 0 && temperature! <= 24) {
      return 'images/bg_cool.png';
    } else if (temperature! >= 25 && temperature! <= 30) {
      return 'images/bg_mild.png';
    } else if (temperature! >= 32 && temperature! <= 35) {
      return 'images/bg_warm.png';
    } else {
      return 'images/bg_hot.png';
    }
  }

  Color _getButtonBackgroundColor() {
    if (temperature == null) {
      return Colors.grey; // Default color for neutral
    } else if (temperature! < 0) {
      return Color(0xFFB7DDE4); // Cold Weather
    } else if (temperature! >= 0 && temperature! <= 24) {
      return Color(0xFF88B2E3); // Cool Weather
    } else if (temperature! >= 25 && temperature! <= 30) {
      return Color(0xFFBEE6CE); // Mild Weather
    } else if (temperature! >= 32 && temperature! <= 35) {
      return Color(0xFFFFE59E); // Warm Weather
    } else {
      return Color(0xFFFCB59C); // Hot Weather
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(
            imagePath: pickedFile.path,
            weatherType: 'Altocumulus', // Default weather type
            cloudType: 'Altocumulus', // Default cloud type
            next8HoursWeather: 'Clear skies, Temperature: 26°C, Wind Speed: 5 km/h', // Default next 8 hours weather
          ),
        ),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthMethods().signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  void _showAccountInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Email: ${FirebaseAuth.instance.currentUser?.email ?? "N/A"}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Username: ${FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? "N/A"}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('Help'),
              onTap: () {
                Navigator.pop(context);
                print('Help selected');
              },
            ),
            ListTile(
              leading: Icon(Icons.miscellaneous_services_outlined),
              title: Text('Services'),
              onTap: () {
                Navigator.pop(context);
                print('Services selected');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sign Out'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Sky Scanner',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          centerTitle: true,
          toolbarHeight: 80.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.account_circle, color: Colors.black, size: 32),
            onPressed: _showAccountInfo,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.chat, color: Colors.black, size: 32),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherChatbot()),
                );
              },
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_getBackgroundImage()),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100), // Adjust the height to ensure content is below AppBar
                  temperature != null
                      ? Column(
                    children: [
                      Text(
                        'Temperature:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${temperature!.toStringAsFixed(1)} °C',
                        style: TextStyle(
                          fontSize: 62,
                          color: Colors.black,
                          fontFamily: 'Ribeye',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    'Temperature: N/A',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Ribeye',
                      fontSize: 34,
                    ),
                  ),
                  SizedBox(height: 10),
                  windSpeed != null
                      ? Column(
                    children: [
                      Text(
                        'Wind Speed:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${windSpeed!.toStringAsFixed(1)} km/h',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontFamily: 'Ribeye',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    'Wind Speed: N/A',
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Ribeye',
                      fontSize: 34,
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _image != null
                        ? Image.file(_image!)
                        : Text(
                      'No image selected.',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonBackgroundColor(),
                        ),
                        onPressed: () => _pickImage(ImageSource.camera),
                        child: Text(
                          'Capture Image',
                          style: TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonBackgroundColor(),
                        ),
                        onPressed: () => _pickImage(ImageSource.gallery),
                        child: Text(
                          'Select Image',
                          style: TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // New section explaining the app
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How the App Works:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Click "Capture Image" to take a new photo.\n'
                              '2. Click "Select Image" to choose an existing photo from your device.\n'
                              '3. The app analyzes the weather conditions based on your location and the selected image.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'How the AI Works:',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Our AI model uses advanced algorithms to analyze the weather data and provide insights.\n'
                              'It takes into consideration various factors such as temperature, wind speed, and environmental conditions to deliver accurate results.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}