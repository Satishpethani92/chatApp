import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import '../widget/message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, this.user, this.chatKey, this.user1}) : super(key: key);
  final String? user, chatKey, user1;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final databaseRef = FirebaseDatabase.instance.reference();
  final textController = TextEditingController();
  List<MessageData> messageList = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getDataFromFirebase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(widget.user!),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {});
              },
              icon: const Icon(Icons.refresh)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: messageList.length,
                itemBuilder: (context, index) {
                  return ChatBubble(
                    time: messageList[index].time!,
                    text: messageList[index].message!,
                    isCurrentUser: messageList[index].sender!,
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.black12),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: TextField(
                        controller: textController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  child: IconButton(
                    onPressed: () async {
                      var nowTime = DateTime.now();
                      String time = DateFormat('kk:mm a').format(nowTime);
                      if (textController.text.isNotEmpty) {
                        databaseRef
                            .child('chatRoom')
                            .child(widget.chatKey!)
                            .child('Message')
                            .push()
                            .set({'content': textController.text, 'time': time, 'sender': widget.user1});
                      }
                      textController.clear();
                      getDataFromFirebase();
                      SchedulerBinding.instance?.addPostFrameCallback((_) {
                        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
                      });
                      setState(() {});
                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  getDataFromFirebase() {
    databaseRef.child('chatRoom').child(widget.chatKey!).child('Message').onValue.listen((event) {
      dynamic data = event.snapshot.value;
      messageList.clear();
      if (data != null) {
        data.forEach((key, value) {
          messageList.add(MessageData(message: value['content'], sender: value['sender'] == widget.user1, time: value['time']));
          SchedulerBinding.instance?.addPostFrameCallback((_) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
          });
          setState(() {});
        });
      }
    });
  }
}

class MessageData {
  String? time;
  String? message;
  bool? sender;

  MessageData({this.time, this.message, this.sender});
}
