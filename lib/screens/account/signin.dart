import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../main.dart';
import '../../widgets/buttons.dart';
import '../../widgets/dialogboxes.dart';
import '../homeScreen.dart';

//==================This is the Login Screen for the app==================
class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => new _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  //Animation
  AnimationController _animController;
  Animation<Offset> _animOffset;

  @override
  void initState() {
    //For animation
    _animController = AnimationController(vsync: this, duration: Duration(milliseconds: 3000));
    final curve = CurvedAnimation(curve: Curves.decelerate, parent: _animController);
    _animOffset = Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(curve);

    Timer(Duration(milliseconds: 500), () {
      _animController.forward();
    });

    super.initState();
  }

  @override
  void dispose() {
    //Animation
    _animController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
        ? MediaQuery.of(context).size.width
        : (!kIsWeb) ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 2;

    return SafeArea(
      child: Scaffold(
        backgroundColor: myAppTheme.backgroundColor,
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  //Title
                  Padding(
                      padding: const EdgeInsets.fromLTRB(35, 50, 5, 20),
                      child: FadeTransition(
                        child: SlideTransition(
                          position: _animOffset,
                          child: Text("Hello there!", style: myAppTheme.textTheme.title, textAlign: TextAlign.center),
                        ),
                        opacity: _animController,
                      )),

                  //Description
                  Padding(
                      padding: const EdgeInsets.all(35),
                      child: FadeTransition(
                        child: SlideTransition(
                          position: _animOffset,
                          child: Text(
                              "Let us get started by signing into great_homies with Google.\n\nOnce you are logged in, your prefrences will get saved, and you will be able to create your custom breathing patterns!",
                              style: myAppTheme.textTheme.caption.copyWith(fontWeight: FontWeight.normal),
                              textAlign: TextAlign.left),
                        ),
                        opacity: _animController,
                      )),
                ],
              ),

              //Get the login Button
              Padding(padding: const EdgeInsets.all(40), child: getLogInButton())
            ],
          ),
        ),
      ),
    );
  }

  //Get the login button
  getLogInButton() {
    return primaryRaisedButton(
      context: context,
      text: "Log In using Google",
      textColor: myAppTheme.backgroundColor == Colors.white ? Colors.white : Colors.black,
      onPressed: () {
        //LOGIN USING GOOGLE HERE
        showLoading(context);

        authService.googleSignIn().then((user) {
          if (user == null) {
            //Login failed
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text("Failed to log in!"),
                  content: new Text(
                      "Please make sure your Google Account is usable. Also make sure that you have a active internet connection, and try again."),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            //Navigate to the HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        });
//        Navigator.of(context, rootNavigator: true).pop();
      },
    );
  }
}
