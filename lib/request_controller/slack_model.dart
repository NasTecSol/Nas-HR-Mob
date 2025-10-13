class SlackModel {
  int? statusCode;
  String? statusMessage;
  dynamic errorMessage;
  List<Data>? data;

  SlackModel({this.statusCode, this.statusMessage, this.errorMessage, this.data});

  SlackModel.fromJson(Map<String, dynamic> json) {
    statusCode = json["statusCode"];
    statusMessage = json["statusMessage"];
    errorMessage = json["errorMessage"];
    data = json["data"] == null ? null : (json["data"] as List).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["statusCode"] = statusCode;
    _data["statusMessage"] = statusMessage;
    _data["errorMessage"] = errorMessage;
    if(data != null) {
      _data["data"] = data?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Data {
  String? id;
  String? chatName;
  String? roomId;
  String? roomType;
  List<Participants>? participants;
  List<ChatHistory>? chatHistory;
  String? createdAt;
  String? updatedAt;
  int? v;

  Data({this.id, this.chatName, this.roomId, this.roomType, this.participants, this.chatHistory, this.createdAt, this.updatedAt, this.v});

  Data.fromJson(Map<String, dynamic> json) {
    id = json["_id"];
    chatName = json["chatName"];
    roomId = json["roomId"];
    roomType = json["roomType"];
    participants = json["participants"] == null ? null : (json["participants"] as List).map((e) => Participants.fromJson(e)).toList();
    chatHistory = json["chatHistory"] == null ? null : (json["chatHistory"] as List).map((e) => ChatHistory.fromJson(e)).toList();
    createdAt = json["createdAt"];
    updatedAt = json["updatedAt"];
    v = json["__v"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["_id"] = id;
    _data["chatName"] = chatName;
    _data["roomId"] = roomId;
    _data["roomType"] = roomType;
    if(participants != null) {
      _data["participants"] = participants?.map((e) => e.toJson()).toList();
    }
    if(chatHistory != null) {
      _data["chatHistory"] = chatHistory?.map((e) => e.toJson()).toList();
    }
    _data["createdAt"] = createdAt;
    _data["updatedAt"] = updatedAt;
    _data["__v"] = v;
    return _data;
  }
}

class ChatHistory {
  String? messageId;
  String? senderId;
  String? content;
  bool? isRead;
  dynamic parentMessageId;
  String? timestamp;

  ChatHistory({this.messageId, this.senderId, this.content, this.parentMessageId, this.timestamp , this.isRead});

  ChatHistory.fromJson(Map<String, dynamic> json) {
    messageId = json["messageId"];
    senderId = json["senderId"];
    content = json["content"];
    isRead = json["isRead"];
    parentMessageId = json["parentMessageId"];
    timestamp = json["timestamp"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["messageId"] = messageId;
    _data["senderId"] = senderId;
    _data["content"] = content;
    _data["isRead"] = isRead;
    _data["parentMessageId"] = parentMessageId;
    _data["timestamp"] = timestamp;
    return _data;
  }
}

class Participants {
  String? id;
  String? name;
  String? designation;
  String? lastSeen;
  bool? isOnline;

  Participants({this.id, this.name, this.designation,this.isOnline , this.lastSeen});

  Participants.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    designation = json["designation"];
    isOnline = json["isOnline"];
    lastSeen = json["lastSeen"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["id"] = id;
    _data["name"] = name;
    _data["designation"] = designation;
    _data["isOnline"] = isOnline;
    _data["lastSeen"] = lastSeen;
    return _data;
  }
}