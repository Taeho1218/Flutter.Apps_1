import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 추가
import 'main.dart';
import 'package:image_picker/image_picker.dart';
import 'bottomnavigate.dart';
import 'dart:io';


class ProfileChange extends StatefulWidget{

  const ProfileChange({super.key});

  @override
  State<ProfileChange> createState() => _ProfileChange();
}

class _ProfileChange extends State<ProfileChange> {

  Map<String, dynamic> my_info = {};
  XFile? profileimage;
  String? profileimageBase64;
  String? newProfilePhoto;
  String? NewNickname;
  String? change_nikname;
  String? NewPw;
  String? current_pw;
  String? profile_photo_url;
  String? profileUrl;

  @override
  void initState() {
    super.initState(); // super.initState()는 먼저 호출하는 것이 좋습니다.
    _getPostsData(); // 데이터 가져오기 함수 호출
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

        Map<String, dynamic> _my_info = responseBody['user_info'] as Map<String, dynamic>;

        setState(() { // 데이터가 변경되었음을 알리고 UI 업데이트
          my_info = _my_info;
          // profile_photo_url = null;
          // profileUrl = null;
          profile_photo_url = my_info["profile_photo_url"];
          if (profile_photo_url != null && profile_photo_url!.isNotEmpty) {
            profileUrl = "$imgsend$profile_photo_url";
          } else {
            profileUrl = null; // 유효하지 않으면 null로 설정
          }
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

  //정보 수정하기
  Future<void> _putUserNickname() async {
    Map <String, Object?> new_nickname = {
      'new_nickname': _nicknameController.text,
    };
    var url_real = Uri.parse("$real/mypage/nickname");
    var url = Uri.parse('$basic/posts'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("$emul/posts"); //에뮬레이터용
    // 로컬 저장소에서 토큰 값 불러오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token'); // String?으로 명시
    print("저장된 토큰:$Token");

    // 서버 엔드포인트는 /api/posts_list 였고, 예시로는 에뮬레이터 주소 사용
    var apiUrl = url_real;

    try {
      var response = await http.put(
        apiUrl,
        headers: {'Authorization': 'Bearer $Token','Content-Type': 'application/json'},
        body: jsonEncode(new_nickname),
      );

      print(new_nickname);
      if (response.statusCode == 200) { // GET 요청 성공은 200 OK
        print('마이 페이지 서버 응답 성공: ${response.body}');
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        String? nikcname = responseBody['new_nickname'];

        setState(() { // 데이터가 변경되었음을 알리고 UI 업데이트
          my_info["nickname"] = nikcname;
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

  Future<void> _putUserPassword() async {
    Map <String, Object?> new_pw = {
      'new_pw': _newPasswordController.text,
      'current_pw': _currentPasswordController.text,
    };
    var url_real = Uri.parse("$real/mypage/password");
    var url = Uri.parse('$basic/posts'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("$emul/posts"); //에뮬레이터용
    // 로컬 저장소에서 토큰 값 불러오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token'); // String?으로 명시
    print("저장된 토큰:$Token");

    // 서버 엔드포인트는 /api/posts_list 였고, 예시로는 에뮬레이터 주소 사용
    var apiUrl = url_real;
    print("보내는 비밀번호 :$new_pw");
    try {
      var response = await http.put(
        apiUrl,
        headers: {'Authorization': 'Bearer $Token','Content-Type': 'application/json'},
        body: jsonEncode(new_pw),
      );

      if (response.statusCode == 200) { // GET 요청 성공은 200 OK
        print('마이 페이지 서버 응답 성공: ${response.body}');
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        //Map<String, dynamic> nikcname = responseBody['new_nickname'] as Map<String, dynamic>;

        setState(() { // 데이터가 변경되었음을 알리고 UI 업데이트
         // change_nikname = nikcname['new_nickname'];
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

  Future<void> _putUserProfile() async {
    Map <String, Object?> new_profile_photo = {
      'new_profile_photo': newProfilePhoto,
    };

    var url_real = Uri.parse("$real/mypage/profile-photo");
    var url = Uri.parse('$basic/posts'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("$emul/posts"); //에뮬레이터용
    // 로컬 저장소에서 토큰 값 불러오기
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Token = prefs.getString('token'); // String?으로 명시
    print("저장된 토큰:$Token");

    // 서버 엔드포인트는 /api/posts_list 였고, 예시로는 에뮬레이터 주소 사용
    var apiUrl = url_real;
    print("변경된 이미지 $new_profile_photo");
    try {
      var response = await http.put(
        apiUrl,
        headers: {'Authorization': 'Bearer $Token','Content-Type': 'application/json'},
        body: jsonEncode(new_profile_photo),
      );

      if (response.statusCode == 200) { // GET 요청 성공은 200 OK
        print('마이 페이지 서버 응답 성공: ${response.body}');
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        String? old_profile_photo_url = responseBody['profile_photo_url'];
        print("변경할 이미지$old_profile_photo_url");


        setState(() { // 데이터가 변경되었음을 알리고 UI 업데이트
          profileimage = null;
          profile_photo_url = old_profile_photo_url;
          if (profile_photo_url != null && profile_photo_url!.isNotEmpty) {
            profileUrl = "$imgsend$profile_photo_url?v=${DateTime.now().millisecondsSinceEpoch}";
          } else {
            profileUrl = null; // 유효하지 않으면 null로 설정
          }
          print("변경 이미지 경로$profileUrl");
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


  Future<void> imagePressed() async {

    final ImagePicker picker = ImagePicker();
    String jpg = 'jpg';
    String png = 'png';
    String heif = 'heif';
    profileimage = await picker.pickImage(source: ImageSource.gallery);
    profileimageBase64 = await encodeXFileToBase64(profileimage!);
    if(profileimage!.path.contains(jpg)){
      newProfilePhoto = 'data:image/jpg;base64,$profileimageBase64';
    }else if(profileimage!.path.contains(png)){
      newProfilePhoto = 'data:image/png;base64,$profileimageBase64';
    }else if(profileimage!.path.contains(heif)){

    }else{
      print("사진을 선택해 주세요 ");
    }
    if (newProfilePhoto != null) {
      await _putUserProfile();
    }
    // setState(() {
    //   profileUrl;
    // });
  }


  // 사용자가 갤러리에서 선택한 이미지를 저장할 File 객체
  File? _profileImage;
  // 닉네임 입력을 위한 컨트롤러
  final TextEditingController _nicknameController = TextEditingController();
  // 현재 비밀번호 입력을 위한 컨트롤러
  final TextEditingController _currentPasswordController = TextEditingController();
  // 새 비밀번호 입력을 위한 컨트롤러
  final TextEditingController _newPasswordController = TextEditingController();


  // 프로필 이미지를 서버에 업데이트하는 함수

  // 닉네임을 서버에 업데이트하는 함수
  void _updateNickname() {
    final NewNickname = _nicknameController.text.trim(); // 입력된 닉네임 앞뒤 공백 제거

    if (NewNickname.isNotEmpty) {
      // TODO: 이곳에 서버로 newNickname을 업데이트하는 실제 로직을 구현합니다.
      // 예: HTTP POST/PUT 요청으로 닉네임 전송
      print('닉네임 업데이트 시도: $NewNickname');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('닉네임이 "$NewNickname"으로 업데이트 요청 처리 중...')),
      );
      _putUserNickname();
      //_getPostsData();
      // 성공 또는 실패 피드백 제공
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 닉네임을 입력해주세요.')),
      );
    }
    _nicknameController.clear();
  }

  // 비밀번호를 서버에 업데이트하는 함수
  void _updatePassword() {
    final current_pw = _currentPasswordController.text;
    final NewPw = _newPasswordController.text;

    if (current_pw.isEmpty || NewPw.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 비밀번호와 새 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }
    if (current_pw == NewPw) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('새 비밀번호는 현재 비밀번호와 달라야 합니다.')),
      );

      return;
    }
    // TODO: 이곳에 서버로 currentPassword와 newPassword를 보내서 비밀번호 변경 실제 로직을 구현합니다.
    // 예: HTTP POST/PUT 요청으로 비밀번호 전송 (보안을 위해 해싱/암호화 필요)
    print('비밀번호 변경 시도 - 현재 비밀번호: $current_pw, 새 비밀번호: $NewPw');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('비밀번호 변경 요청 처리 중...')),
    );
    _putUserPassword();
    // 성공 또는 실패 피드백 제공 후 컨트롤러 비우기
    _currentPasswordController.clear();
    _newPasswordController.clear();
  }

  @override
  void dispose() {
    // 위젯이 dispose될 때 컨트롤러 리소스 해제
    _nicknameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
      ),
      body: SingleChildScrollView( // 내용이 길어질 경우 스크롤 가능하도록
        padding: const EdgeInsets.all(16.0), // 전체 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 1. 프로필 이미지 섹션
            Center( // 이미지를 중앙에 배치
              child: Stack( // 이미지와 카메라 아이콘을 겹치기 위해 Stack 사용
                children: [
                  CircleAvatar(
                    radius: 60, // 원형 아바타의 크기
                    // _profileImage가 null이 아니면 FileImage 사용, 아니면 기본 이미지 사용
                    backgroundImage:(profileUrl != null )
                        ? NetworkImage(profileUrl!) as ImageProvider<Object> // 2순위: 서버에서 받아온 프로필 URL 이미지
                        : const AssetImage('assets/images/logo.jpg') as ImageProvider<Object>, // 3순위: 기본 이미지                    // 기본 이미지로 사용할 에셋 파일이 'assets/default_profile.png'에 있어야 합니다.
                    // 만약 NetworkImage로 기존 프로필 URL을 받아와야 한다면, 초기화 시 여기에 적용합니다.
                    // 예: NetworkImage(initialProfileUrl ?? '...')
                  ),
                  Positioned( // 카메라 아이콘을 원형 아바타의 오른쪽 하단에 배치
                    bottom: 0,
                    right: 0,
                    child: InkWell( // 아이콘을 클릭 가능하게 만듦
                      onTap: imagePressed, // 갤러리에서 이미지 선택 함수 호출
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor, // 테마의 기본 색상 사용
                          borderRadius: BorderRadius.circular(20.0), // 원형으로 만듦
                        ),
                        child: const Icon(
                          Icons.camera_alt, // 카메라 아이콘
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // 공백
            // Align( // '프로필 이미지 변경' 버튼을 이미지 아래에 배치하고 오른쪽 정렬
            //   alignment: Alignment.centerRight,
            //   child: ElevatedButton(
            //     onPressed:(){
            //     _putUserProfile();
            //     },
            //     child: const Text('프로필 이미지 변경'),
            //   ),
            // ),
            // const SizedBox(height: 30),

            // 2. 닉네임 변경 섹션
            const Text('닉네임', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _nicknameController,
              decoration:  InputDecoration(
                hintText: my_info["nickname"],
                border: OutlineInputBorder(), // 테두리 추가
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 10),
            Align( // '닉네임 변경' 버튼을 오른쪽 정렬
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _updateNickname, // 닉네임 변경 함수 호출
                child: const Text('닉네임 변경'),
              ),
            ),
            const SizedBox(height: 30), // 공백

            // 3. 비밀번호 변경 섹션
            const Text('비밀번호 변경', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _currentPasswordController,
              obscureText: true, // 비밀번호 숨김 처리
              decoration: const InputDecoration(
                hintText: '현재 비밀번호',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: true, // 비밀번호 숨김 처리
              decoration: const InputDecoration(
                hintText: '새 비밀번호',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 10),
            Align( // '비밀번호 변경' 버튼을 오른쪽 정렬
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _updatePassword, // 비밀번호 변경 함수 호출
                child: const Text('비밀번호 변경'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              child: TextButton(onPressed: (){
                Navigator.of(context).pop();
              }, child: Text("변경 완료")),
            )
          ],

        ),
      ),
    );
  }
}