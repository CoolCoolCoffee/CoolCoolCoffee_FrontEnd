import 'package:coolcoolcoffee_front/model/short_term_param.dart';
import 'package:coolcoolcoffee_front/notification/notification_global.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final shortTermNotiProvider = StateNotifierProvider<ShortTermNotiNotifier,ShortTermParam>((ref){
  return ShortTermNotiNotifier();
});
class ShortTermNotiNotifier extends StateNotifier<ShortTermParam>{
  ShortTermNotiNotifier():super(ShortTermParam(todayAlarm: false, isCaffTooMuch: false, isCaffOk: false, goal_sleep_time: "", predict_sleep_time: ""));
  void setTodayAlarm(){
    state.todayAlarm = true;
  }
  void resetTodayAlarm(){
    state.todayAlarm = false;
  }
  //short term1
  void setIsCaffTooMuch(){
    state.isCaffTooMuch = true;
    state.isCaffOk = false;
  }
  //short term2
  void setIsCaffOk(){
    state.isCaffTooMuch = false;
    state.isCaffOk = true;
  }
  void resetCaffCompare(){
    state.isCaffTooMuch = false;
    state.isCaffOk = false;
  }
  void setGoalSleepTime(String goal_sleep_time){
    state.goal_sleep_time = goal_sleep_time;
  }
  void setPredictSleepTime(String predict_sleep_time){
    state.predict_sleep_time = predict_sleep_time;
  }
  void setCaffCompare(){
    print('provider predict ${state.predict_sleep_time}');
    print('provider goal ${state.goal_sleep_time}');
    if(state.predict_sleep_time != ""&&state.goal_sleep_time != ""){
      bool isAm = false;
      double goal_sleep_time_hour = 0;
      double goal_sleep_time_min = 0;
      double predict_sleep_time_hour = 0;
      double predict_sleep_time_min = 0;
      //goal sleep time 숫자로 변환
      if(state.goal_sleep_time.contains('AM')){
        isAm = true;
      }else{
        isAm = false;
      }
      var arr = state.goal_sleep_time.split(' ');
      arr = arr[0].split(':');
      goal_sleep_time_hour = double.parse(arr[0]);
      if(isAm) goal_sleep_time_hour += 24;
      goal_sleep_time_min = double.parse(arr[1])/60.0;

      if(state.predict_sleep_time.contains('AM')){
        isAm = true;
      }else{
        isAm = false;
      }
      arr = state.predict_sleep_time.split(' ');
      arr = arr[0].split(':');
      print(arr);
      predict_sleep_time_hour = double.parse(arr[0]);
      if(isAm) predict_sleep_time_hour += 24;
      predict_sleep_time_min = double.parse(arr[1])/60.0;


      if((goal_sleep_time_hour+goal_sleep_time_min)>(predict_sleep_time_hour+predict_sleep_time_min)){
        //short term 2
        print('short term 2');
        state.isCaffOk = true;
        state.isCaffTooMuch = false;
        //NotificationGlobal.shortTermFeedBackNoti(state.isCaffOk, state.isCaffTooMuch, caff_length, hour, minute, delayed_hour, delayed_minutes)
      }else{
        //short term 1
        print('short term 1');
        state.isCaffOk = false;
        state.isCaffTooMuch = true;
      }
    }
  }
}