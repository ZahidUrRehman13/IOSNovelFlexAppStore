// To parse this JSON data, do
//
//     final bookEditModel = bookEditModelFromJson(jsonString);

import 'dart:convert';

BookEditModel bookEditModelFromJson(String str) => BookEditModel.fromJson(json.decode(str));

String bookEditModelToJson(BookEditModel data) => json.encode(data.toJson());

class BookEditModel {
  BookEditModel({
    this.status,
    this.message,
    this.data,
  });

  int? status;
  String? message;
  Data? data;

  factory BookEditModel.fromJson(Map<String, dynamic> json) => BookEditModel(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data!.toJson(),
  };
}

class Data {
  Data({
    this.id,
    this.bookTitle,
    this.description,
    this.bookImage,
    this.publishedDate,
    this.modifiedDate,
    this.userId,
    this.chapters,
  });

  String? id;
  String? bookTitle;
  String? description;
  String? bookImage;
  DateTime? publishedDate;
  dynamic modifiedDate;
  String? userId;
  List<Chapter>? chapters;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    bookTitle: json["bookTitle"],
    description: json["description"],
    bookImage: json["bookImage"],
    publishedDate: DateTime.parse(json["publishedDate"]),
    modifiedDate: json["modifiedDate"],
    userId: json["userId"],
    chapters: List<Chapter>.from(json["chapters"].map((x) => Chapter.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "bookTitle": bookTitle,
    "description": description,
    "bookImage": bookImage,
    "publishedDate": publishedDate!.toIso8601String(),
    "modifiedDate": modifiedDate,
    "userId": userId,
    "chapters": List<dynamic>.from(chapters!.map((x) => x.toJson())),
  };
}

class Chapter {
  Chapter({
    this.id,
    this.name,
    this.image,
    this.url,
  });

  String? id;
  String? name;
  dynamic image;
  String? url;

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "url": url,
  };
}
