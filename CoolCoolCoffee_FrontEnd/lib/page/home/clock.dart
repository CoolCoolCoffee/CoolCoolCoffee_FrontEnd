import 'dart:ui';

import 'package:coolcoolcoffee_front/provider/sleep_param_provider.dart';
import 'package:flutter/material.dart';
import 'package:analog_clock/analog_clock.dart';
import 'package:flutter_health_connect/flutter_health_connect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class EditPopup extends StatefulWidget {
  final Function(String) onSave;
  final void Function(String) updateParentState;
  final String sleepTime;

  const EditPopup({
    Key? key,
    required this.onSave,
    required this.updateParentState,
    required this.sleepTime, // Add sleepTime parameter to the constructor
  }) : super(key: key);

  @override
  _EditPopupState createState() => _EditPopupState();
}

class _EditPopupState extends State<EditPopup> {
  TextEditingController sleepHoursController = TextEditingController();
  TextEditingController sleepMinutesController = TextEditingController();

  bool sleepIsAM = true;
  bool isCancelled = false;

  @override
  void initState() {
    super.initState();
    // Set initial values for controllers based on sleepTime and wakeTime
    List<String> sleepTimeParts = widget.sleepTime.split(':');
    if (sleepTimeParts.length == 2) {
      sleepHoursController.text = sleepTimeParts[0];
      List<String> minutesAndAMPM = sleepTimeParts[1].split(' ');
      if (minutesAndAMPM.length == 2) {
        sleepMinutesController.text = minutesAndAMPM[0];
        sleepIsAM = minutesAndAMPM[1] == 'AM';
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    List<bool> _isSelected = [sleepIsAM, !sleepIsAM];
    void toggleSelect(value) {
      print(value);

      if(value == 0){
        sleepIsAM = true;
      } else{
        sleepIsAM = false;
      }

      setState(() {
        _isSelected = [sleepIsAM, !sleepIsAM];
        print(_isSelected);
      });
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Center(child: Text('목표 취침 시간을 입력해주세요', style: TextStyle(fontSize: 16),)),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    ToggleButtons(
                        direction: Axis.vertical,
                        isSelected: _isSelected,
                        onPressed: toggleSelect,
                        selectedColor: Colors.white,
                        fillColor: Colors.brown.withOpacity(0.6),
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                        constraints: const BoxConstraints(
                          minHeight: 45.0,
                          minWidth: 60.0,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('AM', style: TextStyle(fontSize: 16),),),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('PM', style: TextStyle(fontSize: 16),),),
                        ]
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: TextField(
                        controller: sleepHoursController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '시',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      ' : ',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 5),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: TextField(
                        controller: sleepMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: '분',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            isCancelled = true;
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(60, 40),
          ),
          child: const Text(
            '취소',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            String sleepEnteredTime =
                '${sleepHoursController.text}:${sleepMinutesController.text} ${sleepIsAM ? 'AM' : 'PM'}';

            List<String> timeComponents = sleepEnteredTime.split(':');
            int hours = int.parse(timeComponents[0]);
            if (!sleepIsAM && hours < 12) {
              hours += 12;
            } else if (sleepIsAM && hours == 12) {
              hours = 0;
            }
            String convertedTime = '$hours:${timeComponents[1]}';
            convertedTime = convertedTime.replaceAll(RegExp(r'\s?[APMapm]{2}\s?$'), '');

            String uid = FirebaseAuth.instance.currentUser!.uid;
            DocumentReference userDocRef = FirebaseFirestore.instance.collection('Users').doc(uid);
            bool docExists = (await userDocRef.get()).exists;

            Future<void> updateFirestore() async {
              try {
                if (docExists) {
                  // 필드 있으면 goal_sleep_time 필드를 업데이트
                  await userDocRef.update({
                    'goal_sleep_time': convertedTime,
                  });
                } else {
                  // 필드 없으면 만들어 업데이트
                  await userDocRef.set({
                    'goal_sleep_time': convertedTime,
                  });
                }
                widget.updateParentState(sleepEnteredTime);

                Navigator.of(context).pop();
              } catch (error) {
                print('error : $error');
              }
            }
            updateFirestore();
          },
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            minimumSize: const Size(60, 40),
          ),
          child: const Text(
            '확인',
            style: TextStyle(
              color: Colors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}


class ClockWidget extends ConsumerStatefulWidget {
  final bool isControlMode;
  const ClockWidget({required this.isControlMode, Key? key}) : super(key: key);

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends ConsumerState<ClockWidget>{
  String sleepEnteredTime = '';
  String resultText = '';
  bool isNightMode = false;

  @override
  void initState() {
    super.initState();
    _getSleepEnteredTime();
  }

  Future<void> _getSleepEnteredTime() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot<Map<String, dynamic>> userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if(!userDoc.data()!.containsKey('goal_sleep_time')){
        print("here");
        String storedTime = userDoc['avg_bed_time'];
        List<String> timeComponents = storedTime.split(':');
        int hours = int.parse(timeComponents[0]);
        String minutes = timeComponents[1];

        String amPm = (hours >= 12) ? 'PM' : 'AM';

        if (hours > 12) {
          hours -= 12;
        }

        String formattedTime = '$hours:$minutes $amPm';
        ref.watch(sleepParmaProvider.notifier).changeGoalSleepTime(formattedTime);
        ref.watch(sleepParmaProvider.notifier).changeTw(userDoc['tw']);
        ref.watch(sleepParmaProvider.notifier).changeHalfTime(userDoc['caffeine_half_life']);
      }

      if (userDoc.exists && userDoc.data()!.containsKey('goal_sleep_time')) {
        print("hoal here!!");
        String storedTime = userDoc['goal_sleep_time'];
        print(storedTime);
        List<String> timeComponents = storedTime.split(':');
        int hours = int.parse(timeComponents[0]);
        String minutes = timeComponents[1];

        String amPm = (hours >= 12) ? 'PM' : 'AM';

        if (hours > 12) {
          hours -= 12;
        }

        String formattedTime = '$hours:$minutes $amPm';
        print(formattedTime);
        setState(() {
          sleepEnteredTime = formattedTime;
          print('sleepEnteredTime $sleepEnteredTime');
          ref.watch(sleepParmaProvider.notifier).changeGoalSleepTime(sleepEnteredTime);
          ref.watch(sleepParmaProvider.notifier).changeTw(userDoc['tw']);
          ref.watch(sleepParmaProvider.notifier).changeHalfTime(userDoc['caffeine_half_life']);
        });
      } else {
        print('error1');
      }
    } catch (e) {
      print('error2 : $e');
    }
  }

  @override
  Widget build(BuildContext context){
    final prov = ref.watch(sleepParmaProvider);
    print('build ${prov.goal_sleep_time}');

    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10,0,10,20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.ideographic,
            children: [
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    if (prov.goal_sleep_time.isNotEmpty)
                      TextSpan(
                        text: "카페인 섭취 제한 시작까지\n",
                        style: TextStyle(
                          color: widget.isControlMode? Colors.black : Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    if (prov.goal_sleep_time.isNotEmpty)
                      const TextSpan(
                        text: "n시간 m분",
                        style: TextStyle(
                          color:  Color(0xffD4936F),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (prov.goal_sleep_time.isNotEmpty)
                      TextSpan(
                        text: " 남았어요!",
                        style: TextStyle(
                          color: widget.isControlMode? Colors.black : Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    if (prov.goal_sleep_time.isEmpty)
                      TextSpan(
                        text: "목표 수면 시간을 설정해주세요.",
                        style: TextStyle(
                          color: widget.isControlMode? Colors.black : Colors.white,
                          fontSize: 20,
                        ),
                      ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  _showEditPopup(context);
                  print("dddd $sleepEnteredTime");
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit, // 연필 아이콘
                      color: widget.isControlMode? Color(0xff707070) : Colors.white,
                      size: 18,

                    ),
                    const SizedBox(width: 3),
                    Text(
                      prov.goal_sleep_time.isNotEmpty
                          ? '수정'
                          : '입력',
                      style: TextStyle(
                        color: widget.isControlMode? Color(0xff707070) : Colors.white,
                        fontSize: 17,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(150),
          child: Container(
            width: 250,
            height: 250,
            color: widget.isControlMode ? Color(0xff93796A) : Color(0xffF9F8F7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(prov.goal_sleep_time.isNotEmpty)
                  Column(
                    children: [
                      Text('목표 취침 시간', style: TextStyle(color: widget.isControlMode? Colors.white : Colors.black, fontSize: 20,)),
                      const SizedBox(height: 10),
                      Text('${prov.goal_sleep_time}', style: TextStyle(color: widget.isControlMode? Colors.white : Colors.black, fontSize: 20,))
                    ],
                  )
                else
                  Column(
                    children: [
                      Text('아직 목표 취침시간을 설정하지 않았어요!', style: TextStyle(color: widget.isControlMode? Colors.white : Colors.black, fontSize: 20,)),
                      const SizedBox(height: 10),
                      Text('목표 취침시간을 설정해주세요!', style: TextStyle(color: widget.isControlMode? Colors.white : Colors.black, fontSize: 20,))
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

//시간 수정 팝업
  void _showEditPopup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPopup(
          onSave: (sleepTime) {
          },
          updateParentState: (sleepTime) {
            setState(() {
              sleepEnteredTime = sleepTime;
              ref.watch(sleepParmaProvider.notifier).changeGoalSleepTime(sleepEnteredTime);
            });
          },
          sleepTime: sleepEnteredTime,
        );
      },
    );
  }
}