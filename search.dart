import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'main.dart';
import 'bottomnavigate.dart';
class SearchFilterPage extends StatefulWidget {
  const SearchFilterPage({super.key});

  @override
  State<SearchFilterPage> createState() => _SearchFilterPageState();
}

class _SearchFilterPageState extends State<SearchFilterPage> {
  final List<String> university_names = [
    '서울대',
    '홍대',
    '이대',
    '한양대',
    '건대',
    '교대',
    '연세대'
  ];
  final List<String> ages = [
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '29',
  ];
  final List<String> genders = [
    '남자',
    '여자',
  ];

  // --- 선택된 항목들을 저장할 Map (Set을 사용하여 중복 방지 및 빠른 조회) ---
  final Map<String, Set<String>> _selectedFilters = {
    'university_names': {},
    'ages': {},
    'genders': {},
  };
  Map<String, dynamic> _sendFilters = {};


  // 모든 필터 선택 해제 함수
  void _clearAllFilters() {
    setState(() {
      _selectedFilters['university_names']!.clear();
      _selectedFilters['ages']!.clear();
      _selectedFilters['genders']!.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('모든 필터가 초기화되었습니다.')),
    );
  }

  // 정보 보내기
  Future<void> sendRegisterData() async {
    var url = Uri.parse('http://localhost:3000/api/posts_list/search'); // ← 서버 주소에 맞게 바꾸세요
    var url_emul = Uri.parse("http://10.0.2.2:3000/api/posts_list/search"); //에뮬레이터용
    var url_real = Uri.parse("$real/posts_list/search");

    try {
      var response = await http.post(
        url_real,
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $Token'},
        body: jsonEncode(_sendFilters),
      );

      if (response.statusCode == 200) {
        print('서버 응답 성공: ${response.body}');
        Navigator.of(context).pushReplacement( MaterialPageRoute(builder: (context) =>  BottomNaviagte()),);

      } else {
        print('서버 응답 실패: ${response.statusCode},${response.body}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }

    print(_sendFilters);
  }

  // 필터 적용 (실제 검색 로직은 여기에)
  void _applyFilters() {
    print('선택된 대학교: ${_selectedFilters['university_names']}');
    print('선택된 나이대: ${_selectedFilters['ages']}');
    print('선택된 성별: ${_selectedFilters['genders']}');

    _sendFilters = _selectedFilters;

    sendRegisterData();
    // TODO: 여기에 실제 검색 로직을 구현합니다.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('필터 적용!')),
    );
  }

  // 필터 섹션을 빌드하는 헬퍼 위젯 (Wrap 위젯 사용)
  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String filterKey,
    required double sectionWidth,
    required double sectionHeight,
  }) {
    return Container(
      width: sectionWidth,
      height: sectionHeight,
      // color: Colors.blue.withOpacity(0.1), // 디버깅용 배경색
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          // Wrap 위젯을 사용하여 자식들이 공간을 넘칠 때 다음 줄로 자동 배치
          Expanded( // Container의 height 범위 내에서 Wrap이 유연하게 공간을 차지하도록 Expanded 추가
            child: Wrap(
              spacing: 8.0, // 자식 위젯들 간의 수평 간격
              runSpacing: 4.0, // 줄 사이의 수직 간격
              alignment: WrapAlignment.start, // 정렬 방식
              children: options.map((option) {
                final isSelected = _selectedFilters[filterKey]!.contains(option);
                return GestureDetector( // Checkbox와 Text를 터치 영역으로 만들기 위해 GestureDetector 사용
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedFilters[filterKey]!.remove(option);
                      } else {
                        _selectedFilters[filterKey]!.add(option);
                      }
                    });
                  },
                  child: Container(
                    // 개별 선택 항목의 스타일링
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row( // 체크박스와 텍스트를 한 줄에 배치
                      mainAxisSize: MainAxisSize.min, // Row가 내용물 만큼만 너비를 차지하도록
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (bool? newValue) {
                            setState(() {
                              if (newValue == true) {
                                _selectedFilters[filterKey]!.add(option);
                              } else {
                                _selectedFilters[filterKey]!.remove(option);
                              }
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 체크박스 터치 영역 최소화
                        ),
                        Text(option, style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 부모 컨테이너의 너비와 높이 정의
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double sectionWidth = screenWidth * 1;
    final double sectionHeight = screenHeight * 0.6; // 각 섹션에 25%의 높이 할당

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 필터'),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('초기화'),
          ),
          // TextButton(
          //   onPressed:(){
          //     sendRegisterData();
          //     _applyFilters();
          //   } ,
          //   style: TextButton.styleFrom(foregroundColor: Colors.white),
          //   child: const Text('적용'),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center( // 모든 섹션을 중앙에 배치
          child: Column(
            children: [
              _buildFilterSection(
                title: '대학교',
                options: university_names,
                filterKey: 'university_names',
                sectionWidth: sectionWidth,
                sectionHeight: sectionHeight/1.5,
              ),
              _buildFilterSection(
                title: '나이대',
                options: ages,
                filterKey: 'ages',
                sectionWidth: sectionWidth,
                sectionHeight: sectionHeight/1.4,
              ),
              _buildFilterSection(
                title: '성별',
                options: genders,
                filterKey: 'genders',
                sectionWidth: sectionWidth,
                sectionHeight: sectionHeight/3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:(){
                  // sendRegisterData();
                  _applyFilters();
                } ,
                child: const Text('필터 적용'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
