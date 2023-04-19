
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline_new/google_map_polyline_new.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kheti_go_fleet/staticData.dart';

import '../models/farmer_request.dart';

class RequestInfo extends StatefulWidget {
  FarmerRequest farmerRequest;
  Position userPosition;
  RequestInfo({Key? key,required this.farmerRequest,required this.userPosition}) : super(key: key);
  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  List<LatLng>? routeCoords =[];
  GoogleMapPolyline googleMapPolyline = GoogleMapPolyline(apiKey:  apiKey);
  final Set<Polyline> polylines ={};
  @override
  void initState() {
    // TODO: implement initState
    getLinePoints();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final CameraPosition _cameraPosition =  CameraPosition(
      target:  LatLng(widget.farmerRequest.location!.latitude, widget.farmerRequest.location!.longitude),
      zoom:  14,
    );
    final _marker = [
      Marker(
        markerId: const MarkerId('1'),
        position: LatLng(widget.farmerRequest.location!.latitude, widget.farmerRequest.location!.longitude),
          icon:  BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('2'),
        position: LatLng(widget.userPosition.latitude, widget.userPosition.longitude),
      ),
    ];
    return Padding(padding: const EdgeInsets.fromLTRB(40, 80, 40, 120),
    child: Card(
      color: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: routeCoords!.isEmpty?const Center(child: CircularProgressIndicator()) : Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controler)async{
              polylines.add(
                Polyline(
                    polylineId: const PolylineId('route1'),
                  visible: true,
                  points: routeCoords!,
                  width: 4,
                  color: Colors.blue,
                  startCap: Cap.roundCap,
                  endCap: Cap.buttCap,
                )
              );
              setState(() {
              });
            },
            polylines: polylines,
            initialCameraPosition: _cameraPosition,
            markers: _marker.toSet(),
          ),
        ],
      )
    ),
    );
  }
  getLinePoints()async{
    routeCoords= await googleMapPolyline.getCoordinatesWithLocation(
        origin: LatLng(widget.userPosition.latitude, widget.userPosition.longitude),
        destination: LatLng(widget.farmerRequest.location!.latitude, widget.farmerRequest.location!.longitude),
        mode:  RouteMode.driving).whenComplete((){
          setState(() {
          });
    });
  }

  calculateDistance(){
    double totalDistance = 0.0;
    for(int i=1;i<routeCoords!.length-1;i++) {
      //print('${routeCoords![i]}  ${routeCoords![i+1]}');
      totalDistance = Geolocator.distanceBetween(
          routeCoords![i - 1].latitude,
          routeCoords![i - 1].longitude,
          routeCoords![i].latitude,
          routeCoords![i].longitude
      );
    }
    print('Total Distance = ${totalDistance} km');
  }
}
