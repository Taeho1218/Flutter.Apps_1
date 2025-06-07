import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'main.dart';

class FinalWeb extends StatefulWidget {
  final File imageFile;
  final String final_result;
  FinalWeb({super.key, required this.final_result, required this.imageFile});
  final List<Map<String,String>> animal_result = [
    {
      'name': '쥐띠',
      'story': '''
기회가 많은데, 다 잡으려다 꽝 될 수도! 신중하게~
- 직장/사업: 여기저기서 새로운 기회가 막 찾아와요! 하지만 다 잡으려다간 체력 방전될 수도… 하나를 확실히 잡는 게 중요해요.
- 금전: 돈이 들어오는 건 맞는데, 쓸 곳도 많네요. 예상치 못한 지출이 생길 테니 과소비 금지!
- 건강: 바쁜 일정 속에서 소화기 건강 신경 쓰세요. 급하게 먹고 체할 수도 있어요!
- 인간관계: 도움이 필요한 순간, 의외의 조력자가 나타날 가능성이 커요. 사람들 잘 챙기기!
'''
    },
    {
      'name': '소띠',
      'story': '''
묵묵히 가다 보면, 어느새 정상에 도착해 있을지도!
- 직장/사업: 한 걸음씩 차근차근 가면 올해 결실을 볼 수 있어요. 조급해하지 말고 꾸준함을 유지하세요.
- 금전: 큰돈을 벌 기회는 적지만, 나갈 돈도 적어요. 소소한 재테크를 시작하면 좋아요!
- 건강: 열심히 일하다가 체력이 바닥날 위험! 무리하지 말고, 잠은 꼭 챙겨요.
- 인간관계: 새 인연보단 기존 인맥이 큰 힘이 될 거예요. 오랜 친구, 동료들에게 연락해보세요!
'''
    },
    {
      'name': '호랑이띠',
      'story': '''
어흥! 변화를 두려워하지 말 것!
- 직장/사업: 기존 방식은 이제 그만! 색다른 도전이 필요해요. 새로운 일, 프로젝트에 적극적으로 나서보세요.
- 금전: 투자는 신중하게! 남들 따라 했다간 낭패 볼 수도...
- 건강: 운동을 안 하면 체력 급감! 바쁜 와중에도 틈틈이 스트레칭이라도 해보세요.
- 인간관계: 올해는 경쟁이 심하지만, 너무 예민해지지 말고 대화로 풀어보는 자세가 중요해요.
'''
    },
    {
      'name': '토끼띠',
      'story': '''
튀지 말고, 차분히 내실을 다질 때!
- 직장/사업: 올해는 과감한 도전보단, 현재 자리에서 실력을 다지는 해! 급하게 뛰어들지 마세요.
- 금전: 수입은 안정적이지만, 지출 관리는 필수. 작은 돈도 아껴두면 나중에 도움 될 거예요.
- 건강: 정신적 스트레스 조심! 너무 생각이 많아지면 건강까지 영향받을 수 있어요.
- 인간관계: 가깝다고 다 좋은 게 아니에요. 신뢰할 사람과만 진짜 친해지기!
'''
    },
    {
      'name': '용띠',
      'story': '''
올해는 주인공! 하지만 자만하면 나락 가능?!
- 직장/사업: 주도권을 쥘 기회가 많아요! 하지만 독단적으로 굴면 손해. 협력이 중요해요.
- 금전: 재물운이 강하지만, 쓰는 것도 많아요. '내가 왕이다!' 하고 팍팍 쓰지 말기.
- 건강: 일정이 많아 피로 누적 주의! 과로하면 한 방에 무너질 수도 있어요.
- 인간관계: 리더십이 중요한 한 해! 하지만 '내 말이 다 맞아!'라는 태도는 금물.
'''
    },
    {
      'name': '뱀띠',
      'story': '''
올해는 조심조심! 특히 말실수 조심!
- 직장/사업: 급하게 결정하면 후회! 신중하게 한 발씩 나아가야 해요.
- 금전: 무난한 수준이지만, 큰 지출은 피하는 게 좋아요. 돈 쓸 때 두 번 생각하기!
- 건강: 스트레스 관리 필수! 신경성 질환 조심하세요.
- 인간관계: 말 한마디가 화근이 될 수 있어요. 쓸데없는 말은 삼가는 게 좋겠어요.
'''
    },
    {
      'name': '말띠',
      'story': '''
전력 질주보다는 한 방에 집중!
- 직장/사업: 이것저것 하려다 다 놓칠 수도 있어요! 한 가지 목표에 집중하는 게 중요해요.
- 금전: 돈이 들어와도, 여러 곳에 나갈 위험이 있어요. 큰 지출은 한 번 더 고민!
- 건강: 에너지는 넘치지만, 운동하다가 부상 조심!
- 인간관계: 새로운 좋은 인연이 찾아올 수도 있으니, 열린 마음을 가지세요.
'''
    },
    {
      'name': '양띠',
      'story': '''
운명의 인연이 찾아올지도?! 💕
- 직장/사업: 혼자보단 협업이 잘 맞는 해! 주변 사람들과 힘을 합쳐보세요.
- 금전: 갑작스러운 지출 가능성! '이건 꼭 필요해?' 한 번 더 체크하세요.
- 건강: 위장 건강이 중요해요. 소화가 잘되는 음식 챙겨 먹기!
- 인간관계: 뜻밖의 좋은 인연을 만날 가능성이 커요! 새로운 사람들에게 마음을 열어보세요.
'''
    },
    {
      'name': '돼지띠',
      'story': '''
안정적인 한 해, 하지만 현실적인 선택이 필요!
- 직장/사업: 무리한 도전보다는 현재를 지키는 것이 더 유리한 해! 기존 업무를 철저히 다지는 게 좋아요.
- 금전: 돈이 들어오는 만큼 나갈 수도 있어요. '이거 정말 필요한 지출인가?' 항상 체크하기!
- 건강: 체중 관리와 식습관 조절이 중요해요. 야식 줄이기! (하지만 맛있는 건 참기 힘들겠죠? 😆)
- 인간관계: 가까운 사람들과의 관계를 더욱 돈독히 해야 하는 시기! '오래된 친구일수록 더 챙겨야 할 때!'
'''
    },
    {
      'name': '개띠',
      'story': '''
믿음직하고 성실한 하루, 하지만 감정 기복 조심!
- 직장/사업: 맡은 일은 꼼꼼하게, 동료들 신뢰도 쑥쑥! 단, 너무 오지랖 부리진 말아요.
- 금전: 지출은 평범하지만, 한 번에 확 질러버릴 유혹이 있을 듯! 충동구매 주의.
- 건강: 피곤이 쌓여 허리, 어깨 뻐근. 스트레칭과 가벼운 산책 추천.
- 인간관계: 오해로 인한 작은 말다툼 가능성. 감정 조절이 포인트!
'''
    },
    {
      'name': '닭띠',
      'story': '''
촉이 날카로운 하루! 직감 믿어도 괜찮아요.
- 직장/사업: 평소엔 망설이던 일도 오늘은 과감하게 도전해볼 만! 예상보다 좋은 결과.
- 금전: 작은 재물운! 잊고 있던 돈이나 쿠폰 발견 운도 있어요.
- 건강: 컨디션 최상, 단 밤 늦게까지 폰 보면 숙면 방해됨. 일찍 꺼두기!
- 인간관계: 평소 연락 없던 친구에게 연락 와서 기분 좋아질 수도.
'''
    },
    {
      'name': '원숭이띠',
      'story': '''
센스와 재치로 분위기 메이커! 하지만 말 실수 조심.
- 직장/사업: 아이디어 빛나는 날! 회의에서 의견 내면 칭찬 받을 확률 높음.
- 금전: 수입보다 지출이 많을 수 있으니, 가계부 점검.
- 건강: 무릎, 관절 주의. 너무 오래 앉아있지 말고 중간중간 움직이기.
- 인간관계: 장난이 과하면 독. 상대 기분도 슬쩍 체크해가며 농담하기.
'''
    },
  ];
  @override

  State<FinalWeb> createState() => _FinalWebState();

}

class _FinalWebState extends State<FinalWeb> {
  final String exaple_result = '말띠';
  late String animal_name= "";
  late String animal_story= "";
  late String animal_image= "";




  @override
  void initState() {
    super.initState();
    show_ment();
  }

  void show_ment(){
    for(int i=0; i<widget.animal_result.length;i++){
      if(widget.final_result == widget.animal_result[i]['name']){
        animal_name = widget.animal_result[i]['name']!;
        animal_story = widget.animal_result[i]['story']!;
        animal_image = 'assets/images/$animal_name.jpg' ;
      }else{
        print(widget.final_result);
      }
    }
  }


  @override

  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(

        body: Container(
          child: SingleChildScrollView(
            child:Column(
              children: [
                SizedBox(height: 40,),
                Image.asset(animal_image,
                  width: 300,
                  height:300,
                  fit: BoxFit.cover,), //닮은 꼴 이미지 등록
                SizedBox(height: 20,),
                Center(
                  child:
                  Row(
                    children: [
                      SizedBox(width: 150,),

                      Image.file(widget.imageFile! ,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,),//선택한 이미지들어갈 화면
                      Text(animal_name),//닮은 꼴 이미지이름
                    ],
                  ),
                ),

                SizedBox(height: 40,),
                Text(animal_story),
                SizedBox(height: 10,),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(200, 50) ),
                    onPressed: (){
                      print("FianlWeb 으로 이동 ");
                        showDialog(context: context, builder: (BuildContext ctx){
                          return AlertDialog(
                            content: Text('처음 화면으로 돌아갈까요?'),
                            actions: [
                              Center(
                                child: FloatingActionButton(
                                    child: Text('네'),
                                    onPressed:(){
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) {
                                          return MyHomePage();
                                        },
                                      ));
                                    }
                                ),

                              )
                            ],
                          );
                        });

                    },
                    child: Text("다시 하기")),

              ],
            ) ,
          ),

        ),
      ),


    );
  }
}
