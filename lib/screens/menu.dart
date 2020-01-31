import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_homies/widgets/buttons.dart';
import 'package:great_homies/widgets/shapes.dart';
import 'package:stepper_touch/stepper_touch.dart';
import '../main.dart';
import '../services/auth.dart';
import '../themes/maintheme.dart';
import '../widgets/appbar.dart';
import '../widgets/drawer.dart';

//==================This is the Menu for the app==================
class MenuScreen extends StatefulWidget {
  Map mapFoodSite = new Map();

  MenuScreen(this.mapFoodSite);

  @override
  _MenuScreenState createState() => new _MenuScreenState(mapFoodSite);
}

class _MenuScreenState extends State<MenuScreen> {
  Map mapFoodSite = new Map();

  //List Cart
  List lstCart=new List();

  _MenuScreenState(this.mapFoodSite);

  //Keys
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

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
    double size = MediaQuery.of(context).size.width < MediaQuery.of(context).size.height
        ? MediaQuery.of(context).size.width
        : (!kIsWeb) ? MediaQuery.of(context).size.height : MediaQuery.of(context).size.height / 2;

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: myAppTheme.scaffoldBackgroundColor,
        appBar: getAppBar(
            scaffoldKey: scaffoldKey, context: context, strAppBarTitle: mapFoodSite["name"], showBackButton: true),

        //Body
        body: getRestaurants(size),
      ),
    );
  }

  getRestaurants(double size) {
    return FutureBuilder(
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot == null || snapshot.data == null || snapshot.hasData == false) {
          return Center(
              child: Container(
                width: 300,
                height: 300,
                child: FlareActor(
                    "assets/animations/pizza-loading.flr", isPaused: false,
                    alignment: Alignment.center, fit: BoxFit.contain,
                    animation: "animate"
                ),
              )
          );
        } else {
          return ListView.builder(
              padding: EdgeInsets.all(8),
              scrollDirection: MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
                  ? Axis.vertical
                  : Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                //Data
                DocumentSnapshot _ds = snapshot.data[index];

                //Check if this Menu item is added to the Cart
                Map mapMenuItem= new Map();

                //Get the Name
                lstCart.forEach((element) {
                  Map mapTMP = element;
                  if (mapTMP["name"] == _ds.data["name"]) {
                    //This Item Exists in the Cart
                    mapMenuItem = mapTMP;
                  }
                });

                return Card(
                  shape: roundedShape(),
                  color: myAppTheme.cardColor,
                  margin: EdgeInsets.all(2),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        //Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: 100,
                            width: 100,
                            child: Image.network(
                              _ds.data["photo"],
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),

                        //Content
                        Container(
                          width: 180,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              //Food Place Name
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _ds.data["name"],
                                  style: myAppTheme.textTheme.caption,
                                ),
                              ),

                              //Address
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                child: Text(_ds.data["description"], style: myAppTheme.textTheme.body2),
                              ),

                              //Rating
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                child: Text("Price: " + _ds.data["price"].toString(), style: myAppTheme.textTheme.body2),
                              ),
                            ],
                          ),
                        ),


                        //Add Button
                        mapMenuItem != null && mapMenuItem.length > 0 && mapMenuItem["repeat"] > 0 ?
                        Container(
                          width: size * 0.22,
                          height: size * 0.22,
                          child: Theme(
                            data: myAppTheme,
                            child: StepperTouch(
                              withSpring: true,
                              initialValue: mapMenuItem.containsKey("repeat") ? mapMenuItem["repeat"] : 0,
                              onChanged: (int value) {
                                mapMenuItem["repeat"] = mapMenuItem["repeat"] + 1;
                                setState(() {
                                  lstCart.add(mapMenuItem);
                                });
                              },
                            ),
                          ),
                        ) : primaryRaisedButton(
                            context: context,
                            text: "Add",
                            textColor: Colors.white,
                            onPressed: () {
                              Map mapThisMenuItem = _ds.data;
                              mapThisMenuItem["repeat"] = 1;
                              setState(() {
                                lstCart.add(mapThisMenuItem);
                              });
                            }
                        ),
                      ],
                    ),
                  ),
                );
              });
        }
      },
      future: getMenuContent(),
    );
  }

  Future<List> getMenuContent() async {
    //Speed up the fucking loading
    await Future.delayed(Duration(seconds: 2));

    QuerySnapshot _qs = await Firestore.instance
        .collection("Restaurants")
        .document(mapFoodSite["name"])
        .collection("Menu")
        .getDocuments();
    return _qs.documents;
  }
}
