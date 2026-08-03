import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:nashr/l10n/app_localizations.dart';
import 'package:nashr/screens/pdf_viewer_screen.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentListTab extends StatefulWidget {
  final List<dynamic> documentsInfo;
  final Future<void> Function() onRefresh;
  final String searchQuery;

  const DocumentListTab({
    super.key,
    required this.documentsInfo,
    required this.onRefresh,
    this.searchQuery = '',
  });

  @override
  State<DocumentListTab> createState() => _DocumentListTabState();
}

class _DocumentListTabState extends State<DocumentListTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getFileIcon(String fileUrl) {
    final extension = fileUrl.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'images/pdf.png';
      case 'doc':
      case 'docx':
        return 'images/word.png';
      case 'xls':
      case 'xlsx':
        return 'images/excel.png';
      case 'ppt':
      case 'pptx':
        return 'images/powerPoint.png';
      default:
        return 'images/documentIcons.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    
    // Filter documents by search query if any
    final effectiveQuery = widget.searchQuery.isNotEmpty ? widget.searchQuery : _searchQuery;
    final query = effectiveQuery.toLowerCase().trim();
    final visibleDocs = widget.documentsInfo.where((doc) {
      if (query.isEmpty) return true;
      final type = doc.type?.toString().toLowerCase() ?? '';
      return type.contains(query);
    }).toList();

    return Column(
      children: [
        // List View
        Expanded(
          child: RefreshIndicator(
            color: NasColors.darkBlue,
            backgroundColor: Colors.white,
            onRefresh: widget.onRefresh,
            child: visibleDocs.isNotEmpty
                ? ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: visibleDocs.length,
                    itemBuilder: (context, index) {
                      final doc = visibleDocs.reversed.toList()[index];
                      const String s3BaseUrl = 'https://nastecsol-hr-store.s3.amazonaws.com/';
                      final String url = [
                        doc.url,
                        doc.remarks,
                      ].firstWhere(
                        (value) => value != null && value.toString().contains(s3BaseUrl),
                        orElse: () => '',
                      );
                      
                      final fileType = url.split('.').last.toLowerCase();
                      final isImage = ['png', 'jpg', 'jpeg', 'gif'].contains(fileType);

                      return GestureDetector(
                        onTap: () {
                          if (url.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FileViewerScreen(
                                  url: url,
                                  fileName: "${doc.type}",
                                ),
                              ),
                            );
                          } else {
                            debugPrint('Invalid attachment URL');
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      doc.type == "Doc_Contract_Emp"
                                          ? l.employmentContract
                                          : doc.type == "Doc_Uploaded_EMP"
                                              ? l.uploadedDocument
                                              : doc.type ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: NasColors.darkBlue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.grey.shade400,
                                    size: 16,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: isImage
                                        ? Image.network(
                                            url,
                                            height: 52,
                                            width: 80,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topCenter,
                                          )
                                        : Image.asset(
                                            _getFileIcon(url),
                                            height: 52,
                                            width: 52,
                                          ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () async {
                                      if (url.isNotEmpty) {
                                        final uri = Uri.parse(url);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                                        } else {
                                          debugPrint('Could not launch $url');
                                        }
                                      } else {
                                        debugPrint('Invalid download URL');
                                      }
                                    },
                                    child: Image.asset(
                                      'images/download.png',
                                      height: 32,
                                      width: 32,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 180,
                            width: 180,
                            child: Lottie.asset('images/empty.json'),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l.noData,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: NasColors.darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
