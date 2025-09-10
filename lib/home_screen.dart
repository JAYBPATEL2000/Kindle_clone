import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user logged in')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('UID: ${user.uid}'),
                  Text('Email: ${user.email ?? "No email"}'),
                  Text('Name: ${user.displayName ?? "No name"}'),
                ],
              ),
      ),
    );
  }
}
