import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/account/signin.dart';
import 'screens/homeScreen.dart';
import 'services/auth.dart';
import 'themes/maintheme.dart';

//==================This file is the Splash Screen for the app==================

BuildContext _context;
AuthService authService;
ThemeData myAppTheme;

void main() {
  runApp(MaterialApp(home: new SplashScreen()));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => new _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    //Call the Class so that the constructor is called
    authService = new AuthService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    //Initialize the theme
    myAppTheme = getMainThemeWithBrightness(context, Brightness.light);

    return MaterialApp(
      theme: myAppTheme,
      home: Scaffold(
          backgroundColor: Colors.black,
          body: Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/images/icon.png",
                    alignment: Alignment.center,
                    width: 100,
                    height: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Great Homies\nGreat food from home at home",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

Future<void> mainNavigationPage() async {

  if (blIsSignedIn || kIsWeb) {
    if (userProfile.containsKey("Theme"))
      myAppTheme = userProfile["Theme"] == "Dark Theme"
          ? getMainThemeWithBrightness(_context, Brightness.dark)
          : getMainThemeWithBrightness(_context, Brightness.light);

    Navigator.pushReplacement(
      _context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  } else {
    Navigator.pushReplacement(
      _context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }
}
