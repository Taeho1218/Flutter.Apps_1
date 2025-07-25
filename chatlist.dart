import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'main.dart';
import 'chat.dart';
final GlobalKey<_ChatList> chatilistPageKey = GlobalKey<_ChatList>();


class ChatList extends StatefulWidget {
  final VoidCallback onPageSelected;

  const ChatList({Key? key, required this.onPageSelected}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatList();
}

class _ChatList extends State<ChatList>{
  List<Map<String,dynamic>> _chatlists = [];
  Future<void> refreshChatListData() async {
    print("UserPage: refreshProfileData() 호출됨.");
    await _getPostsData(); // 프로필 데이터를 다시 불러옵니다.
  }

  @override
  void initState() {
    super.initState(); // super.initState()는 먼저 호출하는 것이 좋습니다.
    _getPostsData(); // 데이터 가져오기 함수 호출
  }

  Future<void> _getPostsData() async {
    // WidgetsFlutterBinding.ensureInitialized(); // 이 줄은 main() 함수에 있어야 합니다. 여기서는 제거
    var url_real = Uri.parse("$real/chat/rooms_list");
    var url = Uri.parse('$basic/posts'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("$emul/posts"); //에뮬레이터용
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
        Map<String, dynamic> responseBody = jsonDecode(response.body);

        List<dynamic> rawChatLists = responseBody['rooms'];
        List<Map<String, dynamic>> getPosts =
        rawChatLists.map((post) => post as Map<String, dynamic>).toList();

        setState(() { // 데이터가 변경되었음을 알리고 UI 업데이트
          _chatlists = getPosts;
          //_isLoading = false; // 로딩 끝
        });

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: _chatlists.length, // 받아온 게시물 개수만큼 아이템 생성
          itemBuilder: (BuildContext context, int index) {
            final chatlist = _chatlists[index]; // 현재 순서의 게시물 Map

            // 이미지 URL을 위한 서버 기본 주소
            final String? profileUrl = chatlist['other_profile_photo_url'] != null
                ? "$imgsend${chatlist['other_profile_photo_url']}"
                : null;

            return InkWell(
              child: Container(
                width: MediaQuery.of(context).size.width*1,
                height: MediaQuery.of(context).size.height*0.1,
                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // 좌우 여백 추가
                padding: const EdgeInsets.all(8.0), // 내부 여백
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                  color: Colors.white,
                ),
                child:
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.2,
                      height: MediaQuery.of(context).size.height*0.1,
                      child:  CircleAvatar(
                        backgroundImage: (profileUrl == null || profileUrl!.isEmpty)
                            ? const AssetImage('assets/images/logo.jpg') // 기본 이미지 (AssetImage)
                            : NetworkImage(profileUrl!) as ImageProvider<Object>,// 프로필 이미지 (임시)
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width*0.6,
                        height: MediaQuery.of(context).size.height*0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.6,
                              height: MediaQuery.of(context).size.height*0.04,
                              child: Text(chatlist["other_nickname"]),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.6,
                              height: MediaQuery.of(context).size.height*0.02,
                              child: Text(chatlist["last_message"],
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
                            ),
                            )
                          ],
                        )
                    ),
                  ],
                ),


              ),
              onTap: (){
                print("$chatlist를 눌렀습니다");
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) =>  ChatPage( conversation_id: chatlist['conversation_id'])),
                );
              },
            );
          },
        ),
      ],
      ),
    );
  }
}
