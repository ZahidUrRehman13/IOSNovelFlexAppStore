import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../MixScreens/UploadDataScreen.dart';
import '../MixScreens/upload_history_screen.dart';
import '../Models/AuthorProfileModel.dart';
import '../Models/ProfileStatusModel.dart';
import '../Models/UserUploadHistoryModel.dart';
import '../Provider/UserProvider.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../Utils/toast.dart';
import '../Widgets/reusable_button_small.dart';
import '../localization/Language/languages.dart';

class Profile_Screen extends StatefulWidget {
  String? payload;
  Profile_Screen([this.payload]);

  @override
  State<Profile_Screen> createState() => _Profile_ScreenState();
}

class _Profile_ScreenState extends State<Profile_Screen> {
  static const String id = 'profile_screen';
  UserUploadHistoryModel? _userUploadHistoryModel;
  AuthorProfileModel? _authorProfileModel;
  ProfileStatusModel? _profileStatusModel;
  String email = "";
  File? imageFile;
  bool _isLoading = false;
  bool _isHistoryLoading = false;
  bool _isAuthorLoading = false;
  bool _isInternetConnected = true;
  String role = "0";
  bool _emtyFlag = false;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();

  }

  @override
  void dispose() {



    super.dispose();
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
      Constants.showToastBlack(context, "Internet not connected");
      if (this.mounted) {
        setState(() {
          _isLoading = false;
          _isInternetConnected = false;
        });
      }
    } else {
      _profileStatusAPI();
    }
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: _isLoading ||_isAuthorLoading ?  Colors.white : Color(0xFF256D85),
        body: SafeArea(
            child: Container(
                child: _isInternetConnected
                    ? _isLoading
                        ? const Center(
                  child: CupertinoActivityIndicator(
                    color: const Color(0xFF256D85),
                    radius: 20,
                  ),
                )
                        : _profileStatusModel!.data!.userType == "3"
                            ? _isAuthorLoading ? const Center(
                  child: CupertinoActivityIndicator(
                    color: const Color(0xFF256D85),
                    radius: 20,
                  ),
                )
                    :  Stack(
                                children: [
                                  Positioned(
                                      child: Container(
                                    height: _height * 0.9,
                                    color: Colors.white,
                                  )),
                                  Positioned(
                                    child: Container(
                                      height: _height * 0.175,
                                      width: _width,
                                      color: Color(0xFF256D85),
                                      // color: Colors.white,
                                      child: Image.asset(
                                          "assets/icon_whitout_pg.png",),
                                    ),
                                  ),
                                  Positioned(
                                    left: _width * 0.05,
                                    top: _height * 0.1,
                                    child: GestureDetector(
                                      onTap: () {
                                        _getFromGallery();
                                      },
                                      child:_authorProfileModel!.data![0].img== "" ? Container(
                                        child: Icon(Icons.person_pin,size:  _height*_width*0.00009,),
                                      ): Container(
                                        height: _height * 0.13,
                                        width: _width * 0.25,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              width: 4,
                                              color: Colors.white,
                                            ),
                                            color: Color(0xFF256D85),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    _authorProfileModel!.data![0].img.toString(),)
                                            )),
                                      ),
                                    ),
                                  ),
                                  Positioned(

                                    top: _height * 0.28,
                                    child: Container(
                                      width: _width,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            context.read<UserProvider>().UserName!,
                                            style: const TextStyle(
                                                color: Color(0xff313131),
                                                fontWeight: FontWeight.w800,
                                                fontFamily: "Poppins",
                                                fontStyle: FontStyle.normal,
                                                fontSize: 20.0),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(),
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => UploadDataScreen()));
                                            },
                                            child: Row(
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                        Languages.of(context)!.authorC,
                                                        style: const TextStyle(
                                                          fontFamily: 'Lato',
                                                          color: Color(0xff313131),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w700,
                                                          fontStyle: FontStyle.normal,
                                                        )
                                                    ),
                                                    Container(
                                                      color: Colors.black,
                                                      width: _width*0.23,
                                                      height: 1,
                                                    )
                                                  ],
                                                ),
                                                SizedBox(width: _width*0.03,),
                                                CircleAvatar(
                                                  radius: _height*_width*0.000065,
                                                  backgroundColor: Color(0xFF256D85),
                                                  child: Center(
                                                    child: IconButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => UploadDataScreen()));

                                                      },
                                                      icon: const Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: _height * 0.45,
                                    child: Container(
                                      height: _height * 0.3,
                                      width: _width,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          // Our Projects
                                          Column(
                                            children: [
                                              Text(
                                                  Languages.of(context)!
                                                      .subscriber,
                                                  style: const TextStyle(
                                                    fontFamily: 'Lato',
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                              SizedBox(
                                                height: _height * 0.03,
                                              ),
                                              Text(
                                                  _authorProfileModel!.data![0].subscribers!,
                                                  style: const TextStyle(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xff313131),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                  )
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(Languages.of(context)!.level,
                                                  style: const TextStyle(
                                                    fontFamily: 'Lato',
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                              SizedBox(
                                                height: _height * 0.03,
                                              ),
                                              Text(
                                                  _authorProfileModel!.data![0].level!,
                                                  style: const TextStyle(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xff313131),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                  )
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                               Text(Languages.of(context)!.publishedBooks,
                                                  style: const TextStyle(
                                                    fontFamily: 'Lato',
                                                    color: Colors.black54,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                  )),
                                              SizedBox(
                                                height: _height * 0.03,
                                              ),
                                              Text(
                                                  "0",
                                                  style: TextStyle(
                                                    fontFamily: 'Lato',
                                                    color: Color(0xff313131),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    fontStyle: FontStyle.normal,
                                                  )
                                              )
                                            ],
                                          )
                                        ],//hello
                                      ),
                                    ),
                                  ),
                                  // Positioned(
                                  //   left: _width * 0.05,
                                  //   right: _width * 0.05,
                                  //   top: _height * 0.5,
                                  //   child: Container(
                                  //     // width: _width,
                                  //     child: Text(
                                  //       "Authors, I am writter as well as publisher for publishing new and attractive books to society like other publishers "
                                  //       "I am new Author of this society work for the chaning of these society",
                                  //       style: TextStyle(
                                  //         fontFamily: 'Lato',
                                  //         color: Color(0xff313131),
                                  //         fontSize: 14,
                                  //         fontWeight: FontWeight.w700,
                                  //         fontStyle: FontStyle.normal,
                                  //       ),
                                  //       overflow: TextOverflow.ellipsis,
                                  //       maxLines: 7,
                                  //     ),
                                  //   ),
                                  // ),
                                  Positioned(
                                    top: _height * 0.58,
                                    left: context.read<UserProvider>().SelectedLanguage == "English" ? _width*0.8 : 0.0,
                                    right: context.read<UserProvider>().SelectedLanguage != "English" ? _width*0.8 : 0.0,
                                    child: Container(
                                      height: _height * 0.3,
                                      width: _width,
                                      child: GestureDetector(
                                        onTap: (){
                                          // if (_interstitialAd != null) {
                                          //   _interstitialAd?.show();
                                          // } else {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Uploadscreen()));
                                          // }
                                        },
                                        child: Text(
                                            Languages.of(context)!.seeAll,
                                            style: const TextStyle(
                                              fontFamily: 'Lato',
                                              color:  Colors.blue,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              fontStyle: FontStyle.normal,
                                            )
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: _height * 0.6,
                                    child: _isHistoryLoading
                                        ? Padding(
                                          padding:  EdgeInsets.only(left: _height*_width*0.0006,top: _height*_width*0.0004),
                                          child: const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                     AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(0xFF256D85),
                                                ),
                                              ),
                                            ),
                                        )
                                        : _emtyFlag
                                            ? Padding(
                                                 padding:  EdgeInsets.all(_height*_width*0.0004),
                                              child: Center(
                                                  child: Text(
                                                    Languages.of(context)!
                                                        .nouploadhistory,
                                                    style: const TextStyle(
                                                        fontFamily:
                                                            Constants.fontfamily,
                                                        color: Colors.black54),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                            )
                                            : SizedBox(
                                                height: _height * 0.3,
                                                width: _width,
                                                child: ListView.builder(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  itemCount:
                                                      _userUploadHistoryModel!
                                                          .data!.length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index1) {
                                                    return GestureDetector(
                                                      onTap: () {

                                                        // if (_interstitialAd != null) {
                                                        //   _interstitialAd?.show();
                                                        // } else {
                                                        //   Navigator.push(
                                                        //       context,
                                                        //       MaterialPageRoute(
                                                        //           builder: (context) => Uploadscreen()));
                                                        // }

                                                      },
                                                      child: Column(
                                                        children: [
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                width: _width *
                                                                    0.22,
                                                                height:
                                                                    _height *
                                                                        0.12,
                                                                margin: EdgeInsets
                                                                    .all(_width *
                                                                        0.05),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5.0),
                                                                  color: Colors
                                                                      .black,
                                                                  image: DecorationImage(
                                                                    fit: BoxFit.cover,
                                                                      image: _userUploadHistoryModel!.data![index1].bookImage ==
                                                                              ""
                                                                          ? const AssetImage(
                                                                              "assets/quotes_data/manga image.png")
                                                                          : NetworkImage(_userUploadHistoryModel!
                                                                              .data![index1]
                                                                              .bookImage
                                                                              .toString()) as ImageProvider),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                  top: _height *
                                                                      0.12,
                                                                  left: _width *
                                                                      0.07,
                                                                  child: Icon(
                                                                    Icons
                                                                        .remove_red_eye,
                                                                    color: Colors
                                                                        .white,
                                                                    size: _height *
                                                                        _width *
                                                                        0.00005,
                                                                  )),
                                                              Positioned(
                                                                  top: _height *
                                                                      0.122,
                                                                  left: _width *
                                                                      0.13,
                                                                  child:  Text(
                                                                    _userUploadHistoryModel!.data![index1].views.toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            10.0,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        fontFamily:
                                                                            "Lato",
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .normal,
                                                                        color: Colors
                                                                            .white),
                                                                  ))
                                                            ],
                                                          ),
                                                          Text(_userUploadHistoryModel!
                                                              .data![index1]
                                                              .bookTitle
                                                              .toString(),
                                                              style: const TextStyle(
                                                                fontFamily:
                                                                    'Lato',
                                                                color: Color(
                                                                    0xff313131),
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                              ),
                                                          overflow: TextOverflow.ellipsis,),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                )),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Visibility(
                                      visible:
                                          Provider.of<InternetConnectionStatus>(
                                                  context) ==
                                              InternetConnectionStatus
                                                  .disconnected,
                                      child: Constants.InternetNotConnected(
                                          _height * 0.03)),
                                  GestureDetector(
                                    onTap: () {
                                      _getFromGallery();
                                    },
                                    child: Container(
                                      width: _width,
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            height: _height * 0.4,
                                            child: const Center(
                                              child: Icon(
                                                Icons.person_pin,
                                                size: 190,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: _width * 0.58,
                                            top: _height * 0.22,
                                            child: const CircleAvatar(
                                              backgroundColor: Colors.black54,
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                color: Colors.white,
                                                size: 30.0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30)),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: _height * 0.1,
                                                left: _width * 0.02,
                                                right: _width * 0.02),
                                            child: Text(
                                              context
                                                  .read<UserProvider>()
                                                  .UserEmail!,
                                              style: TextStyle(
                                                fontFamily:
                                                    Constants.fontfamily,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: _height * 0.1),
                                            child: Visibility(
                                                visible: _isLoading,
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Color(0xFF256D85),
                                                  ),
                                                )),
                                          ),
                                          Center(
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  top: _height * 0.1),
                                              child:
                                                  ResuableMaterialButtonSmall(
                                                onpress: () {
                                                  showTermsAndConditionAlert();
                                                },
                                                buttonname:
                                                    Languages.of(context)!
                                                        .MyMangaUploads,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                    : Center(
                        child: Constants.InternetNotConnected(_height * 0.03),
                      ),),),);
  }

  Future<void> UploadProfileImageApi() async {
    setState(() {
      _isLoading = true;
    });
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "accesstoken": context.read<UserProvider>().UserToken.toString(),
    };

    var jsonResponse;

    var request = http.MultipartRequest(
        'POST', Uri.parse(ApiUtils.PROFILE_IMAGE_UPLOAD_API));
    request.files.add( http.MultipartFile.fromBytes(
      "image",
      File(imageFile!.path)
          .readAsBytesSync(), //UserFile is my JSON key,use your own and "image" is the pic im getting from my gallary
      filename: "Image.jpg",
      contentType: MediaType('image', 'jpg'),
    ));

    request.headers.addAll(headers);

    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        if (response.statusCode == 200) {
          print("Image Uploaded! ");
          print('profile_image_upload ' + response.body);
          Constants.showToastBlack(context, "Image Upload Successfully");
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
  }

  Future _profileStatusAPI() async {
    setState(() {
      _isLoading = true;
      _isInternetConnected = true;
    });

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "accesstoken": context.read<UserProvider>().UserToken.toString(),
    };

    final response = await http.get(Uri.parse(ApiUtils.PROFILE_STATUS_API),
        headers: headers);

    if (response.statusCode == 200) {
      print('profile_status_response under 200 ${response.body}');
      var jsonData = json.decode(response.body);
      _profileStatusModel = ProfileStatusModel.fromJson(jsonData);
      print(_profileStatusModel!.message.toString());
      if (_profileStatusModel!.data!.userType == "3") {

        _authorProfileAPI();
        _callUploadHistoryAPI();
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      Constants.showToastBlack(context, "Some things went wrong");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _updateProfileStatusAPI() async {
    setState(() {
      _isLoading = true;
      _isInternetConnected = true;
    });

    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "accesstoken": context.read<UserProvider>().UserToken.toString(),
    };

    final response = await http
        .get(Uri.parse(ApiUtils.UPDATE_PROFILE_STATUS_API), headers: headers);

    if (response.statusCode == 200) {
      print('update_profile_response under 200 ${response.body}');
      var jsonData = json.decode(response.body);
      _checkInternetConnection();
    } else {
      Constants.showToastBlack(context, "Some things went wrong");
      setState(() {
        _isLoading = false;
      });
    }
  }

  _getFromGallery() async {
    final PickedFile? image =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (image != null) {
      imageFile = File(image.path);
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      final fileName = path.basename(imageFile!.path);
      final File localImage = await imageFile!.copy('$appDocPath/$fileName');

      // prefs!.setString("image", localImage.path);

      setState(() {
        imageFile = File(image.path);
        UploadProfileImageApi();
      });
    }
  }

  showTermsAndConditionAlert() {
    bool agree = false;
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    showDialog(
        barrierDismissible: true,
        barrierColor: Colors.black54,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Stack(
              children: [
                AlertDialog(
                  backgroundColor: Color(0xFFe4e6fb),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        20.0,
                      ),
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(
                    top: 10.0,
                  ),
                  title: Text(
                    Languages.of(context)!.terms,
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                  content: Container(
                    height: 400,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Languages.of(context)!.longTextTerms,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Material(
                            color: Color(0xFFe4e6fb),
                            child: Checkbox(
                              value: agree,
                              onChanged: (value) {
                                setState(() {
                                  agree = value ?? false;
                                });
                              },
                            ),
                          ),
                          Text(
                            Languages.of(context)!.termsText_1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 10.0),
                          ),
                          SizedBox(
                            height: _height * 0.05,
                          ),
                          Container(
                            width: double.infinity,
                            height: 60,
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: agree ? _doSomething : null,
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF256D85),
                                // fixedSize: Size(250, 50),
                              ),
                              child: Text(
                                Languages.of(context)!.agree,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: _height * 0.05,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                    top: _height * 0.15,
                    left: _width * 0.87,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: _height * 0.08,
                        width: _width * 0.08,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage(
                                    "assets/quotes_data/cancel_icon.png"))),
                      ),
                    ))
              ],
            );
          });
        });
  }

  void _doSomething() {
    setState(() {
      _updateProfileStatusAPI();
      Navigator.pop(context);
    });
  }

  Future _callUploadHistoryAPI() async {
    setState(() {
      _isHistoryLoading = true;
      _isInternetConnected = true;
    });
    var map = new Map<String, String>();
    map['accesstoken'] = context.read<UserProvider>().UserToken.toString();
    final response =
        await http.get(Uri.parse(ApiUtils.UPLOAD_HISTORY_API), headers: map);

    if (response.statusCode == 200) {
      print('upload_history_response under 200 ${response.body}');
      var jsonData = response.body;
      //var jsonData = response.body;
      var jsonData1 = json.decode(response.body);
      if (jsonData1['status'] == 200) {
        _userUploadHistoryModel = userUploadHistoryModelFromJson(jsonData);
        setState(() {
          _isHistoryLoading = false;
        });
      } else {
        ToastConstant.showToast(context, jsonData1['message'].toString());
        setState(() {
          _isHistoryLoading = false;
          _emtyFlag = true;
        });
      }
    }
  }

  Future _authorProfileAPI() async {
    setState(() {
      _isAuthorLoading = true;
    });
    var map = new Map<String, String>();
    map['accesstoken'] = context.read<UserProvider>().UserToken.toString();
    final response =
    await http.get(Uri.parse(ApiUtils.AUTHOR_PROFILE_API), headers: map);

    if (response.statusCode == 200) {
      print('author_profile_response under 200 ${response.body}');
      var jsonData = response.body;
      //var jsonData = response.body;
      var jsonData1 = json.decode(response.body);
      if (jsonData1['status'] == 200) {
        _authorProfileModel = authorProfileModelFromJson(jsonData);
        setState(() {
          _isAuthorLoading = false;
        });
      } else {
        ToastConstant.showToast(context, jsonData1['message'].toString());
        setState(() {
          _isAuthorLoading = false;
        });
      }
    }
  }
}
