import 'package:chat_app/constants.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference userRef =
    FirebaseFirestore.instance.collection('Users');

  String errText = '';

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
                  controller: nameController,
                  decoration: kInputDecoration.copyWith(
                    prefixIcon: const Icon(Icons.person_outline_outlined, color: Colors.grey),
                    hintText: 'Name',
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
                        'Sign up',
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
                      'Already have an account?',
                      style: TextStyle(
                        fontSize: 14,
                        color: kLightGrey,
                      ),
                    ),
                    TextButton(
                      onPressed: (){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: const Text(
                        'Sign in',
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
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    Map<String, dynamic> newMap = Map();
    newMap['displayName'] = name;
    newMap['email'] = email;
    newMap['password'] = password;

    bool status = validationForm(name, email, password);

    if(status == true){
      try {
        auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        )
            .then((value) {
              newMap['userId'] = value.user!.uid;
              userRef.add(newMap).then((value) => print(value));
              resetValues();
        });
      } catch (e) {
        print(e);
      }
    }
    else{
      //pass
    }
  }

  bool validationForm(String name, String email, String password){
    bool validation = true;
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    setState(() {
      if(name == '' || email == '' || password == ''){
        errText = 'Can not be empty!';
        validation = false;
      }
      else if(emailValid)
      {
        if(password.length < 6)
        {
          errText = 'Password must be at least 6 characters long!';
          print('Password must be at least 6 characters long!');
          validation = false;
        }
      }
      else
      {
        errText = 'Invalid email!';
        print('Invalid email!');
        validation = false;
      }
    });
    setState(() {
      errText = '';
    });
    return validation;
  }

  resetValues(){
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

}

