import 'dart:convert';
import 'dart:io';

import 'package:app_version_update/app_version_update.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:new_version_plus/new_version_plus.dart';
// import 'package:parallax_animation/parallax_area.dart';
// import 'package:parallax_animation/parallax_widget.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import '../Drawer/drawer_screen.dart';
import '../MixScreens/BookDetailScreen.dart';
import '../MixScreens/SeeAllBooksScreen.dart';
import '../MixScreens/notification_screen.dart';
import '../Models/DashBoardModelMain.dart';
import '../Provider/UserProvider.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../localization/Language/languages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final globalKey = GlobalKey<ScaffoldState>();

  // AppUpdateInfo? _updateInfo;
  //
  // // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> checkForUpdate() async {
  //   InAppUpdate.checkForUpdate().then((info) {
  //     setState(() {
  //       _updateInfo = info;
  //     });
  //   }).catchError((e) {
  //     showSnack(e.toString());
  //   });
  // }

  // void showSnack(String text) {
  //   if (globalKey.currentContext != null) {
  //     ScaffoldMessenger.of(globalKey.currentContext!)
  //         .showSnackBar(SnackBar(content: Text(text)));
  //   }
  // }



  //check version
  // String? version = '';
  // String? storeVersion = '';
  // String? storeUrl = '';
  // String? packageName = '';


  DashBoardModelMain? _dashBoardModelMain;
  bool _isLoading = false;
  DioCacheManager? _dioCacheManager;
  late final translator;

  // final versionCheck = VersionCheck(
  //   packageName: Platform.isIOS
  //       ? 'com.tachyonfactory.iconFinder'
  //       : 'com.eshtisharati.flutter_novel_flex',
  //   packageVersion: '1.0.1',
  //   showUpdateDialog: customShowUpdateDialog,
  //   country: 'kr',
  // );
  //
  // Future checkVersion() async {
  //   await versionCheck.checkVersion(context);
  //   setState(() {
  //     version = versionCheck.packageVersion;
  //     packageName = versionCheck.packageName;
  //     storeVersion = versionCheck.storeVersion;
  //     storeUrl = versionCheck.storeUrl;
  //   });
  // }

  final appleId = '1234567890';
  final playStoreId = 'com.appcom.estisharati.novel.flex';
  final country = 'us';


  checkUpdate()async{
    await AppVersionUpdate.checkForUpdates(
        // appleId: appleId,
        playStoreId: playStoreId, country: country)
        .then((data) async {
      print(data.storeUrl);
      print(data.storeVersion);
      if(data.canUpdate!){
        //showDialog(... your custom widgets view)
        //or use our widgets
        // AppVersionUpdate.showAlertUpdate
        // AppVersionUpdate.showBottomSheetUpdate
        // AppVersionUpdate.showPageUpdate
        AppVersionUpdate.showAlertUpdate(
            appVersionResult: data, context: context,
          content: 'Would you like to update your application?',
          cancelButtonStyle: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Colors.redAccent)),


        );
      }


    });
  }


  @override
  void initState() {
    super.initState();
    // checkUpdate();
    // checkVersion();
    // _checkVersionnew();
    // checkForUpdate();
    // _updateInfo?.updateAvailability == UpdateAvailability.updateAvailable
    //     ? InAppUpdate.performImmediateUpdate()
    //     .catchError((e) => showSnack(e.toString()))
    //     : null;


    translator = GoogleTranslator();
    _callDashboardDioAPI();
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      key: globalKey,
      appBar: AppBar(
        elevation: 0.2,
        toolbarHeight: _height * 0.07,
        backgroundColor: const Color(0xFF256D85),
        leading: IconButton(
          onPressed: () {
            globalKey.currentState!.openDrawer();
          },
          icon: SizedBox(
              height: _height * 0.07,
              width: _width * 0.07,
              child: Image.asset(
                "assets/hamburger_img.png",
              )),
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
              ],
            ),
          ),
         Platform.isIOS ? Container(): SizedBox(
            child: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen()));
                // MaterialPageRoute(
                //     builder: (context) => AnotherHomeScreen()));
              },
              icon: const Icon(
                Icons.notifications,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            width: 5.0,
          )
        ],
      ),
      body: _isLoading
          ? const Align(
              alignment: Alignment.center,
              child: const Center(
                child: CupertinoActivityIndicator(
                  color: const Color(0xFF256D85),
                  radius: 20,
                ),
              )
            )
          : Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                  visible: Provider.of<InternetConnectionStatus>(context) ==
                      InternetConnectionStatus.disconnected,
                  child: Constants.InternetNotConnected(_height * 0.03)),
              Expanded(
                child: Scaffold(
                  body: RefreshIndicator(
                    onRefresh: () async {
                      _callDashboardDioAPI();
                    },
                    child: ListView.builder(
                      shrinkWrap: true, // outer ListView
                      // reverse: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _dashBoardModelMain!.data!.length,
                      itemBuilder: (_, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // FutureBuilder<String>(
                                  //     future: _ChangeLanguage(),
                                  //     builder: (context,
                                  //         AsyncSnapshot<String> snapshot) {
                                  //       if (snapshot.hasData) {
                                  //         return Text(snapshot.data.toString());
                                  //       } else {
                                  //         return CircularProgressIndicator();
                                  //       }
                                  //     }),
                                  Text(
                                    context
                                                    .read<UserProvider>()
                                                    .SelectedLanguage ==
                                                "English" ||
                                            context
                                                    .read<UserProvider>()
                                                    .SelectedLanguage ==
                                                null
                                        ? _dashBoardModelMain!
                                            .data![index].categoryTitle!
                                        : _dashBoardModelMain!
                                            .data![index].titleAr!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.fontfamily,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SeeAllBookScreen(
                                                    categoriesId:
                                                        '${_dashBoardModelMain!.data![index].categoryId}',
                                                  )));
                                    },
                                    child: Text(
                                      Languages.of(context)!.seeAll,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                        fontFamily: Constants.fontfamily,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: _height*0.28,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: _dashBoardModelMain!
                                    .data![index].books!.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index1) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BookDetailScreen(
                                                    BookID:
                                                    _dashBoardModelMain!.data![index].books![index1].id!,
                                                  )));
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: _width*0.45,
                                          margin: const EdgeInsets.all(3.0),

                                          child: CachedNetworkImage(
                                            filterQuality: FilterQuality.high,
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.circular(10),
                                                image: DecorationImage(
                                                    image: imageProvider, fit: BoxFit.cover),
                                              ),
                                            ),
                                            imageUrl:
                                            _dashBoardModelMain!
                                                .data![index]
                                                .books![index1]
                                                .bookImage!,
                                            fit: BoxFit.contain,
                                            placeholder: (context,
                                                url) =>
                                                const Center(
                                                    child:
                                                    CupertinoActivityIndicator(
                                                      color: Color(0xFF256D85),
                                                    )),
                                            errorWidget:
                                                (context, url, error) =>
                                                const Center(child: Icon(Icons.error_outline)),
                                          ),
                                        ),
                                        Positioned(
                                            top: _height * 0.22,
                                            left: _width * 0.08,
                                            right: _width * 0.06,
                                            child: Text(
                                              _dashBoardModelMain!
                                                  .data![index]
                                                  .books![index1]
                                                  .bookTitle!,
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight:
                                                FontWeight.bold,
                                                fontFamily:
                                                Constants.fontfamily,
                                              ),
                                            ))
                                      ],
                                    ),
                                  );
                                },
                              )



                              // CarouselSlider.builder(
                              //     itemCount: _dashBoardModelMain!
                              //         .data![index].books!.length,
                              //     options: CarouselOptions(
                              //         aspectRatio: 1.5,
                              //         // disableCenter: true,
                              //         scrollPhysics:
                              //             BouncingScrollPhysics(),
                              //         viewportFraction: 0.58,
                              //         scrollDirection: Axis.horizontal,
                              //         // viewportFraction: 0.43,
                              //         // aspectRatio: 1.8,
                              //         // reverse: true,
                              //         // autoPlay: true,
                              //         enableInfiniteScroll: false),
                              //     itemBuilder:
                              //         (context, index1, realIndex) {
                              //       return GestureDetector(
                              //         onTap: () {
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       BookDetailScreen(
                              //                         BookID:
                              //                             '${_dashBoardModelMain!.data![index].books![index1].id!}',
                              //                       )));
                              //         },
                              //         child: Stack(
                              //           children: [
                              //             Container(
                              //               height: _height * 0.4,
                              //               width: _width * 0.5,
                              //               child: ClipRRect(
                              //                 borderRadius:
                              //                     BorderRadius.circular(
                              //                         1.0),
                              //                 child: CachedNetworkImage(
                              //                   imageUrl:
                              //                       _dashBoardModelMain!
                              //                           .data![index]
                              //                           .books![index1]
                              //                           .bookImage!,
                              //                   fit: BoxFit.cover,
                              //                   placeholder: (context,
                              //                           url) =>
                              //                       Center(
                              //                           child:
                              //                               CupertinoActivityIndicator(
                              //                     color: Color(0xFF256D85),
                              //                   )),
                              //                   errorWidget:
                              //                       (context, url, error) =>
                              //                           Icon(Icons.error),
                              //                 ),
                              //               ),
                              //             ),
                              //             Positioned(
                              //                 top: _height * 0.29,
                              //                 left: _width * 0.035,
                              //                 right: _width * 0.05,
                              //                 child: Text(
                              //                   _dashBoardModelMain!
                              //                       .data![index]
                              //                       .books![index1]
                              //                       .bookTitle!,
                              //                   overflow:
                              //                       TextOverflow.ellipsis,
                              //                   style: TextStyle(
                              //                     color: Colors.white,
                              //                     fontSize: 15,
                              //                     fontWeight:
                              //                         FontWeight.bold,
                              //                     fontFamily:
                              //                         Constants.fontfamily,
                              //                   ),
                              //                 ))
                              //           ],
                              //         ),
                              //       );
                              //     }),
                            )
                            // CarouselSlider(
                            //   options: CarouselOptions(height: 400.0),
                            //   items:  _dashBoardModelMain!
                            //       .data![index].books!.map((i) {
                            //     return Builder(
                            //       builder: (BuildContext context) {
                            //         return Container(
                            //             width: MediaQuery.of(context).size.width,
                            //             margin: EdgeInsets.symmetric(horizontal: 5.0),
                            //             decoration: BoxDecoration(
                            //                 color: Colors.amber
                            //             ),
                            //             child: Container(
                            //               decoration: BoxDecoration(
                            //                 image: DecorationImage(
                            //                   image: NetworkImage( _dashBoardModelMain!
                            //                       .data![index].books!.bookImage.toString())
                            //                 )
                            //               ),
                            //             )
                            //         );
                            //       },
                            //     );
                            //   }).toList(),
                            // )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
      drawer: DrawerCode(),
    );
  }

  Future _callDashboardDioAPI() async {
    setState(() {
      _isLoading = true;
    });
    _dioCacheManager = DioCacheManager(CacheConfig());

    Options _cacheOptions =
        buildCacheOptions(const Duration(days: 7), forceRefresh: true);
    Dio _dio = Dio();
    _dio.interceptors.add(_dioCacheManager!.interceptor);
    Response response =
        await _dio.get(ApiUtils.HOME_SCREEN_API, options: _cacheOptions);
    if (response.statusCode == 200) {
      print('dashboard_screen_response ${response.data}');
      var jsonData = response.data;
      _dashBoardModelMain = DashBoardModelMain.fromJson(jsonData);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkVersionnew()async{
    final newVersion=NewVersionPlus(
      androidId: "com.eshtisharati.flutter_novel_flex",
    );
    final status=await newVersion.getVersionStatus();
    if(status?.canUpdate==true){
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status!,
        allowDismissal: false,
        dialogTitle: "UPDATE",
        dialogText: "Please update the app from ${status.localVersion} to ${status.storeVersion}",
      );}}


}

// void customShowUpdateDialog(BuildContext context, VersionCheck versionCheck) {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => AlertDialog(
//       title: Text('NEW Update Available'),
//       content: SingleChildScrollView(
//         child: ListBody(
//           children: <Widget>[
//             Text(
//                 'Do you REALLY want to update to ${versionCheck.storeVersion}?'),
//             Text('(current version ${versionCheck.packageVersion})'),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           child: Text('Update'),
//           onPressed: () async {
//             await versionCheck.launchStore();
//             Navigator.of(context).pop();
//           },
//         ),
//         TextButton(
//           child: Text('Close'),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ],
//     ),
//   );
// }
