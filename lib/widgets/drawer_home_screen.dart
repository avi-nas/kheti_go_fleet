import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/fleetadmin.dart';
import '../provider/auth_provider.dart';
import '../screens/login_screen.dart';
import 'small_widgets.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  var fireAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 50,
      child: Column(
        children: [
          Container(
            color: Colors.green,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: Icon(Icons.person,
                  ),
                ),
                const SizedBox(height: 20,),
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('FleetAdmin')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Something went wrong");
                    }
                    if (snapshot.hasData && !snapshot.data!.exists) {
                      return const Text("Document does not exist");
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data =
                      snapshot.data!.data() as Map<String, dynamic>;
                      var fleetAdmin = FleetAdmin.fromJson(data);
                      return Column(
                        children: [
                          Text(
                            "${fleetAdmin.name}",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                wordSpacing: 5,
                                letterSpacing: 2
                            ),
                          ),
                          Text('${fleetAdmin.phoneNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              wordSpacing: 1,
                            ),
                          ),
                          Text('${fleetAdmin.emailID}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              wordSpacing: 1,
                            ),
                          )
                        ],
                      );
                    }
                    return const CustomLoading();
                  },
                ),
              ],
            ),
          ),
          ListTile(
              onTap: (){},
              leading: const Icon(Icons.person_2_rounded),
              title: const Text('My Profile')
          ),
          ListTile(
            onTap: (){},
            leading: const Icon(Icons.dashboard_customize_outlined),
            title: const Text('Payments'),
          ),
          ListTile(
              onTap: (){},
              leading: const Icon(Icons.car_repair),
              title: const Text('My Vehicle')
          ),
          ListTile(
              onTap: () async {
                await fireAuth.signOut();
                await AppAuthProvider.setCurrentUser('');
                if (context.mounted) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ));
                }
              },
              leading: const Icon(Icons.logout),
              title: const Text('Logout')
          ),
        ],
      ),
    );
  }
}
