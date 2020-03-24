import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';
import 'package:great_homies/services/auth.dart';
import 'package:great_homies/widgets/buttons.dart';
import 'package:great_homies/widgets/shapes.dart';
import '../../main.dart';
import '../../widgets/appbar.dart';

//==================This is the Menu for the app==================
class OrderScreen extends StatefulWidget {
  String strOrderID;

  OrderScreen(this.strOrderID);

  @override
  _OrderScreenState createState() => new _OrderScreenState(strOrderID);
}

class _OrderScreenState extends State<OrderScreen> {
  String strOrderID;

  _OrderScreenState(this.strOrderID);

  //Keys
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: myAppTheme.scaffoldBackgroundColor,
          appBar:
              getAppBar(scaffoldKey: scaffoldKey, context: context, strAppBarTitle: "Your Order", showBackButton: true),

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
                List lstItems = snapshot.data["Items"];

                return ListView(
                  padding: EdgeInsets.all(8),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        snapshot.data["restaurant"],
                        style: myAppTheme.textTheme.headline2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Order ID: " + snapshot.data["timestamp"],
                        style: myAppTheme.textTheme.bodyText1,
                      ),
                    ),

                    //Ordered Items
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Ordered items", style: myAppTheme.textTheme.caption),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 200,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: lstItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            Map mapItem = lstItems[index];

                            return Card(
                              shape: roundedShape(),
                              color: myAppTheme.cardColor,
                              margin: EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  //Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Container(
                                      height: 80,
                                      width: 100,
                                      child: Image.network(
                                        mapItem["photo"],
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),

                                  //Content
                                  Container(
                                    height: 70,
                                    width: 120,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        //Food Place Name
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          height: 40,
                                          width: 100,
                                          child: Text(
                                            mapItem["name"],
                                            style: myAppTheme.textTheme.caption,
                                          ),
                                        ),

                                        //Price
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                          child: Text("₹" + mapItem["price"].toString(),
                                              style: myAppTheme.textTheme.bodyText2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),


                    //Total Price
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Total Price: ", style: myAppTheme.textTheme.caption),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("₹" + snapshot.data["total"].toString(), style: myAppTheme.textTheme.bodyText1),
                    ),

                    //Tracking
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Tracking: ", style: myAppTheme.textTheme.caption),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                          Text("Status: " + snapshot.data["status description"], style: myAppTheme.textTheme.bodyText1),
                    ),
                    RoundedProgressBar(
                        childLeft: Icon(Icons.restaurant, color: Colors.white),
                        percent: snapshot.data["status value"] + 0.0,
                        theme: RoundedProgressBarTheme.red),

                    //Back
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
