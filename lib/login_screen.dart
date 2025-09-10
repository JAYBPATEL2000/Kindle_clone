import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String error = '';

  Future<void> signInWithGoogle() async {
    try {
      setState(() {
        error = '';
      });

      // Initialize Google Sign-In with proper configuration
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in flow
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Validate tokens before proceeding
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        if (!mounted) return;
        setState(() {
          error = 'Google Sign-In failed: Invalid authentication tokens';
        });
        return;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Store user profile in Firestore
      await _storeUserProfile(userCredential.user);

      // Clear error on successful login
      if (!mounted) return;
      setState(() {
        error = '';
      });
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? 'Authentication failed';
      if (!mounted) return;
      setState(() {
        error = 'Google Sign-In failed: $message';
      });
      print('Google Sign-In Firebase Error: $e');
    } catch (e) {
      // Check if this is a non-critical error that doesn't prevent login
      if (e.toString().contains('pigeonuserdetails') ||
          e.toString().contains('List<object> is not a subtype')) {
        // These are known non-critical errors - don't show them to user
        print('Google Sign-In non-critical error (ignored): $e');
        // Still clear the error since login might have succeeded
        if (!mounted) return;
        setState(() {
          error = '';
        });
        return;
      }

      // Only show actual errors that prevent login
      if (!mounted) return;
      setState(() {
        error = 'Google Sign-In failed: ${e.toString()}';
      });
      print('Google Sign-In Error: $e');
    }
  }

  Future<void> signInWithEmail() async {
    print('=== EMAIL LOGIN DEBUG START ===');
    print('Email field: "${emailController.text}"');
    print('Password field: "${passwordController.text}"');

    // Clear error first
    setState(() {
      error = '';
    });

    // Validate inputs first - this should happen before any Firebase calls
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      print('DEBUG: Validation failed - empty fields');
      setState(() {
        error = 'Please enter both email and password';
      });
      print('DEBUG: Error set to: $error');
      return;
    }

    print('DEBUG: Validation passed, proceeding with Firebase auth');

    try {
      print('DEBUG: Calling Firebase signInWithEmailAndPassword...');
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      print('DEBUG: Firebase auth successful');
      await _storeUserProfile(userCredential.user);
      if (!mounted) return;
      setState(() {
        error = '';
      });
      print('DEBUG: Login completed successfully');
    } on FirebaseAuthException catch (e) {
      print('DEBUG: FirebaseAuthException caught: $e');
      final message = e.message ?? 'Authentication failed';
      if (!mounted) return;
      setState(() {
        error = 'Email Sign-In failed: $message';
      });
      print('Email Sign-In Error: $e');
    } catch (e) {
      print('DEBUG: General exception caught: $e');
      print('DEBUG: Exception type: ${e.runtimeType}');
      print('DEBUG: Exception toString: ${e.toString()}');
      if (!mounted) return;

      // Check if this is a non-critical error that doesn't prevent login
      if (e.toString().contains('pigeon') ||
          e.toString().contains('List<object> is not a subtype') ||
          e.toString().contains('dev.flutter.pigeon')) {
        // These are known non-critical errors - don't show them to user
        print('Email Sign-In non-critical error (ignored): $e');
        // Still clear the error since login might have succeeded
        setState(() {
          error = '';
        });
        return;
      }

      // Only show actual errors that prevent login
      setState(() {
        error = 'Email Sign-In failed: ${e.toString()}';
      });
      print('Email Sign-In Unknown Error: $e');
    }
    print('=== EMAIL LOGIN DEBUG END ===');
  }

  Future<void> _storeUserProfile(User? user) async {
    if (user == null) return;

    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await doc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'subscriptionStatus': false,
        'lastSignIn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error storing user profile: $e');
      // Don't throw here as the user is already signed in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: signInWithEmail,
                child: const Text('Login with Email'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: signInWithGoogle,
                icon: const Icon(Icons.login),
                label: const Text('Login with Google'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Don\'t have an account? Sign up'),
            ),
            if (error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
