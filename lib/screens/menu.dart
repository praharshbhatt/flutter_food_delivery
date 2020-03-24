import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_homies/services/auth.dart';
import 'package:great_homies/widgets/buttons.dart';
import 'package:great_homies/widgets/dialogboxes.dart';
import 'package:great_homies/widgets/shapes.dart';
import 'package:great_homies/widgets/stepper_switch.dart';
import '../main.dart';
import '../widgets/appbar.dart';
import 'order_management/order.dart';
import 'order_management/checkout.dart';

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
  List lstCart = new List();

  double dbTotal = 0;

  _MenuScreenState(this.mapFoodSite);

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
        appBar: getAppBar(scaffoldKey: scaffoldKey, context: context, strAppBarTitle: "Menu", showBackButton: true),

        //Body
        body: getMenu(size),
      ),
    );
  }

  getMenu(double size) {
    return FutureBuilder(
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
          List lstPhotos = new List();
          if (mapFoodSite.containsKey("Photos")) lstPhotos = mapFoodSite["Photos"];

          return Column(
            children: <Widget>[
              //Title and Cover Photo
              Expanded(
                flex: 3,
                child: Column(
                  children: <Widget>[
                    //Title
                    Text(mapFoodSite["name"], style: myAppTheme.textTheme.caption.copyWith(fontSize: size * 0.07)),

                    //Cover Photo
                    lstPhotos.length > 0
                        ? Hero(
                            tag: lstPhotos.length > 0 ? lstPhotos[0] ?? mapFoodSite["name"] : mapFoodSite["name"],
                            child: CarouselSlider(
                              height: MediaQuery.of(context).size.height * 0.22,
                              autoPlay: true,
                              autoPlayInterval: Duration(seconds: 2),
                              autoPlayAnimationDuration: Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              pauseAutoPlayOnTouch: Duration(seconds: 10),
                              enlargeCenterPage: true,
                              items: lstPhotos.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Image.network(i);
                                  },
                                );
                              }).toList(),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),

              //Menu
              Expanded(
                flex: 5,
                child: ListView.builder(
                    padding: EdgeInsets.all(8),
                    scrollDirection: MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
                        ? Axis.vertical
                        : Axis.horizontal,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      //Data
                      DocumentSnapshot _ds = snapshot.data[index];

                      //Check if this Menu item is added to the Cart
                      Map mapMenuItem = new Map();

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
                                width: 170,
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
                                      child: Text(_ds.data["description"], style: myAppTheme.textTheme.bodyText2),
                                    ),

                                    //Rating
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                      child: Text("₹" + _ds.data["price"].toString(),
                                          style: myAppTheme.textTheme.bodyText2),
                                    ),
                                  ],
                                ),
                              ),

                              //Add Button
                              mapMenuItem != null && mapMenuItem.length > 0 && mapMenuItem["repeat"] > 0
                                  ? Container(
                                      width: size * 0.2,
                                      height: size * 0.2,
                                      child: StepperTouch(
                                        withSpring: true,
                                        primaryColor: myAppTheme.primaryColor,
                                        textColor: Colors.white,
                                        initialValue: mapMenuItem.containsKey("repeat") ? mapMenuItem["repeat"] : 0,
                                        onChanged: (int value) {
                                          //Update the cart
                                          if (value == 0) {
                                            setState(() {
                                              //Update the total price
                                              double dbDishPrice = (_ds.data["price"] ?? 0) + 0.0;
                                              dbTotal = dbTotal - (dbDishPrice);

                                              //Remove the item from the cart
                                              mapMenuItem["repeat"] = 0;

                                              lstCart.removeWhere((element) {
                                                Map mapTMP = element;
                                                if (mapTMP["name"] == _ds.data["name"]) {
                                                  return true;
                                                } else {
                                                  return false;
                                                }
                                              });
                                            });
                                          } else {
                                            setState(() {
                                              //Change the quantity in the cart
                                              mapMenuItem["repeat"] = value;
                                              lstCart.add(mapMenuItem);

                                              //Update the total price
                                              double dbDishPrice = (_ds.data["price"] ?? 0) + 0.0;
                                              dbTotal = dbTotal + dbDishPrice;
                                            });
                                          }
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: size * 0.2,
                                      child: primaryRaisedButton(
                                          context: context,
                                          text: "Add",
                                          textColor: Colors.white,
                                          onPressed: () {
                                            setState(() {
                                              //Update the total price
                                              double dbDishPrice = (_ds.data["price"] ?? 0) + 0.0;
                                              dbTotal = dbTotal + (dbDishPrice);

                                              //Update the Cart
                                              Map mapThisMenuItem = _ds.data;
                                              mapThisMenuItem["repeat"] = 1;

                                              //Add this dish to the cart
                                              lstCart.add(mapThisMenuItem);
                                            });
                                          }),
                                    ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),

              //Total
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Total: ₹" + dbTotal.toString(),
                      style: myAppTheme.textTheme.caption,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),

              //Checkout
              ButtonTheme(
                minWidth: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: primaryRaisedIconButton(
                      context: context,
                      text: "Checkout",
                      color: myAppTheme.primaryColor,
                      textColor: Colors.white,
                      icon: Icon(Icons.add_shopping_cart, color: Colors.white),
                      onPressed: () async {
                        //Checkout here
                        if (lstCart.length > 0) {
                          print(lstCart.toString());

                          showLoading(context);

                          //Set the order
                          String strOrderID = DateTime.now().toString();
                          await Firestore.instance
                              .collection("Users")
                              .document(userProfile["email"])
                              .collection("Orders")
                              .document(strOrderID)
                              .setData({
                            "Items": lstCart,
                            "restaurant": mapFoodSite["name"],
                            "timestamp": strOrderID,
                            "total": dbTotal,
                            "status description": "Preparing Order",
                            "status value": 10.0,
                            "address": userProfile["address"] ?? "1, house, near place, city",
                            "user name": userProfile["name"],
                            "user email": userProfile["email"]
                          });
                          Navigator.of(context, rootNavigator: true).pop();

                          //Go to the Checkout screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => CheckoutScreen(strOrderID)),
                          );
                        } else {
                          showSnackBar(scaffoldKey: scaffoldKey, text: "No Items selected!");
                        }
                      }),
                ),
              )
            ],
          );
        }
      },
      future: getMenuContent(),
    );
  }

  //Get Menu
  Future<List> getMenuContent() async {
    QuerySnapshot _qs = await Firestore.instance
        .collection("Restaurants")
        .document(mapFoodSite["name"])
        .collection("Menu")
        .getDocuments();
    return _qs.documents;
  }
}
