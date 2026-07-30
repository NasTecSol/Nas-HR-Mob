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
  void initState() {
    super.initState();
    singletonClass.activeScreen = 'SlackChatDetailScreen';
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    messages = widget.chatHistory?.chatHistory ?? [];

    socket = SocketService2().getSocket();

    _setupChatListeners();
    _joinRoom();

    final currentUserId = singletonClass.getJWTModel()?.employeeId?.toString();

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

        if (incomingRoomId == currentRoomId) {
          setState(() => messages.add(msg));
          _scrollToBottom();

          if (msg.senderId.toString() != currentUserId) {
            _playReceiveSound();

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

        if (senderId != myUserId) {
          setState(() {
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

  Future<void> _playSendSound() async {
    try {
      await _audioPlayer.play(AssetSource('send2.wav'));
    } catch (e) {
      debugPrint("🔊 Send sound error: $e");
    }
  }

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
    Future.delayed(const Duration(milliseconds: 1), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // ── Header Widget (Gradient Header Matching LeaveRequestScreen) ──────────
  Widget _buildHeader(BuildContext context) {
    final currentUserId = singletonClass.getJWTModel()?.employeeId ?? "";
    final roomType = widget.chatHistory?.roomType ?? "direct";
    final other = widget.chatHistory?.participants?.firstWhere(
      (p) => p.id.toString() != currentUserId,
      orElse: () => widget.chatHistory!.participants!.first,
    );
    final displayName = roomType == "group"
        ? (widget.chatHistory?.chatName ?? "Group")
        : (other?.name ?? "---");
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [NasColors.darkBlue, NasColors.lightBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: NasColors.darkBlue.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.25),
                    radius: 20,
                    child: roomType == "group"
                        ? const Icon(Icons.group_rounded, color: Colors.white, size: 20)
                        : Text(
                            initial,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                  if (roomType == "direct" && other != null)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: other.isOnline == true ? Colors.greenAccent : Colors.white54,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = singletonClass.getJWTModel()?.employeeId ?? "";
    final roomType = widget.chatHistory?.roomType ?? "direct";
    final meInitial = singletonClass.getJWTModel()?.userName?.isNotEmpty == true
        ? singletonClass.getJWTModel()!.userName![0].toUpperCase()
        : "M";

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.noMessageYet,
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        dateDivider = _getDateDivider(msgTime);
                      }

                      return Column(
                        children: [
                          if (dateDivider != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: NasColors.darkBlue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    dateDivider,
                                    style: GoogleFonts.inter(
                                      color: NasColors.darkBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // ── Chat Bubble Row ─────────────────────────────
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (!isMe)
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: roomType == "group" ? senderColor : NasColors.darkBlue,
                                    child: Text(
                                      senderInitial,
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.70,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: isMe
                                          ? LinearGradient(
                                              colors: [NasColors.darkBlue, NasColors.lightBlue],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isMe ? null : Colors.white,
                                      border: isMe ? null : Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isMe
                                              ? NasColors.darkBlue.withOpacity(0.2)
                                              : Colors.black.withOpacity(0.03),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        if (roomType == "group" && !isMe)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 2.0),
                                            child: Text(
                                              senderName,
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: senderColor,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          msg.content ?? "",
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            color: isMe ? Colors.white : NasColors.darkBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              timeLabel,
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                                color: isMe ? Colors.white70 : Colors.grey.shade500,
                                              ),
                                            ),
                                            if (isMe && !isGroup) ...[
                                              const SizedBox(width: 4),
                                              Icon(
                                                msg.isRead == true ? Icons.done_all_rounded : Icons.done_rounded,
                                                size: 14,
                                                color: msg.isRead == true ? Colors.lightBlueAccent : Colors.white70,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (isMe)
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundColor: NasColors.lightBlue,
                                    child: Text(
                                      meInitial,
                                      style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // ── Bottom Message Input Bar ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: NasColors.backGround,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _messageController,
                        cursorColor: NasColors.darkBlue,
                        style: GoogleFonts.inter(color: NasColors.darkBlue, fontSize: 15),
                        textInputAction: TextInputAction.newline,
                        onChanged: (value) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.typeAMessage,
                          hintStyle: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _messageController.text.trim().isNotEmpty
                        ? () => _sendMessage(_messageController.text)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        gradient: _messageController.text.trim().isNotEmpty
                            ? LinearGradient(
                                colors: [NasColors.darkBlue, NasColors.lightBlue],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: _messageController.text.trim().isNotEmpty
                            ? null
                            : Colors.grey.shade300,
                        shape: BoxShape.circle,
                        boxShadow: _messageController.text.trim().isNotEmpty
                            ? [
                                BoxShadow(
                                  color: NasColors.darkBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
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
      return DateFormat("dd MMM yyyy", isArabic ? "ar" : "en").format(date);
    }
    return DateFormat("dd MMM yyyy", isArabic ? "ar" : "en").format(date);
  }
}
