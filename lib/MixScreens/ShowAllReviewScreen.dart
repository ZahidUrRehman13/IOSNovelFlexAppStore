import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Models/BookReviewModel.dart';
import '../Provider/UserProvider.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../Utils/toast.dart';
import '../localization/Language/languages.dart';



class ShowAllReviewScreen extends StatefulWidget {
  String? bookId;
  ShowAllReviewScreen({required this.bookId});

  @override
  State<ShowAllReviewScreen> createState() => _ShowAllReviewScreenState();
}

class _ShowAllReviewScreenState extends State<ShowAllReviewScreen> {
  bool _isLoading = false;

  bool _isInternetConnected = true;
  bool _emtyFlag = false;
  BookReviewModel? _bookReviewModel;
  var token;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    token = context.read<UserProvider>().UserToken.toString();
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
      _callReviewAPI();
    }
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: _height * 0.07,
          backgroundColor: const Color(0xFF256D85),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 35,
              color: Colors.white,
            ),
          ),
          actions: [
            SizedBox(
              width: _width * 0.14,
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: _height * 0.02,
                  ),
                  Text(
                    Languages.of(context)!.seeAllreview2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      fontFamily: Constants.fontfamily,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              child: IconButton(
                onPressed: () {
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>GiveReviewScreen()));
                  showDialog(
                    context: context,
                    barrierDismissible:
                        true, // set to false if you want to force a rating
                    builder: (context) => Dialogue(context),
                  );
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 5.0,
            )
          ],
        ),
        body: _isInternetConnected == false
            ? SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "INTERNET NOT CONNECTED",
                        style: TextStyle(
                          fontFamily: Constants.fontfamily,
                          color: Color(0xFF256D85),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(
                        height: _height * 0.019,
                      ),
                      InkWell(
                        child: Container(
                          width: _width * 0.40,
                          height: _height * 0.058,
                          decoration: BoxDecoration(
                            color: const Color(0xFF256D85),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                40.0,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    const Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "No Internet Connected",
                              style: TextStyle(
                                fontFamily: Constants.fontfamily,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          _checkInternetConnection();
                        },
                      ),
                    ],
                  ),
                ),
              )
            : _isLoading
                ? const Align(
                    alignment: Alignment.center,
                    child: const Center(
                      child: CupertinoActivityIndicator(
                        color: const Color(0xFF256D85),
                        radius: 20,
                      ),
                    )
                  )
                : _emtyFlag
                    ? Column(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(),
                        SizedBox(),
                        Center(
                            child: Text(
                              Languages.of(context)!.noReview,
                              style: const TextStyle(
                                  fontFamily: Constants.fontfamily,
                                  color: Colors.black54),
                            ),
                          ),
                        SizedBox(),
                        // _bannerAd != null
                        //     ? Align(
                        //   alignment: Alignment.topCenter,
                        //   child: Container(
                        //     width: _bannerAd!.size.width.toDouble(),
                        //     height: _bannerAd!.size.height.toDouble(),
                        //     child: AdWidget(ad: _bannerAd!),
                        //   ),
                        // )
                        //     : Container(),
                      ],
                    )
                    : ListView.builder(
                        itemCount: _bookReviewModel!.data!.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (BuildContext context, index) {
                          return GFListTile(
                              color: Colors.black12,
                              avatar: GFAvatar(
                                backgroundColor: Colors.white12,
                                backgroundImage:
                                    _bookReviewModel!.data![index].userImage !=
                                            null
                                        ? NetworkImage(_bookReviewModel!
                                            .data![index].userImage
                                            .toString())
                                        : const AssetImage(
                                            'assets/profile_pic.png',
                                          ) as ImageProvider,
                              ),
                              title: Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  _bookReviewModel!.data![index].username!
                                      .split(' ').first,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: Constants.fontfamily,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0),
                                ),
                              ),
                              subTitleText: _bookReviewModel!
                                  .data![index].comments
                                  .toString(),
                              icon: Column(
                                children: [
                                  const Icon(
                                    Icons.star_rate,
                                    color: Colors.amberAccent,
                                  ),
                                  Text(
                                    _bookReviewModel!.data![index].rating
                                        .toString(),
                                    style: const TextStyle(
                                      fontFamily: Constants.fontfamily,
                                    ),
                                  ),
                                ],
                              )
                              // ListView.builder(
                              //   shrinkWrap: true,
                              //   scrollDirection: Axis.horizontal,
                              //   physics: NeverScrollableScrollPhysics(),
                              //   itemCount: 1,
                              //   itemBuilder: (BuildContext context,index){
                              //     return Icon(Icons.star_rate,color: Colors.red,);
                              //   },
                              //
                              // ),
                              );
                        }));
  }

  Future _callReviewAPI() async {
    setState(() {
      _isLoading = true;
      _isInternetConnected = true;
    });

    final response = await http.get(
      Uri.parse(ApiUtils.SEE_ALL_REVIEWS_API + widget.bookId.toString()),
    );

    if (response.statusCode == 200) {
      print('book_review_response under 200 ${response.body}');
      var jsonData = json.decode(response.body);
      var jsonData1 = response.body;
      if (jsonData['status'] == 200) {
        _bookReviewModel = bookReviewModelFromJson(jsonData1);
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _emtyFlag = true;
        });
      }
    }
  }

  Widget Dialogue(var context){
    return  RatingDialog(
      // starColor: Color(0xFF256D85),
      initialRating: 1.0,
      // your app's name?
      title: const Text(
        'Rate Us',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          fontFamily: Constants.fontfamily,
        ),
      ),
      // encourage your user to leave a high rating?
      message: const Text(
        'Tap a star to set your rating. Add more description here if you want.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15,fontFamily: Constants.fontfamily,),
      ),
      // your app's logo?
      image:  Image.asset('assets/icon_whitout_pg.png'),
      submitButtonText: 'Submit',
      commentHint: ' Comment ',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        _addCommentAPI(response.rating,response.comment,context);
        print('rating: ${response.rating}, comment: ${response.comment}');

        // TODO: add your own logic
        if (response.rating < 3.0) {
          // send their comments to your email or anywhere you wish
          // ask the user to contact you instead of leaving a bad review
        } else {
          // _rateAndReviewApp();
        }
      },
    );
  }

  Future _addCommentAPI(double rating,String comments,var context) async {

    Map<String, String> headers = {
      // 'Content-type': 'application/json',
      // 'Accept': 'application/json',
      "accesstoken": token,
    };

    var map =  Map<String, dynamic>();
    map['bookId'] =  widget.bookId.toString();
    map['rating'] = rating.toString();
    map['comments'] = comments.toString().trim();
    final response = await http.post(
      Uri.parse(
          ApiUtils.ADD_REVIEW_API),
      headers: headers,
      body: map,
    );

    if (response.statusCode == 200) {
      print('review_response under 200 ${response.body}');
      var jsonData = json.decode(response.body);
      if(jsonData['status'] == 200)
      {
        Constants.showToastBlack(context, "Thanks! for Review");
       setState(() {
          _emtyFlag=false;
          _callReviewAPI();
       });
      }else{
        ToastConstant.showToast(context,jsonData['message'].toString());
      }

    } else {
      print("error_occur");

    }
  }
}

