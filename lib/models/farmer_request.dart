
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerRequest {
  String? uid;
  String? toolId;
  GeoPoint? location;
  bool? requestAccepted;
  FarmerRequest({this.uid,this.toolId, this.location, this.requestAccepted});

  FarmerRequest.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    toolId = json['toolId'];
    location = json['location'];
    requestAccepted = json['requestAccepted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['toolId'] = this.toolId;
    data['location'] = this.location;
    data['requestAccepted'] = this.requestAccepted;
    return data;
  }
}

