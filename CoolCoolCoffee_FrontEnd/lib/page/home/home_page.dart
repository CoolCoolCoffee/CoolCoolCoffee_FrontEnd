
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolcoolcoffee_front/provider/sleep_param_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../service/user_caffeine_service.dart';
import 'caffeine_left.dart';
import 'drink_list.dart';
import 'clock.dart';
import 'package:coolcoolcoffee_front/page/home/longterm_popup_A.dart';
import 'package:coolcoolcoffee_front/page/home/longterm_popup_B.dart';
import 'package:permission_handler/permission_handler.dart';

import '../menu/menu_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime now = DateTime.now();
  DateFormat dayFormatter = DateFormat('yyyy-MM-dd');
  String date = '';
  @override
  void initState(){
    super.initState();
    _initializeSleepParam();
  }
  Future<void> _initializeSleepParam() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DateTime today = DateTime.now();
    String todaydate = today.toLocal().toIso8601String().split('T')[0];
    DateTime yesterday = today.subtract(Duration(days: 1));
    String yesterdaydate = yesterday.toLocal().toIso8601String().split('T')[0];
    DocumentSnapshot<Map<String, dynamic>> userSleepDoc =
    await FirebaseFirestore.instance.collection('Users').doc(uid).collection('user_sleep').doc(todaydate).get();

    DocumentSnapshot<Map<String, dynamic>> yesUserSleepDoc =
    await FirebaseFirestore.instance.collection('Users').doc(uid).collection('user_sleep').doc(yesterdaydate).get();
    //오늘의 수면 정보 받아오기
    if(userSleepDoc.exists && userSleepDoc.data()!.containsKey('wake_time')&&userSleepDoc.data()!.containsKey('sleep_quality_score')){

      ref.watch(sleepParmaProvider.notifier).changeWakeTime(userSleepDoc['wake_time']);
      //print('wake time ${userSleepDoc['wake_time']}');
      ref.watch(sleepParmaProvider.notifier).changeSleepQuality(userSleepDoc['sleep_quality_score']);
      setState(() {
        now = today;
      });
    }
    //오늘 꺼가 없으면 어제꺼로
    else if(yesUserSleepDoc.exists&&yesUserSleepDoc.data()!.containsKey('wake_time')&&yesUserSleepDoc.data()!.containsKey('sleep_quality_score')){
      ref.watch(sleepParmaProvider.notifier).changeWakeTime(yesUserSleepDoc['wake_time']);
      print('!!!!!!1어제꺼다잉 wake time ${userSleepDoc['wake_time']}');
      ref.watch(sleepParmaProvider.notifier).changeSleepQuality(yesUserSleepDoc['sleep_quality_score']);
      setState(() {
        now = yesterday;
      });
    }
    else{
      ref.watch(sleepParmaProvider.notifier).changeWakeTime("");

      ref.watch(sleepParmaProvider.notifier).changeSleepQuality(-1);
    }
  }
  @override
  Widget build(BuildContext context) {

    //DateFormat timeFormatter = DateFormat('HH:mm:ss');
    date = dayFormatter.format(now);
    UserCaffeineService userCaffeineService = UserCaffeineService();
    userCaffeineService.checkExits(date);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.brown.withOpacity(0.1),
        appBar: AppBar(
          title: const Center(
            child: Text(
              '홈 화면',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        toolbarHeight: 50,
        iconTheme: IconThemeData(color: Colors.white),
    ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            ClockWidget(),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LongPopup_A();
                      },
                    );
                  },
                  child: Text('LongTerm_A'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LongPopup_B();
                      },
                    );
                  },
                  child: Text('LongTerm_B'),
                ),
                ElevatedButton(
                  onPressed: () {
                    openAppSettings(); // 허용 설정 페이지
                  },
                  child: Text('알림 허용'),
                ),
              ],
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Users').doc(userCaffeineService.uid).collection('user_caffeine').doc(date).snapshots(),
              builder: (context,snapshot){
                print('좀 바뀌어라 ㅅㅂ');
                return CaffeineLeftWidget(snapshots: snapshot,);
             }),
            SizedBox(height: 20),
            DrinkListWidget(),
          ],
        ),
      )
    );
  }
}
