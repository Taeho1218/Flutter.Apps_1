import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'result.dart';
import 'dart:io';
import 'imageselect.dart';
import 'test_result.dart';


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

  File? result;
  void pickImage()async{
    final File? selectedImage = await Navigator.push(context, MaterialPageRoute(builder:(context)=> ImageSelect()),);
    if (selectedImage != null) {
      setState(() {
        result = selectedImage;  // ✅ 이미지 저장 후 화면 갱신
      });
    }
  }
  void TimeImage(){
    Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        pickImage();
        print("1초마다 비교중");
      });
    });
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
                                    result != null
                                        ? Image.file(result! ,width: 100, height: 100,)
                                        : Image.asset('assets/images/img_mainSnake.jpg',width: 100, height: 100,)

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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      // builder: (context) => HtmlClassifierPage(imageFile: result!), // ✅ ! 사용으로 null 아님 보장, 싫험 페이지
                                      builder: (context) => FinalWeb(imageFile: result!),
                                    ),
                                  );
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
    //   },
    // );
  }

}
