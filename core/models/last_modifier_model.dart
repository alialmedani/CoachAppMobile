class LastModifierModel {
  dynamic tenantId;
  String? userName;
  String? name;
  String? surname;
  String? email;
  bool? emailConfirmed;
  dynamic phoneNumber;
  bool? phoneNumberConfirmed;
  bool? isActive;
  bool? lockoutEnabled;
  int? accessFailedCount;
  dynamic lockoutEnd;
  String? concurrencyStamp;
  int? entityVersion;
  String? lastPasswordChangeTime;
  bool? isDeleted;
  dynamic deleterId;
  dynamic deletionTime;
  String? lastModificationTime;
  String? lastModifierId;
  String? creationTime;
  String? creatorId;
  String? id;

  LastModifierModel({
    this.tenantId,
    this.userName,
    this.name,
    this.surname,
    this.email,
    this.emailConfirmed,
    this.phoneNumber,
    this.phoneNumberConfirmed,
    this.isActive,
    this.lockoutEnabled,
    this.accessFailedCount,
    this.lockoutEnd,
    this.concurrencyStamp,
    this.entityVersion,
    this.lastPasswordChangeTime,
    this.isDeleted,
    this.deleterId,
    this.deletionTime,
    this.lastModificationTime,
    this.lastModifierId,
    this.creationTime,
    this.creatorId,
    this.id,
  });

  LastModifierModel.fromJson(Map<String, dynamic> json) {
    tenantId = json["tenantId"];
    userName = json["userName"];
    name = json["name"];
    surname = json["surname"];
    email = json["email"];
    emailConfirmed = json["emailConfirmed"];
    phoneNumber = json["phoneNumber"];
    phoneNumberConfirmed = json["phoneNumberConfirmed"];
    isActive = json["isActive"];
    lockoutEnabled = json["lockoutEnabled"];
    accessFailedCount = json["accessFailedCount"];
    lockoutEnd = json["lockoutEnd"];
    concurrencyStamp = json["concurrencyStamp"];
    entityVersion = json["entityVersion"];
    lastPasswordChangeTime = json["lastPasswordChangeTime"];
    isDeleted = json["isDeleted"];
    deleterId = json["deleterId"];
    deletionTime = json["deletionTime"];
    lastModificationTime = json["lastModificationTime"];
    lastModifierId = json["lastModifierId"];
    creationTime = json["creationTime"];
    creatorId = json["creatorId"];
    id = json["id"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["tenantId"] = tenantId;
    data["userName"] = userName;
    data["name"] = name;
    data["surname"] = surname;
    data["email"] = email;
    data["emailConfirmed"] = emailConfirmed;
    data["phoneNumber"] = phoneNumber;
    data["phoneNumberConfirmed"] = phoneNumberConfirmed;
    data["isActive"] = isActive;
    data["lockoutEnabled"] = lockoutEnabled;
    data["accessFailedCount"] = accessFailedCount;
    data["lockoutEnd"] = lockoutEnd;
    data["concurrencyStamp"] = concurrencyStamp;
    data["entityVersion"] = entityVersion;
    data["lastPasswordChangeTime"] = lastPasswordChangeTime;
    data["isDeleted"] = isDeleted;
    data["deleterId"] = deleterId;
    data["deletionTime"] = deletionTime;
    data["lastModificationTime"] = lastModificationTime;
    data["lastModifierId"] = lastModifierId;
    data["creationTime"] = creationTime;
    data["creatorId"] = creatorId;
    data["id"] = id;
    return data;
  }
}
