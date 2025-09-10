import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../models/book.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  @override
  void initState() {
    super.initState();
    _secureScreen(true);
  }

  @override
  void dispose() {
    _secureScreen(false);
    super.dispose();
  }

  Future<void> _secureScreen(bool enable) async {
    if (!mounted) return;
    if (Platform.isAndroid) {
      try {
        if (enable) {
          await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        } else {
          await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
        }
      } on PlatformException {
        // Ignore if not supported
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.book.title)),
      body: SfPdfViewer.asset(widget.book.assetPdfPath),
    );
  }
}


