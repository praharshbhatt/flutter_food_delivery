import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:great_homies/screens/chef.dart';
import 'package:great_homies/screens/menu.dart';
import 'package:great_homies/widgets/shapes.dart';
import '../main.dart';
import '../services/auth.dart';
import '../themes/maintheme.dart';
import '../widgets/appbar.dart';
import '../widgets/drawer.dart';

//==================This is the Homepage for the app==================
String strAppBarTitle = "Restaurants in your area";

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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

    //For Refreshing the theme
    if (userProfile.containsKey("Theme"))
      myAppTheme = userProfile["Theme"] == "Light Theme"
          ? getMainThemeWithBrightness(context, Brightness.light)
          : getMainThemeWithBrightness(context, Brightness.dark);

    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: myAppTheme.scaffoldBackgroundColor,
        appBar: getAppBar(
            scaffoldKey: scaffoldKey, context: context, strAppBarTitle: strAppBarTitle, showBackButton: false),

        //drawer
        drawer: getDrawer(context, scaffoldKey),

        //Body
        body: ListView(
//          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Top Chefs of the week
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text("Top Chefs of the week", style: myAppTheme.textTheme.caption, textAlign: TextAlign.left,),
            ),
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.22,
              child: getChefs(size),
            ),

            //Restaurants
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text("Restaurants", style: myAppTheme.textTheme.caption, textAlign: TextAlign.left,),
            ),
            Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.55,
                child: getRestaurants(size))
          ],
        ),
      ),
    );
  }

  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //

  //Get Top Chefs of the week
  getChefs(double size) {
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
          return ListView.builder(
              padding: EdgeInsets.all(8),
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                //Data
                DocumentSnapshot _ds = snapshot.data[index];
                return InkWell(
                  child: Card(
                    shape: roundedShape(),
                    color: myAppTheme.cardColor,
                    margin: EdgeInsets.all(2),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          //Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                                height: 90,
                                width: 90,
                                child: Hero(
                                  tag: _ds.data["photo"] ?? _ds.data["name"],
                                  child: CircleAvatar(
                                    backgroundImage: Image.network(
                                      _ds.data["photo"] ??
                                          "https://cdn2.iconfinder.com/data/icons/food-restaurant-1/128/flat-11-512.png",
                                      fit: BoxFit.cover,
                                    ).image,
                                  ),
                                )),
                          ),

                          //Name
                          Hero(
                            tag: _ds.data["name"] ?? "",
                            child: Text(
                              _ds.data["name"] ?? "",
                              style: myAppTheme.textTheme.caption,
                            ),
                          ),

                          //Rating
                          Text(_ds.data["rating"].toString() + " ⭐" ?? "-",
                              style: myAppTheme.textTheme.bodyText1),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChefScreen(_ds.data)),
                    );
                  },
                );
              });
        }
      },
      future: getChefContent(),
    );
  }

  Future<List> getChefContent() async {
    QuerySnapshot _qs = await Firestore.instance.collection("Chef").getDocuments();
    return _qs.documents;
  }

  //Get all the restaurants
  getRestaurants(double size) {
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
          return ListView.builder(
              padding: EdgeInsets.all(8),
              scrollDirection: MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
                  ? Axis.vertical
                  : Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                //Data
                DocumentSnapshot _ds = snapshot.data[index];

                List lstPhotos = new List();
                if (_ds.data.containsKey("Photos")) lstPhotos = _ds.data["Photos"];

                return InkWell(
                  child: Card(
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
                            child: Hero(
                              tag: lstPhotos.length > 0
                                  ? lstPhotos[0] ?? _ds.data["name"]
                                  : _ds.data["name"],
                              child: Container(
                                width: size * 0.35,
                                height: 90,
                                child: Image.network(
                                  lstPhotos.length > 0
                                      ? lstPhotos[0] ?? ""
                                      : "https://cdn2.iconfinder.com/data/icons/food-restaurant-1/128/flat-11-512.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),

                          Container(
                            width: size * 0.5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                //Food Place Name
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _ds.data["name"] ?? "",
                                    style: myAppTheme.textTheme.caption,
                                  ),
                                ),

                                //Address
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                  child: Text(_ds.data["address"] ?? "", style: myAppTheme.textTheme.bodyText2),
                                ),

                                //Rating
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                  child: Text("Ratings: " + _ds.data["rating"].toString() ?? "-" + " stars",
                                      style: myAppTheme.textTheme.bodyText2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuScreen(_ds.data)),
                    );
                  },
                );
              });
        }
      },
      future: getRestaurantContent(),
    );
  }

  Future<List> getRestaurantContent() async {
    QuerySnapshot _qs = await Firestore.instance.collection("Restaurants").getDocuments();
    return _qs.documents;
  }
}
