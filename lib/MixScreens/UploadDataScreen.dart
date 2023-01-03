import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Models/DropDown2Model.dart';
import '../Models/DropDownCategoriesModel.dart';
import '../Models/DropDownSubCategoriesModel.dart';
import '../Models/PostImageOtherFieldModel.dart';
import '../Models/UploadMultipleFileModel.dart';
import '../Provider/UserProvider.dart';
import '../Utils/ApiUtils.dart';
import '../Utils/Constants.dart';
import '../Utils/toast.dart';
import '../Widgets/reusable_button.dart';
import '../localization/Language/languages.dart';

class UploadDataScreen extends StatefulWidget {
  @override
  State<UploadDataScreen> createState() => _UploadDataScreenState();
}

class _UploadDataScreenState extends State<UploadDataScreen> {

  final _bookTitleKey = GlobalKey<FormFieldState>();
  final _descriptionKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController? _bookTitleController;
  TextEditingController? _descriptionController;

  String? fileName;
  var pathImage;
  String language = "";
  bool subCategoriesStatus= false;

  Future<void> _retrievePath() async {
    final prefs = await SharedPreferences.getInstance();

    // Check where the name is saved before or not
    if (!prefs.containsKey('path_img')) {
      return;
    }

    setState(() {
      pathImage = prefs.getString('path_img');
      log("Index number is: ${pathImage.toString()}");
    });
  }

  Future<void> _savePath(var _pathFine) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('path_img', _pathFine);
    });
  }

  Future<void> _clearPath() async {
    final prefs = await SharedPreferences.getInstance();
    // Check where the name is saved before or not
    if (!prefs.containsKey('path_img')) {
      return;
    }

    await prefs.remove('path_img');
    setState(() {
      pathImage = null;
    });
  }

  List<DropDownCategoriesModel>? _dropDownCategoriesModelList;
  DropDownCategoriesModel? _dropDownCategoriesModel;

  List<DropDown2Model>? _dropDown2ModelList;
  DropDown2Model? _dropDown2Model;

  List<DropDownSubCategoriesModel>? _downSubCategoriesModelList;
  DropDownSubCategoriesModel? _downSubCategoriesModel;

  PostImageOtherFieldModel? _postImageOtherFieldModel;

  UploadMultipleFileModel? _uploadMultipleFileModel;
  List<UploadMultipleFileModel>? _uploadMultipleFileModelList;

  bool _isLoading = false;
  bool _isLoadingLast = false;
  bool _isInternetConnected = true;
  List categoryItemList = [];
  var dropDownId;
  var dropDown2Id;
  var dropDownSub2Id;
  List<File>? DocumentFilesList;
  int fileLength = 0;
  File? imageFile;
  var documentFile;
  bool docUploader= false;

  var dio;


  @override
  void initState() {
    super.initState();
    _bookTitleController = new TextEditingController();
    _descriptionController = new TextEditingController();
    _callDropDownCategoriesAPI();
    dio = Dio();
    print("all_token: ${context.read<UserProvider>().UserToken.toString()}");
  }

  @override
  void dispose() {
    _bookTitleController =  TextEditingController();
    _descriptionController =  TextEditingController();
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
      _callDropDownCategoriesAPI();
    }
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: height * 0.07,
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
                      height: height * 0.019,
                    ),
                    InkWell(
                      child: Container(
                        width: width * 0.40,
                        height: height * 0.058,
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
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: height * 0.05,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 15.0, bottom: 15.0, left: width * 0.05,right:width * 0.05 ),
                              child: Text(
                                Languages.of(context)!.selectLanguage,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.fontfamily,
                                    fontSize: 15.0),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: width * 0.05),
                              child: Column(
                                children: [
                                  RadioListTile(
                                    title: const Text("English",style: TextStyle(fontFamily: Constants.fontfamily,),),
                                    value: "eng",
                                    groupValue: language,
                                    onChanged: (value) {
                                      setState(() {
                                        language = value.toString();
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: const Text("Arabic",style: TextStyle(fontFamily: Constants.fontfamily,),),
                                    value: "arb",
                                    groupValue: language,
                                    onChanged: (value) {
                                      setState(() {
                                        language = value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(
                                  top: height * 0.04,
                                  left: width * 0.02,
                                  right: width * 0.02),
                              height: height * 0.07,
                              width: width * 0.9,
                              child: TextFormField(
                                key: _bookTitleKey,
                                controller: _bookTitleController,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                cursorColor: Colors.black,
                                validator: validateBookTitle,
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
                                    top: height * 0.07,
                                    left: width * 0.02,
                                    right: width * 0.02),
                                height: height * 0.07,
                                width: width * 0.9,
                                child: _dropDownCategoriesWidget()),
                            Container(
                                margin: EdgeInsets.only(
                                    top: height * 0.07,
                                    left: width * 0.02,
                                    right: width * 0.02),
                                height: height * 0.07,
                                width: width * 0.9,
                                child: _dropDownCategoriesWidget2()),
                            // _isLoadingLast ? const Align(
                            //     alignment: Alignment.center,
                            //     child: const Center(
                            //       child: CupertinoActivityIndicator(
                            //         color: const Color(0xFF256D85),
                            //         radius: 20,
                            //       ),
                            //     )
                            // ) :  subCategoriesStatus ? Container(
                            //     margin: EdgeInsets.only(
                            //         top: height * 0.07,
                            //         left: width * 0.02,
                            //         right: width * 0.02),
                            //     height: height * 0.07,
                            //     width: width * 0.9,
                            //     child: _dropDownCategoriesWidgetSubCategories2()
                            // ): Container(),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: height * 0.05,
                                  bottom: 15.0,
                                  left: width * 0.02,
                                  right: width * 0.02),
                              child: Text(Languages.of(context)!.writetheDescription,

                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.fontfamily,
                                      fontSize: 15.0)),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: height * 0.015,
                                  left: width * 0.02,
                                  right: width * 0.02),
                              height: height * 0.35,
                              width: width * 0.9,
                              child: TextFormField(
                                key: _descriptionKey,
                                controller: _descriptionController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 10,
                                textInputAction: TextInputAction.next,
                                cursorColor: Colors.black,
                                validator: validateDescription,
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
                            GestureDetector(
                              onTap: () async {
                                _getFromGallery();
                              },
                              child: Container(
                                margin: EdgeInsets.only(left: width * 0.02,right: width * 0.02),
                                height: height * 0.35,
                                width: width * 0.7,
                                child: Center(
                                  child: pathImage == null
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              left: width * 0.02),
                                          height: height * 0.35,
                                          width: width * 0.7,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              color: Colors.black12),
                                          child: Center(
                                            child: Text(
                                                Languages.of(context)!.taptoUploadCoverImage,style: const TextStyle(fontFamily: Constants.fontfamily,),),
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.file(
                                            File(pathImage!),
                                            fit: BoxFit.cover,
                                            colorBlendMode:
                                                BlendMode.saturation,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    color: Colors.black12),
                                                child: Center(
                                                  child: Text(
                                                      Languages.of(context)!.taptoUploadCoverImage,style: TextStyle(fontFamily: Constants.fontfamily,),),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: height * 0.05,
                            ),
                            Visibility(
                                visible: docUploader==true,
                                child: const Center(
                                  child: CupertinoActivityIndicator(
                                    color: const Color(0xFF256D85),
                                    radius: 20,
                                  ),
                                )),
                            Container(
                              decoration: const ShapeDecoration(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 0.5, style: BorderStyle.solid),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  color: Colors.white),
                              width: width * 0.9,
                              height: height * 0.08,
                              margin: EdgeInsets.only(
                                  left: width * 0.02,
                                  right: width * 0.02,
                                  top: height * 0.05),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // SizedBox(
                                  //   width: _width * 0.04,
                                  //   height: _height * 0.07,
                                  // ),
                                  fileLength == 0
                                      ? Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0,right: 8.0),
                                            child: Text(Languages.of(context)!.SelectBook,
                                                style: const TextStyle(
                                                    color: Colors.black54,fontFamily: Constants.fontfamily,)),
                                          ),
                                        )
                                      : Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Text(
                                              '$fileLength ${Languages.of(context)!.filesSelected}',
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 18,
                                                fontFamily: Constants.fontfamily,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                  // SizedBox(
                                  //   width: _width * 0.35,
                                  // ),
                                  IconButton(
                                      onPressed: () {
                                        getPdfAndUpload();
                                      },
                                      icon: const Icon(Icons.file_upload_outlined)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: height * 0.06,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
        alignment: Alignment.center,
        height: height * 0.08,
        width: width * 0.95,
        child: ResuableMaterialButton(
          onpress: () {
            // if (language.isNotEmpty &&
            //     _bookTitleController!.text.isNotEmpty &&
            //     dropDownId != null &&
            //     _descriptionController!.text.isNotEmpty &&
            //     imageFile != null) {
            //   if(DocumentFilesList!.length != 0){
            // SingleBookUploadApi();
            _AutomaticCallApiMethod();
            // }else{
            //   Constants.showToastBlack(context, "Please Select AtLeast 1 document!");
            // }

            // }else{
            //   Constants.showToastBlack(context, "Please fill all the fields in sequence!");
            // }
          },
          buttonname: Languages.of(context)!.Publish,
        ),
      ),
    );
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
        _savePath(localImage.path);
        UploadBookImageAndOtherFieldApi();
        _retrievePath();
      });
    }
  }

  _AutomaticCallApiMethod() {
    if (language.isNotEmpty &&
        _bookTitleController!.text.isNotEmpty &&
        dropDownId != null &&
        _descriptionController!.text.isNotEmpty &&
        imageFile != null) {
      if( DocumentFilesList != null){
        SingleBookUploadApi();
      } else {
        Constants.showToastBlack(
            context, "Please Select at Least 1 Pdf file");
      }

      // UploadBookImageAndOtherFieldApi();
      // _uploadImageWithFieldsAPI();
      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => MyFileUploadScreen()));

    } else {
      Constants.showToastBlack(
          context, "Please fill all the fields in sequence!");
    }
  }

  Widget _dropDownCategoriesWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      child: DropdownButton<DropDownCategoriesModel>(
        hint: Text(
          Languages.of(context)!.selectGenerals,
          style: const TextStyle(
            fontFamily: Constants.fontfamily,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        items: _dropDownCategoriesModelList!
            .map((DropDownCategoriesModel newItem) {
          return DropdownMenuItem<DropDownCategoriesModel>(
            value: newItem,
            child: Text(
              context.read<UserProvider>().SelectedLanguage == "English" ? newItem.title!: newItem.titleAr!,
              style: const TextStyle(
                  fontFamily: Constants.fontfamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (DropDownCategoriesModel? newItem) {
          setState(() {
            _dropDownCategoriesModel = newItem;
            dropDownId =  newItem!.categoryId;
            // print(dropdownvalue!.typeNameCont);
          });
        },
        value: _dropDownCategoriesModel,
        isExpanded: true,
        underline: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _dropDownCategoriesWidget2() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      child: DropdownButton<DropDown2Model>(
        hint: Text(
          Languages.of(context)!.selectProducts,
          style: const TextStyle(
            fontFamily: Constants.fontfamily,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        items: _dropDown2ModelList!
            .map((DropDown2Model newItem) {
          return DropdownMenuItem<DropDown2Model>(
            value: newItem,
            child: Text(
              context.read<UserProvider>().SelectedLanguage == "English" ? newItem.titleEn!: newItem.titleAr!,
              style: const TextStyle(
                  fontFamily: Constants.fontfamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (DropDown2Model? newItem) {
          setState(() {
            _dropDown2Model = newItem;
            dropDown2Id =  newItem!.id;

            // if(subCategoriesStatus==true){
            //  setState(() {
            //    subCategoriesStatus==false;
            //    _downSubCategoriesModelList!.clear();
            //
            //  });
            // }
            _callDropDownCategoriesAPISubCategories2( newItem.id);

            // print(dropdownvalue!.typeNameCont);
          });
        },
        value: _dropDown2Model,
        isExpanded: true,
        underline: Container(color: Colors.transparent),
      ),
    );
  }

  Widget _dropDownCategoriesWidgetSubCategories2() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 0.5, style: BorderStyle.solid),
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
      child: DropdownButton<DropDownSubCategoriesModel>(
        hint: Text(
          Languages.of(context)!.selectSubCategories,
          style: const TextStyle(
            fontFamily: Constants.fontfamily,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
        items: _downSubCategoriesModelList!
            .map((DropDownSubCategoriesModel newItem) {
          return DropdownMenuItem<DropDownSubCategoriesModel>(
            value: newItem,
            child: Text(
              context.read<UserProvider>().SelectedLanguage == "English" ? newItem.subTitle!: newItem.subTitleAr!,
              style: const TextStyle(
                  fontFamily: Constants.fontfamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Colors.black),
            ),
          );
        }).toList(),
        onChanged: (DropDownSubCategoriesModel? newItem) {
          setState(() {
            _downSubCategoriesModel = newItem;
            dropDownSub2Id =  newItem!.categoryId;
            // print(dropdownvalue!.typeNameCont);
          });
        },
        value: _downSubCategoriesModel,
        isExpanded: true,
        underline: Container(color: Colors.transparent),
      ),
    );
  }

  Future _callDropDownCategoriesAPI() async {
    setState(() {
      _isLoading = true;
      _isInternetConnected = true;
    });

    final response = await http.get(
      Uri.parse(ApiUtils.DROP_DOWN_CATEGORIES_API),
    );

    if (response.statusCode == 200) {
      print('dropDownApiResponse under 200 ${response.body}');
      var jsonData = response.body;
      //var jsonData = response.body;
      _dropDownCategoriesModelList = dropDownCategoriesModelFromJson(jsonData);
      // setState(() {
      //   _isLoading = false;
      // });
      _callDropDownCategoriesAPI2();
    }
  }

  Future _callDropDownCategoriesAPI2() async {


    final response = await http.get(
      Uri.parse(ApiUtils.DROP_DOWN_CATEGORY_2_API),
    );

    if (response.statusCode == 200) {
      print('dropDownApiResponse_2 under 200 ${response.body}');
      var jsonData = response.body;
      _dropDown2ModelList = dropDown2ModelFromJson(jsonData);
      setState(() {
        _isLoading = false;
      });

    }
  }

  Future _callDropDownCategoriesAPISubCategories2(var id) async {
    setState(() {
      _isLoadingLast = true;
    });
    var map = Map<String, dynamic>();
    map['id'] = id.toString();

    final response = await http.post(
      Uri.parse(ApiUtils.DROP_DOWN_SUB_CATEGORY_2_API),
      body: map
    );

    if (response.statusCode == 200) {
      print('dropDownApiResponse_SubCategories_2 under 200 ${response.body}');
      var jsonData = response.body;
      _downSubCategoriesModelList = dropDownSubCategoriesModelFromJson(jsonData);

      setState(() {
        _isLoadingLast = false;
        subCategoriesStatus=true;

      });
    }
  }

  Future getPdfAndUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: true,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.first.extension=='pdf') {
      DocumentFilesList = result.paths.map((path) => File(path!)).toList();
      setState(() {
        // documentFile= result.paths;
        fileLength = DocumentFilesList!.length;
        // for(int i=0;i<=DocumentFilesList!.length;i++){
        //   print(DocumentFilesList);
        // }
        // fileLength = 2;
      });
    } else {
      Constants.showToastBlack(
          context, "Please select only pdf file!");

    }

  }

  String? validateBookTitle(String? value) {
    if (value!.isEmpty)
      return 'Enter Book Title';
    else
      return null;
  }

  String? validateDescription(String? value) {
    if (value!.isEmpty)
      return 'Enter Description';
    else
      return null;
  }

  _navigateAndRemove(){
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _descriptionController!.clear();
      _bookTitleController!.clear();
      Navigator.of(context).pushNamedAndRemoveUntil(
          'tab_screen', (Route<dynamic> route) => false);
    });
  }

  Future<void> UploadBookImageAndOtherFieldApi() async {
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "accesstoken": context.read<UserProvider>().UserToken.toString()
    };
    var jsonResponse;

    var request = http.MultipartRequest(
        'POST', Uri.parse(ApiUtils.ADD_IMAGE_WITH_FILED_API));
    request.fields['title'] = _bookTitleController!.text.trim();
    request.fields['description'] = _descriptionController!.text.trim();
    request.fields['categoryId'] = dropDownId.toString();
    request.fields['language'] = language.trim().toString();
    request.files.add(new http.MultipartFile.fromBytes(
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
          print("Uploaded! ");
          print('response_image_upload ' + response.body);
          _postImageOtherFieldModel =
              postImageOtherFieldModelFromJson(response.body);
          print(
              "imageUploadModel_response_1 ${_postImageOtherFieldModel!.data!.id}");
        }
      });
    });
  }

  Future _callMultiUploadBooksApi() async {
    var formData = FormData.fromMap({
      'bookId': _postImageOtherFieldModel!.data!.id,
      'filename[]': DocumentFilesList,
    }, ListFormat.multiCompatible);

    var response = await dio.post(
        ApiUtils.MULTIPLE_PDF_UPLOAD_API,
        data: formData,
        options: Options(
          headers: {
            // 'Content-Type': 'application/json',
            // 'Accept': 'application/json',
            // 'Accept': 'application/json',
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
            "accesstoken": context.read<UserProvider>().UserToken.toString()
          },
        ));
    // check response status code
    if (response.statusCode == 200) {
      // it's uploaded
      print("Done_Status");
    } else {
      // User canceled the picker
    }
  }

  Future<void> SingleBookUploadApi() async {

    setState(() {
      docUploader = true;
    });
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "accesstoken": context.read<UserProvider>().UserToken.toString()
    };

    var request = http.MultipartRequest('POST',
        Uri.parse(ApiUtils.MULTIPLE_PDF_UPLOAD_API));
    // request.files.add(new http.MultipartFile.fromBytes(
    //   "files",
    //   File(DocumentFilesList!.path)
    //       .readAsBytesSync(), //UserFile is my JSON key,use your own and "image" is the pic im getting from my gallary
    //   filename: "zahid.pdf",
    //   // contentType: MediaType('image', 'jpg'),
    // )

    // );
    request.fields['bookId'] = _postImageOtherFieldModel!.data!.id.toString();
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
            docUploader = false;

          });
          ToastConstant.showToast(context, "Books Uploaded Successfully");
          _navigateAndRemove();
          // _postImageOtherFieldModel =
          //     postImageOtherFieldModelFromJson(response.body);

        }
      });
    });
  }

}
