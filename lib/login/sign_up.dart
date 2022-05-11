import 'package:chat_app/navigate_pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String? name, number, userid;
  String _key = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final databaseRef = FirebaseDatabase.instance.reference();
  final _prefs = SharedPreferences.getInstance();
  TextEditingController numController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  AuthCredential? _credential;
  dynamic smsCode;

  Future registerUser(String mobile, String name, BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.verifyPhoneNumber(
        phoneNumber: numController.text,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          _auth.signInWithCredential(_credential!).then((result) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          userNum: numController.text,
                          userName: nameController.text,
                        )));
          }).catchError((e) {
            print(e);
          });
        },
        verificationFailed: (FirebaseAuthException authException) {
          print(authException.message);
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          //show dialog to take input from the user
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: const Text("Enter SMS Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          controller: codeController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                          onPressed: () {
                            FirebaseAuth auth = FirebaseAuth.instance;
                            smsCode = codeController.text.trim();
                            _credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
                            auth.signInWithCredential(_credential!).then((result) async {
                              final prefs = await _prefs;
                              prefs.setString('isSignUp', numController.text);
                              prefs.setString('userName', nameController.text);
                              addDataInFirebase();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage(
                                            userNum: number.toString(),
                                            userName: name,
                                          )));
                            });
                          },
                          child: const Text('Done'))
                    ],
                  ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          print(verificationId);
          print("Timeout");
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.lightBlue,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                ),
                elevation: 20,
                child: Container(
                    height: MediaQuery.of(context).size.height * 0.38,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.cyanAccent,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                    ),
                    child: const Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, bottom: 20),
                          child: Text(
                            'SignUp',
                            style: TextStyle(fontFamily: 'Comfort', fontSize: 60),
                          ),
                        ))),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white70,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextFormField(
                      controller: numController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        label: Text('Enter Your Number'),
                      ),
                      onChanged: (value) {
                        number = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Your Number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white70,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        label: Text('Enter Your Name'),
                      ),
                      onChanged: (value) {
                        name = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter Your Name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.cyanAccent, minimumSize: const Size(90, 50)),
                  onPressed: () async {
                    final mobile = numController.text.trim();
                    final name = nameController.text.trim();
                    registerUser(mobile, name, context);
                  },
                  child: const Text(
                    'SignUp',
                    style: TextStyle(fontFamily: 'Comfort', color: Colors.black, fontSize: 25),
                  )),
            ],
          ),
        ),
      ),
    ));
  }

  void addData() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    databaseRef.child("Users").push().set({'name': nameController.text, 'number': numController.text, 'userId': _auth.currentUser!.uid});
  }

  void update() {
    databaseRef.child("Users").child(_key).update({'name': nameController.text});
  }

  addDataInFirebase() {
    List<bool> isAdded = [];

    databaseRef.child("Users").once().then((event) {
      dynamic data = event.value;
      data.forEach((key, value) {
        print(value['number']);
        if (numController.text == value['number']) {
          _key = key;
          isAdded.add(true);
        } else {
          isAdded.add(false);
        }
      });

      print(" ISS ADDED : ${isAdded.any((element) => element == true)}");
      if (isAdded.any((element) => element == true)) {
        update();
      } else {
        addData();
      }
    });
  }
}
