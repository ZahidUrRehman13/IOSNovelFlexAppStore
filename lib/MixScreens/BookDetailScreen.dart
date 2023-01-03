import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:novelflex/MixScreens/pdfViewerScreen.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/AddReviewModel.dart';
import '../Models/BookDetailsModel.dart';
import '../Provider/UserProvider.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../Utils/toast.dart';
import '../localization/Language/languages.dart';
import 'ShowAllReviewScreen.dart';

class BookDetailScreen extends StatefulWidget {
  String? BookID;

  BookDetailScreen({required this.BookID});
  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isLoading = false;
  bool _isInternetConnected = true;
  AddReviewModel? _addReviewModel;
  BookDetailsModel? _bookDetailsModel;
  var token;
  bool subscribe = false;

  @override
  void initState() {
    super.initState();
    token = context.read<UserProvider>().UserToken.toString();
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
      _callBookDetailsAPI();
    }
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: _height * 0.07,
          elevation: 0.0,
          backgroundColor: Color(0xFF256D85),
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
              width: _width * 0.0,
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: _height * 0.02,
                  ),
                  Text(
                    Languages.of(context)!.YourManga,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  )
                ],
              ),
            ),
            SizedBox(
              child: IconButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => GiveReviewScreen()));
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
          ],
        ),
        backgroundColor: Colors.white,
        body: _isInternetConnected == false
            ? Center(
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
                        Offset(0, 3), // changes position of shadow
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
            : Container(
          height: _height*0.9,
          decoration: BoxDecoration(
            color:  Colors.white,
            image: DecorationImage(
              alignment: Alignment.topCenter,
              image: NetworkImage(
                _bookDetailsModel!.data!.bookImage!,

              ),
              // fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            physics: ClampingScrollPhysics(),
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: _height * 0.3,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ShowAllReviewScreen(
                                          bookId: _bookDetailsModel!
                                              .data!.id
                                              .toString(),
                                        )));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding:  EdgeInsets.only(left: _width*0.13,right: 12,),
                                child: GestureDetector(
                                  onTap: (){
                                    _callSubscribeAPI();
                                    setState(() {
                                      subscribe=true;
                                    });
                                  },
                                  child: Container(
                                    width: _width*0.25,
                                    height: _height*0.04,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: const Color(0xFF256D85),
                                    ),
                                    child: Center(
                                      child: subscribe ? Icon(Icons.notification_add_outlined,color: Colors.white,): Text(
                                          Languages.of(context)!
                                              .follow,
                                          style: const TextStyle(
                                            fontFamily: 'Lato',
                                            fontSize: 13,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontStyle: FontStyle.normal,

                                          )
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.end,
                                children: [

                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      Languages.of(context)!
                                          .seeAllReviews,
                                      style: const TextStyle(
                                        color: Color(0xFF256D85),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily:
                                        Constants.fontfamily,
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: _height * 0.1,
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: _width * 0.02,
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(0),
                              child: Container(
                                color: Colors.white,
                                child:Container(
                                  height: _height*0.13,
                                  width: _width*0.25,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(width: 4,color: Color(0xFF256D85),),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: _bookDetailsModel!
                                            .data!.author!.img ==
                                            null
                                            ? const AssetImage(
                                            "assets/quotes_data/profile_image.png")
                                            : NetworkImage(
                                          _bookDetailsModel!
                                              .data!.author!.img!
                                              .toString(),
                                        ) as ImageProvider,
                                      )
                                  ),
                                ),

                                // height: _height * 0.18,
                                // width: _width * 0.3,
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  _bookDetailsModel!.data!.bookTitle!,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(
                                  height: _height * 0.07,
                                ),
                                Text(
                                  _bookDetailsModel!
                                      .data!.author!.name!
                                      .split(' ')
                                      .first,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.fontfamily,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: _width * 0.02,
                            ),
                            SizedBox(
                              width: _width * 0.01,
                            ),
                          ],
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 20,
                                left: 10,
                                right: 10),
                            child: Text(
                              _bookDetailsModel!.data!.description!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                fontFamily: Constants.fontfamily,
                              ),
                              textAlign: TextAlign.center,
                              // textAlign: TextAlign.center,
                              // overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        //  _bannerAd != null
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
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: _bookDetailsModel!.data!.chapters!.length,
                        itemBuilder: (BuildContext context, index) {
                          return GestureDetector(
                            onTap: () {

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfScreen(
                                          url: _bookDetailsModel!
                                              .data!.chapters![index].url,
                                          name: _bookDetailsModel!
                                              .data!.bookTitle,
                                        )));

                              // PdfScreen()));
                            },
                            child: Container(
                              decoration: const ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 0.5, style: BorderStyle.solid),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5.0)),
                                  ),
                                  color: Color(0xFF256D85)),
                              width: _width * 0.9,
                              height: _height * 0.08,
                              margin: EdgeInsets.only(
                                  left: _width * 0.02,
                                  right: _width * 0.02,
                                  top: _height * 0.05),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  // SizedBox(
                                  //   width: _width * 0.04,
                                  //   height: _height * 0.07,
                                  // ),
                                  _bookDetailsModel!.data!.chapters!.length ==
                                      0
                                      ? const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 8.0),
                                      child: Text('No PDF Found',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily:
                                            Constants.fontfamily,
                                          )),
                                    ),
                                  )
                                      : Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Text(
                                        _bookDetailsModel!.data!
                                            .chapters!.length ==
                                            1
                                            ? '${_bookDetailsModel!.data!.bookTitle}'
                                            : '${_bookDetailsModel!.data!.bookTitle}:   Chapter  (${index + 1})',
                                        // '${_bookDetailsModel!.data!.chapters![index].name!.replaceAll(".pdf", "")}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily:
                                          Constants.fontfamily,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  // SizedBox(
                                  //   width: _width * 0.35,
                                  // ),
                                  IconButton(
                                      onPressed: () async {
                                        // _pdf = await PDFDocument.fromURL(_bookDetailsModel!.data!.chapters![index].url.toString());
                                        // Navigator.push(context, MaterialPageRoute(builder: (context)=>PdfViewScreen()));
                                        // setState(() {
                                        //   _isLoadingPdf = false;
                                        // });
                                      },
                                      icon: const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  Container(
                    height: _height*0.1,
                    color: Colors.white,
                  ),
                ],
              )
            ],
          ),
        ));
  }

  Widget Dialogue(var context) {
    return RatingDialog(
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
        style: TextStyle(
          fontSize: 15,
          fontFamily: Constants.fontfamily,
        ),
      ),
      // your app's logo?
      image: Image.asset('assets/icon_whitout_pg.png'),
      submitButtonText: 'Submit',
      commentHint: ' Comment ',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        _addCommentAPI(response.rating, response.comment, context);
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

  // show the dialog

  Future _callBookDetailsAPI() async {
    setState(() {
      _isLoading = true;
      _isInternetConnected = true;
    });

    final response = await http.get(
      Uri.parse(ApiUtils.BOOK_DETAIL_API + widget.BookID.toString()),
    );

    if (response.statusCode == 200) {
      print('BookDetail_response under 200 ${response.body}');
      var jsonData = json.decode(response.body);
      //var jsonData = response.body;
      _bookDetailsModel = BookDetailsModel.fromJson(jsonData);
      print(_bookDetailsModel!.message.toString());
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

  Future _callSubscribeAPI() async {
    UserProvider userProvider =
    Provider.of<UserProvider>(context, listen: false);

    print("user_id: ${userProvider.UserID}");

    var map = new Map<String, dynamic>();
    map['reader_id'] = userProvider.UserID;
    map['writer_id'] = _bookDetailsModel!.data!.author!.id;

    final response = await http.post(
      Uri.parse(ApiUtils.SUBSCRIBE_API),
      body: map,
    );

    var jsonData;

    switch (response.statusCode) {
      case 200:
      //Success

        var jsonData = json.decode(response.body);
        print('subscribe_data: $jsonData');
        if (jsonData['status'] == 200) {

          ToastConstant.showToast(context,jsonData['message']);
        } else {
          ToastConstant.showToast(context,jsonData['message']);
        }
    }
  }

  Future _addCommentAPI(double rating, String comments, var context) async {
    Map<String, String> headers = {
      // 'Content-type': 'application/json',
      // 'Accept': 'application/json',
      "accesstoken": token,
    };

    var map = new Map<String, dynamic>();
    map['bookId'] = _bookDetailsModel!.data!.id.toString();
    map['rating'] = rating.toString();
    map['comments'] = comments.toString().trim();
    final response = await http.post(
      Uri.parse(ApiUtils.ADD_REVIEW_API),
      headers: headers,
      body: map,
    );

    if (response.statusCode == 200) {
      print('review_response under 200 ${response.body}');
      var jsonData = json.decode(response.body);
      if (jsonData['status'] == 200) {
        Constants.showToastBlack(context, "Thanks! for Review");
      } else {
        ToastConstant.showToast(context, jsonData['message'].toString());
      }
    } else {
      print("error_occur");
    }
  }
}




