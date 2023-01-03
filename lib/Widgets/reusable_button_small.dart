import 'package:flutter/material.dart';

import '../Utils/Constants.dart';

class ResuableMaterialButtonSmall extends StatelessWidget {
  ResuableMaterialButtonSmall({
    Key? key,
    required this.onpress,
    required this.buttonname,
  }) : super(key: key);

   var onpress;
   var  buttonname;

  @override
  Widget build(BuildContext context) {

    var height= MediaQuery.of(context).size.height;
    var width= MediaQuery.of(context).size.width;
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),

      ),
      color: Color(0xff3a6c83),
      minWidth: width*0.9,
      height: height*0.06,
      onPressed: onpress,
      child:  Text(buttonname,style: TextStyle(color: Colors.white,fontSize:width*0.04,fontFamily: Constants.fontfamily, ),)
    );
  }
}