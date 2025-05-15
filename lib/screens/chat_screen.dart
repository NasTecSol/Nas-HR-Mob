import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  SingletonClass singletonClass = SingletonClass();
  bool isBotTyping = false;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late FlutterSoundRecorder _recorder;
  bool _isRecorderInitialized = false;
  bool _isRecording = false;
  late FlutterSoundPlayer _player;
  String? _recordedFilePath;
  bool _isPlaying = false;
  final List<String> _suggestedMessages = [
    "Tell me about documents",
    "Show my info",
    "Leave balance",
    "My department",
    "Who is the developer?",
  ];


  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeAudio();
    _addBotMessage("Hi, welcome to Nas HR. How can I help you?");
    _scrollToBottom();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  Future<void> _initializeAudio() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
    await _player.openPlayer();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    await _player.setVolume(1.0);
    setState(() {
      _isRecorderInitialized = true;
    });
  }

  Future<void> _togglePlayback() async {
    if (!_player.isOpen()) {
      await _player.openPlayer();
    }

    if (_isPlaying) {
      await _player.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    } else {
      if (_recordedFilePath != null) {
        final file = File(_recordedFilePath!);
        print('Recording size: ${await file.length()} bytes');
        await _player.startPlayer(
          fromURI: _recordedFilePath,
          codec: Codec.aacMP4,
          whenFinished: () {
            setState(() {
              _isPlaying = false;
            });
          },
        );
        await _player.setVolume(1.0);
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({'sender': 'user', 'text': message});
    });
    _scrollToBottom();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({'sender': 'bot', 'text': message});
    });
    _scrollToBottom();
  }

  void _handleSuggestedMessage(String message) {
    _messageController.text = message;
    _handleSendMessage();
  }

  void _handleSendMessage() {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addUserMessage(text);
    _messageController.clear();

    setState(() {
      isBotTyping = true;
    });
    FocusScope.of(context).requestFocus(_focusNode);
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        isBotTyping = false;
      });

      final textLower = text.toLowerCase().trim();
      final info = singletonClass.employeeDataList.first.data?.employeeInfo?.first;
      final info2 = singletonClass.employeeDataList.first.data;

      bool matches(String pattern) => RegExp(r'\b(' + pattern + r')\b').hasMatch(textLower);

      if (matches(r'hello|hi')) {
        _addBotMessage("Greetings! How can I assist you today?");
      } else if (matches(r'attendance')) {
        _addBotMessage("You can view your attendance and clocking data from the dashboard.");
      } else if (matches(r'document|documents')) {
        _addBotMessage("You can find documents under the 'Documents' section.");
      } else if (matches(r'assets?')) {
        _addBotMessage("You can manage or view assets under the 'Assets' tab.");
      } else if (matches(r'team')) {
        _addBotMessage("Team attendance and details are available in the 'Team Attendance' tab.");
      } else if (matches(r'request|requests')) {
        _addBotMessage("You can submit new requests from the 'Requests' section.");
      } else if (matches(r'owner')) {
        _addBotMessage("The owner of this system is Mr. Nassar Ibarahim.");
      } else if (matches(r'developer')) {
        _addBotMessage("This system was developed by Suleman Azeem Khan.");
      } else if (matches(r'my info|who am i|show my details|details')) {
        if (info != null) {
          _addBotMessage(
              "Here is your information:\n"
                  "• Name: ${info2?.firstName ?? "N/A"} ${info2?.middleName ?? "N/A"} ${info2?.lastName ?? "N/A"}\n"
                  "• Designation: ${info.designation ?? "N/A"}\n"
                  "• Grade: ${info.grade ?? "N/A"}\n"
                  "• Department: ${info.depName ?? "N/A"}\n"
                  "• Employee ID: ${info.empId ?? "N/A"}");
        } else {
          _addBotMessage("Sorry, your information is not available.");
        }
      } else if (matches(r'name|my name')) {
        _addBotMessage("Your name is: ${info2?.firstName ?? "N/A"} ${info2?.middleName ?? ""} ${info2?.lastName ?? ""}");
      } else if (matches(r'username|user name')) {
        _addBotMessage("Your username is: ${info2?.userName ?? "N/A"}");
      } else if (matches(r'marital status|status')) {
        _addBotMessage("Your marital status is: ${info2?.martialStatus ?? "N/A"}");
      } else if (matches(r'religion')) {
        _addBotMessage("Your religion is: ${info2?.religion ?? "N/A"}");
      } else if (matches(r'address')) {
        _addBotMessage("Your address is: ${info2?.address?.country ?? "N/A"} ${info2?.address?.city ?? "N/A"} ${info2?.address?.streetAddress ?? "N/A"}");
      } else if (matches(r'nic|cnic')) {
        _addBotMessage("Your NIC number is: ${info2?.nic ?? "N/A"}");
      } else if (matches(r'iqama')) {
        _addBotMessage("Your Iqama number is: ${info2?.iqamaNumber?.id ?? "N/A"}");
      } else if (matches(r'passport')) {
        _addBotMessage("Your passport number is: ${info2?.passport?.id ?? "N/A"}");
      } else if (matches(r'immigration|immigration status')) {
        _addBotMessage("Your immigration status is: ${info2?.imigrationSatus ?? "N/A"}");
      } else if (matches(r'dob|birth|date of birth')) {
        _addBotMessage("Your date of birth is: ${info2?.dob ?? "N/A"}");
      } else if (matches(r'what is my age|my age|^age$')) {
        _addBotMessage("Your age is: ${info2?.age ?? "N/A"}");
      } else if (matches(r'gender')) {
        _addBotMessage("Your gender is: ${info2?.gender ?? "N/A"}");
      } else if (matches(r'role')) {
        _addBotMessage("Your role is: ${info2?.role ?? "N/A"}");
      } else if (matches(r'profession')) {
        _addBotMessage("Your profession is: ${info2?.profession ?? "N/A"}");
      } else if (matches(r'nationality')) {
        _addBotMessage("Your nationality is: ${info2?.nationality ?? "N/A"}");
      } else if (matches(r'created by')) {
        _addBotMessage("Your record was created by: ${info2?.createdBy ?? "N/A"}");
      } else if (matches(r'branch')) {
        _addBotMessage("Your branch ID is: ${info2?.branchId ?? "N/A"}");
      } else if (matches(r'department|my department')) {
        _addBotMessage("Your department name is: ${info?.depName ?? "N/A"}");
      } else if (matches(r'organization')) {
        _addBotMessage("Your organization ID is: ${info2?.organizationId ?? "N/A"}");
      } else if (matches(r'leave balance|leave summary|leave status|leave')) {
        final sick = info2?.leaveBalance?.sickLeave;
        final annual = info2?.leaveBalance?.annualLeave;
        final casual = info2?.leaveBalance?.casualLeave;

        _addBotMessage("Your leave balances are:\n"
            "• Sick Leave - Total: ${sick?.entitlement ?? "N/A"}, Used: ${sick?.used ?? "N/A"}, Remaining: ${sick?.remaining ?? "N/A"}\n"
            "• Annual Leave - Total: ${annual?.entitlement ?? "N/A"}, Used: ${annual?.used ?? "N/A"}, Remaining: ${annual?.remaining ?? "N/A"}\n"
            "• Casual Leave - Total: ${casual?.entitlement ?? "N/A"}, Used: ${casual?.used ?? "N/A"}, Remaining: ${casual?.remaining ?? "N/A"}");
      } else {
        _addBotMessage("Sorry, I didn't understand that. Can you try again?");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      body: Padding(
        padding: const EdgeInsets.only(top: 45.0, left: 20, right: 20),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_outlined,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  "Nass Mudeer",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: _scrollController,
                      itemCount: _messages.length + (isBotTyping ? 1 : 0), // Add 1 if bot is typing
                      itemBuilder: (context, index) {
                        if (isBotTyping && index == _messages.length) {
                          // Display the typing indicator if it's the last item in the list
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, bottom: 8),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage('images/bot.png'),
                                    radius: 18,
                                  ),
                                  SizedBox(
                                    height: 75,
                                    width: 75,
                                    child: Lottie.asset(
                                        'images/chat2.json'
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final message = _messages[index];
                        final isUser = message['sender'] == 'user';

                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment:
                            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (!isUser)
                                const CircleAvatar(
                                  backgroundImage: AssetImage('images/bot.png',),
                                  radius: 18,

                                ),
                              if (!isUser) const SizedBox(width: 8),
                              Flexible(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isUser ? NasColors.onTime : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    message['text']!,
                                    style: TextStyle(
                                      color: isUser ? Colors.white : Colors.black,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                              if (isUser) const SizedBox(width: 8),
                              if (isUser)
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: (singletonClass.employeeDataList.first.data?.profilePic != null &&
                                      singletonClass.employeeDataList.first.data!.profilePic!.isNotEmpty)
                                      ? NetworkImage(singletonClass.employeeDataList.first.data!.profilePic!)
                                      : const AssetImage('images/DP.png') as ImageProvider,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestedMessages.map((suggestion) {
                        return ActionChip(
                          label: Text(suggestion),
                          backgroundColor: Colors.grey.shade200,
                          onPressed: () {
                            _handleSuggestedMessage(suggestion);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
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
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _handleSendMessage(),
                          ),
                        ),
                        if (_recordedFilePath != null && !_isRecording)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                                  size: 28,
                                  color: NasColors.darkBlue,
                                ),
                                onPressed: _togglePlayback,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 22,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _recordedFilePath = null;
                                    _isPlaying = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        IconButton(
                          icon: Image.asset(
                            'images/microphone.png',
                            height: 24,
                            width: 24,
                            color: _isRecording ? Colors.red : NasColors.onTime,
                          ),
                          onPressed: _handleMicPress,
                        ),
                        IconButton(
                          icon: Image.asset(
                            'images/send.png',
                            height: 24,
                            width: 24,
                            color: NasColors.onTime,
                          ),
                          onPressed: _handleSendMessage,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMicPress() async {
    if (!_isRecorderInitialized) return;

    if (_isRecording) {
      String? path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });

      if (path != null) {
        final file = File(path);
        final fileBytes = await file.readAsBytes();

        // Logging file size
        debugPrint("Sending audio file of size: ${fileBytes.length} bytes");

        try {
          debugPrint("Audio file sent successfully via WebSocket.");
        } catch (e) {
          debugPrint("Failed to send audio file: $e");
        }
      }
    } else {
      final tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

      await Permission.microphone.request();
      await Permission.storage.request();

      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacMP4,
        bitRate: 256000,
        sampleRate: 44100,
      );

      setState(() {
        _isRecording = true;
        _recordedFilePath = filePath;
      });

      debugPrint("Recording started...");
    }
  }
}
