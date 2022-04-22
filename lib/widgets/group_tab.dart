import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:chat_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/chat_message_dialog.dart';

class GroupsChat extends StatefulWidget {
  const GroupsChat({Key? key}) : super(key: key);

  @override
  _GroupsChatState createState() => _GroupsChatState();
}

class _GroupsChatState extends State<GroupsChat> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference messageRef =
     FirebaseFirestore.instance.collection('Messages');
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  bool isEditing = false;
  String updatingMessage = '';
  String updatingMessageID = '';

  @override
  void initState() {
    super.initState();
  }

  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: StreamBuilder(
                stream: messageRef
                    .orderBy('date', descending: true)
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      reverse: true,
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: snapshot.data!.docs.map(
                            (doc) {
                          String id = doc.id;
                          Map data = doc.data() as Map;
                          bool isMe = data['sender'] == auth.currentUser!.uid;
                          return GestureDetector(
                            onTap: () {
                              onMessageTapped(data, id);
                            },
                            child: Bubble(
                              margin: BubbleEdges.only(
                                  top: 10,
                                  left: isMe ? 10 : 0,
                                  right: !isMe ? 10 : 0),
                              nip: (isMe)
                                  ? BubbleNip.rightTop
                                  : BubbleNip.leftTop,
                              color: (isMe)
                                  ? const Color.fromRGBO(225, 255, 199, 1)
                                  : Colors.white,
                              alignment: (isMe)
                                  ? Alignment.topRight
                                  : Alignment.topLeft,
                              child: Column(
                                children: [
                                  Text(
                                    data['email'],
                                    style: const TextStyle(
                                      fontSize: 9.0,
                                      color: kMainBlue,

                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(data['text']),
                                ],
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    );
                  } //
                  else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            // padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18,),
                  child: Visibility(
                    visible: isEditing,
                    child: Container(
                      width: size.width - 65,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 3),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(225, 255, 199, 1),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(4),
                          topLeft: Radius.circular(4),
                        ),
                      ),
                      child: Text(updatingMessage),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 15, right: 5),
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                          child: TextField(
                            minLines: 1,
                            maxLines: 5,
                            onTap: () {
                              Timer(
                                const Duration(milliseconds: 300),
                                    () {
                                  scrollController.jumpTo(scrollController.position.minScrollExtent);
                                },
                              );
                            },
                            controller: controller,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              hintText: 'Write your message...',
                            ),
                          )
                        ),
                      ),
                      IconButton(
                          onPressed: sendMessage,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: kMainBlue, size: 35,
                          ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    String text = controller.text;
    if (text.length <= 2) {
      return;
    }

    Map<String, dynamic> newMap = Map();
    newMap['text'] = text;
    String dateTime = DateTime.now().toString();
    String date = dateTime.substring(0, 10);
    String time = dateTime.substring(11, 19);
    newMap['time'] = time;
    newMap['date'] = date;
    // edit
    if (isEditing == true) {
      DocumentReference doc = messageRef.doc(updatingMessageID);
      doc.update({
        'text': text,
      });
    } // add
    else {
      newMap['sender'] = auth.currentUser!.uid;
      newMap['email'] = auth.currentUser!.email;
      messageRef.add(newMap).then((value) {
        print(value);
      });
    }
    resetValues();
  }

  onMessageTapped(Map data, String id) {
    showDialog(
      builder: (BuildContext context) {
        return ChatDialog(
          onDelete: () {
            onDelete(data, id);
          },
          onEdit: () {
            onEdit(data, id);
          },
        );
      },
      context: context,
    );
  }

  onDelete(Map data, String id) async {
    messageRef.doc(id).delete();
    Navigator.pop(context);
  }

  onEdit(Map data, String id) async {

    setState(() {
      isEditing = true;
      updatingMessage = data['text'];
      controller.text = data['text'];
      updatingMessageID = id;
    });
    Navigator.pop(context);
  }

  resetValues() {
    controller.clear();
    setState(() {
      updatingMessageID = '';
      updatingMessage = '';
      isEditing = false;
    });
  }
}
