import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/UserUploadHistoryModel.dart';
import '../Provider/UserProvider.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../Utils/toast.dart';
import '../localization/Language/languages.dart';
import 'BookDetailEditScreen.dart';
import 'BookDetailScreen.dart';
import 'UploadDataScreen.dart';

class Uploadscreen extends StatefulWidget {
  const Uploadscreen({Key? key}) : super(key: key);

  @override
  State<Uploadscreen> createState() => _UploadscreenState();
}

class _UploadscreenState extends State<Uploadscreen> {
  UserUploadHistoryModel? _userUploadHistoryModel;

  bool _isLoading = false;
  String? token;
  bool _isInternetConnected = true;

  List<File>? DocumentFilesList;
  int fileLength = 0;
  bool docUploader= false;
  bool _emtyFlag = false;

  @override
  void initState() {
    super.initState();
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

      _callUploadHistoryAPI();
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
                  Text(Languages.of(context)!.UploadHistory,style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    fontFamily: Constants.fontfamily,
                  ),)
                ],
              ),
            ),
            SizedBox(
              child: IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadDataScreen()));
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
        ) : _emtyFlag
            ? Center(
          child: Text(
            Languages.of(context)!.nouploadhistory,
            style: const TextStyle(
                fontFamily: Constants.fontfamily,
                color: Colors.black54),
          ),
        )
            :ListView.builder(
          itemCount:_userUploadHistoryModel!.data!.length,
            itemBuilder: (BuildContext context, index){
          return GestureDetector(
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BookDetailScreen(
                            BookID:
                            '${_userUploadHistoryModel!.data![index].id!}',
                          )));
            },
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 1,
              shadowColor: Colors.white,
              child: Container(
                height: _height*0.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [

                           Padding(
                             padding: const EdgeInsets.all(15.0),
                             child: Container(
                               height: _height*0.15,
                               width: _width*0.25,
                               decoration: BoxDecoration(
                                 color: Colors.black12,
                                 image: DecorationImage(
                                   image: NetworkImage(_userUploadHistoryModel!.data![index].bookImage.toString(),
                                   ),
                                   fit: BoxFit.cover
                                 ),
                               ),
                             ),
                           ),
                           Container(
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(5.0),
                                 color: Color(0xFF256D85),
                               ),
                               height: _height*0.04,
                               width: _width*0.25,
                               child: Center(child: Padding(
                             padding: const EdgeInsets.only(left: 15),
                             child: Text(_userUploadHistoryModel!.data![index].categoryTitle.toString(),style: TextStyle(fontFamily: Constants.fontfamily,color: Colors.white),),
                           ))),

                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // margin: EdgeInsets.only(bottom: _height*0.02),
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // SizedBox(height: _height*0.05,),
                            // SizedBox(height: 10.0,),
                            Text(_userUploadHistoryModel!.data![index].bookTitle.toString(),style: const TextStyle(
                              fontSize: 15,fontWeight: FontWeight.w700,
                              fontFamily: Constants.fontfamily,

                            ),),
                            // SizedBox(height: _height*0.07,),
                           // Text('Modified Date: ${_userUploadHistoryModel!.data![index].modifiedDate.toString()}',),
                            Text('Published Date: ${ DateFormat('dd-MM-yyyy').format(_userUploadHistoryModel!.data![index].publishedDate!.toUtc())}',overflow: TextOverflow.clip,style: TextStyle(fontFamily: Constants.fontfamily,color: Colors.black),),
                            const SizedBox(height: 1.0,),
                               ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        // getPdfAndUpload(_userUploadHistoryModel!.data![index].id.toString());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailEditScreen(
                                      BookID:
                                      '${_userUploadHistoryModel!.data![index].id!}',
                                    )));

                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Color(0xFF256D85),
                        ),
                        height: _height*0.04,
                        width: _width*0.25,

                        margin: EdgeInsets.only(top: _height*0.22,right: _width*0.1,left: _width*0.03),
                        child: Center(
                          child: Text(Languages.of(context)!.EditButton,textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 15,color: Colors.white,fontFamily: Constants.fontfamily,),),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );

        })
    );
}



  Future _callUploadHistoryAPI() async {
    setState(() {
      _isLoading = true;
      _isInternetConnected = true;
    });
    var map = new Map<String, String>();
    map['accesstoken'] = context.read<UserProvider>().UserToken.toString();
    final response = await http.get(
      Uri.parse(ApiUtils.UPLOAD_HISTORY_API),
      headers: map
    );

    if (response.statusCode == 200) {
      print('upload_history_response under 200 ${response.body}');
      var jsonData = response.body;
      //var jsonData = response.body;
      var jsonData1 = json.decode(response.body);
      if(jsonData1['status'] == 200)
     {
       _userUploadHistoryModel = userUploadHistoryModelFromJson(jsonData);
       setState(() {
         _isLoading = false;

       });
     }else{
        ToastConstant.showToast(context, jsonData1['message'].toString());
        setState(() {
          _isLoading = false;
          _emtyFlag = true;
        });
      }
      }

  }

  Future getPdfAndUpload(String id) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      DocumentFilesList = result.paths.map((path) => File(path!)).toList();
      setState(() {
        fileLength = DocumentFilesList!.length;
        SingleBookUploadApi(id);
      });
    } else {
      // User canceled the picker
    }

  }

  Future<void> SingleBookUploadApi(String id) async {

    setState(() {
      _isLoading = true;
    });
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "accesstoken":context.read<UserProvider>().UserToken.toString()
    };

    var request = http.MultipartRequest('POST',
        Uri.parse(ApiUtils.MULTIPLE_PDF_UPLOAD_API));

    request.fields['bookId'] = id;
    // request.fields['bookId'] = '41';

    List<http.MultipartFile> newList = <http.MultipartFile>[];

    for (int i = 0; i < DocumentFilesList!.length; i++) {
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
          'filename[]', DocumentFilesList![i].path,
          // contentType: MediaType('application', 'pdf')
          contentType: MediaType('application', 'pdf')
        // contentType: MediaType(
        //   'pdf',
        //   'jpeg',
        // ),
      );
      newList.add(multipartFile);
    }

    request.files.addAll(newList);
    request.headers.addAll(headers);
    // request.headers["accesstoken"] = '$userToken';
    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        if (response.statusCode == 200) {
          print("multiple  books Uploaded! ");
          print('response_book_upload ' + response.body);
          setState(() {
            _isLoading = false;

          });
          ToastConstant.showToast(context, "Books Added Successfully");
          // _navigateAndRemove();
          // _postImageOtherFieldModel =
          //     postImageOtherFieldModelFromJson(response.body);

        }
      });
    });
  }
}
