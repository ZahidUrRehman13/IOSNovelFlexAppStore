import 'package:custom_signin_buttons/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:novelflex/UserAuthScreen/login_screen.dart';
import '../../localization/Language/languages.dart';
import 'SignUpScreen_Second.dart';

class SignUpScreen_First extends StatefulWidget {
  const SignUpScreen_First({Key? key}) : super(key: key);

  @override
  State<SignUpScreen_First> createState() => _SignUpScreen_FirstState();
}

class _SignUpScreen_FirstState extends State<SignUpScreen_First> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return  Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild!.unfocus();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              mainText2(width),
              SizedBox(
                height: height*0.1,
                width: width*0.6,
                child: Image.asset('assets/quotes_data/NoPath.png',fit: BoxFit.cover,),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomSignInButton(
                    text: 'Register      ',
                    customIcon: Icons.email,
                    height: height*0.06,
                    width: width*0.85,
                    iconTopPadding: 5,
                    buttonColor: Color(0xff3a6c83),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    mini: false,
                    onPressed: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen_Second()));
                    },
                  ),
                  SizedBox(height: height*0.02,),
                  CustomSignInButton(
                    text: 'Sign In With Gmail',
                    iconSize: width*height*0.0001,
                    height: height*0.06,
                    width: width*0.85,
                    iconTopPadding: 5,
                    customIcon: Icons.g_mobiledata_outlined,
                    buttonColor: Color(0xfff14336),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    mini: false,
                  ),
                  SizedBox(height: height*0.02,),
                  CustomSignInButton(
                    text: 'Sign In With Facebook',
                    customIcon: Icons.facebook_outlined,
                    height: height*0.06,
                    width: width*0.85,
                    iconTopPadding: 5,
                    buttonColor: Color(0xff2275e9),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    mini: false,
                  ),
                  SizedBox(height: height*0.02,),
                  CustomSignInButton(
                    text: 'Sign In With Apple',
                    customIcon: Icons.apple,
                    height: height*0.06,
                    width: width*0.85,
                    iconTopPadding: 5,
                    buttonColor: Color(0xff1e1e1e),
                    iconColor: Colors.white,
                    textColor: Colors.white,
                    mini: false,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
                child: Container(
                  margin: EdgeInsets.only(
                    top: height * 0.02,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      Languages.of(context)!.alreadyhaveAccountSignIn,
                      style: const TextStyle(
                          color:  const Color(0xff002333),
                          fontWeight: FontWeight.w400,
                          fontFamily: "Lato",
                          fontStyle:  FontStyle.normal,
                          fontSize: 14.0
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget mainText2(var width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Languages.of(context)!.signup,
          style: const TextStyle(
              color:  const Color(0xff002333),
              fontWeight: FontWeight.w700,
              fontFamily: "Lato",
              fontStyle:  FontStyle.normal,
              fontSize: 14.0
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
