import '../../Helper/string.dart';

class TaxesModel {
  String? id, title, percentage, status;

  TaxesModel({
    this.id,
    this.title,
    this.percentage,
    this.status,
  });

  factory TaxesModel.fromJson(Map<String, dynamic> json) {
    return TaxesModel(
      id: json[Id],
      title: json[tItle],
      percentage: json[Percentage],
      status: json[STATUS],
    );
  }

  @override
  String toString() {
    return title!;
  }

  String userAsString() {
    return '#$id $title';
  }
}
