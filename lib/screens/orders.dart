import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_homies/screens/checkout.dart';
import 'package:great_homies/services/auth.dart';
import 'package:great_homies/widgets/buttons.dart';
import '../main.dart';
import '../widgets/appbar.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => new _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
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
              scaffoldKey: scaffoldKey, context: context, strAppBarTitle: "Past Orders", showBackButton: true),

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
                List lstPastOrders = snapshot.data;

                return ListView.builder(
                    itemCount: lstPastOrders.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot _ds = lstPastOrders[index];

                      return ListTile(
                        title: Text(
                          "Order from " + _ds.data["restaurant"].toString(),
                          style: myAppTheme.textTheme.caption,
                        ),
                        subtitle: Text(
                          "Total: ₹" + _ds.data["total"].toString(),
                          style: myAppTheme.textTheme.bodyText1,
                        ),
                        trailing: Icon(Icons.arrow_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CheckoutScreen(_ds.data["timestamp"].toString())),
                          );
                        },
                      );
                    });
              }
            },
            future: getOrders(),
          )),
    );
  }

  getOrders() async {
    return (await Firestore.instance
            .collection("Users")
            .document(userProfile["email"])
            .collection("Orders")
            .getDocuments())
        .documents;
  }
}
