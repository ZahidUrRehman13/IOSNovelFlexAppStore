 import 'package:flutter/material.dart';

class VariableProvider extends ChangeNotifier{
 bool _reviewflag = false;
 bool _isloading = false;


 bool reviewFlag() => _reviewflag;
 bool loadingFlag() => _isloading;


 //method to get update value of variable
 updateReview(bool flagR){
  _reviewflag =flagR ;  //method to update the variable value
  notifyListeners();
 }

 updateLoader(bool flagL){
  _isloading =flagL ;  //method to update the variable value
  notifyListeners();
 }



 }