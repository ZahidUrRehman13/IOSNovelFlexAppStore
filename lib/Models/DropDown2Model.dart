// To parse this JSON data, do
//
//     final dropDown2Model = dropDown2ModelFromJson(jsonString);

import 'dart:convert';

List<DropDown2Model> dropDown2ModelFromJson(String str) => List<DropDown2Model>.from(json.decode(str).map((x) => DropDown2Model.fromJson(x)));

String dropDown2ModelToJson(List<DropDown2Model> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropDown2Model {
  DropDown2Model({
    this.id,
    this.titleEn,
    this.titleAr,
  });

  String? id;
  String? titleEn;
  String? titleAr;

  factory DropDown2Model.fromJson(Map<String, dynamic> json) => DropDown2Model(
    id: json["id"],
    titleEn: json["titleEn"],
    titleAr: json["titleAr"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "titleEn": titleEn,
    "titleAr": titleAr,
  };
}
