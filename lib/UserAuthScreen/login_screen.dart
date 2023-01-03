import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:novelflex/UserAuthScreen/SignUpScreens/signUpScreen_First.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/UserModel.dart';
import '../Provider/UserProvider.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../Utils/toast.dart';
import '../Widgets/reusable_button.dart';
import '../Widgets/reusable_button_small.dart';
import '../localization/Language/languages.dart';
import 'ForgetPasswordScreen.dart';
import 'SignUpScreens/SignUpScreen_Second.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String id = 'login_screen';

  final _emailFocusNode = new FocusNode();
  final _passwordFocusNode = new FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _passwordKey = GlobalKey<FormFieldState>();
  final _emailKey = GlobalKey<FormFieldState>();

  TextEditingController? _controllerEmail;
  TextEditingController? _controllerPassword;

  bool _autoValidate = false;

  bool _isLoading = false;

  UserModel? _userModel;

  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
    _controllerEmail = TextEditingController();
    _controllerPassword = TextEditingController();
  }

  @override
  void dispose() {
    _controllerEmail!.dispose();
    _controllerPassword!.dispose();
    super.dispose();
  }

  void handleLoginUser() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _checkInternetConnection();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Future _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (!(connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi)) {
      Fluttertoast.showToast(
        msg: "Internet Not Connected",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.white,
        backgroundColor: Colors.black,
        fontSize: 14,
      );
      _errorMsg = "No internet connection.";
    } else {
      _callLoginAPI();
    }
  }

  _navigateAndRemove() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controllerEmail!.clear();
      _controllerPassword!.clear();
      Navigator.of(context).pushNamedAndRemoveUntil(
          'tab_screen', (Route<dynamic> route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xffebf5f9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: height * 0.02,
                    ),
                    mainText2(width),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    SizedBox(
                      height: height * 0.2,
                      width: width * 0.4,
                      child: Image.asset('assets/quotes_data/NoPath.png'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.02, horizontal: width * 0.04),
                      child: TextFormField(
                        key: _emailKey,
                        controller: _controllerEmail,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        cursorColor: Colors.black,
                        validator: validateEmail,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                        decoration: InputDecoration(
                            errorMaxLines: 3,
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.white12,
                              ),
                            ),
                            disabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF256D85),
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF256D85),
                              ),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.red,
                                )),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.red,
                              ),
                            ),
                            hintText: Languages.of(context)!.email,
                            // labelText: Languages.of(context)!.email,
                            hintStyle: const TextStyle(
                              fontFamily: Constants.fontfamily,
                            )),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.02, horizontal: width * 0.04),
                      child: TextFormField(
                        key: _passwordKey,
                        controller: _controllerPassword,
                        focusNode: _passwordFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        cursorColor: Colors.black,
                        validator: validatePassword,
                        obscureText: true,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_emailFocusNode);
                        },
                        decoration: InputDecoration(
                            errorMaxLines: 3,
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white,
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.black12,
                              ),
                            ),
                            disabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.black12,
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Color(0xFF256D85),
                              ),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.red,
                                )),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                width: 1,
                                color: Colors.red,
                              ),
                            ),
                            hintText: Languages.of(context)!.password,
                            // labelStyle: TextStyle(
                            //   color: Colors.red
                            // ),
                            // labelText: Languages.of(context)!.password,
                            hintStyle: const TextStyle(
                              fontFamily: Constants.fontfamily,
                            )),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgetPasswordScreen()),
                              ModalRoute.withName("forgetPassword_screen"));
                        },
                        child: forgetPassword(height)),
                    Container(
                      margin: EdgeInsets.only(top: height * 0.03),
                      child: ResuableMaterialButtonSmall(
                        onpress: () {
                          handleLoginUser();
                        },
                        buttonname: Languages.of(context)!.login,
                      ),
                    ),
                    Platform.isIOS ? Container() : Padding(
                      padding: EdgeInsets.only(top: height * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: width * 0.2,
                              height: 1,
                              decoration: BoxDecoration(
                                  color: const Color(0xff3a6c83))),
                          Text(Languages.of(context)!.continueWith,
                              style: const TextStyle(
                                  color: const Color(0xff002333),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Lato",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 12.0),
                              textAlign: TextAlign.center),
                          Container(
                              width: width * 0.2,
                              height: 1,
                              decoration: BoxDecoration(
                                  color: const Color(0xff3a6c83)))
                        ],
                      ),
                    ),
                    Platform.isIOS ? Container() :Padding(
                      padding: EdgeInsets.only(top: height * 0.03),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                              "assets/quotes_data/google_login.svg", //asset location

                              fit: BoxFit.scaleDown),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          SvgPicture.asset(
                              "assets/quotes_data/facebook_login.svg", //asset location

                              fit: BoxFit.scaleDown),
                          SizedBox(
                            width: width * 0.02,
                          ),
                          SvgPicture.asset(
                              "assets/quotes_data/apple_login.svg", //asset location
                              fit: BoxFit.scaleDown)
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Visibility(
                  visible: _isLoading == true,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF256D85),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SignUpScreen_Second()));
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      top: height * 0.02,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        Languages.of(context)!.donthaveanaccountSignUp,
                        style: const TextStyle(
                            color: const Color(0xff3a6c83),
                            fontWeight: FontWeight.w700,
                            fontFamily: "Lato",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mainText(var width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Languages.of(context)!.welcomenovelflex,
          style: TextStyle(
            color: Colors.black87,
            fontSize: width * 0.05,
            fontWeight: FontWeight.w800,
            fontFamily: Constants.fontfamily,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget mainSmallText(double height) {
    return Container(
      margin: EdgeInsets.only(top: height * 0.02),
      child: Text(
        Languages.of(context)!.socailtext,
        style: TextStyle(
          color: Colors.black26,
          fontSize: height * 0.02,
          fontFamily: Constants.fontfamily,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget mainText2(var width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Languages.of(context)!.login,
          style: const TextStyle(
              color: const Color(0xff002333),
              fontWeight: FontWeight.w700,
              fontFamily: "Lato",
              fontStyle: FontStyle.normal,
              fontSize: 14.0),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget forgetPassword(double height) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: height * 0.01,
                  right: height * 0.04,
                  left: height * 0.04),
              child: Text(
                Languages.of(context)!.forgetPassword,
                style: const TextStyle(
                    color: const Color(0xff002333),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Lato",
                    fontStyle: FontStyle.normal,
                    fontSize: 12.0),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(right: height * 0.04, left: height * 0.04),
              child: SizedBox(
                width: width * 0.24,
                child: const Divider(
                  color: Colors.black,
                  thickness: 1.0,
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'Please Enter Email';
    }

    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    // RegExp regex = new RegExp(pattern);
    RegExp regex = RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return 'Enter Valid Email';
    } else
      return null;
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) return 'Please enter password';

    if (value.length < 6) {
      return 'Password should be more than 6 characters';
    } else
      return null;
  }

  Future _callLoginAPI() async {
    setState(() {
      _isLoading = true;
    });
    var map = Map<String, dynamic>();
    map['email'] = _controllerEmail!.text.trim();
    map['password'] = _controllerPassword!.text.trim();

    final response = await http.post(
      Uri.parse(ApiUtils.URL_LOGIN_USER_API),
      body: map,
    );

    var jsonData;

    if (response.statusCode == 200) {
      //Success

       jsonData = json.decode(response.body);
      print('loginSuccess_data: $jsonData');
      if (jsonData['status'] == 200) {
        _userModel = UserModel.fromJson(jsonData);
        saveToPreferencesUserDetail(_userModel);
        _navigateAndRemove();

        ToastConstant.showToast(context, "Login Successfully");
        setState(() {
          _isLoading = false;
        });

      } else {
        ToastConstant.showToast(context, "Invalid Credential!");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ToastConstant.showToast(context, "Internet Server Error!");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void saveToPreferencesUserDetail(UserModel? _userModel) async {
    UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);

    userProvider.setUserEmail(_userModel!.data!.email!);
    userProvider.setUserToken(_userModel.data!.accessToken!);
    userProvider.setUserName(_userModel.data!.fname!);
    // userProvider.setUserImage(_userModel.data.img);
    userProvider.setUserID(_userModel.data!.id!.toString());
    userProvider.setLanguage("English");
  }
}
