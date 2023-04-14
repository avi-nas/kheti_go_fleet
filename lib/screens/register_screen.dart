import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/custom_widgets.dart';
import 'package:kheti_go_fleet/firebase_operation/handle_user_data.dart';
import 'package:kheti_go_fleet/models/fleetadmin.dart';
import 'package:kheti_go_fleet/screens/home_screen.dart';
import 'package:geolocator/geolocator.dart';
class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    _locationController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }


  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 203, 66, 1.0),
      appBar: AppBar(
        title: const Text("Kheti Go - Fleet Registration"),
        backgroundColor: Colors.lightGreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.person),
                        hintText: 'Enter name of your brand',
                        labelText: 'Name',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.email),
                        hintText: 'Enter your email',
                        labelText: 'Email ID',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (!value!.contains('@')) {
                          return 'Please valid email Id';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 50,
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.phone),
                        hintText: 'Enter your phone number',
                        labelText: 'Phone Number',
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: ()async{
                       await getLatLong();
                       storeLocationInFirebase();
                      },
                      child: const Text("Get Location"),
                      style: ElevatedButton.styleFrom(
                       ),),
                    const SizedBox(
                      height: 50,
                    ),
                    // CloseButton(color: Colors.red, onPressed: exit(0),)
                    CustomButton(
                      text: 'Register',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          FleetAdmin fa = FleetAdmin(
                              name: _nameController.text,
                              emailID: _emailController.text,
                              location: _locationController.text,
                              phoneNumber: FirebaseAuth
                                  .instance.currentUser?.phoneNumber);
                          await HandleUserData.createNewUser(fa.toJson());
                          gotoNextScreen(HomeScreen(), context);
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),


    );
  }
  double? lat;

  double? long;

  String address = "";

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
  getLatLong() {
    Future<Position> data = _determinePosition();
    data.then((value) {
      print("value $value");
      setState(() {
        lat = value.latitude;
        long = value.longitude;
      });

      getAddress(value.latitude, value.longitude);
    }).catchError((error) {
      print("Error $error");
    });
  }
  getAddress(lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    setState(() {
      address = placemarks[0].street! + " " + placemarks[0].country!;
    });

    for (int i = 0; i < placemarks.length; i++) {
      print("INDEX $i ${placemarks[i]}");
    }
  }
  storeLocationInFirebase(){
    GeoPoint geoPoint=GeoPoint(lat! ,  long!);
    final  Map<String,dynamic > data={
      'location': geoPoint
    };
    FirebaseFirestore.instance.collection('FleetLoaction').doc(FirebaseAuth.instance.currentUser?.uid).set(data);

  }

}

