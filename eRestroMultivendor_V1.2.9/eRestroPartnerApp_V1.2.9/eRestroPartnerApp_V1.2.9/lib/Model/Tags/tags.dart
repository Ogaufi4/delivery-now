import '../../Helper/string.dart';

class TagsModel {
  String? id, resturantid, title, datecreated;

  TagsModel({
    this.id,
    this.resturantid,
    this.title,
    this.datecreated,
  });

  factory TagsModel.fromJson(Map<String, dynamic> json) {
    return TagsModel(
      id: json[Id],
      resturantid: json[resturantId],
      title: json[tItle],
      datecreated: json[DateCreated],
    );
  }
}
