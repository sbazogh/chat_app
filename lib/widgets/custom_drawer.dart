import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class CustomDrawer extends StatelessWidget {

  final FirebaseAuth auth;

  const CustomDrawer({Key? key, required this.auth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: kLightBlue,
                  ),
                  child: Center(child: Text(auth.currentUser!.email ?? 'Not signed in')),
                ),
              ),
            ],
          ),
          ListTile(
            title: const Text(
              'Global Chat',
            ),
            trailing: const Icon(Icons.message),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Sign Out',
            ),
            trailing: const Icon(Icons.exit_to_app),
            onTap: () {
              auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
    );
  }
}
