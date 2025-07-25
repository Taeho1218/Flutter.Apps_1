import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottomnavigate.dart';
import 'main.dart';


class FirstPostCreate extends StatefulWidget {
  // final OnPageSelected onPageSelected;
  //
  // const FirstPostCreate({super.key, required this.onPageSelected});

  @override
  State<FirstPostCreate> createState() => _FirstPostCreate();
}

class _FirstPostCreate extends State<FirstPostCreate>{
  TextEditingController _bodyController = TextEditingController();
  List<XFile>? postimages; // 여러 이미지를 저장할 리스트
  List<String>? postimagesBase64; // 여러 이미지의 Base64 데이터를 저장할 리스트
  List<String>? sendpostimages;
  String? ip;

  late Map <String, dynamic?> _postcreatdata = {
    'post_text' : _bodyController.text,
    'post_file': sendpostimages ,
  };

  Future<String> encodeXFileToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  Future<void> getpostImage() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage(); // 여러 이미지 선택

    if (selectedImages != null && selectedImages.isNotEmpty) {
      postimages = selectedImages; // 새로 선택된 이미지로 업데이트
      postimagesBase64 = [];
      sendpostimages = [];
      for (XFile image in postimages!) {
        String base64 = await encodeXFileToBase64(image);
        String mimeType;

        if (image.path.toLowerCase().endsWith('.jpg') || image.path.toLowerCase().endsWith('.jpeg')) {
          mimeType = 'image/jpg';
        } else if (image.path.toLowerCase().endsWith('.png')) {
          mimeType = 'image/png';
        } else if (image.path.toLowerCase().endsWith('.heic') || image.path.toLowerCase().endsWith('.heif')) {
          mimeType = 'image/heif';
        } else {
          print("지원되지 않는 이미지 형식: ${image.path}");
          continue;
        }
        sendpostimages!.add('data:$mimeType;base64,$base64');
        postimagesBase64!.add(base64);
      }
      setState(() {
        _postcreatdata['post_file'] = sendpostimages;
      });
    } else {
      print("사진을 선택해 주세요 ");
    }
  }


  Future<void> sendPostData() async {
    var url_real = Uri.parse("$real/posts");
    var url_local = Uri.parse('http://localhost:3000/api/posts'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("http://10.0.2.2:3000/api/posts"); //에뮬레이터용

    _postcreatdata['post_text'] = _bodyController.text;
    _postcreatdata['post_file'] = sendpostimages;

    try {
      var response = await http.post(
        url_real,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $Token'},
        body: jsonEncode(_postcreatdata),
      );
      var jsonResponse = jsonDecode(response.body);
      print(Token);

      if (response.statusCode == 201) {
        print('서버 응답 성공: ${response.body}');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BottomNaviagte()));
      } else {
        print('오류: ${response.body}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }

    print(_postcreatdata);
  }



  Future<void> sendGetData() async {
    var url_real = Uri.parse("$real/posts");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token'); // 'token' 키로 저장된 값을 불러옵니다.
    print("저장된 토큰:$Token");

    try {
      print(Token);
      var response = await http.get(
        url_real,
        headers: {'Authorization': 'Bearer $Token'},
      );
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('서버 응답 성공: ${response.body}');
      } else {
        print('오류: ${response.body}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }

    print("Get신청 완료");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sendGetData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Stack( // Stack 위젯을 사용하여 이미지 위에 버튼을 겹쳐 표시
                        children: [
                          postimages != null && postimages!.isNotEmpty
                              ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: postimages!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  elevation: 4,
                                  child: Image.file(
                                    File(postimages![index].path),
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          )
                              : Center(
                            child: Text('선택된 사진이 없습니다.'), // 이미지가 없을 때 표시
                          ),
                          Positioned( // '사진 선택' 버튼을 항상 표시
                            bottom: 10,
                            right: 10,
                            child: ElevatedButton(
                              onPressed: () {
                                getpostImage();
                              },
                              child: Text(postimages != null && postimages!.isNotEmpty ? '사진 다시 선택' : '사진 선택'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      height: MediaQuery.of(context).size.height * 0.15,
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '본문을 입력해주세요 ',
                        ),
                        controller: _bodyController,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1, // 화면 너비에 맞게 조정
                height: MediaQuery.of(context).size.height * 0.1,
                child: ElevatedButton(
                  onPressed: () {
                    sendPostData();
                  },
                  child: Text('작성완료'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

