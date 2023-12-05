import 'dart:io';import 'package:flutter/cupertino.dart';import 'package:flutter/material.dart';import 'package:image_picker/image_picker.dart';import 'package:coolcoolcoffee_front/service/user_caffeine_service.dart';import 'package:intl/intl.dart';import '../../model/user_caffeine.dart';import 'package:firebase_storage/firebase_storage.dart';import 'package:firebase_auth/firebase_auth.dart';class GeneralMenuAddPage extends StatefulWidget {  const GeneralMenuAddPage({super.key});  @override  State<GeneralMenuAddPage> createState() => _GeneralMenuAddPageState();}class _GeneralMenuAddPageState extends State<GeneralMenuAddPage> {  late UserCaffeineService userCaffeineService;  final brandController = TextEditingController();  final menuController = TextEditingController();  final shotController = TextEditingController();  final caffeineController = TextEditingController();  TextEditingController hoursController = TextEditingController();  TextEditingController minutesController = TextEditingController();  bool isConfirm = false;  bool isAM = true;  String brand = "";  String menu = "";  num shot = 0;  num caffeine = 0;  late String today;  late String time;  bool input_shot = true;  String downloadURL = "https://firebasestorage.googleapis.com/v0/b/coolcoolcoffee-2a74f.appspot.com/o/5070904.png?alt=media&token=23c7fc35-6f4d-45b7-90b6-b828a179cf6e";  XFile? _image; //이미지를 담을 변수 선언  final ImagePicker picker = ImagePicker();  bool imageUpload = false;  @override  void initState() {    super.initState();    userCaffeineService = UserCaffeineService();    DateTime now = DateTime.now();    DateFormat dayFormatter = DateFormat('yyyy-MM-dd');    DateFormat timeFormatter = DateFormat('HH:mm');    today = dayFormatter.format(now);    time = timeFormatter.format(now);    setState(() {});  }  Future<String> uploadImage(File imageFile) async {    try {      String uid = FirebaseAuth.instance.currentUser!.uid;      Reference storageReference = FirebaseStorage.instance          .ref()          .child('menu_images/$uid/${DateTime.now().millisecondsSinceEpoch}.png');      UploadTask uploadTask = storageReference.putFile(imageFile);      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);      // Get the download URL from the uploaded file      downloadURL = await taskSnapshot.ref.getDownloadURL();      //print("!!!!!!올림 $downloadURL");      return downloadURL;    } catch (e) {      print('Error uploading image: $e');      return '';    }  }  @override  Widget build(BuildContext context) {    return Scaffold(      resizeToAvoidBottomInset: false,      appBar: AppBar(        centerTitle: true,        leading: IconButton(          icon: const Icon(Icons.arrow_back),          onPressed: (){            Navigator.pop(context);          },        ),        title: Text('음료 추가하기'),      ),      body: Column(              children: [      Expanded(          flex: 5,          child: Container(            padding: EdgeInsets.only(top: 20,bottom: 10),            child: Stack(              children: [                GestureDetector(                  child: Container(                    margin: EdgeInsets.only(left: 50,right: 50),                    decoration: !imageUpload?                    BoxDecoration(                        borderRadius: BorderRadius.circular(20),                      color: Colors.grey[300],                    ):                    BoxDecoration(                      borderRadius: BorderRadius.circular(20),                      image: DecorationImage(                        fit: BoxFit.fill,                        image: FileImage(File(_image!.path)),                      ),                      color: Colors.blue,                    ),                    child: !imageUpload ?                    Center(                      child: Container(                        margin: EdgeInsets.only(top:80),                        child: Column(                          children: [                            Text('눌러서 메뉴 사진을 업로드하세요!'),                            Icon(Icons.camera_alt_outlined)                          ],                        ),                      ),                    ):                    Center(                      child: Container(                        margin: EdgeInsets.only(top:80),                      ),                    ),                  ),                  onTap: (){                    _dialogBuilder(context);                  },                ),                Align(                  alignment: Alignment.bottomCenter,                  child: Container(                    alignment: Alignment.bottomLeft,                    height: 80,                    margin: EdgeInsets.only(right: 50,left: 50),                    decoration: BoxDecoration(                      //border: Border.all(color: Colors.grey,width: 1),                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),                        color: Colors.white,                        boxShadow: [BoxShadow(                            color: Colors.grey.withOpacity(0.7),                            spreadRadius: 0,                            blurRadius: 5.0,                            offset: Offset(0,5)                        )]                    ),                    child: Column(                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,                      crossAxisAlignment: CrossAxisAlignment.start ,                      children: [                        Container(height: 5,),                        Padding(                          padding: const EdgeInsets.only(left: 8.0),                          child: Text(                            '$brand'      ,                                style: TextStyle(                                fontSize: 15,                                color: Colors.grey                            ),                          ),                        ),                        Padding(                          padding: const EdgeInsets.only(left: 8.0),                          child: Text(                            '$menu',                            style: TextStyle(                                fontSize: 20                            ),                          ),                        )                      ],                    ),                  ),                )              ],            ),          ),      ),      Expanded(        flex: 2,        child: Row(          children: [            Expanded(              flex: 7,              child: Container(                  width: double.infinity,                  margin: EdgeInsets.all(10),                  child: Column(                    mainAxisAlignment: MainAxisAlignment.center,                    crossAxisAlignment: CrossAxisAlignment.start,                    children: [                      Container(                        padding: EdgeInsets.only(left: 10, bottom: 10),                        child: Text('섭취 시간',                            style: TextStyle(                                fontSize: 18, fontWeight: FontWeight.bold)),                      ),                      isConfirm                          ? Row(                          children: [                            ElevatedButton(                              onPressed: () {                                setState(() {                                  // 확인 모드에서 분 입력 상태로 전환                                  isAM = true;                                });                              },                              style: ElevatedButton.styleFrom(                                primary: isAM                                    ? Colors.brown.withOpacity(0.6)                                    : Colors.brown.withOpacity(0.2),                                minimumSize: Size(30, 40),                              ),                              child: Text('AM'),                            ),                            ElevatedButton(                              onPressed: () {                                setState(() {                                  // 확인 모드에서 분 입력 상태로 전환                                  isAM = false;                                });                              },                              style: ElevatedButton.styleFrom(                                primary: !isAM                                    ? Colors.brown.withOpacity(0.6)                                    : Colors.brown.withOpacity(0.2),                                minimumSize: Size(35, 40),                              ),                              child: Text('PM'),                            ),                              Container(                                width: 60,                                height: 40,                                child: TextField(                                  controller: hoursController,                                  //focusNode: hoursFocusNode,                                  keyboardType: TextInputType.number,                                  decoration: InputDecoration(                                    labelText: '시',                                    border: OutlineInputBorder(),                                  ),                                ),                              ),                              Text(                                ' : ',                                style: TextStyle(fontSize: 20),                              ),                              Container(                                width: 60,                                height: 40,                                child: TextField(                                  controller: minutesController,                                  //focusNode: minutesFocusNode,                                  keyboardType: TextInputType.number,                                  decoration: InputDecoration(                                    labelText: '분',                                    border: OutlineInputBorder(),                                  ),                                ),                              ),                          ],                      )                          : Container(                            padding: EdgeInsets.only(left: 30, bottom: 10),                            child: Text('$time', style: TextStyle(fontSize: 20),)),                    ],                  )              ),            ),            Expanded(              flex: 2,                child: Container(                  padding: const EdgeInsets.only(right: 10,top: 30, bottom: 5,),                  child: ElevatedButton(                    onPressed: (){                      //여기!!!!!!!                      if (isConfirm) {                        // 확인 모드에서 수정 버튼을 누른 경우                        int hours = int.parse(hoursController.text);                        if (!isAM && hours < 12) {                          hours += 12;                        }                        time = '${hours.toString().padLeft(2, '0')}:${minutesController.text}';                      }                      isConfirm = !isConfirm;                      setState(() {});                    },                    child: Text(                      isConfirm? '확인':'수정',                      style: TextStyle(fontSize: 15, color: Colors.white),                    ),                    style: ElevatedButton.styleFrom(                      backgroundColor: const Color(0xff93796A),                        minimumSize: const Size.fromHeight(50),                        shape: RoundedRectangleBorder(                            borderRadius: BorderRadius.circular(10)                        )                    ),                  ),                )            ),          ],        ),      ),      Expanded(        flex: 1,        child: Row(          children: [            Container(margin: EdgeInsets.only(left: 20,right: 10),child: Text('브랜드',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),),            Flexible(              child: Container(                width: MediaQuery.of(context).size.width * 0.3, // Adjust the width as needed                child: TextField(                  controller: brandController,                  onChanged: (text) {                    setState(() {                      brand = text;                    });                  },                  decoration: InputDecoration(                    border: OutlineInputBorder(),                    contentPadding: EdgeInsets.symmetric(vertical: 5),                  ),                ),              ),            ),          ],        )      ),      Expanded(        flex: 1,          child: Row(            children: [              Container(margin: EdgeInsets.only(left: 20,right: 30),child: Text('메뉴',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),),              Flexible(                child: Container(                  width: MediaQuery.of(context).size.width * 0.3,                  child: TextField(                    controller: menuController,                    onChanged: (text) {                      setState(() {                        menu = text;                      });                    },                    decoration: InputDecoration(                      border: OutlineInputBorder(),                      contentPadding: EdgeInsets.symmetric(vertical: 5),                    ),                  ),                ),              ),            ],          )      ),      Expanded(        flex: 2,        child: Column(          mainAxisAlignment: MainAxisAlignment.center,          children: [            Text(              '샷 또는 카페인 양을 입력해주세요!',              textAlign: TextAlign.center,              style: TextStyle(fontSize: 12),            ),            Row(              children: [                Container(margin: EdgeInsets.only(left: 20,right: 46),child: Text('샷',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),),                ToggleButtons(                  children: [                    Text('1'),                    Text('2'),                    Text('3'),                    Text('4'),                  ],                  isSelected: [shot == 1, shot == 2, shot == 3, shot == 4],                  onPressed: (int index) {                    setState(() {                      if (input_shot) {                        for (int buttonIndex = 0; buttonIndex < 4; buttonIndex++) {                          if (buttonIndex == index) {                            shot = buttonIndex + 1;                          }                        }                        //caffeine = shot * 100;                      }                    });                  },                ),              ],            ),            Row(              children: [                Container(margin: EdgeInsets.only(left: 20,right: 10),child: Text('카페인',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),),                Flexible(                  child:  Container(                    width: MediaQuery.of(context).size.width * 0.3,                  child : TextField(                    controller: caffeineController,                    keyboardType: TextInputType.number,                    enabled: shot == 0,                    onSubmitted: (text) {                      setState(() {                        //caffeine = num.parse(text);                      });                      input_shot = false;                    },                    decoration: InputDecoration(                      border: OutlineInputBorder(),                      constraints: BoxConstraints(maxHeight: 40),                    ),                  ),                ),                ),                const Text('  mg', style: TextStyle(fontSize: 14),),                const Spacer(),                Container(                  margin: EdgeInsets.only(left: 10,right: 20),                  width: 80,                  child: ElevatedButton(                    style: ElevatedButton.styleFrom(                        backgroundColor: const Color(0xff93796A),                        minimumSize: const Size.fromHeight(50),                        shape: RoundedRectangleBorder(                            borderRadius: BorderRadius.circular(10)                        )                    ),                    child: Text('입력', style: TextStyle(color: Colors.white),),                    onPressed: (){                      setState(() {                        if (shot != 0) {                          caffeine = shot * 100;                        } else {                          caffeine = num.parse(caffeineController.text);                          input_shot = false;                        }                      });                    },                  ),                )              ],            ),          ],        ),      ),      Container(        margin: const EdgeInsets.only(left: 20, top: 10, right: 20),        child: Row(          crossAxisAlignment: CrossAxisAlignment.center,          children: [            Expanded(                child: Padding(                  padding: const EdgeInsets.only(top: 10,bottom: 10),                  child: Column(                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,                    crossAxisAlignment: CrossAxisAlignment.center,                    children: [                      Text(                        '카페인 함량',                        style: TextStyle(                            fontSize: 10                        ),                      ),                      //Container(height: 5,),                      Text(caffeine.toString(),                        style: TextStyle(                            fontSize: 18,                            fontWeight: FontWeight.bold                        ),                      )                    ],                  ),                )            ),            Expanded(                flex: 2,                child: Container(                  padding: const EdgeInsets.only(left: 10,top: 5,bottom: 5,),                  child: ElevatedButton(                    onPressed: isRecordButtonEnabled() ? handleRecordButtonPressed : null,                    style: ElevatedButton.styleFrom(                        backgroundColor: const Color(0xff93796A),                        minimumSize: const Size.fromHeight(50),                        shape: RoundedRectangleBorder(                            borderRadius: BorderRadius.circular(10)                        )                    ),                    child: const Text(                      '기록하기',                      style: TextStyle(fontSize: 15, color: Colors.white),                    ),                  ),                )            )          ],        ),      ),              ],            ),    );  }  bool isRecordButtonEnabled() {    return !isConfirm && menu.isNotEmpty && brand.isNotEmpty && caffeine > 0;  }  void handleRecordButtonPressed() {    userCaffeineService.addNewUserCaffeine(      today,      UserCaffeine(        drinkTime: time,        menuId: menu,        brand: brand,        menuSize: "",        shotAdded: -2,        caffeineContent: caffeine,        menuImg: downloadURL,      ),    );    Navigator.popUntil(context, (route) => route.isFirst);  }  Future getImage(ImageSource imageSource) async {    //pickedFile에 ImagePicker로 가져온 이미지가 담긴다.    final XFile? pickedFile = await picker.pickImage(source: imageSource);    if (pickedFile != null) {      setState(() {        imageUpload = true;        _image = XFile(pickedFile.path); //가져온 이미지를 _image에 저장        File imageFile = File(_image!.path);        uploadImage(imageFile);      });    }  }  Future<void> _dialogBuilder(BuildContext context)  {    return showDialog(        context: context,        barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부        builder: (BuildContext context) {          return AlertDialog(            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((10.0))),            content: const Text("어떤 것으로 접근하시겠습니까?"),            insetPadding: const EdgeInsets.fromLTRB(10, 100, 10, 10),            actions: [              TextButton(                child: const Text("카메라"),                onPressed: ()  {                  getImage(ImageSource.camera);                  Navigator.pop(context);                },              ),              TextButton(                child: const Text("갤러리"),                onPressed: () async {                    getImage(ImageSource.gallery);                    Navigator.pop(context);                },              ),            ],          );        }    );  }}