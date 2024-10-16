import 'package:flutter/material.dart';
import 'auth_methods.dart';
import 'signup_screen.dart';  // Import the signup screen
import 'home_screen.dart';    // Import your home screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  String errorMessage = '';
  bool _obscurePassword = true; // To toggle password visibility

  void showError(String error) {
    setState(() {
      errorMessage = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            // White background for the whole screen
            Container(
              color: Colors.white,
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50), // Spacer for centering content

                    // Log In Here Text
                    Text(
                      'LogIn Here',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Error Message
                    if (errorMessage.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.redAccent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: TextStyle(color: Colors.white),
                                maxLines: 3,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16),

                    // Email Input Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0), // Rounded corners
                          borderSide: BorderSide(color: Colors.black),  // Black border
                        ),
                        filled: true,
                        fillColor: Colors.transparent, // Transparent background
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.black),  // Black border for inactive
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.black),  // Black border for active
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Password Input Field
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword, // Toggle password visibility
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0), // Rounded corners
                          borderSide: BorderSide(color: Colors.black),  // Black border
                        ),
                        filled: true,
                        fillColor: Colors.transparent, // Transparent background
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword; // Toggle the visibility
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Login Button
                    ElevatedButton(
                      onPressed: () async {
                        final error = await _authMethods.signInWithEmailAndPassword(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                        if (error != null) {
                          showError(error);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                          );
                        }
                      },
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF72BCF1), // Button color
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(),

                    // Google Login Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await _authMethods.signInWithGoogle();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                          );
                        } catch (e) {
                          showError('Google sign-in failed: $e');
                        }
                      },
                      icon: Image.asset(
                        'images/gimg.png', // Replace with your Google logo asset path
                        height: 24.0,
                      ),
                      label: Text('Continue with Google'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,// Text color
                      ),
                    ),
                    SizedBox(height: 16),

                    // Sign Up Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                          child: Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
