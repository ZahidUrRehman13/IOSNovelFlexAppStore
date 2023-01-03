// To parse this JSON data, do
//
//     final dropDownSubCategoriesModel = dropDownSubCategoriesModelFromJson(jsonString);

import 'dart:convert';

List<DropDownSubCategoriesModel> dropDownSubCategoriesModelFromJson(String str) => List<DropDownSubCategoriesModel>.from(json.decode(str).map((x) => DropDownSubCategoriesModel.fromJson(x)));

String dropDownSubCategoriesModelToJson(List<DropDownSubCategoriesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DropDownSubCategoriesModel {
  DropDownSubCategoriesModel({
    this.categoryId,
    this.subTitle,
    this.subTitleAr,
  });

  String? categoryId;
  String? subTitle;
  String? subTitleAr;

  factory DropDownSubCategoriesModel.fromJson(Map<String, dynamic> json) => DropDownSubCategoriesModel(
    categoryId: json["category_id"],
    subTitle: json["sub_title"],
    subTitleAr: json["sub_title_ar"],
  );

  Map<String, dynamic> toJson() => {
    "category_id": categoryId,
    "sub_title": subTitle,
    "sub_title_ar": subTitleAr,
  };
}
