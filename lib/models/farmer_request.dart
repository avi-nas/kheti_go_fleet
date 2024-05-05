
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerRequest {
  String? fleetId;
  GeoPoint? location;
  bool? requestAccepted;
  int? requestId;
  bool? requestRejected;
  int? timestamp;
  String? userId;

  Map? service;

  FarmerRequest({this.userId,this.service, this.location, this.requestAccepted,this.timestamp,this.fleetId,this.requestId,this.requestRejected});




  FarmerRequest.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    service = json['service'];
    location = json['location'];
    requestAccepted = json['requestAccepted'];
    timestamp = json['timestamp'];
    fleetId = json['fleetId'];
    requestRejected = json['requestRejected'];
    requestId = json['requestId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['service'] = this.service;
    data['location'] = this.location;
    data['requestAccepted'] = this.requestAccepted;
    data['timestamp'] =  this.timestamp;
    data['fleetId'] =  this.fleetId;
    data['requestRejected'] =  this.requestRejected;
    data['requestId'] = this.requestId;
    return data;
  }
}


class Tool {
  String? toolName;
  String? description;
  String? url;
  int? costPerHour;
  Tool({this.toolName, this.description, this.url,this.costPerHour});

  Tool.fromJson(Map<String, dynamic> json) {
    toolName = json['ToolName'];
    description = json['description'];
    url = json['url'];
    costPerHour = json['costPerHour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ToolName'] = this.toolName;
    data['description'] = this.description;
    data['url'] = this.url;
    data['costPerHour'] = this.costPerHour;
    return data;
  }
}
