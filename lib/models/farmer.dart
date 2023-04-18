class Farmer {
  String? farmerName;
  String? farmerEmail;
  String? farmerLandArea;
  String? phoneNumber;
  Farmer(
      {this.farmerName,
        this.farmerEmail,
        this.farmerLandArea,
        this.phoneNumber});

  Farmer.fromJson(Map<String, dynamic> json) {
    farmerName = json['farmerName'];
    farmerEmail = json['farmerEmail'];
    farmerLandArea = json['farmerLandArea'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['farmerName'] = this.farmerName;
    data['farmerEmail'] = this.farmerEmail;
    data['farmerLandArea'] = this.farmerLandArea;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
