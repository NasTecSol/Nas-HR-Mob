import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
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

  bool get isPdf => widget.url.toLowerCase().endsWith('.pdf');
  bool get isExcel => widget.url.toLowerCase().endsWith('.xlsx');
  bool get isDoc => widget.url.toLowerCase().endsWith('.docx');
  bool get isPpt => widget.url.toLowerCase().endsWith('.pptx');
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

    final lower = widget.url.toLowerCase();
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
        actions: [
          if (isPdf)
          IconButton(onPressed: () async {
            setState(() => _isLoading = true);

            final file = await _downloadFile(widget.url);

            await _printPdf(file);
            setState(() => _isLoading = false);
          }, icon: Icon(Icons.print))
        ],
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
  ///Helper method to open file
  Future<File> _downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));

    final dir = await getApplicationDocumentsDirectory();
    final fileName = url.split('/').last;
    final file = File('${dir.path}/$fileName');

    return file.writeAsBytes(response.bodyBytes);
  }

  Future<void> _printPdf(File file) async {
    final bytes = await file.readAsBytes();

    await Printing.layoutPdf(
      onLayout: (_) => bytes,
    );
  }
}
