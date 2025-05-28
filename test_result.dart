import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class HtmlClassifierPage extends StatefulWidget {
  final File imageFile;
  const HtmlClassifierPage({super.key, required this.imageFile});

  @override
  State<HtmlClassifierPage> createState() => _HtmlClassifierPageState();
}

class _HtmlClassifierPageState extends State<HtmlClassifierPage> {
  late final WebViewController _webViewController;
  String prediction = '분류 중...';

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ResultChannel',
        onMessageReceived: (JavaScriptMessage msg) {
          setState(() {
            prediction = msg.message;
          });
          print(prediction);
        },
      );

    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final htmlString = await rootBundle.loadString('assets/index.html');
    _webViewController.loadHtmlString(htmlString);

    // 이미지 전달 준비
    // final bytes = await widget.imageFile.readAsBytes();
    // final base64Image = base64Encode(bytes);
    // final jsCode = "loadImageFromFlutter('data:image/jpeg;base64,$base64Image')";
    // await Future.delayed(Duration(seconds: 1)); // 로딩 지연
    // _webViewController.runJavaScript(jsCode);
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) async {
          // 이미지 전달 준비
          final bytes = await widget.imageFile.readAsBytes();
          final base64Image = base64Encode(bytes);
          final jsCode =
              "loadImageFromFlutter('data:image/jpeg;base64,$base64Image')";
          await _webViewController.runJavaScript(jsCode);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teachable Machine 결과')),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _webViewController)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("결과: $prediction", style: TextStyle(fontSize: 18)),

          ),
        ],
      ),
    );
  }
}
