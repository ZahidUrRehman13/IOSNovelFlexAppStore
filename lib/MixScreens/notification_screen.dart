import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {



  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: _height * 0.5,
            left: _width * 0.35,
            child: Center(
              child: Text("No Notifications"),
            ),
          ),
        ],
      ),
    );
  }
}
