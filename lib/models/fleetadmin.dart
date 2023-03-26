class FleetAdmin {
  String? name;
  String? emailID;
  String? location;
  String? phoneNumber;

  FleetAdmin(
      {this.name,
        this.emailID,
        this.location,
        this.phoneNumber});

  FleetAdmin.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    emailID = json['emailID'];
    location = json['location'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['emailID'] = this.emailID;
    data['location'] = this.location;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
