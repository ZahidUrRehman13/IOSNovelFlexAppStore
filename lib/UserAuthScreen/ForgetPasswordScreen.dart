import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../Models/ForgetPasswordModel.dart';
import '../Models/ResetPasswordModel.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../Utils/toast.dart';
import '../Widgets/reusable_button.dart';
import '../Widgets/reusable_button_small.dart';
import '../localization/Language/languages.dart';
import '../tab_screen.dart';
import 'login_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  static const String id = 'forgetPassword_screen';

  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  var _emailFocusNode = new FocusNode();
  var _passwordFNode = new FocusNode();
  var _confirmPasswordFocusNode = new FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  var _emailKey = GlobalKey<FormFieldState>();
  var _passKey = GlobalKey<FormFieldState>();
  var _cPassKey = GlobalKey<FormFieldState>();

  TextEditingController? _controllerEmail;
  TextEditingController? _passcontoller;
  TextEditingController? _cPAsscontroller;

  bool _autoValidate = false;

  bool _isLoading = false;

  bool _firstScreenVisisbility =true;
  bool _secondScreenVisibilities =false;


  ForgetPasswordModel? _forgetPasswordModel;
  ResetPasswordModel? _resetPasswordModel;
  @override
  void initState() {
    super.initState();
    _controllerEmail = TextEditingController();
    _passcontoller = TextEditingController();
    _cPAsscontroller = TextEditingController();
  }

  @override
  void dispose() {
    _controllerEmail!.dispose();
    _passcontoller!.dispose();
    _cPAsscontroller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: const Color(0xffebf5f9),
        appBar: AppBar(
          toolbarHeight: _height*0.1,
          title: Text(Languages.of(context)!.forgetPassword,style: TextStyle( color: const Color(0xFF256D85),fontSize: _width*0.043),),
          centerTitle: true,
          backgroundColor:const Color(0xffebf5f9),
          elevation: 0.0,
          leading: IconButton(
              onPressed: (){

                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back,size: _height*0.03,color: Colors.black54,)),
        ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Visibility(
                  visible: _firstScreenVisisbility,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: _width*0.5 ,
                            height: _height*0.2,
                            decoration: BoxDecoration(
                                color:  Colors.black12,
                              borderRadius: BorderRadius.circular(20)
                            ),
                          child: Icon(Icons.lock,color:  const Color(0xff3a6c83),size: _height*_width*0.0003,),
                        ),
                        Padding(padding: EdgeInsets.only(top: _height*0.03 ),
                        child:Text(
                            Languages.of(context)!.resetPasswordtxt,
                            style: const TextStyle(
                                color:  const Color(0xff3a6c83),
                                fontWeight: FontWeight.w700,
                                fontFamily: "Lato",
                                fontStyle:  FontStyle.normal,
                                fontSize: 20.0
                            ),
                            textAlign: TextAlign.center
                        ), ),
                        Padding(padding: EdgeInsets.only(top: _height*0.03 ),
                          child:Text(
                              Languages.of(context)!.resetPasswordtxt2,
                              style: const TextStyle(
                                  color:  const Color(0xff002333),
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Lato",
                                  fontStyle:  FontStyle.normal,
                                  fontSize: 12.0
                              ),
                              textAlign: TextAlign.center
                          ) ),
                        Padding(
                          padding:  EdgeInsets.only(left: _width*0.05,right: _width*0.05,top: _height*0.05),
                          child: TextFormField(
                            key: _emailKey,
                            controller: _controllerEmail,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            cursorColor: Colors.black,
                            validator: validateEmail,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus();
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
                                    color: Color(0xFF256D85),
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
                        Container(
                          margin: EdgeInsets.only(top: _height * 0.06),
                          child: ResuableMaterialButtonSmall(
                            onpress: () {
                              handleResetUser();

                            },
                            buttonname: Languages.of(context)!.forgetPassword,
                          ),
                        ),
                        Visibility(
                          visible: _isLoading,
                          child: Padding(
                            padding:  EdgeInsets.only(top: _height*0.1),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color:Color(0xFF256D85)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _secondScreenVisibilities,
                  child: Form(
                    key: _formKey1,
                    child: Column(
                      children: [
                        SizedBox(height: _height*0.05,),
                        mainText2(_width),
                        Visibility(
                          visible: _isLoading,
                          child: Padding(
                            padding:  EdgeInsets.only(top: _height*0.1),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color:Color(0xFF256D85)
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: _height * 0.1,
                                right: _width * 0.04,
                                left: _width * 0.04),
                            child: TextFormField(
                              key: _passKey,
                              controller: _passcontoller,
                              focusNode: _passwordFNode,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              validator: validatePassword,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus();
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
                                      color: Color(0xFF256D85),
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
                                  hintText: Languages.of(context)!.newFpassword,
                                  // labelText: Languages.of(context)!.email,
                                  hintStyle: const TextStyle(
                                    fontFamily: Constants.fontfamily,

                                  )),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: _height * 0.05,
                                right: _width * 0.04,
                                left: _width * 0.04),
                            child: TextFormField(
                              key: _cPassKey,
                              controller: _cPAsscontroller,
                              focusNode:_confirmPasswordFocusNode ,
                              textInputAction: TextInputAction.next,
                              cursorColor: Colors.black,
                              obscureText: true,
                              validator: validatePassword,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus();
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
                                      color: Color(0xFF256D85),
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
                                  hintText: Languages.of(context)!.confirmnewpassword,
                                  // labelText: Languages.of(context)!.email,
                                  hintStyle: const TextStyle(
                                    fontFamily: Constants.fontfamily,

                                  )),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: _height * 0.06),
                            child: ResuableMaterialButtonSmall(
                              onpress: () {
                                handleForgetUser();
                              },
                              buttonname: Languages.of(context)!.doneText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
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
    } else {
      return null;
    }
  }

  void handleResetUser() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey.currentState!.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState!.save();
      //Call api
      // _checkInternetConnection();
      _checkInternetConnection();
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  void handleForgetUser() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (_formKey1.currentState!.validate()) {
//    If all data are correct then save data to out variables
      _formKey1.currentState!.save();
      //Call api
      // _checkInternetConnection();
      _checkInternetConnection1();
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  _navigateAndRemove() {
    _controllerEmail!.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        ModalRoute.withName("login_screen"));
    // Fluttertoast.showToast(
    //     msg:
    //         "Verification Email is Sent to Your Given Email Address  Successfully!",
    //     gravity: ToastGravity.BOTTOM,
    //     backgroundColor: Colors.black87,
    //     textColor: Colors.white,
    //     fontSize: 16.0);
  }

  Widget mainText2(var width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Languages.of(context)!.newPasswordCreate,
            style: const TextStyle(
                color:  const Color(0xff3a6c83),
                fontWeight: FontWeight.w700,
                fontFamily: "Lato",
                fontStyle:  FontStyle.normal,
                fontSize: 20.0
            ),
            textAlign: TextAlign.center
        ),
      ],
    );
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
    print('_passwordKey: ${_passKey.currentState!.value}');
    if (value != _passKey.currentState!.value) {
      return 'Password does not match';
    } else {
      return null;
    }
  }

  Future _checkInternetConnection() async {
    // if (this.mounted) {
    //   setState(() {
    //     _isLoading = true;
    //   });
    // }

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (!(connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi)) {
      ToastConstant.showToast(context, "Internet Not Connected");
      // if (this.mounted) {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // }
    } else {
      _callResetPassword1stAPI();
    }
  }

  Future _callResetPassword1stAPI() async {
    setState(() {
      _isLoading = true;
    });

    var map = Map<String, dynamic>();
    map['email'] = _controllerEmail!.text.trim();



    final response = await http.post(
      Uri.parse(ApiUtils.FORGET_PASSWORD_API),
      body: map,
    );

    var jsonData;

    switch (response.statusCode) {

      case 200:
      //Success

        var jsonData = json.decode(response.body);

        if(jsonData['status']==200){
          _forgetPasswordModel = ForgetPasswordModel.fromJson(jsonData);
          print('forget_response: $jsonData');
          ToastConstant.showToast(context, _forgetPasswordModel!.message.toString());
          setState(() {
            _isLoading = false;
            _firstScreenVisisbility = false;
            _secondScreenVisibilities = true;
          });
        }else{

          ToastConstant.showToast(context, "Sorry You have not register yet!");
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

  Future _checkInternetConnection1() async {
    // if (this.mounted) {
    //   setState(() {
    //     _isLoading = true;
    //   });
    // }

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (!(connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi)) {
      ToastConstant.showToast(context, "Internet Not Connected");
      // if (this.mounted) {
      //   setState(() {
      //     _isLoading = false;
      //   });
      // }
    } else {
      _callForgetPassword1stAPI();
    }
  }

  Future _callForgetPassword1stAPI() async {
    setState(() {
      _isLoading = true;
    });
    var map1 = new Map<String, String>();
    map1['accesstoken'] = _forgetPasswordModel!.data!.accessToken.toString();

    var map = new Map<String, dynamic>();
    map['newpassword'] = _passcontoller!.text.trim();
    map['confirmpassword'] = _cPAsscontroller!.text.trim();



    final response = await http.post(
      Uri.parse(ApiUtils.UPDATE_PASSWORD_API),
      body: map,
      headers: map1,
    );

    var jsonData;

    switch (response.statusCode) {

      case 200:
      //Success

        var jsonData = json.decode(response.body);

        if(jsonData['status'] ==200){
          print('resetPassword_response: $jsonData');
          _resetPasswordModel = ResetPasswordModel.fromJson(jsonData);
          ToastConstant.showToast(context, _resetPasswordModel!.message.toString());
          setState(() {
            _isLoading = false;
            _firstScreenVisisbility = true;
            _secondScreenVisibilities = false;

          });
          _navigateAndRemove();
        }else{

          ToastConstant.showToast(context, jsonData['message'].toString());
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




}
