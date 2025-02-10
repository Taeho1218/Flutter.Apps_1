import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:project_taeyoung/main.dart';

class ImageSelect extends StatefulWidget{
  const ImageSelect({super.key});

  @override
  State<ImageSelect> createState() => _ImageSelectState();
}

class _ImageSelectState extends State<ImageSelect>{

  XFile? image; //이미지 선택 파일

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void imagePressed() async {
   final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery); // await - 함수가 끝낳때 까지 기다림.
   // 그 뒤 - 사용자의 갤러리 열어서 이미지 선택 후 파일 타입으로 저장
    setState(() { // UI를 다시 그림.
      print("페이지 넘어와서 이미지 선택 ");
      if (pickedImage != null) {
        image = pickedImage;
        File imageFile = File(pickedImage.path);
        print("이미지가 선택되었습니다");
        Navigator.pop(context,imageFile);
       Navigator.push(context,MaterialPageRoute(builder: (context) =>  MyHomePage()));
       print(" 이미지가 메인으로 전송된 후 메인페이지로 돌아감");
      } else {
          print("이미지 선택이 취소됌");
        };
       }
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(title: Text('이미지 선택기')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이미지 표시 영역
                image != null
                    ? Image.file(File(image!.path), width: 200, height: 200, fit: BoxFit.cover) //파일 타입으로 변환하여 이미지 로드
                    : Text("이미지를 선택해주세요"),

                SizedBox(height: 20),

                // 이미지 선택 버튼
                ElevatedButton(
                  onPressed: imagePressed,
                  child: Text("이미지 선택"),
                ),
              ],
            ),
          ),

    );
  }

}
