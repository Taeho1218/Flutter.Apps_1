import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("cards");


  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //   theme: ThemeData.dark().copyWith(
      // scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),),
      home: MyHomePage(),
    );
  }

}
///스크롤투 위젯을 카드작성란을 새롭이 만들때마다 호출해야함
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  TextEditingController textEditingController = TextEditingController();
  List<String> cardList = [];
  bool _isSubmitted = false;
  String _curDate = "";
  String cdate = "";

  final _globalKey = GlobalKey();
  var box = Hive.box('cards');

  void scrollToWidget(){
    if (_globalKey.currentContext != null) {
      Scrollable.ensureVisible(_globalKey.currentContext!);
    }

    // Scrollable.ensureVisible(_globalKey.currentContext as BuildContext);
    // print("눌렀습니댜");
  } // 스크롤 지정


  // 하루에 한개만 생성가능하게 하기
  @override
  void initState() {
    super.initState();

    var keys = box.keys.toList();
    for (String key in keys) {
      String card = box.get(key); // 이 부분에서 key를 사용하여 해당 키에 맞는 값을 가져옵니다.

      print("저장된 hive card?? key?: $key, card?: $card");

      cardList.add(card);
    }



    _curDate = getToday();

    // "key == _curDate"가 원래 if안에 들어가야함

    if (box.containsKey(_curDate)){
      noMoreInput();
      print("날짜가 같아요");
      print(_curDate);
    }else{
      showInput();

    }
    scrollToWidget();


    Timer.periodic(const Duration(milliseconds:1000), (timer) {
      // 당일 날짜 확ㄷ인하고 입력받은 카드랑 같으면 더 못쓰게 하기


      // if (box.containsKey(_curDate)){
      //
      //   // 내가 글을 작성했을때 하루에 한번만 글을 쓰게 하는기능
      //   // 하루에 한번은 당일날짜로 쓰는 카드가 한개만 존재해야함
      //   noMoreInput();
      //   print("%$_curDate의 날짜의 작성된 카드가 있어요");
      //   print(_curDate + "key: ${box.keys.toList()}");
      // }else{
      //   // 당일날짜로 된 카드가 하나도 없을시
      //   // 당일날짜로된 카드작성가능하게
      //   showInput();
      //
      //   if(_curDate != getToday()) {
      //     _curDate = getToday();
      //
      //     scrollToWidget();
      //   }
      //
      // }
      if(_curDate == getToday()) {
        if (box.containsKey(_curDate)){
          noMoreInput();
          print("%$_curDate의 날짜의 작성된 카드가 있어요");
          print(_curDate + "key: ${box.keys.toList()}");
        }
        else{}
      }
      else{
        _curDate = getToday();
        showInput();
        scrollToWidget();

      }




    });

    WidgetsBinding.instance.addPostFrameCallback(
            (_) {
          scrollToWidget();

        }
    );
  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("하루한줄"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (cardList.isNotEmpty)
                  Column(
                    children: cardList.map((text) {
                      return Card(
                        child: ListTile(
                          title: Text(text),
                        ),
                      );
                    }).toList(),
                  ),


                SizedBox(height: 20),
                _isSubmitted
                    ? SizedBox.shrink()
                    : Card(
                  child: Container(
                    child: Row(
                        children: [
                          Container(
                              width: 100,
                              height: 50,

                              child:Column(
                                children: [
                                  Text("하루한줄"),
                                  Text(_curDate),
                                ],
                              )


                          ),




                          Flexible(
                            child: TextField(
                              maxLength: 34,
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,),
                              onChanged:(text) {

                              },
                              //당일 날짜가 나오도록 클래스만들기,
                            ),
                          ),
                        ]
                    ),

                  ),

                ),
                SizedBox(height: 20),
                Container(


                  child:
                  _isSubmitted
                      ? SizedBox.shrink()
                      :ElevatedButton(

                    onPressed: ( ) {
                      _submitTextFromButton();
                      scrollToWidget();
                      noMoreInput();

                    },
                    child: Text('작성완료'),
                  ),
                ),
                SizedBox(key: _globalKey,
                    height: 60),
              ],
            ),
          ),
        ),
      ),
    );

    // 플러스버튼 누르면 카드가 하나 추가 글이 써있지 않을때만 생성
  }


  void _submitTextFromButton() {
    if (textEditingController.text.isNotEmpty) {
      setState(() {
        _processTextSubmission(textEditingController.text);
        textEditingController.clear();
        // Call scrollToWidget after adding the new card
      });
    }
  }

  void _processTextSubmission(String enteredText) {
    final String  cdate = getToday();
    print("$cdate");
    String finalText = cdate + " " + enteredText;
    setState(() {

      cardList.add(finalText);
      box.put("$cdate", finalText);

      var hiveData = box.get("$cdate");

      print("입력받은 card:$finalText");
      print("hive card:$hiveData");

    });

    Future.delayed(Duration(milliseconds: 100), () {
      scrollToWidget();
    });
  }

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    var strToday = formatter.format(now);
    return strToday;
  }

  void noMoreInput(){
    setState(() {
      _isSubmitted = true;
    });
  }
  void showInput(){
    setState(() {
      _isSubmitted = false;
    });
  }

}