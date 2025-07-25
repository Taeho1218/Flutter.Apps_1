import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tjt_project/postcreate.dart';
import 'postlist.dart';
import 'main.dart';

enum Gender {MAN,WOMAN}

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key:key);

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  TextEditingController _chpwController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _universityController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  Gender? _gender = Gender.MAN;
  String checkPW="";
  XFile? usimage ;
  String? usimageBase64;
  XFile? pfimage;
  String? pfimageBase64;
  String? sendusimage;
  String? sendpfimage;

  late  Map <String, Object?> _registerdata = {
    'user_id' : _idController.text,
    'user_pw': _pwController.text,
    'gender': _gender.toString(),
    'age': _ageController.text,
    'korean_name': _nameController.text,
    'nickname': _nicknameController.text,
    'university_name': _universityController.text,
    'student_photo':  sendusimage ,
    'send_photo':  sendpfimage,
  };

  Future<String> encodeXFileToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<XFile?> getUsImage() async{
    final ImagePicker picker = ImagePicker();
    usimage = await picker.pickImage(source: ImageSource.gallery);
    usimageBase64 = await encodeXFileToBase64(usimage!);
    String jpg = 'jpg';
    String png = 'png';
    String heif = 'heif';
    if(usimage!=null){
      setState(() {
        usimage;
      });
    }

    if(usimage!.path.contains(jpg)){
      sendusimage = 'data:image/jpg;base64,$usimageBase64';
    }else if(usimage!.path.contains(png)){
      sendusimage = 'data:image/png;base64,$usimageBase64';
    }else if(usimage!.path.contains(heif)){

    }else{
      print("사진을 선택해 주세요 ");
    }
    print("usimage: $usimage");
    return usimage;
  } //이미지 피커 함수 정의 , 학생증 사진

  Future<XFile?> getPfImage() async{
    final ImagePicker picker = ImagePicker();
    pfimage = await picker.pickImage(source: ImageSource.gallery);
    pfimageBase64 = await encodeXFileToBase64(pfimage!);
    String jpg = 'jpg';
    String png = 'png';
    String heif = 'heif';
    if(pfimage!=null){
      setState(() {
        pfimage;
      });
    }

    if(pfimage!.path.contains(jpg)){
      sendpfimage = 'data:image/jpg;base64,$pfimageBase64';
    }else if(pfimage!.path.contains(png)){
      sendpfimage = 'data:image/png;base64,$pfimageBase64';
    }else if(pfimage!.path.contains(heif)){

    }else{
      print("사진을 선택해 주세요 ");
    }

    return pfimage;
  } // 프로필 사진 받기

  Future<void> sendRegisterData() async {
    var url = Uri.parse('http://localhost:3000/api/register'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("http://10.0.2.2:3000/api/register"); //에뮬레이터용
    var url_real = Uri.parse("$real/register");
    try {
      var response = await http.post(
        //url,
        //url_emul,
        url_real,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_registerdata),
      );

      if (response.statusCode == 201) {
        print('서버 응답 성공: ${response.body}');
        setState(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("회원가입이 성공적으로 완료되었습니다!\n 회원인증이 완료되면 앱을 사용하실수 있습니다\n 예상시간은 2일입니다 "),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    },
                    child: Text("확인"),
                  ),
                ],
              );
            },
          );
        });
        Navigator.of(context).push( MaterialPageRoute(builder: (context) => const MyApp()),);

      } else {
        print('서버 응답 실패: ${response.statusCode},${response.body}');
        setState(() {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("회원가입 시 필요한 정보를 모두 입력해주세요"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 다이얼로그 닫기
                    },
                    child: Text("확인"),
                  ),
                ],
              );
            },
          );
        });
      }
    } catch (e) {
      print('오류 발생: $e');
    }

    print(_registerdata);
  }
  Future<void> checkId() async {
    Map <String, Object?> _checkiddata = {
      'user_id' : _idController.text,
    };
    var url = Uri.parse('http://localhost:3000/api/check-id'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("http://10.0.2.2:3000/api/check-id"); //에뮬레이터용
    var url_real = Uri.parse("$real/check-id");
    try {
      var response = await http.post(
        //url,
        //url_emul,
        url_real,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_checkiddata),
      );
      var jsonResponse = jsonDecode(response.body);
      bool isAvailable = jsonResponse['is_available'];

      if (isAvailable) {
        print('아이디가 사용가능합니다');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("아이디가 사용 가능합니다!"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: Text("확인"),
                ),
              ],
            );
          },
        );
      } else {
        print('아이디 사용이 불가능합니다');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("아이디가 중복되어 사용할수 없습니다!"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: Text("확인"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('오류 발생: $e');
      print(_registerdata);

    }
  }
  Future<void> CheckNick() async {
    Map <String, Object?> _checknickdata = {
      'nickname': _nicknameController.text,
    };
    var url = Uri.parse('http://localhost:3000/api/check-nickname'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("http://10.0.2.2:3000/api/check-nickname"); //에뮬레이터용
    var url_real = Uri.parse("$real/check-nickname");
    try {
      var response = await http.post(
        //url,
        //url_emul,
        url_real,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_checknickdata),
      );
      var jsonResponse = jsonDecode(response.body);
      bool isAvailable = jsonResponse['is_available'];

      if (isAvailable) {
        print('닉네임이 사용가능합니다');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("닉네임이 사용가능합니다!"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: Text("확인"),
                ),
              ],
            );
          },
        );

      } else {
        print('닉네임이 불가능합니다');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("닉네임이 중복되었습니다!"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: Text("확인"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  void initState() {
    super.initState();

    // 두 번째 텍스트필드 값이 변경될 때마다 _checkMatch 함수 실행
    _chpwController.addListener(() {
      _checkMatch();
    });
  }

  void _checkMatch() {
    String text1 = _pwController.text;
    String text2 = _chpwController.text;

    setState(() {
      if (text1.isEmpty && text2.isEmpty) {
        checkPW = '';
      } else if (text1 == text2) {
        checkPW = '✅ 입력값이 일치합니다.';
      } else {
        checkPW = '❌ 입력값이 다릅니다.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              title: Text('회원가입')
          ),
          body: Center(
              child: SingleChildScrollView(
                  child: Column(
                      children:[
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          height: MediaQuery.of(context).size.height*0.1,
                          child:
                          Row(
                              children:[
                                Container(
                                  width: MediaQuery.of(context).size.width*0.55,
                                  height: MediaQuery.of(context).size.height*0.1,
                                  child: Row(
                                      children:[
                                        Text("ID"),
                                        Expanded(child:  TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: '아이디를 입력하세요',
                                              hintText: '영문 숫자만 가능합니다',
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
                                  width: MediaQuery.of(context).size.width*0.25,
                                  height: MediaQuery.of(context).size.height*0.1,

                                  child:  ElevatedButton(
                                    onPressed: () {
                                      //중복있는지 없는지 확인
                                      checkId();
                                    },
                                    child: Text("중복확인"),
                                  ),
                                ),
                              ]
                          ),
                        ), //아이디 확인
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          height: MediaQuery.of(context).size.height*0.1,
                          child:
                          Row(
                              children:[
                                Container(
                                  width: MediaQuery.of(context).size.width*0.55,
                                  height: MediaQuery.of(context).size.height*0.1,
                                  child: Row(
                                      children:[
                                        Text("PW"),
                                        Expanded(child:  TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: '비밀번호를 입력하세요',
                                              hintText:'영문 숫자만 가능합니다'
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
                          ),
                        ), //비밀번호 설정
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          height: MediaQuery.of(context).size.height*0.1,
                          child:
                          Row(
                              children:[
                                Container(
                                  width: MediaQuery.of(context).size.width*0.55,
                                  height: MediaQuery.of(context).size.height*0.1,
                                  child: Row(
                                      children:[
                                        Text("비밀번호 재확인"),
                                        Expanded(child:  TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: '비밀번호를 다시 입력하세요'
                                          ),
                                          keyboardType:  TextInputType.text,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                          ],
                                          obscureText: true,
                                          onChanged:(_) => _checkMatch(),
                                          controller:_chpwController,
                                        ),),
                                      ]
                                  ),
                                ),
                                Container(
                                    width: MediaQuery.of(context).size.width*0.25,
                                    height: MediaQuery.of(context).size.height*0.1,
                                    margin: EdgeInsets.all(
                                        MediaQuery.of(context).size.height*0.03
                                    ),

                                    child:Text(checkPW,
                                      style: TextStyle(
                                        color: checkPW.contains('일치') ? Colors.green : Colors.red,
                                        fontSize: 16,
                                      ),)
                                ),
                              ]
                          ),
                        ),//비밀번호 재확인
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          height: MediaQuery.of(context).size.height*0.1,
                          child:
                          Row(
                              children:[
                                Container(
                                  width: MediaQuery.of(context).size.width*0.55,
                                  height: MediaQuery.of(context).size.height*0.1,
                                  child: Row(
                                      children:[
                                        Text("이름"),
                                        Expanded(child:  TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: '이름 입력하세요'
                                          ),
                                          controller:_nameController,
                                        ),),
                                      ]
                                  ),
                                ),
                              ]
                          ),
                        ), //이름 입력
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          height: MediaQuery.of(context).size.height*0.1,
                          child:
                          Row(
                              children:[
                                Container(
                                  width: MediaQuery.of(context).size.width*0.55,
                                  height: MediaQuery.of(context).size.height*0.1,
                                  child: Row(
                                      children:[
                                        Text("닉네임"),
                                        Expanded(child:  TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: '닉네임을 입력하세요'
                                          ),
                                          controller:_nicknameController,
                                        ),),
                                      ]
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width*0.25,
                                  height: MediaQuery.of(context).size.height*0.1,

                                  child:  ElevatedButton(
                                    onPressed: () {
                                      //중복있는지 없는지 확인
                                      CheckNick();
                                    },
                                    child: Text("중복확인"),
                                  ),
                                ),
                              ]
                          ),
                        ), //닉네임 입력
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          height: MediaQuery.of(context).size.height*0.1,
                          child:
                          Row(
                              children:[
                                Container(
                                  width: MediaQuery.of(context).size.width*0.55,
                                  height: MediaQuery.of(context).size.height*0.1,
                                  child: Row(
                                      children:[
                                        Text("나이"),
                                        Expanded(child:  TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: '나이 입력하세요'
                                          ),
                                          controller:_ageController,
                                        ),),
                                      ]
                                  ),
                                ),
                              ]
                          ),
                        ), //나이 입력
                        Container(
                            width: MediaQuery.of(context).size.width*0.9,
                            height: MediaQuery.of(context).size.height*0.3,
                            child: Column(
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.9,
                                    height: MediaQuery.of(context).size.height*0.1,
                                    child: Text('성별'),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.45,
                                        height: MediaQuery.of(context).size.height*0.2,
                                        child: ListTile(
                                          title:Text('남자'),
                                          leading:Radio(
                                            value:Gender.MAN,
                                            groupValue:_gender,
                                            onChanged: (Gender? value) {
                                              setState((){
                                                _gender = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width*0.45,
                                        height: MediaQuery.of(context).size.height*0.2,
                                        child: ListTile(
                                          title:Text('여자'),
                                          leading:Radio(
                                            value:Gender.WOMAN,
                                            groupValue:_gender,
                                            onChanged: (Gender? value) {
                                              setState((){
                                                _gender = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                ]
                            )
                        ), //성별 선택
                        Container(
                          width: MediaQuery.of(context).size.width*0.9,
                          height: MediaQuery.of(context).size.height*0.1,
                          child:
                          Row(
                              children:[
                                Container(
                                  width: MediaQuery.of(context).size.width*0.55,
                                  height: MediaQuery.of(context).size.height*0.1,
                                  child: Row(
                                      children:[
                                        Text("대학교"),
                                        Expanded(child:  TextField(
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: '대학교를  입력하세요'
                                          ),
                                          controller:_universityController,
                                        ),),
                                      ]
                                  ),
                                ),
                              ]
                          ),
                        ), //대학교 입력
                        Container(
                            width: MediaQuery.of(context).size.width*0.9,
                            height: MediaQuery.of(context).size.height*0.6,
                            child: Row(
                                children:[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.2,
                                    height: MediaQuery.of(context).size.height*0.1,
                                    child:Text('학생증 사진을 넣어주세요'),
                                  ),

                                  Container(
                                      width: MediaQuery.of(context).size.width*0.5,
                                      height: MediaQuery.of(context).size.height*0.6,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.5,
                                            height: MediaQuery.of(context).size.height*0.45,
                                            child: usimage != null
                                                ? Image.file(File(usimage!.path),
                                                width: MediaQuery.of(context).size.width*0.5,
                                                height: MediaQuery.of(context).size.height*0.4, fit: BoxFit.cover) //파일 타입으로 변환하여 이미지 로드
                                                : Text("이미지를 선택해주세요"),
                                          ),
                                          Container(
                                            child:    ElevatedButton(onPressed:(){
                                              getUsImage();
                                              print(usimage);
                                            },
                                                child: Text('사진을 선택해 주세요')),
                                          ),
                                        ],
                                      )
                                  )

                                ]
                            )
                        ), //학생증 사진 입력
                        Container(
                            width: MediaQuery.of(context).size.width*0.9,
                            height: MediaQuery.of(context).size.height*0.6,
                            child: Row(
                                children:[
                                  Container(
                                    width: MediaQuery.of(context).size.width*0.2,
                                    height: MediaQuery.of(context).size.height*0.1,
                                    child:Text('연락 하게 될때 보내질 본인 사진을 넣어주세요'),
                                  ),

                                  Container(
                                      width: MediaQuery.of(context).size.width*0.5,
                                      height: MediaQuery.of(context).size.height*0.6,
                                      child: Column(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.5,
                                            height: MediaQuery.of(context).size.height*0.45,
                                            child: pfimage != null
                                                ? Image.file(File(pfimage!.path),
                                                width: MediaQuery.of(context).size.width*0.5,
                                                height: MediaQuery.of(context).size.height*0.4, fit: BoxFit.cover) //파일 타입으로 변환하여 이미지 로드
                                                : Text("이미지를 선택해주세요"),
                                          ),
                                          Container(
                                            child:    ElevatedButton(onPressed:(){
                                              getPfImage();
                                              print(pfimage);
                                            },
                                                child: Text('사진을 선택해 주세요')),
                                          ),
                                        ],
                                      )
                                  )

                                ]
                            )
                        ), // 상대에게 보낼사진 등록

                        // Container(
                        //     width: MediaQuery.of(context).size.width*0.9,
                        //     height: MediaQuery.of(context).size.height*0.1,
                        //     child: Column(
                        //         children:[
                        //           Text('본인인증 '),
                        //         ]
                        //     )
                        // ), //본인 인증
                        SizedBox(height: 200,),
                        Container(
                            width: MediaQuery.of(context).size.width*0.2,
                            height: MediaQuery.of(context).size.height*0.1,
                            child: ElevatedButton(
                                onPressed: () {
                                  sendRegisterData();
                                  //소요 시간 말해주기
                                },
                                child: Text('회원 가입 신청하기')
                            )
                        ), //회원가입 버튼 및 알람
                      ]
                  )
              )
          )
      ),
    );
  }
}
