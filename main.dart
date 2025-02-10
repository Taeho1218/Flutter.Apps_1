import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'result.dart';
import 'dart:io';
import 'imageselect.dart';


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
  File? selectedImage;

  void pickImage()async{
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ImageSelect()));
    if (result != null && result is File) {
      setState(() {
        selectedImage = result;
        print("이미지 메인에 저장 완료");
      });
    }
  }

  // void  userImage(){
  //   유저의 이미지를 1초마다 비교해서 이미지를 산출하도록 하기
  // }


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
                                          child: Text("사이트 이름", style: TextStyle(fontSize: 40),),
                                        ),
                                      ),

                                    ),
                                      Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                print("이미지 선택페이지로 이동");
                                                // _ImageSelectState();
                                                Navigator.push(context,MaterialPageRoute(builder: (context) =>  const ImageSelect()));
                                                // ImagePressed(); 나의 저장공간에서 이미지를 불러오는 위젯을 연결해야함.
                                              },
                                              child:   Stack(
                                                children: [

                                                Image.asset(
                                                'assets/images/img_mainSnake.png',
                                                width: 350,
                                                height: 450,
                                                fit: BoxFit.cover,),
                                                  Positioned(
                                                      top:275 ,
                                                      left: 75,
                                                      child:
                                                      selectedImage != null
                                                       ? Image.file(selectedImage! ,width: 50, height: 50,)
                                                       : Image.asset('assets/images/img_mainSnake.png',width: 50, height: 50, )
                                            //           if(selectedImage != null){
                                            //             Image.file(selectedImage , width : 50, height: 50,)
                                            // }else{
                                            //             Image.asset('assets/images/img_mainSnake.png',width: 50, height: 50,)
                                            // };

                                                  ),
                                                ],
                                              ),
                                              ),


                                            SizedBox(height: 50,),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(minimumSize: Size(200, 50) ),
                                                onPressed: (){
                                                  print("FianlWeb 으로 이동 ");
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FinalWeb()  ) );
                                                }, //여기가 문제 해걀해야함
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
