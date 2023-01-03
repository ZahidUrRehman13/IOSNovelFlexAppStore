import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../MixScreens/disclimar_screen.dart';
import '../Models/language_model.dart';
import '../Provider/UserProvider.dart';
import '../Utils/Constants.dart';
import '../localization/Language/languages.dart';
import '../localization/locale_constants.dart';

class DrawerCode extends StatefulWidget {
  static const String id = 'drawer_screen';

  @override
  State<DrawerCode> createState() => _DrawerCodeState();
}

class _DrawerCodeState extends State<DrawerCode> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor:
          const Color(0xffebf5f9), //This will change the drawer background to blue.
          //other styles
        ),
        child: Drawer(
          elevation: 0.0,
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: <Widget>[
              SizedBox(
                height: _height * 0.2,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: const Color(0xffebf5f9)),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: AssetImage('assets/icon_whitout_pg.png'),
                                fit: BoxFit.fill),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: _height * 0.12,
                child: Card(
                  elevation: 0,
                  color: const Color(0xffebf5f9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              color:  const Color(0xffebf5f9),
                              child: CircleAvatar(
                                backgroundColor: Colors.black12,
                                backgroundImage: Provider.of<UserProvider>(context,
                                    listen: false)
                                    .UserImage !=
                                    null ? NetworkImage(
                                  Provider.of<UserProvider>(context,
                                      listen: false)
                                      .UserImage!,

                                ): AssetImage('assets/profile_pic.png') as ImageProvider,

                              ),
                              height: _height * 0.18,
                              width: _width * 0.3,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              color: const Color(0xffebf5f9),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    (Provider.of<UserProvider>(context,
                                            listen: false)
                                        .UserName!),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.fontfamily,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 6.0,
                                  ),
                                  Text(
                                    Provider.of<UserProvider>(context,
                                            listen: false)
                                        .UserEmail!,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: Constants.fontfamily,
                                        color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              Card(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                color: const Color(0xffebf5f9),
                elevation: 0.0,
                child: ListTile(
                  leading: Icon(Icons.home),
                  title: Text(Languages.of(context)!.home,style: TextStyle( fontFamily: Constants.fontfamily,),),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Card(
                elevation: 0.0,
                color: const Color(0xffebf5f9),
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: ListTile(
                  leading: Icon(Icons.back_hand_outlined),
                  title: Text(Languages.of(context)!.Disclaimer,style: TextStyle( fontFamily: Constants.fontfamily,),),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DisclimarScreen()));
                  },
                ),
              ),
              Card(
                elevation: 0.0,
                color: const Color(0xffebf5f9),
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: ListTile(
                  leading: Icon(Icons.login),
                  title: Text(Languages.of(context)!.LogOut,style: TextStyle( fontFamily: Constants.fontfamily,),),
                  onTap: () {
                    // Navigator.pop(context);
                    showDialog();


                  },
                ),
              ),
              Card(
                elevation: 0.0,
                color: const Color(0xffebf5f9),
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: ListTile(
                  leading: Icon(Icons.delete,),
                  title: Text(Languages.of(context)!.DeleteAccount,style: TextStyle( fontFamily: Constants.fontfamily,),),
                  onTap: () {
                    // Navigator.pop(context);
                    showDeleteDialog();


                  },
                ),
              ),
              SizedBox(
                height: _height * 0.01,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: _width * 0.01,
                ),
                child: Container(
                  color: const Color(0xffebf5f9),
                  margin: EdgeInsets.only(
                    top: _height * 0.05,
                    right: _width * 0.1,
                    left: _width * 0.1,
                  ),
                  child: _createLanguageDropDown(context),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  _createLanguageDropDown(BuildContext context) {
    return Container(
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black),
      ),
      child: DropdownButton<LanguageModel>(
        iconSize: 30,
        underline: SizedBox(),
        isExpanded: true,
        hint: Text(Languages.of(context)!.labelSelectLanguage),
        onChanged: (LanguageModel? language) {
          changeLanguage(context, language!.languageCode);
          UserProvider userProviderlng =
              Provider.of<UserProvider>(this.context, listen: false);
          userProviderlng.setLanguage(language.name);

          print("my_lang: ${userProviderlng.SelectedLanguage}");

          Navigator.pop(context);
        },
        items: LanguageModel.languageList()
            .map<DropdownMenuItem<LanguageModel>>(
              (e) => DropdownMenuItem<LanguageModel>(
                value: e,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      e.flag,
                      style: TextStyle(fontSize: 30),
                    ),
                    Text(e.name)
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void showDialog(){
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(Languages.of(context)!.alert,style: TextStyle(
              fontFamily: Constants.fontfamily
          ),),
          content: Text(Languages.of(context)!.dialogAreyousure,style: TextStyle(
            fontFamily: Constants.fontfamily
          ),),
          actions: [
            CupertinoDialogAction(
                child: Text(Languages.of(context)!.yes,style: TextStyle(
                    fontFamily: Constants.fontfamily
                ),),
                onPressed: ()
                { UserProvider userProvider =
                Provider.of<UserProvider>(this.context, listen: false);

                userProvider.setUserToken("");
                userProvider.setUserEmail("");
                userProvider.setUserName("");
                // userProvider.setLanguage("");
                Phoenix.rebirth(context);
                  Navigator.of(context).pop();
                }
            ),
            CupertinoDialogAction(
              child: Text(Languages.of(context)!.no,style: TextStyle(
                  fontFamily: Constants.fontfamily
              ),),
              onPressed: (){
                Navigator.of(context).pop();
              }
              ,
            )
          ],
        );
      },
    );
  }

  void showDeleteDialog(){
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(Languages.of(context)!.DeleteAccount,style: TextStyle(
              fontFamily: Constants.fontfamily
          ),),
          content: Text(Languages.of(context)!.deleteAccountText,style: TextStyle(
              fontFamily: Constants.fontfamily
          ),),
          actions: [
            CupertinoDialogAction(
                child: Text(Languages.of(context)!.yes,style: TextStyle(
                    fontFamily: Constants.fontfamily
                ),),
                onPressed: ()
                { UserProvider userProvider =
                Provider.of<UserProvider>(this.context, listen: false);

                userProvider.setUserToken("");
                userProvider.setUserEmail("");
                userProvider.setUserName("");
                userProvider.setLanguage("");
                Phoenix.rebirth(context);
                Navigator.of(context).pop();
                }
            ),
            CupertinoDialogAction(
              child: Text(Languages.of(context)!.no,style: TextStyle(
                  fontFamily: Constants.fontfamily
              ),),
              onPressed: (){
                Navigator.of(context).pop();
              }
              ,
            )
          ],
        );
      },
    );
  }

  _sendingMails() async {
    var url = Uri.parse("mailto:n0velflexsupp0rt@gmail.com");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}
