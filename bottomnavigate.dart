import 'dart:convert';
import 'package:flutter/material.dart';
import 'chatlist.dart';
import 'userpage.dart';
import 'postcreate.dart';
import 'postlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'search.dart';
import 'firstpostcreate.dart';

class BottomNaviagte extends StatefulWidget {
  @override
  _BottomNaviagte createState() => _BottomNaviagte();
}

class _BottomNaviagte extends State<BottomNaviagte> {
  int _currentIndex = 0;
  String? api;
  void checkToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token');
    var url_real = Uri.parse("$real/$api");
    var url = Uri.parse('http://localhost:3000/api/$api'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("http://10.0.2.2:3000/api/$api"); //에뮬레이터용
    var response = await http.post(
      //url,
      // url_emul,
      url_real,
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer $Token'},
    );
    print(response);
    print("토큰정보 전송");
    var jsonResponse = jsonDecode(response.body);
  }

  Future<void> logout(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key); // 해당 키의 값을 삭제합니다.
    print('Key: $key 의 값이 로컬 저장소에서 삭제되었습니다.');
    Navigator.of(context).push( MaterialPageRoute(builder: (context) => Login()),);

  }


  late final List<Widget> _pages;

    @override
  void initState() {
    super.initState();
    // initState()에서 _widgetOptions 리스트 초기화
    _pages = <Widget>[
      PostList(key:postlistchangeKey,onPageSelected: () {
        postlistchangeKey.currentState?.refreshData();
      },),
      // PostCreate 위젯을 생성할 때, checkToken() 함수를 콜백으로 전달
      PostCreate(onPageSelected: () {
        checkToken();
      }),
      ChatList(key: chatilistPageKey, onPageSelected: () {
        chatilistPageKey.currentState?.refreshChatListData();
      }),
      UserPage(key: userPageKey, onPageSelected: () { // userPageKey도 할당 (이전 답변에서 누락되었을 수 있음)
        userPageKey.currentState?.refreshProfileData();
      }),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: Text("로고랑 로그아웃 버튼이 들어갈 예정"),
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              IconButton(onPressed:(){
                Navigator.of(context).push( MaterialPageRoute(builder: (context) => SearchFilterPage()),);

              }, icon:Icon(Icons.search)),
              ElevatedButton(onPressed:(){
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      content: Text("로그아웃하시겠습니까?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            logout('token');
                            Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                          },
                          child: Text("확인"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                          },
                          child: Text("취소"),
                        ),
                      ],
                    );
                  },
                );
              } , child: Text("LogOut"))

            ],
          )
        ],

      ),
      body: IndexedStack( // ⭐ 현재 인덱스에 해당하는 페이지를 보여줍니다.
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.amber,

        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // 탭을 누르면 인덱스만 변경하여 IndexedStack이 화면을 전환
          });
          final selectedPage = _pages[_currentIndex];
          if (index == 0) {
            if (_pages[index] is PostList) {
              api = 'posts_list';
              final postListPage = _pages[index] as PostList;
              postListPage.onPageSelected();
            }
          }else if(index ==1){
            if (_pages[index] is PostCreate) {
              api = 'posts';
              final postCreatePage = _pages[index] as PostCreate;
              postCreatePage.onPageSelected();
            }
          }else if(index ==2){
            if (_pages[index] is ChatList) {
              api = 'chat';
              final ChatListPage = _pages[index] as ChatList;
              ChatListPage.onPageSelected();
            }
          }else if(index ==3){
            if (_pages[index] is UserPage) {
              api = 'mypage';
              final userpagePage = _pages[index] as UserPage;
              userpagePage.onPageSelected();
            }
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈',),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_rounded), label: '만들기',),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: '메시지',),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}