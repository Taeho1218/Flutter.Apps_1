import 'package:flutter/material.dart';
import 'package:tjt_project/firstpostcreate.dart';
import 'postlist.dart';
import 'register.dart';
import 'bottomnavigate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'firstpostcreate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/services.dart';

String? Token ;
String? nickname;
String? gender;
String? age;
String? university_name;
String? user_id;


var real = "$imgsend/api";
var emul = "http://10.0.2.2:3000/api";
var basic = "http://localhost:3000/api";
var imgsend = 'http://35.216.37.60:443';


IO.Socket socket = IO.io('http://localhost:3000', <String, dynamic>{
  'transports': ['websocket'],
  'autoConnect': false,
});
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // 로컬 저장소에서 토큰 값 불러오기
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Token = prefs.getString('token'); // 'token' 키로 저장된 값을 불러옵니다.
  print("저장된 토큰:$Token");
  socket.connect();

  // 불러온 값에 따라 초기 화면 결정
  if (Token != null && Token!.isNotEmpty) {
    // 토큰이 존재하고 비어있지 않으면 HomePage로 이동
    var url = Uri.parse('$basic/auto-login'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("$emul/auto-login");
    var url_real = Uri.parse("$real/auto-login");//에뮬레이터용
    var response = await http.post(
      //url,
      // url_emul,
      url_real,
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer $Token'},
    );
    var jsonResponse = jsonDecode(response.body);
    bool checkPostExists = jsonResponse['postExists']?? false;
    // String user_id = jsonResponse['userId'];
    if (checkPostExists) {
      print('토큰 확인, 유저확인완료: ${response.body}');
      print(jsonResponse);
      socket.emit('login', '$user_id');
      print("소켓 이벤트 전송완료 $user_id");
      runApp(MaterialApp(
        home: BottomNaviagte(),
      ));

    } else if(checkPostExists ==false ){
      print('게시물 작성한적 없는 유저: ${response.body}');
      socket.emit('login', '$user_id');
      print("소켓 이벤트 전송완료 $user_id");
      runApp(MaterialApp(
        home: FirstPostCreate(),
      ));
    }

  } else {
    // 토큰이 없거나 비어있으면 IntroPage (또는 로그인 페이지)로 이동
    runApp(MyApp());
  }


}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}


class Login extends StatefulWidget{
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();

}

class _LoginState extends State<Login>{
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  var pass =0;



  Future<void> saveStringToLocalStorage(String key, String value) async {
    SharedPreferences TokenSaveLocal = await SharedPreferences.getInstance();
    TokenSaveLocal.setString(key, value);
  } //로컬에 저장하는 함수


  Future<void> sendLoginData() async {
    Map <String, String?> _logindata = {
      'user_id' : _idController.text,
      'user_pw': _pwController.text,
    };
    print("정보 보내기 실행중");
    var url = Uri.parse('$basic/login'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("$emul/login"); //에뮬레이터용
    var url_real = Uri.parse("$real/login");
    try {
      var response = await http.post(
        url_real,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_logindata),
      );
      var jsonResponse = jsonDecode(response.body);
      bool checkPostExists = jsonResponse['postExists'];

      if (checkPostExists) {
        print(' 유저확인완료: ${response.body}');
        saveStringToLocalStorage("token", jsonResponse['token']);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Token = prefs.getString('token');
        print("토큰값이 저장되었습니다${saveStringToLocalStorage(
            "token", jsonResponse['token'])}");print("토큰값이 저장되었습니다${saveStringToLocalStorage(
            "token", jsonResponse['token'])}");
        print(jsonResponse);
        socket.emit('login', '$user_id');
        print("소켓 이벤트 전송완료 $user_id");
        Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) => BottomNaviagte()),);

      } else if(checkPostExists ==false ){
        print('게시물 작성한적 없는 유저: ${response.body}');
        saveStringToLocalStorage("token", jsonResponse['token']);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Token = prefs.getString('token');
        print(Token);
        socket.emit('login', '$user_id');
        print("소켓 이벤트 전송완료 $user_id");
        Navigator.of(context).push( MaterialPageRoute(builder: (context) => FirstPostCreate()),);
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }
  @override
  Widget build(BuildContext){
    return Scaffold(

      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // padding:,
              width:MediaQuery.of(context).size.width*0.8,
              height:MediaQuery.of(context).size.height*0.3,
              child: Column(
                children: [
                  Image.asset(
                      width: 200,
                      height: 150,
                      'assets/images/logo.jpg'),
                  Text(
                      "Log In"
                  ),
                ],
              ),
            ),  //로고 보이는 곳

            Container(
              width:MediaQuery.of(context).size.width,
              height:MediaQuery.of(context).size.height*0.2,
              child:Row(
                children:[
                  Column(
                      children:[
                        Container(
                          width: MediaQuery.of(context).size.width*0.65,
                          height: MediaQuery.of(context).size.height*0.1,
                          child: Row(
                              children:[
                                Text("ID"),
                                Expanded(child:  TextField(
                                  decoration: InputDecoration(

                                      border: OutlineInputBorder(),
                                      labelText: '아이디를 입력해주세요'
                                  ),
                                    keyboardType:  TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                              ],
                                  controller:_idController,

                                ),),

                              ]
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.65,
                          height: MediaQuery.of(context).size.height*0.1,
                          child:  Row(
                              children:[
                                Text("PW"),
                                Expanded(child:   TextField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: '비밀번호를 입력하세요',
                                  ),
                                  keyboardType:  TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                  ],
                                  obscureText: true,
                                  controller:_pwController,
                                ),),

                              ]
                          ),
                        ),
                      ]
                  ), //아이디 비밀번호쓰는 칸
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.05,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.25,
                    height: MediaQuery.of(context).size.height*0.1,
                    child: ElevatedButton(

                      onPressed:(){
                        // 아이디와 비밀 번호 비교후 리스트 피이지로 이동, 제이슨 객체형태로 보냄.
                        print("버튼누름");
                        sendLoginData();

                      },
                      child: Text('로그인',
                        style: TextStyle(
                          fontSize: 12
                        ),
                      ),
                    ),
                  ),  // 로그인 버튼
                ],
              ),
            ),  //아이디 로그인 적고 버튼을 눌러 로그인 하는 곳
            Container(
              width:MediaQuery.of(context).size.width*0.8,
              height:MediaQuery.of(context).size.height*0.2,
              child: Row(
                children:[
                  ElevatedButton(
                    onPressed:(){
                      //회원 가입 페이지로 이동
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Register()),
                      );

                    },
                    child: Text('회원가입'),
                  ),  //회원가입 버튼
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.04,
                  ),

                  ElevatedButton(
                    onPressed:(){},
                    child: Text('비밀번호 찾기'),
                  ),  //비밀번호 찾기 버튼
                ],

              ),
            ),  //회원가입과 비밀번호 찾기로 이동하는곳

          ],
        ),
      ) ,
    );
  }
}