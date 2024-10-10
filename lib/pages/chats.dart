import 'package:chat_app/pages/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('messages').add({
      'senderUID': currentUser!.uid,
      'content': _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Future<void> _deleteMessage(String messageId) async {
    await FirebaseFirestore.instance.collection('messages').doc(messageId).delete();
  }

  Future<void> _editMessage(String messageId, String newContent) async {
    await FirebaseFirestore.instance.collection('messages').doc(messageId).update({
      'content': newContent,
    });
  }

  Future<void> _showOptionsDialog(BuildContext context, String messageId, String currentContent) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Message Options"),
          content: Text("Choose an option:"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Edit"),
              onPressed: () async {
                String? newContent = await _showEditDialog(context, currentContent);
                if (newContent != null && newContent.trim().isNotEmpty) {
                  await _editMessage(messageId, newContent);
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                await _deleteMessage(messageId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showEditDialog(BuildContext context, String currentContent) async {
    final TextEditingController _editController = TextEditingController(text: currentContent);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Message"),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(hintText: "Enter new message"),
          ),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                Navigator.of(context).pop(_editController.text);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade200,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var messages = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      bool isCurrentUser = message['senderUID'] == currentUser!.uid;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: GestureDetector(
                            onLongPress: isCurrentUser
                                ? () => _showOptionsDialog(context, message.id, message['content'])
                                : null,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                color: isCurrentUser ? Colors.blue[300] : Colors.grey[300],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: isCurrentUser ? Radius.circular(15) : Radius.zero,
                                  bottomRight: isCurrentUser ? Radius.zero : Radius.circular(15),
                                ),
                              ),
                              child: Text(
                                message['content'],
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.grey[200],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Enter your message',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendMessage,
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
