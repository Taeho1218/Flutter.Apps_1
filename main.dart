import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      home: Scaffold(
        appBar:
         AppBar(title:Text("앱이름") ,
          leading:IconButton(
            icon:Icon(Icons.menu) , onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menu Button Pressed')),);
          },),),
        body: Container(
          child: Column(
            children: [
                Text("들어갈 내용"),

            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, //아이콘들 규격 맞추기.
            children: [
              IconButton(onPressed: (){}, icon: Icon(Icons.account_box)),
              IconButton(onPressed: (){}, icon: Icon(Icons.account_box)),
              IconButton(onPressed: (){}, icon: Icon(Icons.account_box)),
              IconButton(onPressed: (){}, icon: Icon(Icons.account_box)),
            ],
          ),

        ),

      )
    );
  }
}
