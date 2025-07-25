import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
import 'package:tjt_project/profilechange.dart';
import 'main.dart';
import 'package:image_picker/image_picker.dart';
final GlobalKey<_UserPage> userPageKey = GlobalKey<_UserPage>();

class UserPage extends StatefulWidget{
  final VoidCallback onPageSelected;
  const UserPage({Key? key, required this.onPageSelected}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPage();
}

class _UserPage extends State<UserPage> {

  List<Map<String, dynamic>> _myPosts = [];
  Map<String, dynamic> my_info = {};
  XFile? profileimage;
  String? profileimageBase64;
  String? sendprofileimage;

  @override
  void initState() {
    super.initState(); // super.initState()는 먼저 호출하는 것이 좋습니다.
    _getPostsData(); // 데이터 가져오기 함수 호출
  }
  Future<void> refreshProfileData() async {
    print("UserPage: refreshProfileData() 호출됨.");
    await _getPostsData(); // 프로필 데이터를 다시 불러옵니다.
  }
  Future<void> _getPostsData() async {
    print("유저페이지를 로딩합니다");
    var url_real = Uri.parse("$real/mypage");
    var url = Uri.parse('$basic/posts'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("$emul/posts"); //에뮬레이터용
    // 로컬 저장소에서 토큰 값 불러오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token'); // String?으로 명시
    print("저장된 토큰:$Token");

    if (Token == null) {
      print("오류: 토큰이 없습니다. 로그인 상태를 확인하세요.");
      setState(() {
        //_isLoading = false; // 로딩 끝 (오류 상황)
      });
      return; // 토큰 없으면 함수 종료
    }

    // 서버 엔드포인트는 /api/posts_list 였고, 예시로는 에뮬레이터 주소 사용
    var apiUrl = url_real;

    try {
      var response = await http.get(
        apiUrl,
        headers: {'Authorization': 'Bearer $Token'},
      );

      if (response.statusCode == 200) { // GET 요청 성공은 200 OK
        print('마이 페이지 서버 응답 성공: ${response.body}');
        Map<String, dynamic> responseBody = jsonDecode(response.body);

        List<dynamic> rawMyPosts = responseBody['my_posts']; // 'posts' 키로 배열 추출
        List<Map<String, dynamic>> getMyPosts =
        rawMyPosts.map((post) => post as Map<String, dynamic>).toList();
        Map<String, dynamic> _my_info = responseBody['user_info'] as Map<String, dynamic>;

        setState(() { // 데이터가 변경되었음을 알리고 UI 업데이트
          _myPosts = getMyPosts;
          my_info = _my_info;
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
  Future<String> encodeXFileToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }


  @override
  Widget build(BuildContext context) {
    final String? profileurl = my_info['profile_photo_url'] != null
        ? "$imgsend${my_info['profile_photo_url']}"
        :null;
    return Scaffold(
        body: CustomScrollView(
          slivers: [ SliverToBoxAdapter( // <-- Container를 Sliver로 만들어 스크롤되게 함
            child: Container(
              padding: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.2,
              child:Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child:  CircleAvatar(
                          backgroundImage: (my_info["profile_photo_url"] == null || profileurl!.isEmpty)
                              ? const AssetImage('assets/images/logo.jpg') // 기본 이미지 (AssetImage)
                              : NetworkImage(profileurl!) as ImageProvider<Object>,// 프로필 이미지 (임시)
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${my_info["user_id"]}',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${my_info["nickname"]}',
                              style: TextStyle(fontSize: 12,),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: TextButton(onPressed:() async {
                      await Navigator.of(context).push( MaterialPageRoute(builder: (context) => const ProfileChange()),);
                      refreshProfileData();
                    }, child:Text("프로필정보 수정",
                        style: TextStyle(fontSize: 10,)
                    )),
                  )
                ],
              ),
            ),
          ),
            // _postcard() 함수 대신 SliverList.builder를 직접 사용
            SliverList.builder(
              itemCount: _myPosts.length, // 받아온 게시물 개수만큼 아이템 생성
              itemBuilder: (BuildContext context, int index) {
                final mypost = _myPosts[index]; // 현재 순서의 게시물 Map
                bool _isFavorited = mypost['is_liked_by_me'] ?? false;
                String likeCount = mypost["likes_count"]?.toString() ?? '0';

                // 이미지 URL을 위한 서버 기본 주소
                final List<dynamic>? rawPostFileUrls = mypost['post_file_url'];
                final List<String>? postFileUrls = rawPostFileUrls != null
                    ? rawPostFileUrls.map((url) => "$imgsend$url").toList()
                    : null;

                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0), // 좌우 여백 추가
                  padding: const EdgeInsets.all(8.0), // 내부 여백
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                    color: Colors.white,

                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 컬럼 내용을 왼쪽 정렬
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.2,
                              height: MediaQuery.of(context).size.height * 0.05,
                              child:  CircleAvatar(
                                backgroundImage: (profileurl == null || profileurl!.isEmpty)
                                    ? const AssetImage('assets/images/logo.jpg') // 기본 이미지 (AssetImage)
                                    : NetworkImage(profileurl) as ImageProvider<Object>,// 프로필 이미지 (임시)
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // 닉네임, 나이 등을 왼쪽 정렬
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.height * 0.03,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.2,
                                          child: Text(
                                            my_info['nickname']?.toString() ?? '익명', // post['nickname'] 사용 및 null 처리
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ), //위에 사용자 프로필 및 닉네임, 등등
                      const SizedBox(height: 8), // 간격
                      Expanded( // 남은 세로 공간을 채우도록
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mypost['post_text']?.toString() ?? '내용 없음', // post['post_text'] 사용
                              style: const TextStyle(fontSize: 14),
                              maxLines: 2, // 최대 두 줄
                              overflow: TextOverflow.ellipsis, // 넘치면 ...
                            ),
                            const SizedBox(height: 8), // 간격
                            // ********** 이 부분이 수정된 이미지 표시 로직입니다. **********
                            if (postFileUrls != null && postFileUrls.isNotEmpty) // postFileUrls가 있고 비어있지 않을 경우에만 이미지 표시
                              Expanded( // 이미지가 남은 공간을 채우도록
                                child: SizedBox( // ListView의 높이를 제한하기 위해 SizedBox 사용
                                  height: 200, // 예시 높이, 필요에 따라 조정 (이 PostCard의 전체 높이 안에서 적절히 조정)
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal, // 좌우 스크롤
                                    itemCount: postFileUrls.length,
                                    itemBuilder: (context, imgIndex) {
                                      final String imageUrl = postFileUrls[imgIndex]; // 완전한 URL은 이미 생성됨
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0), // 이미지 사이 간격
                                        child: Card( // 카드 형태로 표시
                                          elevation: 2,
                                          clipBehavior: Clip.antiAlias, // 이미지가 카드 경계를 넘어가지 않도록
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context).size.width * 0.8, // 각 이미지의 너비를 조정
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) =>
                                            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            else
                              const SizedBox.shrink(), // 이미지가 없으면 빈 공간
                            // ********** 수정된 이미지 표시 로직 끝 **********
                          ],

                        ),
                      ), //메인 내용 , 등등
                      Container(
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child:Row(
                          children: [
                            SizedBox(
                                child: Icon( _isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                  color: _isFavorited
                                      ? Colors.red
                                      : Colors.grey,))
                            ,
                            SizedBox(
                              child: Text(likeCount),
                            ),

                          ],
                        ),
                      )
                      // 하단 좋아요/댓글 버튼 등은 여기에 추가
                    ],
                  ),
                );
              },
            ),
          ],
        ),
    );
  }
}