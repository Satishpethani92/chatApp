import 'package:chat_app/login/sign_up.dart';
import 'package:chat_app/navigate_pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SScreen(),
  ));
}

class SScreen extends StatefulWidget {
  const SScreen({Key? key}) : super(key: key);

  @override
  State<SScreen> createState() => _SScreenState();
}

class _SScreenState extends State<SScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () async {
      final _prefs = SharedPreferences.getInstance();
      final prefs = await _prefs;
      final sign = prefs.getString('isSignUp');
      final userName = prefs.getString('userName');
      if (sign == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignUp()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(userNum: sign, userName: userName!)));
      }
      super.initState();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width * 0.15,
          color: Colors.white,
          child: Image.asset('assets/images/whatsapp.png'),
        ),
      ),
    ));
  }
}
