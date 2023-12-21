import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Helper/PushNotificationService.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/app_assets.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/recentSearchModel.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Favorite.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/MyProfile.dart';
import 'package:eshop_multivendor/Screen/Product_Detail.dart';
import 'package:eshop_multivendor/Screen/about_us.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'All_Category.dart';
import 'Cart.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Sale.dart';
import 'Search.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Dashboard extends StatefulWidget {
   Dashboard({ Key? key,}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  // int selBottom = 0;
  late TabController tabController;
  bool _isNetworkAvail = true;
  String? User_email;
  String? User_name;
  String? User_id;
  int _selectedIndex = 0;

  getSharedData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    User_email = prefs.getString('user_email');
    User_name = prefs.getString('user_name');
    User_id = prefs.getString('user_id');
    print("user User_id is $User_id");
    print("user email is $User_email");
    print("user name is $User_name");
    print("user name is ${User_id == "" || User_id == null}");
    await callChat();
  }

  @override
  void initState() {
    getSharedData();
    tabController = TabController(length: 4, vsync: this, );

    getSettings();

    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    initDynamicLinks();
    if (_selectedIndex == 1 &&  (User_id == "" || User_id == null)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
      );
    }

    final pushNotificationService = PushNotificationService(
        context: context, tabController: tabController);
    pushNotificationService.initialise();
    // tabController.addListener(
    //   () {
    //     // _handleTabChange(tabController.index);
    //     Future.delayed(Duration(milliseconds: 1200)).then(
    //       (value) {
    //         if (tabController.index == 1 &&  (User_id == "" || User_id == null)) {
    //
    //
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                 builder: (context) => Login(),
    //               ),
    //             );
    //             tabController.animateTo(0);
    //
    //         }
    //       },
    //     );
    //
    //     setState(
    //       () {
    //
    //         selBottom = tabController.index;
    //       },
    //     );
    //   },
    // );
  }

  void initDynamicLinks() async {
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
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
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
        print("response=${getdata}");
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];
          List<Product> items = [];
          items = (data as List).map((data) => new Product.fromJson(data)).toList();
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
  callChat() async {
    String? name = User_name;
    String? email = User_email;
    print('email inside callchat == ${email}');
    try {
      UserCredential data =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.toString(),
        password: "alpha@123",
      );
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: name.toString(),
          id: data.user!.uid,
          imageUrl: 'https://i.pravatar.cc/300?u=${email.toString()}',
          lastName: "",
        ),
      );
      updateFid(data.user!.uid);
      print("user_fuid_is_____${data.user!.uid}");
    } catch (e) {
      print('$e');
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.toString(),
        password: "alpha@123",
      );
      // App.localStorage.setString("firebaseUid", credential.user!.uid);
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: name.toString(),
          id: credential.user!.uid,
          imageUrl: 'https://i.pravatar.cc/300?u=${email.toString()}',
          lastName: "",
        ),
      );
      updateFid(credential.user!.uid);
      print(e.toString());
    }
    print("user created");
  }

  ///api for fuid
  updateFid(FUID) async{
    var params = {
      FU_ID : '${FUID}',
      USER_ID : '${CUR_USERID}'
    };

    print("url is $updateFuid");
    print("params is $params");

    var response = await http.post(updateFuid, body: params);
    var jsonResponse = convert.jsonDecode(response.body);
    print(" = ${jsonResponse['message']}");


  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: WillPopScope(
        onWillPop: () async {
          if (_selectedIndex != 0) {
            _selectedIndex = 0;
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.lightWhite,
          appBar: _getAppBar(),
          // body: TabBarView(
          //   physics: NeverScrollableScrollPhysics(),
          //   controller: tabController,
          //   children: [
          //     HomePage(),
          //     Sale(),
          //     MyProfile(),
          //     AboutUsScreen(title: getTranslated(context, 'ABOUT_LBL'),),
          //   ],
          // ),

          body: Center(
            child: [
              HomePage(),
              Sale(),
              MyProfile(),
              AboutUsScreen(title: getTranslated(context, 'ABOUT_LBL'),),
            ].elementAt(_selectedIndex),
          ),
          bottomNavigationBar: _getBottomNavigator(),
        ),
      ),
    );
  }


  void onItemTapped(int index) {
    getSharedData();
      print('pressed $_selectedIndex index');
      _selectedIndex = index;
      tabController.index = index;
    setState(() {});
    if (_selectedIndex == 1 &&  (User_id == "" || User_id == null)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
      );
    }
    setState(() {});
  }

  String? appLogo;
  bool isLoading= false;

  getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    var parameter = {};
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      apiBaseHelper.postAPICall(getSettingApi, parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String msg = getdata["message"];
          if (!error) {
            appLogo = getdata["data"]["logo"][0].toString();
            prefs.setString('appLogo', appLogo!);
            print("get_settings logo data $appLogo");
          } else {
            setSnackbar(msg, context);
          }
          setState(() {
            isLoading = false;
          });
        },
        onError: (error) {
          setSnackbar(error.toString(), context);
        },
      );
    } else {
      setState(
            () {
          isLoading = false;
          _isNetworkAvail = false;
        },
      );
    }
  }

  AppBar _getAppBar() {
    String? title;
    if (_selectedIndex == 1)
      title = getTranslated(context, 'SUBSCRIPTION');
    else if (_selectedIndex == 2)
      title = getTranslated(context, 'PROFILE');
    else if (_selectedIndex == 3) title = getTranslated(context, 'ABOUT_LBL');
    return AppBar(
      centerTitle: _selectedIndex == 0 ? true : false,
      title:


      _selectedIndex != 0? Text(
        title.toString(),
        style: TextStyle(
            color: colors.primary, fontWeight: FontWeight.normal),
      ):
      isLoading == true ? Container():
      appLogo != null || appLogo != "" ?
      ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.network(appLogo!, fit: BoxFit.contain,width: 100,)):
      Image.asset(
              MyAssets.normal_logo,
              height: 50,
            ),

      leading: _selectedIndex == 0
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
        _selectedIndex == 0 || _selectedIndex == 4
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
                        builder: (context) => Search(isSubscription: _selectedIndex==1? true:false),
                      ));
                }),
        _selectedIndex == 4
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

      ],
      backgroundColor: Theme.of(context).colorScheme.white,
    );
  }

  Widget _getBottomNavigator() {
    return Material(
       color: Colors.transparent,
      elevation: 0,
      child: CurvedNavigationBar(
        height: 65,
        backgroundColor: Colors.transparent,
        items: <Widget>[
          Icon(Icons.home, color: colors.primary,size: 30),
          ImageIcon(AssetImage('assets/images/subscription.png'), size: 40,color: colors.primary,),
          Icon(Icons.person, color: colors.primary, size: 30),
          Icon(Icons.info_outlined, color: colors.primary,size: 30),
        ],
        onTap: onItemTapped,
        // onTap: (index) {
        //   getSharedData();
        //   tabController.index = index;
        //   // _handleTabChange(tabController.index);
        //
        //   print("user User_id is ${User_id}");
        //   print("User_id == "" || User_id == null is ${User_id == "" || User_id == null}");
        //
        //   tabController.animateTo(index);
        //   if (tabController.index == 1 &&  (User_id == "" || User_id == null)) {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => Login(),
        //         ),
        //       );
        //       tabController.animateTo(0);
        //   }
        //   setState(() {});
        //   print("current index is ${tabController.index}");
        // },
      ),
    );


  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }
}

