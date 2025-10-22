import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:nashr/widgets/colors.dart';

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
      // ✅ Use Microsoft Office Online viewer for Excel/Word/PPT
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
        title: Text(widget.fileName, overflow: TextOverflow.ellipsis),
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
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
