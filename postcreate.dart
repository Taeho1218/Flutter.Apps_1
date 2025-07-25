import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'postlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottomnavigate.dart';
import 'main.dart';

typedef OnPageSelected = void Function();

class PostCreate extends StatefulWidget {
  final OnPageSelected onPageSelected;

  const PostCreate({super.key, required this.onPageSelected});

  @override
  State<PostCreate> createState() => _PostCreate();
}

class _PostCreate extends State<PostCreate> {
  TextEditingController _bodyController = TextEditingController();
  List<XFile>? postimages; // 여러 이미지를 저장할 리스트
  List<String>? postimagesBase64; // 여러 이미지의 Base64 데이터를 저장할 리스트
  List<String>? sendpostimages; // 서버로 보낼 이미지 데이터를 저장할 리스트
  String? ip;

  late Map<String, dynamic> _postcreatdata; // late 초기화 제거 및 dynamic으로 변경

  Future<void> _getPostsData() async {
    var url_real = Uri.parse("$real/posts"); //에뮬레이터용
    // 로컬 저장소에서 토큰 값 불러오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token'); // String?으로 명시
    print("저장된 토큰:$Token");

    if (Token == null) {
      print("오류: 토큰이 없습니다. 로그인 상태를 확인하세요.");
      setState(() {
      });
      return; // 토큰 없으면 함수 종료
    }

    var apiUrl = url_real;

    try {
      var response = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $Token'},
      );

      if (response.statusCode == 200) { // GET 요청 성공은 200 OK
        print('채팅 리스트 서버 응답 성공: ${response.body}');
      } else {
        print('오류: ${response.statusCode} - ${response.body}');
        setState(() {
          //_isLoading = false; // 로딩 끝 (오류 상황)
        });
      }
    } catch (e) {
      print('네트워크 요청 중 오류 발생: $e');
      setState(() {
        // _isLoading = false; // 로딩 끝 (오류 상황)
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getPostsData();
    _postcreatdata = {
      'post_text': _bodyController.text,
      'post_file': sendpostimages, // 여러 이미지에 맞게 변경
    };
    _bodyController.addListener(_updatePostCreateData);
  }

  void _updatePostCreateData() {
    setState(() {
      _postcreatdata['post_text'] = _bodyController.text;
    });
  }

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

  @override
  void dispose() {
    _bodyController.removeListener(_updatePostCreateData);
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}