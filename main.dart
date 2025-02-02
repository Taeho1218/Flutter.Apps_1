// import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'result.dart';
import 'dart:io';
import 'imageselect.dart';
void main() {
  runApp(const MyApp());
}
// class OutlineText extends StatelessWidget{
//   final Text child;
//   final double strokeWidth;
//   final Color? strokeColor;
//   final TextOverflow? overflow;
//
//   const OutlineText(
//       this.child, {
//         super.key,
//         this.strokeWidth = 2,
//         this.strokeColor,
//         this.overflow,
//   });
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Text(
//       // textScaleFactor: child.textScaleFactor,
//       child.data!,
//       style: TextStyle(
//         fontSize: child.style?.fontSize,
//         fontWeight: child.style?.fontWeight,
//         foreground: Paint()
//           ..color = strokeColor ?? Theme.of(context).shadowColor
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = strokeWidth,
//           ),
//           overflow: overflow,
//         ),
//       ],
//     );
//   }
// }

class ImageSelect extends StatefulWidget{
  ImageSelect({Key? key}) : super(key: key);

  @override
  State<ImageSelect> creatState() => _ImageSelectState();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _ImageSelectState extends State<ImageSelect>{

  XFile? image;

  @override
  void initstate() {
    super.initState();
  }

  @override
  void dispose() {
    super.initState();
  }

  void ImagePressed() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return  ScreenUtilInit(
      designSize:  const Size(602, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child){
        return MaterialApp(
            home: Scaffold(
              body: Container(width: 602,
                child: Column(
                  children: [
                    Container(width:602, height: 100 ,
                      child:Center(
                        child: Text("사이트 이름", style: TextStyle(fontSize: 40),),
                      ),
                    ),
                    Column(
                      //
                        children: [
                          // SizedBox(height: 50,),
                          GestureDetector(
                            onTap: () {
                              print("이미지를 눌렀습니다");
                              Navigator.push(context,
                               MaterialPageRoute(builder: (context)=>ImageSelect() ) );

                              child:
                              Image.asset(
                                'assets/images/img_mainSnake.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              );
                            },
                          ),

                          // SizedBox(height: 50,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: Size(20, 50) ),
                              onPressed: (){
                              print("FianlWeb 으로 이동 ");
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const FinalWeb()  ) );
                              }, //여기가 문제 해걀해야함
                              child: Text("결과 보기")),
                        ]
                    ),
                  ],
                ),
              ),
            )
        );
      },
    );
  }
}
