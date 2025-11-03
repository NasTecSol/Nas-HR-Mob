import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nashr/screens/slack_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:nashr/request_controller/slack_model.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import '../l10n/app_localizations.dart';

class SlackChatDetailScreen extends StatefulWidget {
  final Data? chatHistory;
  const SlackChatDetailScreen({super.key, this.chatHistory});

  @override
  State<SlackChatDetailScreen> createState() => _SlackChatDetailScreenState();
}

class _SlackChatDetailScreenState extends State<SlackChatDetailScreen> {
  final SingletonClass singletonClass = SingletonClass();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final Map<String, Color> senderColorMap = {};
  final List<Color> participantColors = [
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
  ];

  IO.Socket? socket;
  List<ChatHistory> messages = [];
  bool isConnected = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  @override
  void initState() {
    super.initState();
    singletonClass.activeScreen = 'SlackChatDetailScreen';
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    messages = widget.chatHistory?.chatHistory ?? [];

    // ✅ Use global socket
    socket = SocketService2().getSocket();

    _setupChatListeners();
    _joinRoom();

    final currentUserId = singletonClass.getJWTModel()?.employeeId?.toString();

    // ✅ Mark unread messages from other users as read (for both direct & group chats)
    if (messages.isNotEmpty) {
      final hasUnreadMessages = messages.any((msg) =>
      msg.senderId.toString() != currentUserId && msg.isRead != true);

      if (hasUnreadMessages) {
        socket!.emit("markAsRead", {
          "_id": widget.chatHistory!.id,
          "userId": singletonClass.getJWTModel()?.employeeId,
          "tenantId": singletonClass.tenantId,
        });
      }
    }

    setState(() {
      singletonClass.activeChatRoomId = widget.chatHistory!.id;
    });
  }


  void _setupChatListeners() {
    final currentRoomId = widget.chatHistory?.id?.toString() ?? "";
    final currentUserId = singletonClass.getJWTModel()?.employeeId ?? "";

    socket!.on("receiveMessage", (data) async {
      if (!mounted) return;

      try {
        final msg = ChatHistory.fromJson(data);
        final incomingRoomId = data["_id"]?.toString() ?? "";

        debugPrint("💬 New message for room: $incomingRoomId (current: $currentRoomId)");

        // 🧩 Show only if this message belongs to the open chat room
        if (incomingRoomId == currentRoomId) {
          setState(() => messages.add(msg));
          _scrollToBottom();

          // 🔔 Play sound only if message is from another user
          if (msg.senderId.toString() != currentUserId) {
            _playReceiveSound();

            // ✅ Mark messages as read for this room only
            socket!.emit("markAsRead", {
              "_id": currentRoomId,
              "userId": currentUserId,
              "tenantId": singletonClass.tenantId,
            });
          }
        } else {
          debugPrint("⚠️ Message ignored — belongs to another room ($incomingRoomId)");
        }
      } catch (e, st) {
        debugPrint("⚠️ Error handling receiveMessage: $e\n$st");
      }
    });
    socket!.on('messagesMarkedAsRead', (data) async {
      try {
        log("🔄 messagesMarkedAsRead event received: $data");

        if (!mounted) return;

        final myUserId = singletonClass.getJWTModel()?.employeeId?.toString();
        final senderId = data["userId"]?.toString();

        // only act if this event isn't from me
        if (senderId != myUserId) {
          setState(() {
            // Mark only the last received message as read (not all)
            if (messages.isNotEmpty) {
              messages.last.isRead = true;
            }
          });
          log("✅ Last message marked as read (triggered by $senderId)");
        } else {
          log("🟦 Ignored self markAsRead event");
        }
      } catch (e, st) {
        log("⚠️ Error refreshing messages after markAsRead: $e\n$st");
      }
    });


  }

  void _joinRoom() {
    final userId = singletonClass.getJWTModel()?.employeeId ?? "";
    final tenantId = singletonClass.tenantId ?? "";
    final selectedRoomId = widget.chatHistory?.id?.toString() ?? "";

    if (selectedRoomId.isNotEmpty) {
      socket!.emit("joinRoom", {
        "_id": selectedRoomId,
        "userId": userId,
        "tenantId": tenantId,
      });
      debugPrint("📌 Joined room $selectedRoomId");
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userId = singletonClass.getJWTModel()?.employeeId ?? "";
    final selectedRoomId = widget.chatHistory?.id?.toString() ?? "";

    socket!.emit("sendMessage", {
      "_id": selectedRoomId,
      "senderId": userId,
      "tenantId": singletonClass.tenantId,
      "content": text.trim(),
    });

    _messageController.clear();
    _scrollToBottom();
    await _playSendSound();
  }


  // 🔊 Play send sound
  Future<void> _playSendSound() async {
    try {
      await _audioPlayer.play(AssetSource('send2.wav'));
    } catch (e) {
      debugPrint("🔊 Send sound error: $e");
    }
  }

// 🔊 Play receive sound
  Future<void> _playReceiveSound() async {
    try {
      await _audioPlayer.play(AssetSource('recieve2.mp3'));
    } catch (e) {
      debugPrint("🔊 Receive sound error: $e");
    }
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
     singletonClass.activeScreen = null;
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    SingletonClass().activeChatRoomId = null;
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 1), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = singletonClass.getJWTModel()?.employeeId ?? "";
    final roomType = widget.chatHistory?.roomType ?? "direct";
    final other = widget.chatHistory?.participants
        ?.firstWhere((p) => p.id.toString() != currentUserId,
        orElse: () => widget.chatHistory!.participants!.first);
    final displayName = other?.name ?? "---";
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";
    final meInitial = singletonClass.getJWTModel()?.userName?.isNotEmpty == true
        ? singletonClass.getJWTModel()!.userName![0].toUpperCase()
        : "M";

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 55.0, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            // --- Header ---
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 2,
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 20),
                CircleAvatar(
                  backgroundColor: roomType == "group" ? Colors.orange : Colors.teal,
                  child: roomType == "group"
                      ? const Icon(Icons.group, color: Colors.white)
                      : Text(initial, style: GoogleFonts.inter(color: Colors.white)),
                ),
                const SizedBox(width: 5),
                roomType == "group" ?
                Text(
                 "${widget.chatHistory!.chatName}",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ) : Text(
                  displayName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10),
                if(roomType == "direct")
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: other!.isOnline == true ? Colors.green : Colors.grey
                  ),
                ),
                const Spacer(),
              ],
            ),
            Expanded(
                child: messages.isEmpty
                    ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.noMessageYet,
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: messages.length,
                  controller: _scrollController,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId.toString() == currentUserId;
                    final isGroup = widget.chatHistory!.roomType == "group";
                    final sender = widget.chatHistory?.participants
                        ?.where((p) => p.id.toString() == msg.senderId.toString())
                        .firstOrNull;
                    final senderName = sender?.name ?? "---";
                    final senderInitial = senderName.isNotEmpty ? senderName[0].toUpperCase() : "?";

                    if (sender != null && !senderColorMap.containsKey(sender.id)) {
                      senderColorMap[sender.id!] =
                      participantColors[senderColorMap.length % participantColors.length];
                    }
                    final senderColor = sender != null ? senderColorMap[sender.id]! : Colors.grey;

                    DateTime msgTime = (msg.timestamp != null)
                        ? DateTime.parse(msg.timestamp!).toLocal()
                        : DateTime.now();


                    final localeCode = Localizations.localeOf(context).languageCode;
                    final isArabic = localeCode == "ar";

                    String timeLabel = DateFormat("hh:mm a", isArabic ? "ar" : "en").format(msgTime);

                    String? dateDivider;
                    if (i == 0 ||
                        DateFormat("yyyyMMdd").format(msgTime) !=
                            DateFormat("yyyyMMdd").format(
                                DateTime.tryParse(messages[i - 1].timestamp ?? "")?.toLocal() ?? DateTime.now())) {
                      dateDivider = _getDateDivider(msgTime); // pass context for locale check
                    }


                    return Column(
                      children: [
                        if (dateDivider != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  dateDivider,
                                  style: GoogleFonts.inter(color: Colors.black87, fontSize: 12),
                                ),
                              ),
                            ),
                          ),

                        // --- Chat Row ---
                        Row(
                          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: roomType == "group" ? senderColor : NasColors.onTime,
                                child: Text(
                                  senderInitial,
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                ),
                              ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? Colors.grey[400]
                                      : (roomType == "group"
                                      ? senderColor.withOpacity(0.8)
                                      : NasColors.onTime),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                    bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.content ?? "",
                                      style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          timeLabel,
                                          style: GoogleFonts.inter(fontSize: 10, color: Colors.white70),
                                        ),
                                        if (isMe && !isGroup) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            msg.isRead == true ? Icons.done_all : Icons.done,
                                            size: 14,
                                            color: msg.isRead == true ? Colors.blue : Colors.white70,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (isMe)
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue,
                                child: Text(
                                  meInitial,
                                  style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: _focusNode,
                              controller: _messageController,
                              cursorColor: Colors.grey,
                              textInputAction: TextInputAction.newline,
                              onChanged: (value) {
                                setState(() {});
                              },
                              decoration:  InputDecoration(
                                hintText: AppLocalizations.of(context)!.typeAMessage,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          _messageController.text.isEmpty ?
                          IconButton(
                            icon: Image.asset('images/send.png',
                                height: 24, width: 24, color: Colors.grey),
                            onPressed: () => _sendMessage(_messageController.text),
                          ) : GestureDetector(
                            onTap: () => _sendMessage(_messageController.text),
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: NasColors.onTime,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'images/send.png',
                                  height: 20,
                                  width: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  ///Helper function
  String _getDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(date.year, date.month, date.day);

    final diff = today.difference(msgDate).inDays;
    final localeCode = Localizations.localeOf(context).languageCode;
    final isArabic = localeCode == "ar";
    if (diff == 0) return AppLocalizations.of(context)!.today;
    if (diff == 1) return AppLocalizations.of(context)!.yesterday;
    if (diff < 7) {
      DateFormat("dd MMM yyyy", isArabic ? "ar" : "en").format(date);
    }
    return DateFormat("dd MMM yyyy", isArabic ? "ar" : "en").format(date);
  }

}
