import 'package:chat_app/constants.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  String errText = '';

  @override
  void initState() {

    super.initState();
    if (auth.currentUser != null) {
      Future.delayed(
        const Duration(milliseconds: 500),
            () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
             },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25,),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 30),
                    padding: const EdgeInsets.all(10),
                    width: 150,
                    height: 150,
                    child: const Image(
                      image: AssetImage('assets/images/message-icon.png'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: emailController,
                  decoration: kInputDecoration.copyWith(
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                    hintText: 'Email',
                    hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: passwordController,
                  decoration: kInputDecoration.copyWith(
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    hintText: 'Password',
                    hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15
                      ),
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){
                      onButtonPressed();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(kDarkBlue),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.0),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Forget your password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: kLightGrey,
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: kMainBlue,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  errText,
                  style: const TextStyle(
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void onButtonPressed(){
    String email = emailController.text;
    String password = passwordController.text;
    bool status = validationForm(email, password);
    if(status == true){
      try {
        auth.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim()
        )
            .then((value) {
              if (auth.currentUser != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              }
        });
      } catch (e) {
        print(e.toString());
      }
    }
  }
  bool validationForm(String email, String password){
    bool validation = true;
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);

      if(email == '' || password == ''){
        errText = 'Can not be empty!';
        validation = false;
      }
      else if(emailValid)
      {
        if(password.length < 6)
        {
          errText = 'Password must be at least 6 characters long!';
          validation = false;
        }
      }
      else
      {
        errText = 'Invalid email!';
        validation = false;
      }

    return validation;
  }


}


