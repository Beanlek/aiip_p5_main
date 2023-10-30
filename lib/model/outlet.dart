class Outlet {
  String id;
  String outletName;
  String outletLocation;
  String? updatedAt;
  String? updatedBy;
  String? createdAt;
  String? createdBy;

  Outlet({
    required this.id,
    required this.outletName,
    required this.outletLocation,
    required this.updatedAt,
    required this.updatedBy,
    required this.createdAt,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "outlet_name": outletName,
        "outlet_location": outletLocation,
        "updated_at": updatedAt,
        "updated_by": updatedBy,
        "created_at": createdAt,
        "created_by": createdBy,
      };

  static Outlet fromJson(Map<String, dynamic> json) => Outlet(
        id: json['id'],
        outletName: json['outlet_name'],
        outletLocation: json['outlet_location'],
        updatedAt: json['updated_at'],
        updatedBy: json['updated_by'],
        createdAt: json['created_at'],
        createdBy: json['created_by'],
      );
}
