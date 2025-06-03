import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/singleton_class.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:provider/provider.dart';
import 'package:nashr/l10n/app_localizations.dart';
import '../Controller/language_change_controller.dart';

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
  bool _isRecording = false;
  late FlutterSoundPlayer _player;
  String? _recordedFilePath;
  bool _isPlaying = false;
  List<String> _suggestedMessages = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeAudio();
    _scrollToBottom();
    Future.delayed(Duration(milliseconds: 300), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    Future.delayed(Duration.zero, () async {
      await postMessages("");
    });
    _speech = stt.SpeechToText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _suggestedMessages = [
      AppLocalizations.of(context)!.tellMeAboutDocuments,
      AppLocalizations.of(context)!.showMyInfo,
      AppLocalizations.of(context)!.leaveBalance,
      AppLocalizations.of(context)!.myDepartment,
      AppLocalizations.of(context)!.whoIsDeveloper,
    ];
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
                  AppLocalizations.of(context)!.nassMudeer,
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
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isUser ? Colors.white : Colors.black,
                                      ),
                                      children: _parseMarkdown(message['text'] ?? ""),
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: _suggestedMessages.map((suggestion) {
                              return ActionChip(
                                label: Text(suggestion),
                                backgroundColor: Colors.grey.shade200,
                                onPressed: () {
                                  postMessages(suggestion);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
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
                            onSubmitted: (_) => postMessages(_messageController.text),
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
                            color: _isListening ? Colors.red : NasColors.onTime,
                          ),
                          onPressed: _handleMicPress,
                        ),
                        isBotTyping
                            ? IconButton(
                          icon: Image.asset(
                            'images/send.png',
                            height: 24,
                            width: 24,
                            color: Colors.grey,
                          ),
                          onPressed: null, // disables the button
                        )
                            : IconButton(
                          icon: Image.asset(
                            'images/send.png',
                            height: 24,
                            width: 24,
                            color: NasColors.onTime,
                          ),
                          onPressed: () async {
                            await postMessages(_messageController.text);
                            _messageController.clear();
                          },
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

  void _handleMicPress() async {
    var systemLocale = await _speech.systemLocale();
    var currentLocaleId = systemLocale?.localeId ?? '';
    print(currentLocaleId);
    if (_isListening) {
      setState(() => _isListening = false);
      await _speech.stop();
    } else {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('Speech status: $val');
          if ((val == 'done' || val == 'notListening') && _isListening) {
            _speech.listen(
              localeId: currentLocaleId,
              onResult: (val) {
                setState(() {
                  _messageController.text = val.recognizedWords;
                });
              },
            );
          }
        },
        onError: (val) => print('Speech error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'en_US',
          onResult: (val) {
            setState(() {
              _messageController.text = val.recognizedWords;
            });
          },
        );
      }
    }
  }






  //CHAT API CALL
  Future<void> postMessages(String text) async {
    String userMessage = text.trim();
  if (userMessage.isNotEmpty) {
    _addUserMessage(userMessage); // Only add if not empty
    _messageController.clear();
  }

  String? employeeID = singletonClass.getJWTModel()?.empId;
  final currentLang = Provider.of<LanguageChangeController>(context, listen: false).appLocale?.languageCode ?? 'en';


  Map<String, dynamic> data = {
      "request": {
        "employee_id": employeeID,
        "message": userMessage,
        "language": currentLang,
      },
    };

    String body = json.encode(data);
    debugPrint("Request JSON POST: $body");

    var uri = Uri.parse('https://madir.nashrms.com/chat');

    try {
      setState(() {
        isBotTyping = true;
      });

      final response = await http.post(
        uri,
        body: body,
        headers: {
          "Content-Type": "application/json",
          "accept": "application/json",
        },
      );

      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
      debugPrint("MESSAGE RESPONSE: $decodedResponse");

      int responseCode = decodedResponse['statusCode'] ?? response.statusCode;

      if (responseCode == 200) {
        String? botReply = decodedResponse['response'];
        if (botReply != null && botReply.isNotEmpty) {
          _addBotMessage(botReply);
        } else {
          _addBotMessage("Sorry, I couldn't understand that.");
        }
      } else {
        _addBotMessage("Something went wrong. Please try again later.");
      }
    } catch (e) {
      debugPrint("POST MESSAGE ERROR: $e");
      _addBotMessage("Network error. Please try again.");
    } finally {
      setState(() {
        isBotTyping = false;
      });
    }
  }

  //RICH TEXT METHOD
  List<TextSpan> _parseMarkdown(String text) {
    final List<TextSpan> spans = [];
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');

    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Handle headings starting with ###
      if (line.startsWith('###')) {
        final headingText = line.replaceFirst('###', '').trim();
        spans.add(TextSpan(
          text: '$headingText\n',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ));
        continue;
      }

      final matches = boldRegex.allMatches(line);

      if (matches.isEmpty) {
        spans.add(TextSpan(text: '$line\n'));
      } else {
        int lastIndex = 0;

        for (final match in matches) {
          if (match.start > lastIndex) {
            spans.add(TextSpan(text: line.substring(lastIndex, match.start)));
          }

          spans.add(TextSpan(
            text: match.group(1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ));

          lastIndex = match.end;
        }

        if (lastIndex < line.length) {
          spans.add(TextSpan(text: line.substring(lastIndex)));
        }

        spans.add(const TextSpan(text: '\n')); // Ensure line break after bold line
      }
    }

    return spans;
  }


}
