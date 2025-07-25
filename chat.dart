// lib/chat.dart

import 'dart:convert';
import 'dart:io'; // File 클래스를 위해 추가
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:image_picker/image_picker.dart'; // 이미지 선택을 위해 추가
import 'bottomnavigate.dart';
import 'main.dart';

class ChatPage extends StatefulWidget {
  final String conversation_id;

  const ChatPage({Key? key, required this.conversation_id}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket socket;
  final TextEditingController _sendMentController = TextEditingController();
  List<Map<String, dynamic>> _chat = [];

  String? _myUserId;
  String? _myNickname;
  // 현재 사용자 프로필 URL도 필요하다면 추가할 수 있습니다.
  // String? _myProfilePhotoUrl;

  late String cvid;
  Map<String, dynamic> chat_info = {}; // 상대방 정보 (opponent_info)
  String? profileUrl; // 상대방 프로필 URL

  final ImagePicker _picker = ImagePicker(); // ImagePicker 인스턴스 생성

  @override
  void initState() {
    super.initState();
    cvid = widget.conversation_id;

    // _loadMyUserInfo()를 먼저 호출하여 SharedPreferences에서 초기 사용자 정보를 로드합니다.
    _loadMyUserInfo().then((_) {
      // 이후 _getPostsData()를 호출하여 서버로부터 채팅방 정보와 함께 최신 사용자 정보를 가져옵니다.
      _getPostsData();
      // _connectSocketIO()는 _getPostsData()에서 _myUserId가 업데이트된 후 호출하는 것이 더 안전할 수 있습니다.
      // 하지만 현재 구조에서는 initState에서 바로 호출해도 큰 문제는 없습니다 (SharedPreferences의 값이 먼저 사용됨).
      // 만약 서버에서 받은 current_user_info로 즉시 Socket 연결 정보를 업데이트해야 한다면,
      // _getPostsData 완료 콜백 내부에서 _connectSocketIO()를 호출하도록 순서를 조정해야 합니다.
      _connectSocketIO();
    });
  }

  // SharedPreferences에서 내 사용자 정보를 로드합니다. (초기 로드 및 로그인 정보 유지용)
  Future<void> _loadMyUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _myUserId = prefs.getString('user_id');
    _myNickname = prefs.getString('nickname');
    // _myProfilePhotoUrl = prefs.getString('profile_photo_url'); // 필요하다면 추가
    setState(() {});
  }

  // 채팅방 정보와 초기 메시지, 그리고 현재 사용자 정보까지 로드
  Future<void> _getPostsData() async {
    print("채팅방 정보를 로딩합니다");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('토큰이 없어 채팅방 정보를 가져올 수 없습니다.');
      return;
    }

    try {
      var url_real = Uri.parse("$real/chat/rooms/${widget.conversation_id}");
      var response = await http.get(
        url_real,
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      print("채팅방 정보 응답: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() {
          // 1. 상대방 정보 로드
          chat_info = jsonResponse['opponent_info'] as Map<String, dynamic>;
          profileUrl = chat_info['profile_photo_url'] != null
              ? "$imgsend${chat_info['profile_photo_url']}"
              : null;
          print(profileUrl);
          // 2. 현재 사용자 정보 로드 (서버 응답에서 직접 가져와 _myUserId, _myNickname 업데이트)
          if (jsonResponse['current_user_info'] != null) {
            _myUserId = jsonResponse['current_user_info']['user_id'] as String?;
            _myNickname = jsonResponse['current_user_info']['nickname'] as String?;
            // _myProfilePhotoUrl = jsonResponse['current_user_info']['profile_photo_url'] as String?; // 필요하다면
            print("현재 사용자 정보 서버에서 업데이트: ID: $_myUserId, 닉네임: $_myNickname");
          } else {
            print("경고: 서버 응답에 current_user_info가 없습니다.");
          }

          // 3. 채팅 메시지 로드
          if (jsonResponse['messages'] != null) {
            _chat = List<Map<String, dynamic>>.from(jsonResponse['messages']);
            _chat.sort((a, b) => (a['sent_at'] ?? '').compareTo(b['sent_at'] ?? ''));
          }
        });
      } else {
        print('채팅방 정보 로딩 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('채팅방 정보 로딩 중 오류 발생: $e');
    }
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _connectSocketIO() async {
    String? token = await _getAuthToken();
    if (token == null) {
      print("토큰이 없어 Socket.IO 연결을 시작할 수 없습니다.");
      return;
    }

    // _myUserId가 _getPostsData에서 업데이트될 수 있으므로,
    // Socket.IO 연결 시점에는 _myUserId가 SharedPreferences의 값이거나
    // _getPostsData가 완료된 후의 값일 수 있습니다.
    // 만약 _getPostsData에서 받은 최신 _myUserId를 반드시 사용해야 한다면,
    // _connectSocketIO() 호출 시점을 _getPostsData() 완료 후로 옮겨야 합니다.
    // 현재는 initState에서 호출되므로, 초기 _myUserId는 SharedPreferences에서 온 값입니다.
    socket = IO.io(
      '$imgsend', // 사용자 요청에 따라 Socket.IO 서버 주소로 $imgsend 사용
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNew()
          .disableAutoConnect()
          .setQuery({
        'token': token,
        'roomId': widget.conversation_id,
        'userId': _myUserId, // 중요: 이 시점의 _myUserId 값을 사용
      })
          .build(),
    );

    socket.onConnect((_) {
      print('Socket.IO 연결 성공!');
      socket.emit('joinRoom', {
        'roomId': widget.conversation_id,
        'userId': _myUserId,
        'nickname': _myNickname,
      });
    });

    socket.onConnectError((data) => print('Socket.IO 연결 에러: $data'));
    socket.onDisconnect((_) => print('Socket.IO 연결 해제'));
    socket.onError((data) => print('Socket.IO 오류: $data'));

    socket.on('chatMessage', (data) {
      print('메시지 수신 (chatMessage): $data');
      if (data is Map<String, dynamic>) {
        setState(() {
          _chat.add(data);
        });
      } else if (data is String) {
        try {
          Map<String, dynamic> decodedData = jsonDecode(data);
          setState(() {
            _chat.add(decodedData);
          });
        } catch (e) {
          print('수신 메시지 파싱 오류: $e, 원본: $data');
          setState(() {
            _chat.add({'sender_user_id': 'System', 'content': data, 'type': 'text'});
          });
        }
      }
    });

    socket.connect();
  }

  // 텍스트 메시지 전송 함수
  void _sendTextMessage() {
    if (_sendMentController.text.isNotEmpty) {
      String messageText = _sendMentController.text;
      _sendMentController.clear();

      Map<String, dynamic> chatMessage = {
        'roomId': widget.conversation_id,
        'sender_user_id': _myUserId,
        'sender_nickname': _myNickname,
        'type': 'text',
        'content': messageText,
        'sent_at': DateTime.now().toIso8601String(),
      };

      socket.emit('sendMessage', chatMessage);
      print('텍스트 메시지 전송 (emit): $chatMessage');

      setState(() {
        _chat.add(chatMessage);
      });
    }
  }

  // 이미지 선택 및 전송을 위한 함수
  Future<void> _pickAndSendImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      print('이미지 선택됨: ${image.path}');
      String? imageUrl = await _uploadImage(File(image.path));

      if (imageUrl != null) {
        print('이미지 업로드 성공: $imageUrl');
        _sendImageMessage(imageUrl);
      } else {
        print('이미지 업로드 실패');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 업로드에 실패했습니다.')),
        );
      }
    } else {
      print('이미지 선택 취소');
    }
  }

  // 이미지 파일을 서버에 업로드하는 함수
  Future<String?> _uploadImage(File imageFile) async {
    // TODO: 여기에 실제 이미지 업로드 API 엔드포인트와 인증 로직을 추가해야 합니다.
    // 현재는 예시 URL입니다. 서버의 이미지 업로드 API에 맞춰 변경해주세요.
    var uploadUrl = Uri.parse('$imgsend'); // 예시: $real 서버에 '/api/upload/image' 경로로 업로드
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('토큰이 없어 이미지를 업로드할 수 없습니다.');
      return null;
    }

    try {
      var request = http.MultipartRequest('POST', uploadUrl);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image', // 서버에서 이미지를 받을 필드 이름 (예: 'image' 또는 'file')
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ));
      print("imageFile:$imgsend${imageFile.path}");
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('이미지 업로드 응답 상태: ${response.statusCode}');
      print('이미지 업로드 응답 본문: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(responseBody);
        // 서버 응답에서 이미지 URL을 추출합니다.
        // 제공해주신 messages 배열의 content 형식: "/uploads/chat_images/uploads\\send_photos\\taeho.png"
        // 업로드 후 서버가 이런 형태의 상대 경로를 'image' 키 등으로 반환한다면 그대로 사용.
        // 만약 'imageUrl' 키로 보내거나 다른 형태라면 그에 맞게 수정해야 합니다.
        // 현재는 'image' 키로 가정하고 있습니다.
        return jsonResponse['image'] as String?;
      } else {
        print('이미지 업로드 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('이미지 업로드 중 오류 발생: $e');
      return null;
    }
  }

  // 이미지 URL을 포함한 메시지를 전송하는 함수
  void _sendImageMessage(String imageUrl) {
    Map<String, dynamic> chatMessage = {
      'roomId': widget.conversation_id,
      'sender_user_id': _myUserId,
      'sender_nickname': _myNickname,
      'type': 'image',
      'content': imageUrl, // 서버로부터 받은 이미지의 상대 경로 (URL)
      'sent_at': DateTime.now().toIso8601String(),
    };

    socket.emit('sendMessage', chatMessage);
    print('이미지 메시지 전송 (emit): $chatMessage');

    setState(() {
      _chat.add(chatMessage);
    });
  }

  @override
  void dispose() {
    _sendMentController.dispose();
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: profileUrl != null
                    ? DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(profileUrl!),
                )
                    : null,
              ),
              child: profileUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(chat_info['nickname'] ?? '채팅 상대', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                final message = _chat[_chat.length - 1 - index];
                final bool isMyMessage = message['sender_user_id'] == _myUserId;

                return Align(
                  alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                    decoration: BoxDecoration(
                      color: isMyMessage ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['sender_nickname'] ?? message['sender_user_id'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        // 메시지 타입에 따라 내용 표시 (텍스트 또는 이미지)
                        if (message['type'] == 'image' && message['content'] != null)
                          GestureDetector(
                            onTap: () {
                              // 이미지 탭 시 확대 등 추가 기능 구현 가능
                            },
                            child: Image.network(
                              // 이미지 URL이 상대 경로이므로 $imgsend를 앞에 붙여 완전한 URL로 만듭니다.
                              // 예: "$imgsend/uploads/chat_images/..."
                              '$imgsend${message['content']}',
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width * 0.5,
                              errorBuilder: (context, error, stackTrace) {
                                print('이미지 로드 오류: $error');
                                return const Text('이미지 로드 실패');
                              },
                            ),
                          )
                        else // 'text' 타입이거나 content가 없는 경우
                          Text(
                            message['content'] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          message['sent_at'] != null
                              ? DateTime.parse(message['sent_at']).toLocal().toString().substring(11, 16)
                              : '',
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // 메시지 입력 필드와 이미지 선택 버튼
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickAndSendImage,
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '메시지를 입력하세요...',
                      ),
                      controller: _sendMentController,
                      onSubmitted: (value) => _sendTextMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: ElevatedButton(
                      onPressed: _sendTextMessage,
                      child: const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}