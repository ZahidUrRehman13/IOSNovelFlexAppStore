import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:novelflex/MixScreens/pdfViewerScreen.dart';
import 'package:novelflex/Models/BookEditModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/AddReviewModel.dart';
import '../Models/BookDetailsModel.dart';
import '../Provider/UserProvider.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../Utils/toast.dart';
import '../Widgets/reusable_button.dart';
import '../localization/Language/languages.dart';
import 'package:path/path.dart' as path;

class BookDetailEditScreen extends StatefulWidget {
  String? BookID;

  BookDetailEditScreen({required this.BookID});
  @override
  State<BookDetailEditScreen> createState() => _BookDetailEditScreenState();
}

class _BookDetailEditScreenState extends State<BookDetailEditScreen> {
  bool _isLoading = false;
  bool _isDeleteLoading = false;
  bool _isImageLoading = false;
  bool _isInternetConnected = true;
  BookEditModel? _bookEditModel;
  var token;
  bool subscribe = false;
  File? imageFile;

  final _bookTitleKey = GlobalKey<FormFieldState>();
  final _descriptionKey = GlobalKey<FormFieldState>();
  TextEditingController? _bookTitleController;
  TextEditingController? _descriptionController;

  File? DocumentFilesList;
  int fileLength = 0;
  bool docUploader= false;


  @override
  void dispose() {
    _bookTitleController =  TextEditingController();
    _descriptionController =  TextEditingController();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bookTitleController = new TextEditingController();
    _descriptionController = new TextEditingController();
    token = context.read<UserProvider>().UserToken.toString();
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
      _callBookDetailsEditAPI();
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
            : Column(
              children: [
                Stack(
                  children: [
                    Positioned(
                      child: Container(
                        height: _height*0.23,
                        decoration: BoxDecoration(
                          color:  Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            image: NetworkImage(
                              _bookEditModel!.data!.bookImage!,

                            ),
                            // fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: _height*0.1,
                      left: _width*0.4,
                      right:  _width*0.4,
                      child: GestureDetector(
                        onTap: () {
                          _getFromGallery();
                        },
                        child: Container(
                          height: _height*0.1,
                          width: _width*0.2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54
                          ),
                          child:_isImageLoading ?  const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ): Center(
                            child: Icon(Icons.image,size: _height*_width*0.0001,
                            color: Colors.white,),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Container(
          height: _height*0.9,
          child: ListView(
                  physics: ClampingScrollPhysics(),
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: _height*0.5,
                          width: _width,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Container(
                                margin: EdgeInsets.only(
                                    top: _height * 0.04,
                                    left: _width * 0.02,
                                    right: _width * 0.02),
                                height: _height * 0.07,
                                width: _width * 0.95,
                                child: TextFormField(
                                  key: _bookTitleKey,
                                  controller: _bookTitleController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    // labelText: widget.labelText,
                                    hintText: Languages.of(context)!.enterBookTitle,
                                    hintStyle: const TextStyle(fontFamily: Constants.fontfamily,),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Color(0xFF256D85)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Color(0xFF256D85)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: _height * 0.015,
                                    left: _width * 0.02,
                                    right: _width * 0.02),
                                height: _height * 0.25,
                                width: _width * 0.95,
                                child: TextFormField(
                                  key: _descriptionKey,
                                  controller: _descriptionController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 10,
                                  textInputAction: TextInputAction.next,
                                  cursorColor: Colors.black,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    // labelText: widget.labelText,
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Color(0xFF256D85)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 2, color: Color(0xFF256D85)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _isDeleteLoading,
                                child: Padding(
                                  padding:  EdgeInsets.only(top: _height*0.02),
                                  child: const Center(
                                    child: CupertinoActivityIndicator(
                                      color: Color(0xFF256D85),
                                      radius: 20,
                                    ),
                                  ),
                                ),
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              color: Colors.white,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: _bookEditModel!.data!.chapters!.length,
                                  itemBuilder: (BuildContext context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => PdfScreen(
                                                  url: _bookEditModel!
                                                      .data!.chapters![index].url,
                                                  name: _bookEditModel!
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
                                            top: _height * 0.03),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                                onPressed: () async {
                                                  _callDeleteBookAPI(
                                                      _bookEditModel!
                                                          .data!.chapters![index].id.toString()
                                                  );
                                                 // setState(() {
                                                 //   _bookEditModel!.data!.chapters!.removeWhere((item) => item.id ==  _bookEditModel!
                                                 //       .data!.chapters![index].id);
                                                 // });
                                                },
                                                icon:  Icon(
                                                  Icons.cancel_presentation,
                                                  color: Colors.white,
                                                  size: _height*_width*0.00012,
                                                )),
                                            _bookEditModel!.data!.chapters!.length ==
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
                                                  _bookEditModel!.data!
                                                      .chapters!.length ==
                                                      1
                                                      ? '${_bookEditModel!.data!.bookTitle}'
                                                      : '${_bookEditModel!.data!.bookTitle}:   Chapter  (${index + 1})',
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
                            GestureDetector(
                              onTap: (){
                                getPdfAndUpload(_bookEditModel!
                                    .data!.id.toString());
                              },
                              child: Container(
                                margin: EdgeInsets.only(left:_width*0.03,
                                top: _height*0.02),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: Color(0xFF256D85),
                                  ),
                                  height: _height*0.04,
                                  width: _width*0.25,
                                  child: Center(child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(Languages.of(context)!.addPDF,style: TextStyle(fontFamily: Constants.fontfamily,color: Colors.white),),
                                  ))),
                            ),
                            Container(
                              margin:  EdgeInsets.only(
                                  top: _height * 0.04,
                                  left: _width * 0.02,
                                  right: _width * 0.02
                              ),
                              alignment: Alignment.center,
                              height: _height * 0.05,
                              width: _width * 0.95,
                              child: ResuableMaterialButton(
                                onpress: () {
                                    _callEditDescriptionAPI();

                                },
                                buttonname: Languages.of(context)!.Update,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: _height*0.1,
                          color: Colors.white,
                        ),
                      ],
                    )
                  ],
          ),
        ),
                ),
              ],
            ));
  }


  // show the dialog

  Future _callBookDetailsEditAPI() async {
    setState(() {
      _isLoading = true;
      _isInternetConnected = true;
    });

    final response = await http.get(
      Uri.parse(ApiUtils.EDIT_BOOK_API + widget.BookID.toString()),
    );

    if (response.statusCode == 200) {
      print('EditBook_response under 200 ${response.body}');
      var jsonData = json.decode(response.body);
      _bookEditModel = BookEditModel.fromJson(jsonData);
      print(_bookEditModel!.message.toString());
      _descriptionController!.text= _bookEditModel!.data!.description.toString();
      _bookTitleController!.text= _bookEditModel!.data!.bookTitle.toString();
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
      });
      UploadCoverImageApi();

    }
  }

  Future _callDeleteBookAPI(String id) async {
    setState(() {
      _isDeleteLoading = true;
    });
    var map = Map<String, dynamic>();
    map['id'] = id;

    final response = await http.post(
      Uri.parse(ApiUtils.DELETE_BOOK_API),
      body: map,
    );

    var jsonData;

    if (response.statusCode == 200) {
      //Success

      jsonData = json.decode(response.body);
      print('delete_chapter_data: $jsonData');
      if (jsonData['status'] == 200) {

        ToastConstant.showToast(context,jsonData['message']);
        setState(() {
          _isDeleteLoading = false;
          _bookEditModel!.data!.chapters!.removeWhere((item) => item.id == id);
        });

      } else {
        ToastConstant.showToast(context, "Invalid Credential!");
        setState(() {
          _isDeleteLoading = false;
        });
      }
    } else {
      ToastConstant.showToast(context, "Internet Server Error!");
      setState(() {
        _isDeleteLoading = false;
      });
    }
  }

  Future getPdfAndUpload(String id) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.first.extension=='pdf') {
      DocumentFilesList= File(result.files.single.path!);
      setState(() {
        SingleBookUploadApi(id);
      });
    } else {
      Constants.showToastBlack(
          context, "Please select only pdf file!");
    }

  }

  Future<void> SingleBookUploadApi(String id) async {

    setState(() {
      _isDeleteLoading = true;
    });
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "accesstoken":context.read<UserProvider>().UserToken.toString()
    };

    var request = http.MultipartRequest('POST',
        Uri.parse(ApiUtils.MULTIPLE_PDF_UPLOAD_API));

      request.fields['bookId'] = id;
      http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
          'filename[]', DocumentFilesList!.path,
          contentType: MediaType('application', 'pdf')
      );


    request.files.add(multipartFile);
    request.headers.addAll(headers);
    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        if (response.statusCode == 200) {
          print("multiple  books Uploaded! ");
          print('response_book_upload ' + response.body);
          setState(() {
            _isDeleteLoading = false;

          });
          _callBookDetailsEditAPI();
          ToastConstant.showToast(context, "Books Added Successfully");

        }
      });
    });
  }

  Future _callEditDescriptionAPI() async {
    Map<String, String> headers = {

      "accesstoken": context.read<UserProvider>().UserToken.toString(),
    };
    setState(() {
      _isDeleteLoading = true;
    });
    var map = Map<String, dynamic>();
    map['title'] = _bookTitleController!.text.trim();
    map['description'] = _descriptionController!.text.trim();
    map['bookId'] = _bookEditModel!.data!.id;

    final response = await http.post(
      Uri.parse(ApiUtils.UPDATE_EDIT_BOOK_API),
      body: map,
      headers: headers
    );

    var jsonData;

    if (response.statusCode == 200) {
      //Success

      jsonData = json.decode(response.body);
      print('update_title_description_data: $jsonData');
      if (jsonData['status'] == 200) {
        ToastConstant.showToast(context, jsonData['message']);
        setState(() {
          _isDeleteLoading = false;
        });
        _callBookDetailsEditAPI();

      } else {
        ToastConstant.showToast(context, "Updates Successfully!");
        setState(() {
          _isDeleteLoading = false;
        });
      }
    } else {
      ToastConstant.showToast(context, "Updates Successfully!");
      setState(() {
        _isDeleteLoading = false;
      });
    }
  }

  Future<void> UploadCoverImageApi() async {
    setState(() {
      _isImageLoading = true;
    });
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "accesstoken": context.read<UserProvider>().UserToken.toString(),
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse(ApiUtils.UPDATE_BOOK_COVER_API));

    request.files.add( http.MultipartFile.fromBytes(
      "image",
      File(imageFile!.path)
          .readAsBytesSync(), //UserFile is my JSON key,use your own and "image" is the pic im getting from my gallary
      filename: "Image.jpg",
      contentType: MediaType('image', 'jpg'),
    ));
    request.fields['bookId'] = _bookEditModel!.data!.id.toString();
    request.headers.addAll(headers);

    request.send().then((result) async {
      http.Response.fromStream(result).then((response) {
        if (response.statusCode == 200) {
          print("Cover Image Update Successfully! ");
          print('book_cover_image_upload ' + response.body);
          Constants.showToastBlack(context, "Cover Image Update Successfully!");
          setState(() {
            _isImageLoading = false;
          });
          _callBookDetailsEditAPI();
        }
        else{
          setState(() {
            _isImageLoading = false;
          });
          Constants.showToastBlack(context, "sorry try again!");
        }
      });
    });
  }

}




