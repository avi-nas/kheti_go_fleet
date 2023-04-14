import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kheti_go_fleet/screens/login_screen.dart';
import 'package:kheti_go_fleet/provider/auth_provider.dart';
import 'package:kheti_go_fleet/screens/home_screen.dart';
import 'package:kheti_go_fleet/screens/register_screen.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  bool loggedIn = await AppAuthProvider.getLoginStatus();
  print('Current user = ${FirebaseAuth.instance.currentUser?.uid}');

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: loggedIn?const HomeScreen(): LoginScreen(),
  ),);
}
