import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/SeeAllModel.dar.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import 'BookDetailScreen.dart';

class SeeAllBookScreen extends StatefulWidget {
  String? categoriesId;
  SeeAllBookScreen({required this.categoriesId});

  @override
  State<SeeAllBookScreen> createState() => _SeeAllBookScreenState();
}

class _SeeAllBookScreenState extends State<SeeAllBookScreen> {
  SeeAllModel? _seeAllModel;
  bool _isLoading = false;
  bool _isInternetConnected = true;

  @override
  void initState() {
    super.initState();
    print("seeAllCategories_id= ${widget.categoriesId}");
    _checkInternetConnection();
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
      _callSeeAllBooksAPI();
    }
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
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
              ? const Center(
        child: CupertinoActivityIndicator(
          color: Colors.white12,
          radius: 20,
        ),
      )
              : Padding(
                  padding: EdgeInsets.only(top: _height * 0.02),
                  child: GridView.builder(
                      itemCount: _seeAllModel!.data!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookDetailScreen(
                                      BookID:
                                      '${_seeAllModel!.data![index].id}',
                                    )));
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                            child: Card(
                              color: Colors.white,
                              elevation: 2,
                                // shape: RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.circular(15),
                                //   //set border radius more than 50% of height and width to make circle
                                // ),
                              child: Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 10.0,bottom: 10.0),
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                          color: Colors.white),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(0.0),
                                        child: Image.network(_seeAllModel!
                                            .data![index].bookImage!
                                            .toString()),
                                      ),
                                    ),
                                    // Positioned(
                                    //   top: _height * 0.17,
                                    //   left: _width * 0.04,
                                    //   child: Text(
                                    //     _seeAllModel!.data![index].bookTitle!
                                    //         .toString(),
                                    //     style: TextStyle(
                                    //       color: Colors.white,
                                    //       fontSize: 15,
                                    //       fontWeight: FontWeight.w500,
                                    //       fontFamily: Constants.fontfamily,
                                    //     ),
                                    //     overflow: TextOverflow.ellipsis,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                  // GridView.count(
                  //   crossAxisCount: 2,
                  //   crossAxisSpacing: 0.0,
                  //   mainAxisSpacing: 5.0,
                  //   shrinkWrap: true,
                  //   children: List.generate(
                  //     _seeAllModel!.data!.length,
                  //     growable: true,
                  //     (index) {
                  //       return GestureDetector(
                  //         onTap: () {
                  //           Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) => BookDetailScreen(
                  //                         BookID:
                  //                             '${_seeAllModel!.data![index].id}',
                  //                       )));
                  //         },
                  //         child: Padding(
                  //           padding: const EdgeInsets.all(10.0),
                  //           child: Stack(
                  //             children: [
                  //               AspectRatio(
                  //                 aspectRatio: 16 / 18,
                  //                 child: Container(
                  //                   // child: Center(child: Text(_seeAllModel!.data![index].bookTitle!.toString())),
                  //                   decoration: BoxDecoration(
                  //                       image: DecorationImage(
                  //                         image: NetworkImage(_seeAllModel!
                  //                             .data![index].bookImage!
                  //                             .toString()),
                  //                         fit: BoxFit.cover,
                  //                       ),
                  //                       borderRadius: BorderRadius.all(
                  //                         Radius.circular(5.0),
                  //                       ),
                  //                       color: Colors.white),
                  //                 ),
                  //               ),
                  //               Positioned(
                  //                 top: _height * 0.17,
                  //                 left: _width * 0.04,
                  //                 child: Text(
                  //                   _seeAllModel!.data![index].bookTitle!
                  //                       .toString(),
                  //                   style: TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 15,
                  //                     fontWeight: FontWeight.w500,
                  //                     fontFamily: Constants.fontfamily,
                  //                   ),
                  //                   overflow: TextOverflow.ellipsis,
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // ),
                ),
    );
  }

  Future _callSeeAllBooksAPI() async {
    setState(() {
      _isLoading = true;
      _isInternetConnected = true;
    });
    // Map<String, String> headers = {
    //   'Content-Type': 'application/json;charset=UTF-8',
    //   'Charset': 'utf-8'
    // };

    final response = await http.get(
      Uri.parse("${ApiUtils.SEE_ALL_BOOKS_API}${widget.categoriesId}"),
    );

    if (response.statusCode == 200) {
      print('See all books under 200 ${response.body}');
      var jsonData = json.decode(response.body);
      //var jsonData = response.body;
      _seeAllModel = SeeAllModel.fromJson(jsonData);
      print('see all api respo  ${_seeAllModel!.data![0].bookTitle}');
      setState(() {
        _isLoading = false;
      });
    }
  }
}
