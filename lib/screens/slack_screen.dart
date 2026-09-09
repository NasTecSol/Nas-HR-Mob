import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/request_controller/slack_model.dart';
import 'package:nashr/screens/chat_screen.dart';
import 'package:nashr/screens/project_screen.dart';
import 'package:nashr/screens/slack_chat_detail_screen.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../main.dart';
import '../request_controller/search_employee_model.dart' hide Data;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../widgets/loader.dart';

class SlackScreen extends StatefulWidget {
  const SlackScreen({super.key});

  @override
  State<SlackScreen> createState() => _SlackScreenState();
}

class _SlackScreenState extends State<SlackScreen> {
  final SingletonClass singletonClass = SingletonClass();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();

  bool isCreating = false;
  bool isLoading = false;
  bool _showSearchResult = false;
  bool _noDataFound = false;

  final List<SearchedResults> _employeeSearchResults = [];
  final List<SearchedResults> _selectedEmployees = [];
  SlackModel? _chatData;
  Timer? _refreshTimer;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 600), () {
        if (searchController.text.trim().isNotEmpty) {
          getSearchEmployeeData(searchController.text.trim());
        }
      });
    });

    singletonClass.activeScreen = "SlackScreen";
    _fetchChats();
    SocketService2().socket!.on('receiveMessage', (data) async {
      try {
        _fetchChats();
        log("🔄 Chats refreshed after receiving new message");
      } catch (e) {
        log("⚠️ Error refreshing chats: $e");
      }
    });
    SocketService2().socket!.on('messagesMarkedAsRead', (data) async {
      try {
        _fetchChats();
        log("🔄 Chats refreshed after mark as read  new message");
      } catch (e) {
        log("⚠️ Error refreshing chats: $e");
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    singletonClass.activeScreen = null;
    super.dispose();
  }

  Future<void> _fetchChats() async {
    final chats = await singletonClass.getChats();
    if (!mounted) return;
    setState(() {
      _chatData = chats;
    });
  }

  // ── Header Widget (Gradient Header Matching LeaveRequestScreen) ──────────
  Widget _buildHeader(BuildContext context) {
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
                onTap: () {
                  Navigator.pop(context);
                  singletonClass.getChats();
                },
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
              Text(
                AppLocalizations.of(context)!.chatBox,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCreating = !isCreating;
                    _showSearchResult = false;
                    _employeeSearchResults.clear();
                    searchController.clear();
                    _noDataFound = false;
                  });
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Icon(
                    isCreating ? Icons.close_rounded : Icons.create_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
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
    ///Nas Mudeer
    final uiSettings = singletonClass.roleAndAccessModelDataList.isNotEmpty
        ? (singletonClass
                .roleAndAccessModelDataList.first.data?.uiSettings?.uiModules ??
            [])
        : [];
    final hasNasMudeer = uiSettings.any((e) {
      final title = (e.title ?? '').toLowerCase();
      if (title == 'dashboard' && e.hidden == false) {
        return e.nasMudeer == true;
      }
      return false;
    });

    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  /// Search Mode
                  if (isCreating) ...[
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (value) {
                                if (value.trim().isNotEmpty) {
                                  getSearchEmployeeData(searchController.text);
                                } else {
                                  setState(() {
                                    _showSearchResult = false;
                                    _employeeSearchResults.clear();
                                    _noDataFound = false;
                                  });
                                }
                              },
                              cursorColor: NasColors.darkBlue,
                              style: GoogleFonts.inter(color: NasColors.darkBlue),
                              decoration: InputDecoration(
                                hintText: '${AppLocalizations.of(context)!.search}...',
                                hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(Icons.search_rounded, color: NasColors.darkBlue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Selected employees preview (chips)
                    if (_selectedEmployees.isNotEmpty)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _selectedEmployees.map((emp) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: NasColors.darkBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: NasColors.darkBlue.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    emp.employeeName ?? "",
                                    style: GoogleFonts.inter(
                                      color: NasColors.darkBlue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedEmployees.remove(emp);
                                      });
                                    },
                                    child: Icon(Icons.close_rounded,
                                        size: 16, color: NasColors.darkBlue),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    const SizedBox(height: 12),
                    if (isLoading)
                      const Expanded(child: Center(child: Loader()))
                    else if (_showSearchResult)
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _employeeSearchResults.length,
                          itemBuilder: (context, index) {
                            final employee = _employeeSearchResults[index];
                            final name = employee.employeeName ?? "---";
                            final designation = employee.designation ?? "";

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: NasColors.darkBlue,
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : "?",
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: NasColors.darkBlue,
                                    ),
                                  ),
                                  subtitle: Text(
                                    designation,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: _selectedEmployees.any((e) => e.employeeId == employee.employeeId),
                                    onChanged: (checked) {
                                      setState(() {
                                        if (checked == true) {
                                          if (!_selectedEmployees.any((e) => e.employeeId == employee.employeeId)) {
                                            _selectedEmployees.add(employee);
                                          }
                                        } else {
                                          _selectedEmployees.removeWhere((e) => e.employeeId == employee.employeeId);
                                        }
                                      });
                                    },
                                    activeColor: NasColors.darkBlue,
                                    checkColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    /// Action Buttons
                    if (_selectedEmployees.length == 1) ...[
                      FutureBuilder<bool>(
                        future: _checkExistingChat(_selectedEmployees.first.employeeId!),
                        builder: (context, snapshot) {
                          final exists = snapshot.data ?? false;
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: NasColors.darkBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 2,
                              ),
                              onPressed: () {
                                if (exists) {
                                  _openExistingChat(_selectedEmployees.first.employeeId!);
                                } else {
                                  createChat(_selectedEmployees.first);
                                }
                              },
                              child: Text(
                                exists
                                    ? AppLocalizations.of(context)!.open
                                    : AppLocalizations.of(context)!.startChat,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ] else if (_selectedEmployees.length > 1) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: groupNameController,
                          cursorColor: NasColors.darkBlue,
                          style: GoogleFonts.inter(color: NasColors.darkBlue),
                          decoration: InputDecoration(
                            hintText: "Enter a group name",
                            hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: NasColors.darkBlue, width: 1.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: NasColors.darkBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 2,
                          ),
                          onPressed: createGroupChat,
                          child: Text(
                            "Create a group",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ] else ...[

                    /// Normal Chat List
                    if (hasNasMudeer)
                      Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                                child: Text(
                                  AppLocalizations.of(context)!.nassMudeer,
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChatScreen(),
                                    ),
                                  ).then((_) => _fetchChats());
                                },
                                leading: CircleAvatar(
                                  backgroundColor: NasColors.darkBlue,
                                  child: const Icon(Icons.group, color: Colors.white),
                                ),
                                title: Text(
                                  AppLocalizations.of(context)!.nassMudeer,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: NasColors.darkBlue,
                                  ),
                                ),
                                subtitle: Text(
                                  "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    Expanded(
                      child: RefreshIndicator(
                        backgroundColor: Colors.white,
                        color: NasColors.darkBlue,
                        onRefresh: _fetchChats,
                        child: _chatData == null
                            ? const Center(child: Loader())
                            : _chatData!.data == null || _chatData!.data!.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 180,
                                          width: 180,
                                          child: Lottie.asset('images/empty.json'),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          AppLocalizations.of(context)!.noData,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: NasColors.darkBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView(
                                    padding: EdgeInsets.zero,
                                    children: [
                                      ...(_chatData!.data!
                                          .where((c) => c.roomType == "direct" || c.roomType == "group")
                                          .toList()
                                        ..sort((a, b) {
                                          final aTime = a.chatHistory?.isNotEmpty == true
                                              ? DateTime.tryParse(a.chatHistory!.last.timestamp ?? "")
                                                      ?.millisecondsSinceEpoch ??
                                                  0
                                              : 0;
                                          final bTime = b.chatHistory?.isNotEmpty == true
                                              ? DateTime.tryParse(b.chatHistory!.last.timestamp ?? "")
                                                      ?.millisecondsSinceEpoch ??
                                                  0
                                              : 0;
                                          return bTime.compareTo(aTime);
                                        }))
                                          .map((chat) => _buildChatTile(
                                                chat,
                                                isGroup: chat.roomType == "group",
                                              )),
                                    ],
                                  ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(Data chat, {required bool isGroup}) {
    final currentUserId = singletonClass.getJWTModel()?.employeeId ?? "";

    String displayName = "---";
    String initial = "?";
    bool? isOnline;

    if (!isGroup &&
        chat.participants != null &&
        chat.participants!.isNotEmpty) {
      final other = chat.participants!.firstWhere(
        (p) => p.id.toString() != currentUserId,
        orElse: () => chat.participants!.first,
      );
      displayName = other.name ?? "---";
      initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";
      isOnline = other.isOnline;
    } else if (isGroup) {
      displayName = chat.chatName ?? "Group";
      initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "G";
    }

    final unreadCount = chat.chatHistory
            ?.where((msg) =>
                msg.senderId.toString() != currentUserId &&
                (msg.isRead == false || msg.isRead == null))
            .length ??
        0;

    String message = AppLocalizations.of(context)!.noMessageYet;
    DateTime? lastMsgTime;
    bool isSentByMe = false;
    bool? isRead;

    if (chat.chatHistory != null && chat.chatHistory!.isNotEmpty) {
      final lastMsg = chat.chatHistory!.last;
      isSentByMe = lastMsg.senderId?.toString() == currentUserId;
      isRead = lastMsg.isRead;
      message = lastMsg.content ?? "";
      if (lastMsg.timestamp != null) {
        lastMsgTime = DateTime.tryParse(lastMsg.timestamp!)?.toLocal();
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SlackChatDetailScreen(chatHistory: chat),
              ),
            ).then((_) => _fetchChats());
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: isGroup ? NasColors.lightBlue : NasColors.darkBlue,
                      radius: 24,
                      child: isGroup
                          ? const Icon(Icons.group, color: Colors.white)
                          : Text(
                              initial,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    if (!isGroup)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          height: 12,
                          width: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline == true ? Colors.green : Colors.grey,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: NasColors.darkBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (isSentByMe && !isGroup)
                            Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Icon(
                                isRead == true ? Icons.done_all_rounded : Icons.check_rounded,
                                size: 16,
                                color: isRead == true ? NasColors.lightBlue : Colors.grey,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lastMsgTime != null ? formatChatTime(context, lastMsgTime) : "",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: NasColors.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Format Chat Time
  String formatChatTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    final localeCode = Localizations.localeOf(context).languageCode;
    final isArabic = localeCode == "ar";

    if (diff.inSeconds <= 1) {
      return AppLocalizations.of(context)!.justNow;
    }
    if (diff.inSeconds < 60) {
      return "${diff.inSeconds}${AppLocalizations.of(context)!.s} ${AppLocalizations.of(context)!.ago}";
    }
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}${AppLocalizations.of(context)!.m} ${AppLocalizations.of(context)!.ago}";
    }
    if (diff.inHours < 24) {
      return DateFormat('h:mm a', isArabic ? "ar" : "en").format(dateTime);
    }
    if (diff.inDays == 1) {
      return AppLocalizations.of(context)!.yesterday;
    }
    if (diff.inDays < 7) {
      return DateFormat("EEEE", isArabic ? "ar" : "en").format(dateTime);
    }
    return DateFormat("dd MMM yyyy", isArabic ? "ar" : "en").format(dateTime);
  }

  /// Search Employee
  Future<void> getSearchEmployeeData(String query) async {
    final employeeId = query;
    if (employeeId.isEmpty) return;

    setState(() {
      isLoading = true;
      _showSearchResult = false;
      _noDataFound = false;
    });

    try {
      var client = http.Client();
      var uri = Uri.parse(
          '${singletonClass.baseURL}/employee/search?emp=$employeeId');
      var response =
          await client.get(uri, headers: singletonClass.getHeaders());

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        var employeeData = SearchEmployeeData.fromJson(responseBody);

        if (employeeData.data != null &&
            employeeData.data!.employees!.isNotEmpty) {
          final emp = employeeData.data!.employees!.first;
          final empInfo = emp.employeeInfo != null &&
                  emp.employeeInfo!.isNotEmpty
              ? emp.employeeInfo!.first
              : null;

          if (empInfo != null) {
            final result = SearchedResults(
              empId: empInfo.empId,
              employeeName: emp.userName ?? "Unknown",
              employeeId: emp.id,
              designation: empInfo.designation ?? "Unknown",
            );

            setState(() {
              if (!_employeeSearchResults.any((e) => e.empId == result.empId)) {
                _employeeSearchResults.add(result);
              }
              _showSearchResult = true;
            });
          } else {
            setState(() => _noDataFound = true);
          }
        } else {
          setState(() => _noDataFound = true);
        }
      } else {
        setState(() => _noDataFound = true);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        _noDataFound = true;
      });
    }
  }

  /// Create direct chat
  Future<void> createChat(SearchedResults employee) async {
    String? currentUserId = singletonClass.getJWTModel()?.employeeId;
    if (currentUserId == null) return;

    final participants = [
      {
        "id": currentUserId,
        "name": singletonClass.employeeDataList.first.data.first.userName ?? "You",
        "designation": singletonClass.employeeDataList.first.data.first.employeeInfo?.first.designation ?? "",
        "isOnline": true,
        "lastSeen": ""
      },
      {
        "id": employee.employeeId,
        "name": employee.employeeName,
        "designation": employee.designation,
        "isOnline": false,
        "lastSeen": ""
      }
    ];

    final body = {
      "chatName": "directMessage",
      "roomType": "direct",
      "participants": participants
    };

    try {
      var client = http.Client();
      var uri = Uri.parse("${singletonClass.baseURL}/chat-system/create");
      var response = await client.post(uri,
          headers: singletonClass.getHeaders(),
          body: jsonEncode(body));
      log("create chat data ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final createdChat = Data.fromJson(responseBody['data']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SlackChatDetailScreen(chatHistory: createdChat)))
            .then((_) => _fetchChats());
        setState(() => isCreating = false);
      }
    } catch (e) {
      log("Chat creation failed: $e");
    }
  }

  /// Create group chat
  Future<void> createGroupChat() async {
    String? currentUserId = singletonClass.getJWTModel()?.employeeId;
    if (currentUserId == null || groupNameController.text.trim().isEmpty) return;

    final participants = [
      {
        "id": currentUserId,
        "name": singletonClass.employeeDataList.first.data.first.userName ?? "You",
        "designation": singletonClass.employeeDataList.first.data.first.employeeInfo?.first.designation ?? "",
        "isOnline": true,
        "lastSeen": ""
      },
      ..._selectedEmployees.map((e) => {
        "id": e.employeeId,
        "name": e.employeeName,
        "designation": e.designation,
        "isOnline": false,
        "lastSeen": ""
      })
    ];

    final body = {
      "chatName": groupNameController.text.trim(),
      "roomType": "group",
      "participants": participants
    };

    try {
      var client = http.Client();
      var uri = Uri.parse("${singletonClass.baseURL}/chat-system/create");
      var response = await client.post(uri,
          headers: singletonClass.getHeaders(),
          body: jsonEncode(body));
      log("create group chat data ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final createdChat = Data.fromJson(responseBody['data']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SlackChatDetailScreen(chatHistory: createdChat)))
            .then((_) => _fetchChats());
        setState(() => isCreating = false);
      }
    } catch (e) {
      log("Group Chat creation failed: $e");
    }
  }

  Future<bool> _checkExistingChat(String empId) async {
    if (_chatData == null || _chatData!.data == null) return false;
    final currentUserId = singletonClass.getJWTModel()?.employeeId ?? "";
    return _chatData!.data!.any((chat) =>
        chat.roomType == "direct" &&
        chat.participants!.any((p) => p.id.toString() == empId) &&
        chat.participants!.any((p) => p.id.toString() == currentUserId));
  }

  void _openExistingChat(String empId) {
    final chat = _chatData!.data!.firstWhere((c) =>
        c.roomType == "direct" &&
        c.participants!.any((p) => p.id.toString() == empId));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SlackChatDetailScreen(chatHistory: chat)),
    ).then((_) => _fetchChats());
    setState(() => isCreating = false);
  }
}

class SocketService2 {
  static final SocketService2 _instance = SocketService2._internal();
  factory SocketService2() => _instance;

  IO.Socket? socket;

  SocketService2._internal();

  SingletonClass singletonClass = SingletonClass();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playReceiveSound() async {
    try {
      await _audioPlayer.play(AssetSource('recieve.mp3'));
    } catch (e) {
      debugPrint("🔊 Receive sound error: $e");
    }
  }

  void initSocket() {
    if (socket != null && socket!.connected) {
      print("⚡ Socket already connected, skipping re-init");
      return;
    }

    String? userId = singletonClass.getJWTModel()?.employeeId;
    String? tenantId = singletonClass.tenantId;

    String? socketBaseUrl = singletonClass.baseURL;
    if (socketBaseUrl!.endsWith('/api')) {
      socketBaseUrl = socketBaseUrl.substring(0, socketBaseUrl.length - 3);
    }

    log("🚀 Connecting socket with userId=$userId, tenantId=$tenantId");
    log("🚀 Connecting global socket...");
    socket = IO.io(
      "${socketBaseUrl}chat",
      IO.OptionBuilder()
          .setTransports(["websocket", "polling"])
          .disableAutoConnect()
          .setQuery({"tenantId": tenantId, "userId": userId})
          .setPath("/socket.io")
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );
    print(socketBaseUrl);
    socket!.on("chatNotification", (data) {
      debugPrint("🔔 Notification: $data");
      _handleBroadcastEvent(data);
    });
    socket!.on('messagesMarkedAsRead', (data) async {
      try {
        singletonClass.getChats();
        log("🔄 Chats refreshed after mark as read  new message");
      } catch (e) {
        log("⚠️ Error refreshing chats: $e");
      }
    });
    socket!.on('receiveMessage', (data) async {
      await singletonClass.getChats();
      log("💬 Incoming message: $data");

      try {
        final msg = ChatHistory.fromJson(data);
        final currentUserId = singletonClass.getJWTModel()?.employeeId ?? "";
        final currentChatId = singletonClass.activeChatRoomId;
        String? incomingRoomId = data["_id"]?.toString();
        print("CDCD$currentChatId");
        print("XDXDXD$incomingRoomId");
        if (msg.senderId != currentUserId && incomingRoomId != currentChatId) {
          _playReceiveSound();
        }
      } catch (e) {
        log("⚠️ Error parsing message: $e");
      }

      if (singletonClass.slackDataList.isEmpty ||
          singletonClass.slackDataList.first.data == null ||
          singletonClass.slackDataList.first.data!.isEmpty) {
        debugPrint("⚠️ No chat data available in singleton");
        singletonClass.unreadCount = 0;
        return;
      }

      final allChats = singletonClass.slackDataList.first.data!;
      final userId = singletonClass.getJWTModel()?.employeeId;

      final unreadChats = allChats.where((chat) {
        if (chat.roomType != "direct") return false;
        final messages = chat.chatHistory ?? [];
        return messages.any((m) => m.isRead == false && m.senderId != userId);
      }).toList();

      singletonClass.unreadCount = unreadChats.length;
      debugPrint("✅ Direct chats with unread messages: ${unreadChats.length}");
    });

    socket!.connect();
    socket!.onConnect((_) {
      log("✅ Global socket connected: ${socket!.id}");
    });

    socket!.onDisconnect((reason) {
      log("❌ Socket disconnected: $reason");
    });

    socket!.onConnectError((err) {
      log("⚠️ Socket connect error: $err");
    });

    socket!.onError((err) {
      log("⚠️ Socket general error: $err");
    });
  }

  Future<void> _handleBroadcastEvent(dynamic data) async {
    try {
      if (data == null) return;
      final message = data['message'] ?? 'New Broadcast Event';
      final title = data['name'] ?? 'New Broadcast Event';
      NotificationService.showNotification(
        title: title,
        body: message,
      );
    } catch (e, st) {
      debugPrint('❌ Error in _handleBroadcastEvent: $e\n$st');
    }
  }

  IO.Socket? getSocket() => socket;
}
