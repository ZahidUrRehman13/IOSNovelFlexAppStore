import 'package:flutter/material.dart';

import '../../Widgets/reusable_button_small.dart';
import '../../localization/Language/languages.dart';

class SingUpScreen_Third extends StatefulWidget {
  const SingUpScreen_Third({Key? key}) : super(key: key);

  @override
  State<SingUpScreen_Third> createState() => _SingUpScreen_ThirdState();
}

class _SingUpScreen_ThirdState extends State<SingUpScreen_Third> {
  bool isReader =false;
  bool isWriter = true;

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return  Scaffold(
      backgroundColor: const Color(0xffebf5f9),
      appBar: AppBar(
        toolbarHeight: _height*0.1,
        title: Text(Languages.of(context)!.signup,style: TextStyle( color: const Color(0xFF256D85),fontSize: _width*0.043),),
        centerTitle: true,
        backgroundColor:const Color(0xffebf5f9),
        elevation: 0.0,
        leading: IconButton(
            onPressed: (){

              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back,size: _height*0.03,color: Colors.black54,)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          mainText(_width),
          InkWell(
            onTap: (){
              setState(() {
                isWriter=true;
                isReader = false;
              });
            },
            child: Container(
                width: _width*0.8,
                height: _height*0.2,
                decoration: isWriter ? BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    ),
                    border: Border.all(
                        color: const Color(0xff30fc56),
                        width: 3
                    ),
                    color: isWriter ?  const Color(0xff3a6c83) : const Color(0xffebf5f9)
                ) :BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    ),
                    border: Border.all(
                        color: const Color(0xff3a6c83),
                        width: 3
                    )
                ),
              child: Stack(
                children: [
                  Positioned(
                    left: _width*0.1,
                      top: _height*0.1,
                      child:Text(
                          Languages.of(context)!.iamWriter,
                          style:  TextStyle(
                              color:  isWriter ? const Color(0xffffffff):const Color(0xff002333),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Lato",
                              fontStyle:  FontStyle.normal,
                              fontSize: 16.0
                          ),
                          textAlign: TextAlign.center
                      ) ),
                  Positioned(
                      left: _width*0.17,
                      top: _height*0.05,
                      child:Image.asset("assets/quotes_data/extra_pngs/penfancy.png",
                        color: isWriter ? const Color(0xffffffff):const Color(0xff002333),)),
                  Positioned(
                      left: _width*0.5,
                      top: _height*0.05,
                      child:Image.asset("assets/quotes_data/extra_pngs/WritingIllustration.png")),

                ],
              ),
            ),
          ),
          InkWell(
            onTap: (){
              setState(() {
                isWriter=false;
                isReader = true;
              });
            },
            child: Container(
                width: _width*0.8,
                height: _height*0.2,
                decoration: isReader ?  BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    ),
                    border: Border.all(
                        color: const Color(0xff30fc56),
                        width: 3
                    ),
                    color: isReader ?  const Color(0xff3a6c83) :const Color(0xffebf5f9)
                ) :BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    ),
                    border: Border.all(
                        color: const Color(0xff3a6c83),
                        width: 3
                    )
                ),
              child: Stack(
                children: [
                  Positioned(
                      left: _width*0.1,
                      top: _height*0.1,
                      child:Text(
                          Languages.of(context)!.iamreader,
                          style:  TextStyle(
                              color: isReader ? const Color(0xffffffff):const Color(0xff002333),
                              fontWeight: FontWeight.w700,
                              fontFamily: "Lato",
                              fontStyle:  FontStyle.normal,
                              fontSize: 16.0
                          ),
                          textAlign: TextAlign.center
                      )),
                  Positioned(
                      left: _width*0.17,
                      top: _height*0.05,
                      child:Image.asset("assets/quotes_data/extra_pngs/glasses.png",
                        color: isReader ? const Color(0xffffffff):const Color(0xff002333),)),
                  Positioned(
                      left: _width*0.35,
                      top: _height*0.04,
                      child:Image.asset("assets/quotes_data/extra_pngs/VNU_M527_04.png")),

                ],
              ),
            ),
          ),
          Container(
            width: _width * 0.9,
            height: _height * 0.06,
            margin: EdgeInsets.only(
                top: _height*0.05
            ),
            child: ResuableMaterialButtonSmall(
              onpress: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=>
                //     SingUpScreen_2()));
              },
              buttonname: Languages.of(context)!.register,
            ),
          ),
          SizedBox(),
          SizedBox()

        ],
      ),
    );
  }
  Widget mainText2(var width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Languages.of(context)!.signup,
          style: const TextStyle(
              color:  const Color(0xff002333),
              fontWeight: FontWeight.w700,
              fontFamily: "Lato",
              fontStyle:  FontStyle.normal,
              fontSize: 14.0
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  Widget mainText(var width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Languages.of(context)!.selectAccountType,
          style: const TextStyle(
              color:  const Color(0xff002333),
              fontWeight: FontWeight.w700,
              fontFamily: "Lato",
              fontStyle:  FontStyle.normal,
              fontSize: 20.0
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
