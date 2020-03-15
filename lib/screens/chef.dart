import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_homies/widgets/appbar.dart';
import 'package:great_homies/widgets/buttons.dart';

import '../main.dart';
import 'menu.dart';

//==================This is the Menu for the app==================
class ChefScreen extends StatefulWidget {
  Map mapChef;

  ChefScreen(this.mapChef);

  @override
  _ChefScreenState createState() => new _ChefScreenState(mapChef);
}

class _ChefScreenState extends State<ChefScreen> {
  Map mapChef;

  _ChefScreenState(this.mapChef);

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
            scaffoldKey: scaffoldKey,
            context: context,
            strAppBarTitle: mapChef["name"] ?? "Chef",
            showBackButton: true),

        //Body
        body: ListView(
          padding: EdgeInsets.all(12),
          children: <Widget>[
            //Image
            Hero(
              tag: mapChef["photo"] ?? mapChef["name"],
              child: Image.network(
                mapChef["photo"] ?? "https://cdn2.iconfinder.com/data/icons/food-restaurant-1/128/flat-11-512.png",
                fit: BoxFit.cover,
              ),
            ),

            //Name
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Hero(
                tag: mapChef["name"] ?? "",
                child: Text(
                  mapChef["name"] ?? "",
                  style: myAppTheme.textTheme.headline2,
                ),
              ),
            ),

            //Rating
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Rating: " + mapChef["rating"].toString() + " ⭐" ?? "-",
                          style: myAppTheme.textTheme.bodyText1),
                    ),
                  ],
                ),
              ],
            ),

            //Customers Served
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(mapChef["customers served"].toString() + " Customers served",
                      style: myAppTheme.textTheme.bodyText1),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                mapChef["description"] ?? "",
                style: myAppTheme.textTheme.bodyText1.copyWith(color: Colors.grey),
              ),
            ),

            mapChef.containsKey("restaurant")
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: primaryRaisedIconButton(
                        context: context,
                        text: "Take me to their restaraunt",
                        color: myAppTheme.primaryColor,
                        textColor: Colors.white,
                        icon: Icon(Icons.fastfood, color: Colors.white),
                        onPressed: () async {
                          //Get the Restaurant data
                          DocumentSnapshot _ds =
                              await Firestore.instance.collection("Restaurants").document(mapChef["restaurant"]).get();

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MenuScreen(_ds.data)),
                          );
                        }),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}