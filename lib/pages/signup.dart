import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sign_in.dart'; // For navigating to SignInPage

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController phoneOtpController = TextEditingController();

  String? _verificationId;
  bool phoneOtpSent = false;
  bool emailVerificationSent = false;

  Future<void> signUp(BuildContext context) async {
    try {
      // Firebase Authentication Sign-Up
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Send phone OTP
      await sendPhoneOtp();

      // Send email verification
      await sendEmailVerification(userCredential.user);

      // Saving additional data (name, mobile) to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'email': emailController.text.trim(),
      });

    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
    }
  }

  // Send Phone OTP
  Future<void> sendPhoneOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: mobileController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto sign-in if verification is successful
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Phone verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          phoneOtpSent = true;
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  // Verify Phone OTP
  Future<void> verifyPhoneOtp() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: phoneOtpController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      print('Phone OTP verified successfully!');
    } catch (e) {
      print('Error verifying phone OTP: $e');
    }
  }

  // Send Email Verification
  Future<void> sendEmailVerification(User? user) async {
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      setState(() {
        emailVerificationSent = true;
      });
    }
  }

  // Check if Email is Verified
  Future<void> verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // reload to get the latest email verification status
      if (user.emailVerified) {
        print('Email verified successfully!');
        // Email is verified, proceed
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } else {
        print('Please verify your email first.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => signUp(context),
                child: const Text('Sign Up',style: TextStyle(color: Colors.black),),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  backgroundColor: Colors.blue.shade300,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              // Phone OTP Section
              if (phoneOtpSent) ...[
                const SizedBox(height: 20),
                const Text('Enter Phone OTP', style: TextStyle(fontSize: 16)),
                TextField(
                  controller: phoneOtpController,
                  decoration: const InputDecoration(
                    labelText: 'Phone OTP',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => verifyPhoneOtp(),
                  child: const Text('Verify Phone OTP'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],

              // Email Verification Section
              if (emailVerificationSent) ...[
                const SizedBox(height: 20),
                const Text('Verify your email by clicking the link sent to your email.', style: TextStyle(fontSize: 16)),
                ElevatedButton(
                  onPressed: () => verifyEmail(),
                  
                  child: const Text('I have verified my email',style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 20),
                    backgroundColor: Colors.blue.shade300,
                  ),
                ),
              ],

              // Navigate to Sign In
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                },
                child: const Text('Already have an account? Sign In', style: TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
