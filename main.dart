import 'dart:async';
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
  File? finalImage;
  void pickImage()async{
   final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ImageSelect()));
    if (result != null && result is File) {

        selectedImage = result;
        print(selectedImage,);
        print("사진파일 이동완료",);

    }
    else{print("이미지 메인에전송 안됌");};
  }

  void changeImage(){
    setState(() {
      if(selectedImage != null){
       // finalImage = '${documentDirectory.path}/downloaded_image_${DateTime.now().toString()}.jpg';
        Image.file(selectedImage!, width: 50, height: 50);
        print("사용자 선택이미지로 변환");
      }
      else{
        // finalImage = Image.asset('assets/images/img_mainSnake.png',);
        print("사용자의 선택 이미지 없음");
      };
  });
  }

  void TimeImage(){
    Timer.periodic(Duration(seconds: 1), (timer) {
      changeImage();
      print("1초마다 비교중");
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
                          child: Text("사이트 이름", style: TextStyle(fontSize: 40),),
                        ),
                      ),

                    ),
                    Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          InkWell(
                            onTap: () async {
                              print("이미지 선택페이지로 이동");
                              TimeImage();
                              pickImage();
                            },
                            child:   Stack(
                              children: [
                                Image.asset(
                                  'assets/images/img_mainSnake.png',
                                  width: 350,
                                  height: 450,
                                  fit: BoxFit.cover,),
                                Positioned(
                                    top:265 ,
                                    left: 62,
                                    child:
                                     selectedImage != null
                                         ? (() {
                                             // pickImage();
                                             // TimeImage();
                                          //  return Image.file(selectedImage!, width: 50, height: 50);
                                       print('파일 이미지 들어옴');
                                            return Image.asset('assets/images/img_mainSnake.png', width: 50,height: 50,);

                                             // return setState(() {
                                             //    //변경된 사진 가져오기
                                             // });
                                             // return Image.asset('assets/images/img_mainSnake.png', width: 50, height: 50,);
                                                  })()
                                         : (() {
                                            print('기본 이미지');
                                            return Image.asset('assets/images/dog.test.jpg', width: 70, height: 70);
                                            })(),


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
