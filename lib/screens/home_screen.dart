import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kheti_go_fleet/screens/login_screen.dart';

import '../models/farmer.dart';
import '../models/farmer_request.dart';
import '../provider/auth_provider.dart';
import '../widgets/show_request_info.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Position userPosition;
  @override
  void initState() {
    // TODO: implement initState
    getUserCurrentLocation();

    setState(() {
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KhetiGo - Fleet Management'),
      ),
      drawer: Drawer(
        child: Center(
          child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await AppAuthProvider.setCurrentUser('');
                if (context.mounted) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ));
                }
              },
              child: const Text('logout')),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.amber, Colors.greenAccent, Colors.green],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Center(
            child: StreamBuilder(
              stream: readRequest(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<FarmerRequest> request = snapshot.data!;
                  return ListView(
                    children: request.map(buildRequest).toList(),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRequest(FarmerRequest farmerRequest) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Farmers')
          .doc(farmerRequest.uid)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          var farmer = Farmer.fromJson(data);
          return Card(
            color: Colors.white70,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${farmer.farmerName}",
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          wordSpacing: 5,
                          letterSpacing: 2),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return RequestInfo(
                                  userPosition: userPosition,
                                  farmerRequest: farmerRequest,
                                );
                              },
                            );
                          },
                          child: const Text('View'),
                        ),
                        const SizedBox(width: 5,),
                        IconButton(
                          color: Colors.green,
                          onPressed: () {},
                          icon: const Icon(Icons.done),
                        ),
                        IconButton(
                          color: Colors.red,
                          onPressed: () {},
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    )
                  ]),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );

  }

  tryMe(FarmerRequest farmerRequest) {
    print('${farmerRequest.requestAccepted}');
  }

  Stream readRequest() => FirebaseFirestore.instance
      .collection('FleetAllocationRequest')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('userRequest')
      .snapshots()
      .map((event) => event.docs.map((e) {
            final Map<String, dynamic> newMap = {"uid": e.reference.id};
            final Map<String, dynamic> myMap = e.data();
            myMap.addAll(newMap);
            print('${myMap}');
            return FarmerRequest.fromJson(myMap);
          }).toList());
  getUserCurrentLocation() async{
    await Geolocator.requestPermission().then((value){}).onError((error, stackTrace){
      print(error);
    });
    userPosition = await Geolocator.getCurrentPosition();
    print(userPosition.latitude);
    storeLocationInFirebase();
  }


  storeLocationInFirebase()async{
    GeoPoint geoPoint =  GeoPoint(userPosition.latitude, userPosition.longitude);
    final Map<String, dynamic> data = {
      'location': geoPoint
    };
     await FirebaseFirestore.instance.collection('FleetLoaction').doc(
        FirebaseAuth.instance.currentUser?.uid).set(data).whenComplete(() => print('Location Stored is ${geoPoint.latitude}  ${geoPoint.longitude}'));
  }
}











