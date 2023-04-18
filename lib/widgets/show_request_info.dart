
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/farmer_request.dart';

class RequestInfo extends StatefulWidget {
  FarmerRequest farmerRequest;
  Position userPosition;
  RequestInfo({Key? key,required this.farmerRequest,required this.userPosition}) : super(key: key);

  @override
  State<RequestInfo> createState() => _RequestInfoState();
}

class _RequestInfoState extends State<RequestInfo> {
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();


  @override
  void initState() {
    // TODO: implement initState
    _getPolyline();
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
      ),
      Marker(
        markerId: const MarkerId('2'),
        position: LatLng(widget.userPosition.latitude, widget.userPosition.longitude),
      ),

    ];
    print(polylineCoordinates);
    return Padding(padding: const EdgeInsets.fromLTRB(40, 80, 40, 120),
    child: Card(
      color: Colors.green[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controler)async{
              await _getPolyline();
            },
            polylines: Set<Polyline>.of(polylines.values),

            initialCameraPosition: _cameraPosition,
            markers: _marker.toSet(),

          ),
        ],
      )
    ),
    );
  }

  void getPolyPoint()async{
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result =await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyC7XOjSB_qJ-ZG5WWhX1ZCNCvCqqF3mQzQ',
        PointLatLng(widget.userPosition.latitude, widget.userPosition.longitude),
        PointLatLng(widget.farmerRequest.location!.latitude, widget.farmerRequest.location!.longitude)
    );
    if(result.points.isNotEmpty){
      result.points.forEach(
              (PointLatLng point)=>polylineCoordinates.add(
                  LatLng(point.latitude, point.longitude),
              ),
      );
      print('hi');
      print('result points = ${result.points.length}');
      print('hi');
      setState(() {

      });
    }
  }


  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result =await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyC7XOjSB_qJ-ZG5WWhX1ZCNCvCqqF3mQzQ',
        PointLatLng(widget.userPosition.latitude, widget.userPosition.longitude),
        PointLatLng(widget.farmerRequest.location!.latitude, widget.farmerRequest.location!.longitude),
      travelMode: TravelMode.driving
    ).whenComplete((){
      print('done');
      setState(() {
      });
    });
    print('len ${result.points.length}');

    if (result.points.isNotEmpty) {
      print('got data');
      result.points.forEach((PointLatLng point) {
        print('Lat = ${point.latitude} lon = ${point.longitude}');
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}
