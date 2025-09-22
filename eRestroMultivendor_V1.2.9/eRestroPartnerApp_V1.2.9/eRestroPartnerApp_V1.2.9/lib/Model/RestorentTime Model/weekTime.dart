import '../../Helper/string.dart';

class WeekTimeModel {
  String? id, resturantid, day, openingTime, closingTime, isOpen, dateCreated;

  WeekTimeModel({
    this.id,
    this.resturantid,
    this.day,
    this.openingTime,
    this.closingTime,
    this.isOpen,
    this.dateCreated,
  });

  factory WeekTimeModel.fromJson(Map<String, dynamic> json) {
    return WeekTimeModel(
      id: json[Id],
      resturantid: json[resturantId],
      day: json["day"],
      openingTime: json["opening_time"],
      closingTime: json["closing_time"],
      isOpen: json["is_open"],
      dateCreated: json["date_created"],
    );
  }
}
