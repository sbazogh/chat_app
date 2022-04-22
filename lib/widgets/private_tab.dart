import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screens/chat_room_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class PrivateChat extends StatefulWidget {
  const PrivateChat({Key? key}) : super(key: key);

  @override
  State<PrivateChat> createState() => _PrivateChatState();
}

class _PrivateChatState extends State<PrivateChat> {

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  late User currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await auth.currentUser!;
      if (user != null) {
        currentUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: StreamBuilder(
              stream: fireStore.collection('Users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.map(
                          (doc) {
                        Map data = doc.data() as Map;
                        return GestureDetector(
                          onTap: () {
                            createConversation(data);
                          },
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(data['displayName'] ?? ''),
                                leading: const CircleAvatar(
                                  radius: 20,
                                  // backgroundColor: kLightBlue,
                                  child: Image(
                                    image: AssetImage('assets/images/avatar5.png',),
                                    // fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const Divider(),
                            ],
                          ),

                        );
                      },
                    ).toList(),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  void createConversation(Map data) {
    String currentId = auth.currentUser!.uid;
    String combinId = getCombinID(currentId, data['userId']);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ChatRoom(
            currentId: currentId, contact: data, combinId: combinId),));
  }

  String getCombinID(String uid, String pid) {
    return uid.hashCode <= pid.hashCode ? uid + '_' + pid : pid + '_' + uid;
  }

}
