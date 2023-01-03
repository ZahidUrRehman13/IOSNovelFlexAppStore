import 'package:flutter/material.dart';

/*
Title:Languages
Purpose:Languages
Created By:Kalpesh Khandla
*/

abstract class Languages {
  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }

  String get appName;

  String get continueWith;

  String get resetPasswordtxt;

  String get resetPasswordtxt2;

  String get labelWelcome;

  String get labelInfo;

  String get labelChangeLanguage;

  String get labelSelectLanguage;

  String get home;

  String get rate_Us;

  String get ContactUs;

  String get Disclaimer;

  String get LogOut;

  String get seeAll;

  String get terms;

  String get agree;

  String get longTextTerms;


  String get termsText_1;

  String get MyMangaUploads;

  String get DeleteAccount;

  String get UploadHistory;

  String get selectLanguage;

  String get enterBookTitle;

  String get selectGenerals;

  String get selectProducts;

  String get selectSubCategories;

  String get writetheDescription;

  String get taptoUploadCoverImage;

  String get SelectBook;

  String get Publish;

  String get Update;

  String get addPDF;

  String get filesSelected;

  String get EditButton;

  String get YourManga;

  String get discliamr_bar;

  String get seeAllReviews;

  String get follow;

  String get level;

  String get authorC;

  String get published;

  String get publishedBooks;

  String get myWallet;

  String get subscriber;

  String get RateusDialog;

  String get submitDialog;

  String get comments;

  String get notSignUpYet;

  String get seeAllreview2;

  String get userName;

  String get email;

  String get password;

  String get login;

  String get newPasswordCreate;

  String get forgetPassword;

  String get donthaveanaccountSignUp;

  String get signup;

  String get confirmpassword;

  String get confirmnewpassword;

  String get register;

  String get iamWriter;

  String get iamreader;

  String get alreadyhaveAccountSignIn;

  String get welcomenovelflex;

  String get forgetpassword;

  String get socailtext;

  String get createAccount;

  String get selectAccountType;

  String get dialogAreyousure;

  String get deleteAccountText;

  String get alert;

  String get yes;

  String get no;

  String get disclaimer;

  String get noReview;

  String get newFpassword;

  String get doneText;

  String get nouploadhistory;


}
