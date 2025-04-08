// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main.dart'; // Import HomePage widget
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key}); // Pass 'key' directly to super

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isRegistering = false; // Toggle between login and registration

  @override
  void initState() {
    super.initState();
    // Initialize Firebase
    Firebase.initializeApp();
    // Check if the user is already logged in
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      // Ensure the widget is still mounted before performing any navigation
      if (!mounted) return;

      if (user != null) {
        // If the user is logged in, navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  // Function for Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        // Navigate to HomePage after successful Google login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      // Handle errors (e.g. show a snack bar with the error message)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google login failed: $e')));
    }
  }

  // Function for Phone Number Sign-In
  Future<void> _signInWithPhone() async {
    // Get phone number from user
    String phoneNumber = await _showPhoneNumberDialog();
    if (phoneNumber.isNotEmpty) {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed: ${e.message}')));
        },
        codeSent: (String verificationId, int? resendToken) async {
          String smsCode = await _showSmsCodeDialog();
          if (smsCode.isNotEmpty) {
            PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId, smsCode: smsCode);
            await FirebaseAuth.instance.signInWithCredential(credential);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  // Show a dialog to enter phone number
  Future<String> _showPhoneNumberDialog() async {
    TextEditingController phoneController = TextEditingController();
    String phoneNumber = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter your phone number'),
          content: TextField(
            controller: phoneController,
            decoration: const InputDecoration(hintText: '+1 234 567 890'),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () {
                phoneNumber = phoneController.text;
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return phoneNumber;
  }

  // Show a dialog to enter SMS code
  Future<String> _showSmsCodeDialog() async {
    TextEditingController smsController = TextEditingController();
    String smsCode = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter the SMS code'),
          content: TextField(
            controller: smsController,
            decoration: const InputDecoration(hintText: 'SMS Code'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                smsCode = smsController.text;
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return smsCode;
  }

  void _submit() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    try {
      if (isRegistering) {
        // Registration logic
        String name = nameController.text.trim();

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful! Welcome $name')),
          );
        }

        // Redirect to home page after successful registration
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        // Login logic
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful! Welcome $email')),
          );
        }

        // Redirect to home page after successful login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = '';

      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use.';
      } else {
        message = 'Failed: ${e.message}';
      }

      // Ensure widget is still mounted before showing the error
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login/Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (isRegistering) ...[
              // Registration Form
              _buildTextField(nameController, 'Name'),
              const SizedBox(height: 10),
            ],
            _buildTextField(emailController, 'Email',
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _buildTextField(passwordController, 'Password', obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isRegistering ? 'Register' : 'Login'),
            ),
            const SizedBox(height: 20),
            // Toggle between login and registration mode
            TextButton(
              onPressed: () {
                setState(() {
                  isRegistering = !isRegistering; // Toggle mode
                });
              },
              child: Text(isRegistering
                  ? 'Already have an account? Login'
                  : 'New user? Register here'),
            ),
            const SizedBox(height: 20),
            // Google Sign-In Button
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: const Text('Continue with Google'),
            ),
            const SizedBox(height: 20),
            // Phone Sign-In Button
            ElevatedButton(
              onPressed: _signInWithPhone,
              child: const Text('Continue with Phone Number'),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable TextField widget
  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  PhoneAuthScreenState createState() => PhoneAuthScreenState();
}

class PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _signInWithPhoneNumber() async {
    try {
      String phoneNumber = _phoneController.text.trim();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          Fluttertoast.showToast(msg: "Phone number verified and signed in!");
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(
              msg: "Phone authentication failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          // Show dialog for OTP input
          showDialog(
            context: context,
            builder: (context) => OTPDialog(verificationId),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phone Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            ElevatedButton(
              onPressed: _signInWithPhoneNumber,
              child: Text("Verify Phone Number"),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPDialog extends StatefulWidget {
  final String verificationId;
  const OTPDialog(this.verificationId, {super.key});

  @override
  OTPDialogState createState() => OTPDialogState();
}

class OTPDialogState extends State<OTPDialog> {
  final TextEditingController _otpController = TextEditingController();

  Future<void> _verifyOTP() async {
    try {
      String smsCode = _otpController.text.trim();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Fluttertoast.showToast(msg: "Phone number verified successfully!");
      Navigator.pop(context); // Close OTP dialog
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid OTP or error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Enter OTP"),
      content: TextField(
        controller: _otpController,
        decoration: InputDecoration(labelText: "OTP"),
        keyboardType: TextInputType.number,
      ),
      actions: [
        TextButton(
          onPressed: _verifyOTP,
          child: Text("Verify OTP"),
        ),
      ],
    );
  }
}
