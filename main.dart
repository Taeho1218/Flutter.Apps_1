import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'result.dart';
import 'dart:io';
import 'imageselect.dart';
import 'test_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();

}


class _MyHomePageState extends State<MyHomePage> {

  File? result ;
  late final WebViewController _webViewController;
  String prediction = '분류 중...';
  late String name = prediction+'띠';

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
          print("✅prediction=,$prediction");
          if(prediction != '분류 중...'){
            print(name);
            Navigator.push(
              context,
              MaterialPageRoute(
                // builder: (context) => HtmlClassifierPage(imageFile: result!), // ✅ ! 사용으로 null 아님 보장, 싫험 페이지
                builder: (context) => FinalWeb(imageFile: result!,  final_result: name,),
              ),
            );
          }
        },
      );
    // _loadHtml();
  }

  // void waitResult() async{
  //
  // }

  void pickImage()async{
    final File? selectedImage = await Navigator.push(context, MaterialPageRoute(builder:(context)=> ImageSelect()),);
    if (selectedImage != null) {
      setState(() {
        result = selectedImage;  // ✅ 이미지 저장 후 화면 갱신
      });
    }
  }

  Future<void> _loadHtml() async {
    final htmlString = await rootBundle.loadString('assets/index.html');
    _webViewController.loadHtmlString(htmlString);

    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) async {
          // 이미지 전달 준비
          if (result != null) {
            final bytes = await result!.readAsBytes();
            final base64Image = base64Encode(bytes);
            final jsCode =
                "loadImageFromFlutter('data:image/jpeg;base64,$base64Image')";

            // 줄바꿈 제거 (JS 에러 방지)
            final cleanBase64 = base64Image.replaceAll('\n', '').replaceAll('\r', '');

            // JavaScript 함수 호출 (이미지 전달)
            final jsCommand = 'loadImageFromFlutter("data:image/jpeg;base64,$cleanBase64");';

            print("✅ JS 호출 준비됨: $jsCommand");
            await _webViewController.runJavaScript(jsCommand);
            print("✅ base64 길이: ${base64Image.length}");
          }

        },
      ),
    );
  }


  @override


  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          body: Container(
              child : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: 400, height: 100,
                      child:                     Container(
                        child:Center(
                          child: Text("닮은꼴 운세 뽑기", style: TextStyle(fontSize: 40),),
                        ),
                      ),

                    ),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: (){
                              print("이미지 선택페이지로 이동");
                              pickImage();
                            },
                            child:   Stack(
                              children: [
                                Image.asset(
                                  'assets/images/img_mainSnake.jpg',
                                  width: 350,
                                  height: 450,
                                  fit: BoxFit.cover,),
                                Positioned(
                                    top:250 ,
                                    left: 100,
                                    child:
                                    SizedBox(
                                        width: 100, height: 100,
                                        child:
                                          result != null
                                            ? CircleAvatar(
                                            backgroundImage: FileImage(result!)
                                            )
                                              :CircleAvatar(
                                              backgroundImage:AssetImage('assets/images/img_mainSnake.jpg')
                                          )

                                    )
                                ),
                              ],
                            ),
                          ),


                          SizedBox(height: 20,),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50) ),
                              onPressed: (){
                                print("FianlWeb 으로 이동 ");
                                if (result != null) {
                                  showDialog(context: context, builder: (BuildContext ctx){
                                    return AlertDialog(
                                      content: Container( height: 250,
                                        child: Column(
                                          children: [
                                            Text('잠시만 기다려 주세요! 닮은 동물을 찾는 중입니다 . . .'),
                                            SizedBox(height: 30),
                                            Image.asset('assets/images/alert_snake.png',
                                              width: 200,
                                              height: 150,
                                              fit: BoxFit.cover,)
                                            ]
                                        )
                                      )
                                    );
                                  });

                                  _loadHtml();
                                }else{
                                  showDialog(context: context, builder: (BuildContext ctx){
                                    return AlertDialog(
                                      content: Text('사진을 선택해 주세요'),
                                      actions: [
                                        Center(
                                          child: FloatingActionButton(
                                              child: Text('네'),
                                              onPressed:(){
                                                Navigator.of(context).pop();
                                              }
                                          ),

                                        )
                                      ],
                                    );
                                  });
                                }
                              },
                              child: Text("결과 보기")),
                        ]
                    ),


                  ],
                ),
              )

          ),
        )
    );


  }

}
