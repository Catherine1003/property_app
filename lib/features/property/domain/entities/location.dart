class LocationData {
  String? address;
  String? city;
  String? country;
  double? latitude;
  double? longitude;
  String? state;
  String? zip;

  LocationData({
    this.address,
    this.city,
    this.country,
    this.latitude,
    this.longitude,
    this.state,
    this.zip,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    address: json["address"],
    city: json["city"],
    country: json["country"],
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
    state: json["state"],
    zip: json["zip"],
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "city": city,
    "country": country,
    "latitude": latitude,
    "longitude": longitude,
    "state": state,
    "zip": zip,
  };
}