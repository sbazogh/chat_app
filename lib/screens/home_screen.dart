import 'package:chat_app/constants.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/widgets/custom_drawer.dart';
import 'package:chat_app/widgets/group_tab.dart';
import 'package:chat_app/widgets/private_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {

  late TabController tabController;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(auth: auth),
      appBar: AppBar(
        backgroundColor: kMainBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app_outlined),
            onPressed: () {
                auth.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
            },
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Group',),
            Tab(text: 'Users'),
          ],
        ),
        title: const Text('Home'),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          const GroupsChat(),
          PrivateChat(),
        ],
      ),

    );
  }
}
