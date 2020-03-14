import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_homies/services/auth.dart';
import 'package:great_homies/widgets/buttons.dart';
import '../main.dart';
import '../widgets/appbar.dart';
import 'order.dart';

//==================This is the Menu for the app==================
class CheckoutScreen extends StatefulWidget {
  String strOrderID;

  CheckoutScreen(this.strOrderID);

  @override
  _CheckoutScreenState createState() => new _CheckoutScreenState(strOrderID);
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String strOrderID;

  _CheckoutScreenState(this.strOrderID);

  //Keys
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
        ? MediaQuery.of(context).size.width
        : (!kIsWeb) ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 2;

    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: myAppTheme.scaffoldBackgroundColor,
          appBar: getAppBar(
              scaffoldKey: scaffoldKey, context: context, strAppBarTitle: "Order Confirmation", showBackButton: true),

          //Body
          body: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot == null || snapshot.data == null || snapshot.hasData == false) {
                return Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    child: FlareActor("assets/animations/pizza-loading.flr",
                        isPaused: false, alignment: Alignment.center, fit: BoxFit.contain, animation: "animate"),
                  ),
                );
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(snapshot.data["restaurant"], style: myAppTheme.textTheme.headline2),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Order ID: " + snapshot.data["timestamp"], style: myAppTheme.textTheme.caption),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Payment method: Cash", style: myAppTheme.textTheme.bodyText1),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Total: " + snapshot.data["total"].toString(), style: myAppTheme.textTheme.bodyText1),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Delivering to: " + snapshot.data["address"].toString(),
                          style: myAppTheme.textTheme.bodyText1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: primaryRaisedIconButton(
                              context: context,
                              text: "Back",
                              color: myAppTheme.primaryColor,
                              textColor: Colors.white,
                              icon: Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () async {
                                Navigator.of(context).pop();
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: primaryRaisedIconButton(
                              context: context,
                              text: "Track my order",
                              color: myAppTheme.primaryColor,
                              textColor: Colors.white,
                              icon: Icon(Icons.add_shopping_cart, color: Colors.white),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OrderScreen(strOrderID)),
                                );
                              }),
                        )
                      ],
                    )
                  ],
                );
              }
            },
            future: getOrder(),
          )),
    );
  }

  getOrder() async {
    return (await Firestore.instance
            .collection("Users")
            .document(userProfile["email"])
            .collection("Orders")
            .document(strOrderID)
            .get())
        .data;
  }
}
