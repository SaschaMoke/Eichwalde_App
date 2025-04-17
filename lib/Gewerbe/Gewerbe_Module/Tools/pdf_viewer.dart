import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

class PDFViewer extends StatelessWidget {
  final BoxConstraints constraints;
  final String url;
  final String title;

  const PDFViewer({super.key, required this.constraints, required this.url, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: constraints.maxWidth*0.05,
          ),
          title
        ),
      ),
      body: PDF().cachedFromUrl(
        url,
        placeholder: (double progress) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: constraints.maxWidth*0.05,
                ),
                'Datei wird geladen, bitte warten:' 
              ),
              Text(
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: constraints.maxWidth*0.05,
                ),
                '$progress%' 
              ),
            ],
          ),
        ),
        errorWidget: (error) => Center(
          child: Text(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: constraints.maxWidth*0.05,
              ),
              error.toString()
            ),
        ),
      ),
    );
  } 
}