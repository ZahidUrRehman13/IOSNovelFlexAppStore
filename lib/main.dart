import 'dart:async';
import 'dart:io';
import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:novelflex/UserAuthScreen/SignUpScreens/SignUpScreen_Second.dart';
import 'package:novelflex/localization/Language/languages.dart';
import 'package:novelflex/tab_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Provider/UserProvider.dart';
import 'Provider/VariableProvider.dart';
import 'TabScreens/profile_screen.dart';
import 'UserAuthScreen/login_screen.dart';
import 'UserAuthScreen/SignUpScreens/signUpScreen_First.dart';
import 'localization/locale_constants.dart';
import 'localization/localizations_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

//NovelFlex
Future<void> main() async {
  // HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  MobileAds.instance.initialize();
  runApp(Phoenix(child: MyApp(sharedPreferences: prefs)));
}


class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

class MyApp extends StatefulWidget {
  late SharedPreferences sharedPreferences;

  MyApp({super.key, required this.sharedPreferences});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<InternetConnectionStatus>(
      initialData: InternetConnectionStatus.connected,
      create: (_) {
        return InternetConnectionCheckerPlus().onStatusChange;
      },
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<UserProvider>(
              create: (context) => UserProvider(widget.sharedPreferences)),
          ChangeNotifierProvider<VariableProvider>(
              create: (context) => VariableProvider()),
        ],
        child: MaterialApp(
          locale: _locale,
          supportedLocales: const [
            Locale('en', ''),
            Locale('ar', ''),
          ],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode &&
                  supportedLocale.countryCode == locale?.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          debugShowCheckedModeBanner: false,
          home: SplashFirst(),
          routes: {
            // 'slider_screen': (context) => SliderScreen(),
            'tab_screen': (context) => TabScreen(),
            'login_screen': (context) => LoginScreen(),
            'profile_screen': (context) => Profile_Screen(),
          },
        ),
      ),
    );
  }
}

class SplashFirst extends StatefulWidget {
  const SplashFirst({Key? key}) : super(key: key);

  @override
  State<SplashFirst> createState() => _SplashFirstState();
}

class _SplashFirstState extends State<SplashFirst> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (context.read<UserProvider>().UserToken == '' ||
          context.read<UserProvider>().UserToken == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SplashPage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => TabScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: const Color(0xffebf5f9),
    );
  }
}





class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {


  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset('assets/quotes_data/bg_login.png',fit: BoxFit.fill,),
          ),
          Positioned(
            top: _height * 0.2,
            // left: _width*0.5,
            child: Image.asset('assets/quotes_data/NoPath.png'),
          ),
          Positioned(
            top: _height * 0.4,
            left: _width * 0.2,
            child: Container(
                width: 256,
                height: 2,
                decoration: BoxDecoration(color: const Color(0xff333333))),
          ),
          Positioned(
            top: _height * 0.45,
            left: _width * 0.25,
            child: Text(Languages.of(context)!.labelWelcome,
                style: const TextStyle(
                    color: const Color(0xff101010),
                    fontWeight: FontWeight.w700,
                    fontFamily: "Lato",
                    fontStyle: FontStyle.normal,
                    fontSize: 20.0),
                textAlign: TextAlign.center),
          ),
          Positioned(
              top: _height * 0.7,
              left: _width * 0.1,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                },
                child: Container(
                  width: 320,
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x24000000),
                            offset: Offset(0, 7),
                            blurRadius: 14,
                            spreadRadius: 0)
                      ],
                      color: const Color(0xff3a6c83)),
                  child: Center(
                    child: Text(
                      Languages.of(context)!.login,
                      style: const TextStyle(
                          color:  const Color(0xffffffff),
                          fontWeight: FontWeight.w700,
                          fontFamily: "Lato",
                          fontStyle:  FontStyle.normal,
                          fontSize: 14.0
                      ),
                    ),
                  ),
                ),
              )),
          Positioned(
            top: _height * 0.8,
            left: _width * 0.1,
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SignUpScreen_Second()));
              },
              child: Container(
                width: 320,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: const Color(0xff3a6c83),
                      width: 2,
                    )),
                child: Center(
                  child: Text(
                    Languages.of(context)!.signup,
                    style: const TextStyle(
                        color: const Color(0xff3a6c83),
                        fontWeight: FontWeight.w700,
                        fontFamily: "Lato",
                        fontStyle: FontStyle.normal,
                        fontSize: 14.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
