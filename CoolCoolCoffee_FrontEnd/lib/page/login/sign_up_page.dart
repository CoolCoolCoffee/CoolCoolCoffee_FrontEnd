import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _pass2Controller = TextEditingController();

  String _email = '';
  String _password = '';
  String _password2 = '';


  String errorMessage = '';

  void _handleSignUp() async{
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
      );
      print('사용자 회원가입 완료: ${userCredential.user!.email}');

      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({'app_access' : false})
          .onError((error, stackTrace) => print('데이엍 추가 에러!'));

      // 왜 토스트 안 되냐 ㅡㅡ
      // Fluttertoast.showToast(
      //   msg: '회원가입이 완료되었습니다!',
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.CENTER,
      //   backgroundColor: Colors.grey,
      //   textColor: Colors.blue,
      // );

      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );

    } on FirebaseAuthException catch (e) {
      //회원가입 예외처리
      switch (e.code) {
        case 'email-already-in-use':
          setState(() {
            errorMessage = '이미 존재하는 이메일 계정입니다.';
            print(errorMessage);
          });
          break;
        case 'invalid-email':
          setState(() {
            errorMessage = '이메일 주소가 올바른 형식이 아닙니다.';
            print(errorMessage);
          });
          break;
        case 'operation-no-allowed':
          setState(() {
            errorMessage = '이메일/패스워드 계정 생성이 허용되지 않습니다.';
            print(errorMessage);
          });
          break;
        case 'weak-password':
          setState(() {
            errorMessage = '비밀번호는 6자 이상이어야 합니다.';
            print(errorMessage);
          });
          break;
        default:
          errorMessage = e.code;
          print('오류가 발생했습니다. : $errorMessage');
      }
    }
  }


  Widget _userEmailWidget(){
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '이메일',
        hintText: '이메일을 입력하세요',
        hintStyle: TextStyle(color: Colors.grey),
      ),
      validator: (value){
        if(value == null || value.isEmpty){
          return "이메일을 입력해주세요";
        }
        return null;
      },
      onChanged: (value){
        setState(() {
          _email = value;
        });
      },
    );
  }

  Widget _userPwWidget(){
    return TextFormField(
      controller: _passController,
      obscureText: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '비밀번호',
        hintText: '비밀번호를 입력하세요',
        hintStyle: TextStyle(color: Colors.grey),
      ),
      validator: (value){
        if(value == null || value.isEmpty){
          return "비밀번호를 입력해주세요.";
        }
        return null;
      },
      onChanged: (value){
        setState(() {
          _password = value;
        });
      },
    );
  }

  Widget _userPw2Widget(){
    return TextFormField(
      controller: _pass2Controller,
      obscureText: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '비밀번호',
        hintText: '비밀번호를 입력하세요.',
        hintStyle: TextStyle(color: Colors.grey),
      ),
      validator: (value){
        if(value == null || value.isEmpty){
          return "비밀번호를 입력해주세요.";
        } else if(value != _password){
          return "비밀번호가 일치하지 않습니다.";
        }
        return null;
      },
      onChanged: (value){
        setState(() {
          _password2 = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('회원가입 화면'),
              const SizedBox(height: 30,),
              _userEmailWidget(),
              const SizedBox(height: 20,),
              _userPwWidget(),
              const SizedBox(height: 20,),
              _userPw2Widget(),
              const SizedBox(height: 30,),
              ElevatedButton(
                onPressed: (){
                  if(_formKey.currentState!.validate()){
                    _handleSignUp();
                  }
                },
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    //해당 클래스가 호출되었을떄
    super.initState();
  }
  @override
  void dispose() {
    // 해당 클래스가 사라질떄
    _emailController.dispose();
    _passController.dispose();
    _pass2Controller.dispose();
    super.dispose();
  }
}
