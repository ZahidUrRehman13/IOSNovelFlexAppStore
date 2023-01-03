import 'package:flutter/material.dart';

class ResuableMaterialButton extends StatelessWidget {
   ResuableMaterialButton({
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
        borderRadius: BorderRadius.circular(8),

      ),
      color:Color(0xFF256D85),
      minWidth: width*0.99,
      height: height*0.1,
      onPressed: onpress,
      child:  Text(buttonname,style: TextStyle(color: Colors.white,fontSize:width*0.04 ),)
    );
  }
}