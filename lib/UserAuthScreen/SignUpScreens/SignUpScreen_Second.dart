import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:novelflex/UserAuthScreen/SignUpScreens/signUpScreen_Third.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/UserModel.dart';
import '../../Provider/UserProvider.dart';
import '../../Utils/ApiUtils.dart';
import '../../Utils/Constants.dart';
import '../../Utils/toast.dart';
import '../../Widgets/reusable_button_small.dart';
import '../../localization/Language/languages.dart';
import '../../tab_screen.dart';
import '../login_screen.dart';

class SignUpScreen_Second extends StatefulWidget {
  static const String id = 'signUp_screen';

  const SignUpScreen_Second({Key? key}) : super(key: key);

  @override
  State<SignUpScreen_Second> createState() => _SignUpScreen_SecondState();
}

class _SignUpScreen_SecondState extends State<SignUpScreen_Second> {

  var _fullnameFocusNode = new FocusNode();
  var _emailFocusNode = new FocusNode();
  var _phoneFocusNode = new FocusNode();
  var _passwordFocusNode = new FocusNode();
  var _confirmpasswordFocusNode = new FocusNode();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(debugLabel: 'GlobalFormKey #SignIn ');

  final _fullNameKey = GlobalKey<FormFieldState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _phoneKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();
  final _confirPasswordKey = GlobalKey<FormFieldState>();

  String _errorMsg = "";

  TextEditingController? _controllerFullName;
  TextEditingController? _controllerEmail;
  TextEditingController? _controllerPhoneNumber;
  TextEditingController? _controllerPassword;
  TextEditingController? _controllerConfirmPassword;

  bool _autoValidate = false;

  bool _isLoading = false;

  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _controllerFullName = TextEditingController();
    _controllerEmail = TextEditingController();
    _controllerPhoneNumber = TextEditingController();
    _controllerPassword = TextEditingController();
    _controllerConfirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _controllerFullName!.dispose();
    _controllerEmail!.dispose();
    _controllerPhoneNumber!.dispose();
    _controllerPassword!.dispose();
    _controllerConfirmPassword!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: const Color(0xffebf5f9),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild!.unfocus();
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    mainText2(_width),
                    SizedBox(
                      height: _height*0.2,
                      width: _width*0.4,
                      child: Image.asset('assets/quotes_data/NoPath.png'),
                    ),
                    mainText(_width),
                    Padding(
                      padding: EdgeInsets.only(
                          top: _height * 0.04,
                          bottom: _height * 0.01,
                          left: _width * 0.04,
                          right: _width * 0.04),
                      child: TextFormField(
                        key: _fullNameKey,
                        controller: _controllerFullName,
                        focusNode: _fullnameFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        cursorColor: Colors.black,
                        validator: validateFullName,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_emailFocusNode);
                        },
                        decoration:  InputDecoration(
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
                            hintText: Languages.of(context)!.userName,
                            // labelText: Languages.of(context)!.userName,
                        hintStyle: const TextStyle(
                          fontFamily: Constants.fontfamily,
                        )),

                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _height * 0.01, horizontal: _width * 0.04),
                      child: TextFormField(
                        key: _emailKey,
                        controller: _controllerEmail,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        cursorColor: Colors.black,
                        validator: validateEmail,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_phoneFocusNode);
                        },
                        decoration:  InputDecoration(
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
                        hintStyle: const TextStyle(fontFamily: Constants.fontfamily,)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _height * 0.01, horizontal: _width * 0.04),
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
                              .requestFocus(_confirmpasswordFocusNode);
                        },
                        decoration:  InputDecoration(
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
                            hintText: Languages.of(context)!.password,
                            // labelText: Languages.of(context)!.password,
                        hintStyle: const TextStyle(fontFamily: Constants.fontfamily,)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: _height * 0.01, horizontal: _width * 0.04),
                      child: TextFormField(
                        key: _confirPasswordKey,
                        controller: _controllerConfirmPassword,
                        focusNode: _confirmpasswordFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        cursorColor: Colors.black,
                        validator: validateConfirmPassword,
                        onFieldSubmitted: (_) {
                          handleRegisterUser();
                        },
                        decoration:  InputDecoration(
                          errorMaxLines: 3,
                          counterText: "",
                          filled: true,
                          fillColor: Colors.white,
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color:  Colors.black12,
                            ),
                          ),
                          disabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color:  Color(0xFF256D85),
                            ),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color:  Color(0xFF256D85),
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.red,
                            ),
                          ),
                          hintText: Languages.of(context)!.confirmpassword,
                          // labelText: Languages.of(context)!.confirmpassword,
                          hintStyle: const TextStyle(
                            fontFamily: Constants.fontfamily,
                          )
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _isLoading == true,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF256D85),
                        ),
                      ),
                    ),
                    Container(
                      width: _width * 0.9,
                      height: _height * 0.06,
                      margin: EdgeInsets.only(
                        top: _height*0.05
                      ),
                      child: ResuableMaterialButtonSmall(
                        onpress: () {
                          // setState(() {
                          //   _isLoading=true;
                          // });
                          handleRegisterUser();
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>
                          // SingUpScreen_Third()));
                        },
                        buttonname: Languages.of(context)!.register,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                            ModalRoute.withName("login_screen"));
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          top: _height * 0.08,
                        ),
                        child: Text(
                            Languages.of(context)!.alreadyhaveAccountSignIn,
                          style: const TextStyle(
                              color:  const Color(0xff3a6c83),
                              fontWeight: FontWeight.w400,
                              fontFamily: "Lato",
                              fontStyle:  FontStyle.normal,
                              fontSize: 14.0
                          ), textAlign: TextAlign.center,

                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget mainText(var width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Languages.of(context)!.createAccount,
          style: const TextStyle(
              color:  const Color(0xff002333),
              fontWeight: FontWeight.w700,
              fontFamily: "Lato",
              fontStyle:  FontStyle.normal,
              fontSize: 20.0
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String? validateFullName(String? value) {
    if (value!.isEmpty) {
      return 'Enter Full Name';
    } else {
      return null;
    }
  }

  String? validateEmail(String? value) {
    if (value!.isEmpty) {
      return 'Please Enter Email';
    }

    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    // RegExp regex = new RegExp(pattern);
    RegExp regex = new RegExp(pattern.toString());
    if (!regex.hasMatch(value)) {
      return 'Enter Valid Email';
    } else
      return null;
  }

  String? validateMobile(String? value) {
    //Mobile number are of 10 digit only
    if (value!.length < 10) {
      return 'Mobile Number cannot be less than 10';
    } else {
      return null;
    }
  }

  String? validatePassword(String? value) {
    if (value!.isEmpty) return 'Please enter password';

    if (value.length < 6) {
      return 'Password should be more than 6 characters';
    } else {
      return null;
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value!.isEmpty) return 'Please Enter Confirm Password';
    print('_passwordKey: ${_passwordKey.currentState!.value}');
    if (value != _passwordKey.currentState!.value) {
      return 'Password do not match';
    } else {
      return null;
    }
  }

  void handleRegisterUser() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState!.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState!.save();
      //Call api
      // _checkInternetConnection();\
      // Navigator.pop(context);
      // Navigator.push(context, MaterialPageRoute(builder: (context)=>TabScreen()));
      _checkInternetConnection();
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Widget reusableTextFormField(
      {var key,
      var controller,
      var focusNode,
      var validator,
      var focusnodeNext,
      var hintText,
      var height,
      var width}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: height * 0.02, horizontal: width * 0.04),
      child: TextFormField(
        key: key,
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        cursorColor: Colors.black,
        validator: validator,
        onFieldSubmitted: (_) {
          FocusScope.of(context).requestFocus(focusnodeNext);
        },
        decoration: InputDecoration(
          errorMaxLines: 3,
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.blue,
            ),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.blue,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.blue,
            ),
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
            ),
          ),
          errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                width: 1,
                color: Colors.red,
              )),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
          hintText: hintText,
        ),
      ),
    );
  }


  Future _checkInternetConnection() async {
    if (this.mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (!(connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi)) {
      ToastConstant.showToast(context, "Internet Not Connected");
      _errorMsg = "No internet connection.";
      if (this.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _callRegisterAPI();
    }
  }

  Future _callRegisterAPI() async {
    setState(() {
      _isLoading = true;
    });

    var map = Map<String, dynamic>();
    map['fname'] =  _controllerFullName!.text.trim();
    map['lname'] = _controllerFullName!.text.trim();
    map['email'] = _controllerEmail!.text.trim();
    map['password'] = _controllerPassword!.text.trim();
    map['confirmd_password'] = _controllerConfirmPassword!.text.trim();



    final response = await http.post(
      Uri.parse(ApiUtils.URL_REGISTER_USER_API),
      body: map,
    );

    var jsonData;

    switch (response.statusCode) {

      case 200:
        //Success

        var jsonData = json.decode(response.body);

        if(jsonData['status']==200){
          print('RegisterSuccess_data: $jsonData');
          _userModel = UserModel.fromJson(jsonData);
          saveToPreferencesUserDetail(_userModel);
          _navigateAndRemove();
          ToastConstant.showToast(context, "Register Successfully");
          setState(() {
            _isLoading = false;
          });
        }else{

          ToastConstant.showToast(context,jsonData['message'].toString());
          setState(() {
            _isLoading = false;
          });
        }


        break;
      case 401:
        jsonData = json.decode(response.body);
        print('jsonData 401: $jsonData');
        ToastConstant.showToast(context, ToastConstant.ERROR_MSG_401);

        break;
      case 404:
        jsonData = json.decode(response.body);
        print('jsonData 404: $jsonData');

        ToastConstant.showToast(context, ToastConstant.ERROR_MSG_404);

        break;
      case 400:
        jsonData = json.decode(response.body);
        print('jsonData 400: $jsonData');

        ToastConstant.showToast(context, 'Email already Exist.');

        break;
      case 405:
        jsonData = json.decode(response.body);
        print('jsonData 405: $jsonData');
        ToastConstant.showToast(context, ToastConstant.ERROR_MSG_405);

        break;
      case 422:
        //Unprocessable Entity
        jsonData = json.decode(response.body);
        print('jsonData 422: $jsonData');

        ToastConstant.showToast(context, ToastConstant.ERROR_MSG_422);
        break;
      case 500:
        jsonData = json.decode(response.body);
        print('jsonData 500: $jsonData');

        ToastConstant.showToast(context, ToastConstant.ERROR_MSG_500);

        break;
      default:
        jsonData = json.decode(response.body);
        print('jsonData failed: $jsonData');

        ToastConstant.showToast(context, "Login Failed Try Again");
    }

    if (this.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void saveToPreferencesUserDetail(UserModel? _userModel) {
    UserProvider userProvider =
    Provider.of<UserProvider>(context, listen: false);

    userProvider.setUserEmail(_userModel!.data!.email!);
    userProvider.setUserToken(_userModel.data!.accessToken!);
    userProvider.setUserName(_userModel.data!.fname!);
    // userProvider.setUserImage(_userModel.data.img);
    userProvider.setUserID(_userModel.data!.id!.toString());
    // userProvider.setUserImage(_userModel.data.img);
    userProvider.setLanguage("English");
  }

  _navigateAndRemove() {
    Navigator.pushAndRemoveUntil(
        this.context,
        MaterialPageRoute(builder: (context) => TabScreen()),
        ModalRoute.withName("tab_screen"));
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

