import 'package:chat_app/login/sign_up.dart';
import 'package:chat_app/widget/app_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required String userNum, required String userName}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

List<HomeListModel> contactList = [];

class _HomePageState extends State<HomePage> {
  final databaseRef = FirebaseDatabase.instance.reference();
  final _prefs = SharedPreferences.getInstance();
  dynamic user1, user2, chatKey;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.teal,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'WhatsApp',
            style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Comfort'),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                final prefs = await _prefs;
                prefs.remove('isSignUp');
                contactList = [];
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp()));
              },
              icon: const Icon(Icons.follow_the_signs)),
          PopupMenuButton(
              itemBuilder: (context) => [
                    const PopupMenuItem(
                        child: AppText(
                      data: 'New Group',
                    )),
                    const PopupMenuItem(
                        child: AppText(
                      data: 'New broadcast',
                    )),
                    const PopupMenuItem(
                        child: AppText(
                      data: 'Linked devices',
                    )),
                    const PopupMenuItem(
                        child: AppText(
                      data: 'Starred messages',
                    )),
                    const PopupMenuItem(
                        child: AppText(
                      data: 'Payments',
                    )),
                    const PopupMenuItem(
                        child: AppText(
                      data: 'Settings',
                    )),
                  ]),
        ],
      ),
      body: ListView.builder(
          itemCount: contactList.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              hoverColor: Colors.black12,
              onTap: () async {
                final prefs = await _prefs;
                String? userNumber = prefs.getString('isSignUp');
                databaseRef.child('Users').once().then((event) {
                  dynamic data = event.value;
                  data.forEach((key, value) {
                    if (userNumber == value['number']) {
                      user1 = value['userId'];
                    } else if (contactList.elementAt(index).contactNo == value['number']) {
                      user2 = value['userId'];
                    }
                  });
                });
                await createChatRoom();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatPage(
                              user1: user1,
                              chatKey: chatKey,
                              user: contactList.elementAt(index).name!,
                            )));
              },
              title: Text(contactList.elementAt(index).name!),
              subtitle: Text(contactList.elementAt(index).contactNo!),
            );
          }),
    ));
  }

  void getData() {
    databaseRef.child('Users').once().then((DataSnapshot snapshot) async {
      final _prefs = SharedPreferences.getInstance();
      final prefs = await _prefs;
      final num = prefs.getString('isSignUp');
      dynamic data = snapshot.value;
      data.forEach((key, value) {
        if (value['number'] != num) {
          contactList.add(HomeListModel(name: value['name'], contactNo: value['number']));
          setState(() {});
        }
      });
    });
  }

  createChatRoom() async {
    List<bool> isAdded = [];
    await databaseRef.child('chatRoom').once().then((event) {
      dynamic data = event.value;
      if (data != null) {
        data.forEach((key, value) {
          if ((value['user1'] == user1 && value['user2'] == user2) || (value['user1'] == user2 && value['user2'] == user1)) {
            chatKey = key;
            isAdded.add(true);
          } else {
            isAdded.add(false);
          }
        });
      } else {
        databaseRef.child('chatRoom').push().set({'user1': user1, 'user2': user2});
        databaseRef.child('chatRoom').once().then((value) {
          value.value.forEach((key, value) {
            chatKey = key;
            setState(() {});
          });
        });
      }
      if (!isAdded.any((element) => element == true) && data != null) {
        databaseRef.child('chatRoom').push().set({'user1': user1, 'user2': user2});
      }
    });
  }
}

class HomeListModel {
  String? name;
  String? contactNo;

  HomeListModel({this.name, this.contactNo});
}
