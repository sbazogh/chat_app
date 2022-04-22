import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:chat_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/widgets/chat_message_dialog.dart';

class ChatRoom extends StatefulWidget {

  final String currentId, combinId;
  final Map contact;

  ChatRoom({required this.currentId, required this.contact, required this.combinId,});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();


  bool isEditing = false;
  String updatingMessage = '';
  String updatingMessageID = '';

  late String currentId, combinId;
  late Map contact;


  @override
  void initState() {
    super.initState();
    currentId = widget.currentId;
    combinId = widget.combinId;
    contact = widget.contact;
  }

  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kMainBlue,
          actions: [
            IconButton(
              icon: const Icon( Icons.close_outlined),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
          title: Text(contact['displayName']),
        ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: fireStore.collection('privateMessage')
                    .doc(combinId)
                    .collection(combinId)
                    .orderBy('date', descending: true)
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      shrinkWrap: true,
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
    newMap['users'] = [currentId, contact['userId']];
    // edit
    if (isEditing == true) {
      DocumentReference doc = fireStore.collection('privateMessage')
          .doc(combinId)
          .collection(combinId).doc(updatingMessageID);
      doc.update({
        'text': text,
      });
    } // add
    else {
      newMap['sender'] = auth.currentUser!.uid;
      newMap['email'] = auth.currentUser!.email;
      fireStore.collection('privateMessage')
          .doc(combinId)
          .collection(combinId).add(newMap).then((value) {
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
    fireStore.collection('privateMessage')
        .doc(combinId)
        .collection(combinId).doc(id).delete();
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