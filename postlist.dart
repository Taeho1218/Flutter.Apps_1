import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
import 'package:tjt_project/chat.dart';
import 'main.dart';
import 'bottomnavigate.dart';
// Token 변수 (어디에 선언되어 있는지에 따라 접근 방식이 달라질 수 있습니다. 예시로 상단에 선언)
 GlobalKey<_PostList> postlistchangeKey = GlobalKey<_PostList>();

class PostList extends StatefulWidget {
  final VoidCallback onPageSelected;
  const PostList({Key? key, required this.onPageSelected}) : super(key: key);

  @override
  State<PostList> createState() => _PostList();
}

class _PostList extends State<PostList> {
  // 1. 게시물 데이터를 저장할 State 변수 선언
  List<Map<String, dynamic>> _posts = [];
  //bool _isLoading = true; // 데이터 로딩 상태를 나타내는 변수
  //
  @override
  void initState() {
    super.initState(); // super.initState()는 먼저 호출하는 것이 좋습니다.
    _getPostsData(); // 데이터 가져오기 함수 호출
  }

  Future<void> refreshData() async {
    print("PostList 페이지 데이터 새로고침 요청됨.");
    await _getPostsData(); // 프로필 데이터를 다시 불러옵니다.
  }

  Future<void> _getPostsData() async {
    // WidgetsFlutterBinding.ensureInitialized(); // 이 줄은 main() 함수에 있어야 합니다. 여기서는 제거
    var url_real = Uri.parse("$real/posts_list");
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
        print('프소트 리스트 서버 응답 성공: ${response.body}');
        Map<String, dynamic> responseBody = jsonDecode(response.body);

        List<dynamic> rawPosts = responseBody['posts']; // 'posts' 키로 배열 추출
        List<Map<String, dynamic>> getPosts =
        rawPosts.map((post) => post as Map<String, dynamic>).toList();
        setState(() { // 데이터가 변경되었음을 알리고 UI 업데이트
          _posts = getPosts;
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

  Future<void> postLike(String post_id, int index) async {
    var url_real = Uri.parse("$real/posts_list");
    var url = Uri.parse('$basic/posts'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("$emul/posts"); //에뮬레이터용
    // 로컬 저장소에서 토큰 값 불러오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token'); // String?으로 명시
    print("저장된 토큰:$Token");

    // 서버 엔드포인트는 /api/posts_list 였고, 예시로는 에뮬레이터 주소 사용
    var apiUrl = Uri.parse("$real/posts/$post_id/like");
    try {
      var response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $Token'},
      );

      if (response.statusCode == 200) { // GET 요청 성공은 200 OK
        print('프소트 리스트 서버 응답 성공: ${response.body}');
        var likesResponse = jsonDecode(response.body);
        bool like = likesResponse["is_liked_by_me"] ?? false;
        int like_count = likesResponse["likes_count"];
        setState(() {
          _posts[index]['is_liked_by_me'] = like;
          _posts[index]['likes_count'] = like_count;
        });
        setState(() {

        });

      } else {
        print('오류: ${response.statusCode} - ${response.body}');
        setState(() {
        });
      }
    } catch (e) {
      print('네트워크 요청 중 오류 발생: $e');
      setState(() {
      });
    }
  }

  Future<void> sendPoke(String receiver_user_id) async {
    Map<String, String?> _sendPokeData = {
      'receiver_user_id': receiver_user_id,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token'); // String?으로 명시
    var apiUrl = Uri.parse("$real/poke/send");
    try {
      var response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $Token'},
        body: jsonEncode(_sendPokeData),
      );

      if (response.statusCode == 200) { // GET 요청 성공은 200 OK
        print('찌르기 서버 응답 성공: ${response.body}');
        var pokeResponse = jsonDecode(response.body);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(conversation_id: pokeResponse["conversation_id"])),);
      } else {
        print('오류: ${response.statusCode} - ${response.body}');
        print(_sendPokeData);
        setState(() {
        });
      }
    } catch (e) {
      print('네트워크 요청 중 오류 발생: $e');
      setState(() {
      });
    }
  }

  String getTextBefore(String text, String delimiter) {
    int index = text.indexOf(delimiter); // 구분자(delimiter)가 시작하는 인덱스를 찾습니다.
    if (index != -1) { // 구분자를 찾았다면
      return text.substring(0, index); // 0부터 구분자 인덱스 전까지의 문자열을 반환합니다.
    } else { // 구분자를 찾지 못했다면 전체 문자열을 반환합니다.
      return text;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // _postcard() 함수 대신 SliverList.builder를 직접 사용
          SliverList.builder(
            itemCount: _posts.length, // 받아온 게시물 개수만큼 아이템 생성
            itemBuilder: (BuildContext context, int index) {
              final post = _posts[index]; // 현재 순서의 게시물 Map
              String create_date = getTextBefore("${post["created_at"].toString()}", "T");
              bool _isFavorited = post['is_liked_by_me'] ?? false;
              String likeCount = post["likes_count"]?.toString() ?? '0';

              // 이미지 URL 리스트를 위한 서버 기본 주소
              // 서버에서 'post_file_urls'라는 키로 URL 배열을 보낸다고 가정합니다.
              final List<dynamic>? rawPostFileUrls = post['post_file_url'];
              final List<String>? postFileUrls = rawPostFileUrls != null
                  ? rawPostFileUrls.map((url) => "$imgsend$url").toList()
                  : null;

              final String? profileurl = post['profile_photo_url'] != null
                  ? "$imgsend${post['profile_photo_url']}"
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
                            child: CircleAvatar(
                              backgroundImage: (profileurl != null && profileurl.isNotEmpty)
                                  ? NetworkImage(profileurl) as ImageProvider<Object>
                                  : null, // profileurl이 없으면 backgroundImage는 null로 설정

                              // profileurl이 없을 때만 Icons.account_circle 아이콘을 child로 보여줌
                              child: (profileurl == null || profileurl.isEmpty)
                                  ? const Icon(
                                Icons.account_circle, // CircleAvatar의 radius에 맞춰 아이콘 크기 조절
                                color: Colors.grey, // 아이콘 색상 설정
                              )
                                  : null, // 프로필 이미지 (임시)
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
                                        width: MediaQuery.of(context).size.width * 0.1,
                                        child: (post['gender'] == "Gender.WOMAN") // post['gender']를 사용
                                            ? const Icon(Icons.woman_outlined, color: Colors.pink)
                                            : const Icon(Icons.man_outlined, color: Colors.blue),
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.4,
                                        child: Text(
                                          post['nickname']?.toString() ?? '익명', // post['nickname'] 사용 및 null 처리
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  height: MediaQuery.of(context).size.height * 0.02,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.1,
                                        height: MediaQuery.of(context).size.height * 0.02,
                                        child: Text(
                                          "${post['age']?.toString() ?? ''}세", // post['age'] 사용
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 5), // 간격
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        height: MediaQuery.of(context).size.height * 0.02,
                                        child: Text(
                                          post['university_name']?.toString() ?? '미등록', // post['university_name'] 사용
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          overflow: TextOverflow.ellipsis, // 길어지면 ...
                                        ),
                                      ),
                                      Expanded( // 남은 공간을 채우도록
                                        child: Text(
                                          create_date,
                                          style: const TextStyle(fontSize: 10, color: Colors.black),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ],

                      ),
                    ), //위에 사용자 프로필 및 닉네임, 등등
                    const SizedBox(height: 8), // 간격
                    Expanded( // 남은 세로 공간을 채우도록
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['post_text']?.toString() ?? '내용 없음', // post['post_text'] 사용
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
                    // 하단 좋아요/댓글 버튼 등은 여기에 추가
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height * 0.05,
                      child:Row(
                        children: [
                          SizedBox(
                              child: IconButton(onPressed:(){
                                String postid = post["post_id"].toString();
                                postLike(postid,index);
                                print("하트 불리언:$_isFavorited");

                              }, icon:  Icon( _isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                                color: _isFavorited
                                    ? Colors.red
                                    : Colors.grey,))
                          ),
                          SizedBox(
                            child: Text(likeCount),
                          ),
                          SizedBox(
                              child: IconButton(onPressed:(){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text("${post['nickname']!}님을 찌르시겠습니까?"),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            String userId = post['user_id'].toString();
                                            print(userId);
                                            sendPoke(userId);
                                            Navigator.of(context).pop(); // 다이얼로그 닫기
                                            print("찌르기를 실행하였습니다");
                                          },
                                          child: Text("확인"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // 다이얼로그 닫기
                                          },
                                          child: Text("취소"),
                                        )
                                      ],
                                    );
                                  },
                                );
                              }, icon:  Icon(Icons.arrow_forward_outlined,
                                color: Colors.green,
                              ))
                          ),
                        ],
                      ),
                    )
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

// _postcard 함수는 이제 더 이상 필요 없으며, 위 build 메서드 안에 통합되었습니다.
// 만약 이 함수를 재사용하고 싶다면, List<Map<String, dynamic>> posts를 인자로 받도록 수정해야 합니다.
/*
Widget _postcard(List<Map<String, dynamic>> posts) {
  // 여기에 위 SliverList.builder의 내용을 그대로 복사 붙여넣고 posts를 사용하도록 수정
  // 예: itemCount: posts.length, final post = posts[index];
}
*/