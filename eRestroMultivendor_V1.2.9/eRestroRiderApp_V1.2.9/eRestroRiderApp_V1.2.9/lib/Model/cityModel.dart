class CityModel {
  String? id;
  String? name;
  String? latitude;
  String? longitude;
  String? geolocationType;
  String? radius;
  String? maxDeliverableDistance;
  String? deliveryChargeMethod;
  String? fixedCharge;
  String? perKmCharge;
  List<RangeWiseCharges>? rangeWiseCharges;
  String? timeToTravel;

  CityModel(
      {this.id,
      this.name,
      this.latitude,
      this.longitude,
      this.geolocationType,
      this.radius,
      this.maxDeliverableDistance,
      this.deliveryChargeMethod,
      this.fixedCharge,
      this.perKmCharge,
      this.rangeWiseCharges,
      this.timeToTravel});

  CityModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    geolocationType = json['geolocation_type'];
    radius = json['radius'];
    maxDeliverableDistance = json['max_deliverable_distance'];
    deliveryChargeMethod = json['delivery_charge_method'];
    fixedCharge = json['fixed_charge'];
    perKmCharge = json['per_km_charge'];
    if (json['range_wise_charges'] != null) {
      rangeWiseCharges = <RangeWiseCharges>[];
      json['range_wise_charges'].forEach((v) {
        rangeWiseCharges!.add(new RangeWiseCharges.fromJson(v));
      });
    }
    timeToTravel = json['time_to_travel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['geolocation_type'] = this.geolocationType;
    data['radius'] = this.radius;
    data['max_deliverable_distance'] = this.maxDeliverableDistance;
    data['delivery_charge_method'] = this.deliveryChargeMethod;
    data['fixed_charge'] = this.fixedCharge;
    data['per_km_charge'] = this.perKmCharge;
    if (this.rangeWiseCharges != null) {
      data['range_wise_charges'] = this.rangeWiseCharges!.map((v) => v.toJson()).toList();
    }
    data['time_to_travel'] = this.timeToTravel;
    return data;
  }
}

class RangeWiseCharges {
  String? fromRange;
  String? toRange;
  String? price;

  RangeWiseCharges({this.fromRange, this.toRange, this.price});

  RangeWiseCharges.fromJson(Map<String, dynamic> json) {
    fromRange = json['from_range'];
    toRange = json['to_range'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['from_range'] = this.fromRange;
    data['to_range'] = this.toRange;
    data['price'] = this.price;
    return data;
  }
}
