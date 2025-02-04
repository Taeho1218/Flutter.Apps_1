import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class FinalWeb extends StatelessWidget {
  const FinalWeb({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(
        //   title: Text("ResultPage"),
        // ),
        body: Container(
          child: SingleChildScrollView(
          child:Column(
            children: [
              SizedBox(height: 50,),
              Image.asset('assets/images/img_mainSnake.png',
                width: 300,
                height:300,
                fit: BoxFit.cover,), //닮은 꼴 이미지 등록
              SizedBox(height: 50,),
              Center(
                child:
                Row(
                  children: [
                    SizedBox(width: 120,),

                    Image.asset('assets/images/img_mainSnake.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,),//선택한 이미지들어갈 화면
                    Text("닮은꼴 이름"),//닮은 꼴 이미지이름
                  ],
                ),
              ),

              SizedBox(height: 50,),
              Text("닮은꽇 해설")

            ],
          ) ,
          ),

        ),
      ),


    );
  }
}
