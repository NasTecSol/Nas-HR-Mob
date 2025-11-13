import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:nashr/widgets/colors.dart';
import 'package:nashr/l10n/app_localizations.dart';
class FileViewerScreen extends StatefulWidget {
  final String url;
  final String fileName;

  const FileViewerScreen({
    super.key,
    required this.url,
    required this.fileName,
  });

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  bool get isPdf => widget.fileName.toLowerCase().endsWith('.pdf');
  bool get isExcel => widget.fileName.toLowerCase().endsWith('.xlsx');
  bool get isDoc => widget.fileName.toLowerCase().endsWith('.docx');
  bool get isPpt => widget.fileName.toLowerCase().endsWith('.pptx');
  bool get isImg {
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.heic',
      '.heif',
      '.tiff',
    ];

    final lower = widget.fileName.toLowerCase();
    return imageExtensions.any((ext) => lower.endsWith(ext));
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
        ),
      );
    if (!isPdf) {

      final officeUrl =
          'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeFull(widget.url)}';
      _controller.loadRequest(Uri.parse(officeUrl));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NasColors.backGround,
      appBar: AppBar(
        title: Text(
            widget.fileName == "Doc_Contract_Emp"
                ? AppLocalizations.of(context)!
                .employmentContract
                :  widget.fileName == "Doc_Uploaded_EMP" ? AppLocalizations.of(context)!.uploadedDocument : widget.fileName,
            overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          if (isPdf)
            SfPdfViewer.network(
              widget.url,
              canShowPaginationDialog: true,
              canShowScrollHead: true,
              enableTextSelection: true,
              onDocumentLoaded: (detail){
                setState(() => _isLoading = false);
              },
            )
          else  if (isImg)
           Image.network(widget.url,)
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
             Center(
              child: CircularProgressIndicator(
                color: NasColors.darkBlue,
              ),
            ),
        ],
      ),
    );
  }
}
