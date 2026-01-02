import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../widgets/colors.dart';

class NoticeBoardOverlay extends StatelessWidget {
  final dynamic notice;
  const NoticeBoardOverlay({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient:  LinearGradient(
              colors: [
                Color(0xFF09212C),
                Color(0xFF043E49),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black26,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                ],
              ),
              /// TITLE
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: Lottie.asset(
                      'images/Announcement.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Spacer(),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Color(0xFF6DDCFF),
                        Color(0xFF7F60F9),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Text(
                      notice.title ?? 'Notice',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // This color will be ignored
                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                      onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.close,
                    color: Colors.white,
                  ))
                ],
              ),

              const SizedBox(height: 12),

              /// MESSAGE
              Text(
                notice.notificationMessage ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              /// ATTACHMENT
              if (notice.attachment != null &&
                  notice.attachment.toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    notice.attachment,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
