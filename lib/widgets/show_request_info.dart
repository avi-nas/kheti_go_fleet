import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kheti_go_fleet/models/farmer.dart';
import 'package:kheti_go_fleet/staticData.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/farmer_request.dart';

class RequestInfo extends StatefulWidget {
  FarmerRequest farmerRequest;
  Position userPosition;

  RequestInfo(
      {Key? key, required this.farmerRequest, required this.userPosition})
      : super(key: key);

  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  List<LatLng>? routeCoords = [];
  GoogleMapPolyline googleMapPolyline = GoogleMapPolyline(apiKey: apiKey);
  final Set<Polyline> polylines = {};

  @override
  void initState() {
    // TODO: implement initState
    getLinePoints();
    super.initState();
    farmerRequest = widget.farmerRequest;
  }

  final TextEditingController otpController = TextEditingController();
  FarmerRequest? farmerRequest;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    final CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(farmerRequest!.location!.latitude,
          farmerRequest!.location!.longitude),
      zoom: 14,
    );
    final _marker = [
      Marker(
        markerId: const MarkerId('1'),
        position: LatLng(farmerRequest!.location!.latitude,
            farmerRequest!.location!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('2'),
        position:
            LatLng(widget.userPosition.latitude, widget.userPosition.longitude),
      ),
    ];
    return Scaffold(
        body: ListView(
          children: [
            SizedBox(
              height: height / 2,
              child: Card(
                  color: Colors.green[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: routeCoords!.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            GoogleMap(
                              onMapCreated:
                                  (GoogleMapController controler) async {
                                polylines.add(Polyline(
                                  polylineId: const PolylineId('route1'),
                                  visible: true,
                                  points: routeCoords!,
                                  width: 4,
                                  color: Colors.blue,
                                  startCap: Cap.roundCap,
                                  endCap: Cap.buttCap,
                                ));
                                setState(() {});
                              },
                              polylines: polylines,
                              initialCameraPosition: _cameraPosition,
                              markers: _marker.toSet(),
                            ),
                          ],
                        )),
            ),
            Container(
              color: Colors.white,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("FleetAllocationRequest")
                      .doc(FirebaseAuth.instance.currentUser?.uid!)
                      .collection("userRequest")
                      .doc("${farmerRequest!.timestamp}")
                      .snapshots(),
                  builder: (context, snapshots) {
                    if (snapshots.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator()); // Display a loading indicator when waiting for data.
                    } else if (snapshots.hasError) {
                      return Text(
                          'Error: ${snapshots.error}'); // Display an error message if an error occurs.
                    } else if (!snapshots.hasData) {
                      return const Text('No data available');
                    }

                    FarmerRequest request =
                        FarmerRequest.fromJson(snapshots.data!.data()!);

                    farmerRequest = request;

                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("Farmers")
                          .doc(farmerRequest!.userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child:
                                  const CircularProgressIndicator()); // Display a loading indicator when waiting for data.
                        } else if (snapshot.hasError) {
                          return Text(
                              'Error: ${snapshot.error}'); // Display an error message if an error occurs.
                        } else if (!snapshot.hasData) {
                          return const Text('No data available');
                        }

                        Farmer farmer = Farmer.fromJson(snapshot.data!.data()!);

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Name: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "${farmer.farmerName}",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    onPressed: () {
                                      _makePhoneCall(farmer.phoneNumber!);
                                    },
                                    icon: const Icon(
                                      Icons.call,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Tool:",
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        widget
                                            .farmerRequest.service?["ToolName"],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "Cost per Hour:",
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '₹${farmerRequest!.service?["costPerHour"]}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        farmerRequest!.service?["url"],
                                    placeholder: (context, data) {
                                      print(data);
                                      return const CircularProgressIndicator();
                                    },
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.fill)),
                                      );
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ),

            if(!farmerRequest!.requestAccepted! &&
                !farmerRequest!.requestRejected!)
              const Center(child: Text("Confirmation Pending from Your Side",style: TextStyle(fontWeight: FontWeight.w600),))
             else if(farmerRequest!.requestRejected!)
              const Center(child: Text("Rejected by you",style: TextStyle(fontWeight: FontWeight.w600),))
            else if (farmerRequest!.requestAccepted! &&
                !farmerRequest!.isStarted!)
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      child: TextField(
                        maxLength: 6,
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter OTP',
                          labelText: 'OTP',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      print(otpController.text);
                      if (int.parse(otpController.text) ==
                          farmerRequest!.otp) {
                        Fluttertoast.showToast(msg: "OTP verified");

                        final timestamp = DateTime.now().millisecondsSinceEpoch;

                        await FirebaseFirestore.instance
                            .collection('FleetAllocationRequest')
                            .doc(farmerRequest!.fleetId)
                            .collection('userRequest')
                            .doc('${farmerRequest!.requestId}')
                            .update(
                                {"isStarted": true, "startTime": timestamp});
                        await FirebaseFirestore.instance
                            .collection('Farmers')
                            .doc(farmerRequest!.userId)
                            .collection('MyBookings')
                            .doc('${farmerRequest!.requestId}')
                            .update(
                                {"isStarted": true, "startTime": timestamp});
                      } else {
                        Fluttertoast.showToast(
                            msg:
                                "Wrong OTP. OTP is ${farmerRequest!.otp}");
                      }
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Start Job",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (!farmerRequest!.isEnded!)
              Column(
                children: [
                  TimeDifferenceWidget(
                      timestampInMillis: farmerRequest!.startTime ?? 0),
                  GestureDetector(
                    onTap: () async {
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      await FirebaseFirestore.instance
                          .collection('FleetAllocationRequest')
                          .doc(farmerRequest!.fleetId)
                          .collection('userRequest')
                          .doc('${farmerRequest!.requestId}')
                          .update({
                        "isEnded": true,
                        "endTime": timestamp,
                      });
                      await FirebaseFirestore.instance
                          .collection('Farmers')
                          .doc(farmerRequest!.userId)
                          .collection('MyBookings')
                          .doc('${farmerRequest!.requestId}')
                          .update({"isEnded": true, "endTime": timestamp});
                      Fluttertoast.showToast(msg: "Ended Work!");
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "End",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else if (farmerRequest!.paymentDone!)
               Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Payment Received",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.cloud_done,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                    Text(
                        "Rs.${(getHourAndMinuteDifference(farmerRequest!.startTime!, farmerRequest!.endTime!).inMinutes / 60) * widget.farmerRequest.service?['costPerHour']}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600))
                  ],
                ),
              )
            else if (!widget.farmerRequest.paymentDone!)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Payment not Received",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.cloud_done,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                    Text(
                        "Rs.${(getHourAndMinuteDifference(widget.farmerRequest.startTime!, widget.farmerRequest.endTime!).inMinutes / 60) * widget.farmerRequest.service?['costPerHour']}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600))
                  ],
                ),
              )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(0.0),
          child: GestureDetector(
            onTap: () async {
              String googleMapsUrl =
                  'https://www.google.com/maps/search/?api=1&query=${widget.farmerRequest.location?.latitude},${widget.farmerRequest.location?.longitude}';
              if (await canLaunchUrlString(googleMapsUrl)) {
                await launchUrlString(googleMapsUrl);
              } else {
                throw 'Could not open Google Maps';
              }
            },
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(8)),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Icon(
                  Icons.directions,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ));
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  getLinePoints() async {
    routeCoords = await googleMapPolyline
        .getCoordinatesWithLocation(
            origin: LatLng(
                widget.userPosition.latitude, widget.userPosition.longitude),
            destination: LatLng(widget.farmerRequest.location!.latitude,
                widget.farmerRequest.location!.longitude),
            mode: RouteMode.driving)
        .whenComplete(() {
      setState(() {});
    });
  }

  calculateDistance() {
    double totalDistance = 0.0;
    for (int i = 1; i < routeCoords!.length - 1; i++) {
      totalDistance = Geolocator.distanceBetween(
          routeCoords![i - 1].latitude,
          routeCoords![i - 1].longitude,
          routeCoords![i].latitude,
          routeCoords![i].longitude);
    }
    print('Total Distance = ${totalDistance} km');
  }

  Duration getHourAndMinuteDifference(int timestamp1, int timestamp2) {
    DateTime dateTime1 = DateTime.fromMillisecondsSinceEpoch(timestamp1);
    DateTime dateTime2 = DateTime.fromMillisecondsSinceEpoch(timestamp2);

    Duration difference = dateTime2.difference(dateTime1);
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);

    return Duration(hours: hours, minutes: minutes);
  }
}

class TimeDifferenceWidget extends StatefulWidget {
  final int timestampInMillis;

  TimeDifferenceWidget({required this.timestampInMillis});

  @override
  _TimeDifferenceWidgetState createState() => _TimeDifferenceWidgetState();
}

class _TimeDifferenceWidgetState extends State<TimeDifferenceWidget> {
  late Timer _timer;
  late Duration _difference;
  late DateTime _timestamp;

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.fromMillisecondsSinceEpoch(widget.timestampInMillis);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _difference = DateTime.now().difference(_timestamp);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var hours;
    var minutes;

    try {
      hours = _difference.inHours ?? 0;
      minutes = (_difference.inMinutes ?? 0) % 60;
    } catch (e) {
      hours = 0;
      minutes = 0;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$hours".padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Text(
          ":",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          "$minutes".padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
