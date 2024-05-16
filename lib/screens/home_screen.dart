import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kheti_go_fleet/widgets/custom_widgets.dart';

import 'package:kheti_go_fleet/widgets/drawer_home_screen.dart';
import '../models/farmer.dart';
import '../models/farmer_request.dart';
import '../widgets/show_request_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Position? userPosition;

  @override
  void initState() {
    // TODO: implement initState
    getUserCurrentLocation();

    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KhetiGo - Fleet Management'),
      ),
      drawer: CustomDrawer(),
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
              // stream: readRequest(),
              stream: FirebaseFirestore.instance
                  .collection("FleetAllocationRequest")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection("userRequest")
              .orderBy("timestamp",descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final requests = snapshot.data!;
                  List<FarmerRequest> request = [];
                  try {
                    for (int i = 0; i < requests.size; i++) {
                      FarmerRequest req =
                          FarmerRequest.fromJson(requests.docs[i].data());
                      request.add(req);
                    }
                  } catch (e) {
                    return Text("Error $e");
                  }
                  if (request.isNotEmpty) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return buildRequest(request[index]);
                      },
                      itemCount: request.length,
                    );
                  } else {
                    return const Text("No Request received");
                  }

                  // return ListView(
                  //   children: request.map(buildRequest).toList(),
                  // );
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
          .doc(farmerRequest.userId)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }
        // if (snapshot.hasData && !snapshot.data!.exists) {
        //   return const Text("Document does not exist");
        // }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          Farmer farmer;
          try {
            farmer = Farmer.fromJson(data);
          } catch (e) {
            return Text("object");
          }
          return Card(
            color: Colors.white70,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "${farmer.farmerName}",
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis
                            // wordSpacing: 5,
                            // letterSpacing: 2
                            ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (userPosition == null) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CircularProgressIndicator(
                                    backgroundColor: Colors.black,
                                  );
                                },
                              );
                            } else {
                              gotoNextScreen(
                                  RequestInfo(
                                    userPosition: userPosition!,
                                    farmerRequest: farmerRequest,
                                  ),
                                  context);

                              // showDialog(
                              //   context: context,
                              //   builder: (BuildContext context) {
                              //     return RequestInfo(
                              //       userPosition: userPosition!,
                              //       farmerRequest: farmerRequest,
                              //     );
                              //   },
                              // );
                            }
                          },
                          child: const Text('View'),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        RequestHandle(farmerRequest)
                      ],
                    )
                  ]),
            ),
          );
        } else {
          return const Card(
            color: Colors.white70,
            child: Padding(
              padding: EdgeInsets.fromLTRB(4, 30, 4, 25),
              child: SizedBox(),
            ),
          );
        }
      },
    );
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

  getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print(error);
    });
    try {
      userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    } catch (e) {
      userPosition = await Geolocator.getLastKnownPosition();
    }
    print(userPosition!.latitude);
    storeLocationInFirebase();
    setState(() {});
  }

  storeLocationInFirebase() async {
    GeoPoint geoPoint =
        GeoPoint(userPosition!.latitude, userPosition!.longitude);
    final Map<String, dynamic> data = {'location': geoPoint};
    await FirebaseFirestore.instance
        .collection('FleetLoaction')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set(data)
        .whenComplete(() => print(
            'Location Stored is ${geoPoint.latitude}  ${geoPoint.longitude}'));
  }

  Widget RequestHandle(FarmerRequest farmerRequest) {
    if (!farmerRequest.requestAccepted! && !farmerRequest.requestRejected!) {
      return Row(
        children: [
          IconButton(
            color: Colors.green,
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('FleetAllocationRequest')
                  .doc(farmerRequest.fleetId)
                  .collection('userRequest')
                  .doc('${farmerRequest.requestId}')
                  .update({"requestAccepted": true});

              await FirebaseFirestore.instance
                  .collection('Farmers')
                  .doc(farmerRequest.userId)
                  .collection('MyBookings')
                  .doc('${farmerRequest.requestId}')
                  .update({"requestAccepted": true});
            },
            icon: const Icon(Icons.done),
          ),
          IconButton(
            color: Colors.red,
            onPressed: () async{
              await FirebaseFirestore.instance
                  .collection('FleetAllocationRequest')
                  .doc(farmerRequest.fleetId)
                  .collection('userRequest')
                  .doc('${farmerRequest.requestId}')
                  .update({"requestRejected": true});

              await FirebaseFirestore.instance
                  .collection('Farmers')
                  .doc(farmerRequest.userId)
                  .collection('MyBookings')
                  .doc('${farmerRequest.requestId}')
                  .update({"requestRejected": true});
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      );
    } else if(farmerRequest.requestAccepted!) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Accepted"),
      );
    }else{
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Rejected"),
      );
    }
  }
}
