import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/PushNotificationService.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/app_assets.dart';
import 'package:eshop_multivendor/Model/Model.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/newSellerModel.dart';
import 'package:eshop_multivendor/Model/recentSearchModel.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Chat.dart';
import 'package:eshop_multivendor/Screen/Favorite.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/MyOrder.dart';
import 'package:eshop_multivendor/Screen/MyProfile.dart';
import 'package:eshop_multivendor/Screen/Product_Detail.dart';
import 'package:eshop_multivendor/Screen/SubCategory.dart';
import 'package:eshop_multivendor/Screen/posts.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'All_Category.dart';
import 'Cart.dart';
import 'ChatRestaurant.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Sale.dart';
import 'Search.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;


class RestaurantDashboard extends StatefulWidget {
  final String title;
  final String? subCatName;
  final String? subCatAddress;
  final String? subCatLogo;
  final String? seller_email;
  final String? seller_fuid;
  final String? seller_mob;
  final sellerId;
  final catId;
  final sellerData;
  final showAll;
  const RestaurantDashboard({Key? key,
    required this.title,
     this.subCatName,
     this.subCatAddress,
     this.subCatLogo,
     this.seller_email,
     this.seller_fuid,
     this.seller_mob,
    this.sellerId,
    this.sellerData,
    this.catId,
  this.showAll}) : super(key: key);

  @override
  State<RestaurantDashboard> createState() => _RestaurantDashboardState();
}

class _RestaurantDashboardState extends State<RestaurantDashboard> with TickerProviderStateMixin {
  int _selBottom = 0;
  late TabController _tabController;
  bool _isNetworkAvail = true;
  Date2? sellerD;
  Room? room_chat;

  @override
  void initState() {
    sellerD = Date2.fromJson(jsonDecode(widget.sellerData));
    log("seller data in dashboard_rest ${sellerD?.userId}  ${widget.sellerData.runtimeType}");

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light,));
    super.initState();

///for firebase  chat
    //callChat();
///----------------------

    initDynamicLinks();
    _tabController = TabController(
      length: 4,
      initialIndex: 0,
      vsync: this,
    );

    final pushNotificationService = PushNotificationService(
        context: context, tabController: _tabController);
    pushNotificationService.initialise();

    _tabController.addListener(
          () {
        // Future.delayed(Duration(seconds: 0)).then(
        //       (value) {
        //     if (_tabController.index == 3) {
        //       if (CUR_USERID == null) {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => Login(),
        //           ),
        //         );
        //         _tabController.animateTo(0);
        //       }
        //     }
        //   },
        // );

        setState(
              () {
            _selBottom = _tabController.index;
          },
        );
      },
    );




  }

  void initDynamicLinks() async {

    await callChat();
    /*FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          final Uri? deepLink = dynamicLink?.link;

          if (deepLink != null) {
            if (deepLink.queryParameters.length > 0) {
              int index = int.parse(deepLink.queryParameters['index']!);

              int secPos = int.parse(deepLink.queryParameters['secPos']!);

              String? id = deepLink.queryParameters['id'];

              String? list = deepLink.queryParameters['list'];

              getProduct(id!, index, secPos, list == "true" ? true : false);
            }
          }
        }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });*/

    /*final PendingDynamicLinkData? data =
    await FirebaseDynamicLinks.instance.getInitialLink();*/
    //final Uri? deepLink = data?.link;
    /*if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        // String list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, true);
      }
    }*/
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
        await post(getProductApi, headers: headers, body: parameter)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<Product> items = [];

          items =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProductDetail(
                index: list ? int.parse(id) : index,
                model: list
                    ? items[0]
                    : sectionList[secPos].productList![index],
                secPos: secPos,
                list: list,
              )));
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      }
    }
  }


  ///for firebase chat
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool chatLoading = false;
  bool iconTapped = false;
  String? User_email;

  getSharedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User_email = prefs.getString('user_email');
     FirebaseChatCore.instance.getFirebaseFirestore();


    print("user email is ${User_email}");
  }

  callChat() async {
    await getSharedData();

    setState(() {
      iconTapped = true;
    });

      var otherUser1 = types.User(
      firstName: sellerD?.username ?? '',
      id: sellerD?.fuid.toString().trim() ?? '',
      imageUrl: 'https://i.pravatar.cc/300?u=${widget.seller_email}',
      lastName: "",
    );

    print("otherUser1 is == $otherUser1  ");
    print("otherUser1 is == $otherUser1  ");

    _handlePressed(otherUser1, context, sellerD?.fuid.toString() ?? '');
  }


  _handlePressed( types.User otherUser, BuildContext context, String fcmID) async {
    if(fcmID == null || fcmID == ""){
      print("fuid is null");
      setState(() {
        chatLoading = false;
        iconTapped = false;
      });
      //setSnackbar(getTranslated(context, 'availMsg')!, context);
    }else if(User_email == null || User_email == ""){
      print("User_email is null");
      setState(() {
        chatLoading = false;
        iconTapped = false;
      });
     // setSnackbar(getTranslated(context, 'emailNullMsg')!, context);
    }else{
      print("mai aa gya");

        final room = await FirebaseChatCore.instance.createRoom(otherUser);
        room_chat = room;
        //
        // print("room is ${room_chat}");
        setState(() {
          chatLoading = false;
          iconTapped = false;
        });



      /*await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRestaurant(
            room: room,
            fcm: fcmID,
            id: sellerD!.userId!,
            name: sellerD!.username!,
            number: sellerD!.mobile!,
            seller_id: sellerD!.id!,
          ),
        ),
      );*/
    }

  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_tabController.index != 0) {
          _tabController.animateTo(0);
          return false;
        }
        return true;
      },
      child:

      Scaffold(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        // appBar: _getAppBar(),
        body:
        // iconTapped==true? Center(child: CircularProgressIndicator()):
        TabBarView(
          physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            widget.showAll ?
            SubCategory(
              title: widget.title,
              sellerData: widget.sellerData,
              sellerId: widget.sellerId,
              catId: widget.catId,
              subCatName: widget.subCatName,
              subCatAddress: widget.subCatAddress,
              subCatLogo: widget.subCatLogo,
            )
          : SubCategory(
              title: widget.title,
            ),
            // AllCategory(),
            PostsScreen(sellerId: widget.sellerId,),
            MyOrder(),
            // Chat(),

            (room_chat == null || sellerD?.fuid.toString() == null || sellerD?.username== null || sellerD?.mobile == null || sellerD?.userId == null || sellerD?.id == null) ?? true ?
               Center(child: CircularProgressIndicator(),)
                : ChatRestaurant(
              room: room_chat!,
              fcm: sellerD?.fuid.toString(),
              id: sellerD!.userId!,
              name: sellerD!.username!,
              number: sellerD!.mobile!,
              seller_id: sellerD!.id!,
            )
            /*ChatRestaurant(id: '${sellerD?.userId}', fcm: sellerD?.fuid.toString(), name: sellerD?.username.toString() ?? '', room: room_chat!, seller_id: sellerD?.id ?? '', number: sellerD?.mobile ?? '',)*/

          ],
        ),
        //fragments[_selBottom],
        // bottomNavigationBar: _getBottomBar(),
        bottomNavigationBar: _getBottomNavigator(),
      ),
    );
  }



  AppBar _getAppBar() {
    String? title;
    if (_selBottom == 1)
      title = getTranslated(context, 'OFFER');
    //  title = getTranslated(context, 'CATEGORY');
    else if (_selBottom == 2)
      title = getTranslated(context, 'PROFILE');
    //title = getTranslated(context, 'OFFER');
    else if (_selBottom == 3) title = getTranslated(context, 'ABOUT_LBL');
    // title = getTranslated(context, 'MYBAG');
    // else if (_selBottom == 4)
    //   title = getTranslated(context, 'PROFILE');

    return AppBar(
      centerTitle: _selBottom == 0 ? true : false,
      title: _selBottom == 0
          ? Image.asset(
        // 'assets/images/titleicon.png',
        MyAssets.normal_logo,
        //height: 40,

        // width: 150,
        height: 50,

        // color: colors.primary,
        // width: 45,
      )
          : Text(
        title!,
        style: TextStyle(
            color: colors.primary, fontWeight: FontWeight.normal),
      ),

      leading: _selBottom == 0
          ? InkWell(
        child: Center(
            child: SvgPicture.asset(
              imagePath + "search.svg",
              height: 20,
              color: colors.primary,
            )),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Search(),
              ));
        },
      )
          : null,
      // iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        _selBottom == 0 || _selBottom == 4
            ? Container()
            : IconButton(
            icon: SvgPicture.asset(
              imagePath + "search.svg",
              height: 20,
              color: colors.primary,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Search(),
                  ));
            }),
        _selBottom == 4
            ? Container()
            : IconButton(
          icon: SvgPicture.asset(
            imagePath + "desel_notification.svg",
            color: colors.primary,
          ),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationList(),
                ))
                : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ));
          },
        ),
        _selBottom == 4
            ? Container()
            : IconButton(
          padding: EdgeInsets.all(0),
          icon: SvgPicture.asset(
            imagePath + "desel_fav.svg",
            color: colors.primary,
          ),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Favorite(),
                ))
                : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ));
          },
        ),
      ],
      backgroundColor: Theme.of(context).colorScheme.white,
    );
  }

  Widget _getBottomBar() {
    return Material(
        color: Theme.of(context).colorScheme.white,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).colorScheme.black26, blurRadius: 10)
            ],
          ),
          child: TabBar(
            onTap: (_) {
              if (_tabController.index == 3) {
                if (CUR_USERID == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                  _tabController.animateTo(0);
                }
              }
            },
            controller: _tabController,
            tabs: [
              Tab(
                icon: _selBottom == 0
                    ? SvgPicture.asset(
                  imagePath + "sel_home.svg",
                  color: colors.primary,
                )
                    : SvgPicture.asset(
                  imagePath + "desel_home.svg",
                  color: colors.primary,
                ),
                text:
                _selBottom == 0 ? getTranslated(context, 'HOME_LBL') : null,
              ),
              // Tab(
              //   icon: _selBottom == 1
              //       ? SvgPicture.asset(
              //           imagePath + "category01.svg",
              //           color: colors.primary,
              //         )
              //       : SvgPicture.asset(
              //           imagePath + "category.svg",
              //           color: colors.primary,
              //         ),
              //   text:
              //       _selBottom == 1 ? getTranslated(context, 'category') : null,
              // ),
              Tab(
                icon: _selBottom == 1
                    ? SvgPicture.asset(
                  imagePath + "sale02.svg",
                  color: colors.primary,
                )
                    : SvgPicture.asset(
                  imagePath + "sale.svg",
                  color: colors.primary,
                ),
                text: _selBottom == 1 ? getTranslated(context, 'SALE') : null,
              ),
              Tab(
                icon: Selector<UserProvider, String>(
                  builder: (context, data, child) {
                    return Stack(
                      children: [
                        Center(
                          child: _selBottom == 2
                              ? SvgPicture.asset(
                            imagePath + "cart01.svg",
                            color: colors.primary,
                          )
                              : SvgPicture.asset(
                            imagePath + "cart.svg",
                            color: colors.primary,
                          ),
                        ),
                        (data != null && data.isNotEmpty && data != "0")
                            ? new Positioned.directional(
                          bottom: _selBottom == 2 ? 6 : 20,
                          textDirection: Directionality.of(context),
                          end: 0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors.primary),
                            child: new Center(
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: new Text(
                                  data,
                                  style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .white),
                                ),
                              ),
                            ),
                          ),
                        )
                            : Container()
                      ],
                    );
                  },
                  selector: (_, homeProvider) => homeProvider.curCartCount,
                ),
                text: _selBottom == 3 ? getTranslated(context, 'CART') : null,
              ),
              Tab(
                icon: _selBottom == 3
                    ? SvgPicture.asset(
                  imagePath + "profile01.svg",
                  color: colors.primary,
                )
                    : SvgPicture.asset(
                  imagePath + "profile.svg",
                  color: colors.primary,
                ),
                text:
                _selBottom == 3 ? getTranslated(context, 'ACCOUNT') : null,
              ),
            ],
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: colors.primary, width: 5.0),
              insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 70.0),
            ),
            labelStyle: TextStyle(fontSize: 9),
            labelColor: colors.primary,
          ),
        ));
  }

  Widget _getBottomNavigator() {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: CurvedNavigationBar(
        height: 75,
        backgroundColor: Colors.transparent,
        items: <Widget>[
          Container(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.home, size: 30),
          ),
          //Icon(Icons.category, size: 30),
          Container(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.local_offer_outlined, size: 30),
          ),

          Container(
            padding: EdgeInsets.all(4),
            child: SvgPicture.asset(
              'assets/images/pro_myorder.svg',
              height: 25,
              color: colors.primary,
            ),
          ),

          Container(
            padding: EdgeInsets.all(4),
            child: ImageIcon(
              AssetImage('assets/images/chat.png'),
              size: 30,
            )
          ),

          // Padding(
          //   padding:  EdgeInsets.only(top: _selBottom == 3
          //       ? 0 : 10.0),
          //   child: Container(
          //     padding: EdgeInsets.all(4),
          //     child: Column(
          //       children: [
          //         Icon(Icons.person, size: 30),
          //         _selBottom == 3
          //             ? Text(
          //                 "Profile",
          //                 style: TextStyle(
          //                     color: colors.primary,
          //                     fontSize: 10,
          //                     fontWeight: FontWeight.w600),
          //               )
          //             : SizedBox.shrink()
          //       ],
          //     ),
          //   ),
          // ),
        ],
        onTap: (index) {
          _tabController.animateTo(index);
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }
}
