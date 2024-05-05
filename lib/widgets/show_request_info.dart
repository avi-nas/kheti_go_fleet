import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final CameraPosition _cameraPosition = CameraPosition(
      target: LatLng(widget.farmerRequest.location!.latitude,
          widget.farmerRequest.location!.longitude),
      zoom: 14,
    );
    final _marker = [
      Marker(
        markerId: const MarkerId('1'),
        position: LatLng(widget.farmerRequest.location!.latitude,
            widget.farmerRequest.location!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('2'),
        position:
            LatLng(widget.userPosition.latitude, widget.userPosition.longitude),
      ),
    ];
    return Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
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
                height: MediaQuery.of(context).size.height / 2,
                color: Colors.white,
                child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("Farmers")
                      .doc(widget.farmerRequest.userId)
                      .get(),
                  builder: (snapshot, context) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tool:",
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                widget.farmerRequest.service?["ToolName"],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
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
                                '₹${widget.farmerRequest.service?["costPerHour"]}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.farmerRequest.service?["url"],
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
                    );
                  },
                ))
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
              width: 150,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(8)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    "Navigate",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Icon(
                      Icons.directions,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  Spacer()
                ],
              ),
            ),
          ),
        ));
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
}
