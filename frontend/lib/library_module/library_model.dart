// To parse this JSON data, do
//
//     final libraryModel = libraryModelFromJson(jsonString);

import 'dart:convert';

LibraryModel libraryModelFromJson(String str) => LibraryModel.fromJson(json.decode(str));

String libraryModelToJson(LibraryModel data) => json.encode(data.toJson());

class LibraryModel {
  bool success;
  Data data;

  LibraryModel({
    required this.success,
    required this.data,
  });

  factory LibraryModel.fromJson(Map<String, dynamic> json) => LibraryModel(
    success: json["success"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
  };
}

class Data {
  int currentPage;
  List<Datum> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  Data({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  int id;
  String title;
  String author;
  String isbn;
  String description;
  int publicationYear;
  String genre;
  bool isAvailable;
  dynamic userId;
  dynamic borrowedAt;
  dynamic dueDate;
  String createdAt;
  String updatedAt;
  dynamic borrower;

  Datum({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.description,
    required this.publicationYear,
    required this.genre,
    required this.isAvailable,
    required this.userId,
    required this.borrowedAt,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.borrower,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    title: json["title"],
    author: json["author"],
    isbn: json["isbn"],
    description: json["description"],
    publicationYear: json["publication_year"],
    genre: json["genre"],
    isAvailable: json["is_available"],
    userId: json["user_id"],
    borrowedAt: json["borrowed_at"],
    dueDate: json["due_date"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    borrower: json["borrower"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "author": author,
    "isbn": isbn,
    "description": description,
    "publication_year": publicationYear,
    "genre": genre,
    "is_available": isAvailable,
    "user_id": userId,
    "borrowed_at": borrowedAt,
    "due_date": dueDate,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "borrower": borrower,
  };
}

class Link {
  String? url;
  String label;
  int? page;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.page,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    page: json["page"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "page": page,
    "active": active,
  };
}
