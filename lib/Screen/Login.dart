import 'dart:async';
import 'dart:convert';

import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/app_assets.dart';
import 'package:eshop_multivendor/Helper/cropped_container.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/SendOtp.dart';
import 'package:eshop_multivendor/Screen/Verify_Otp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';

class Login extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<Login> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  String? countryName;
  FocusNode? passFocus, monoFocus = FocusNode();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool visible = false;
  String? password,
      mobile,
      fullName,
      email,
      id,
      mobileno,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      image;
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;
  String? token;

  dynamic choose = "mobile";

  bool otpOnOff = true;

  getToken() async {
    token = await FirebaseMessaging.instance.getToken();
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    getToken();
    getSetting();
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  Future<void> checkNetwork() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      // choose == "otp" ? getLoginUser() : getLoginPass();
      getLoginUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        await buttonController!.reverse();
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      });
    }
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds:  1),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height/1.3),
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      elevation: 1.0,
    ));
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.only(top: kToolbarHeight),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                } else {
                  await buttonController!.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<void> getLoginUser() async {
if(mobileController.text == "" && emailController.text == ''){
  setSnackbar('Please fill either mobile aur email');
}else{
  SharedPreferences prefs = await SharedPreferences.getInstance();

  var data = {MOBILE: mobileController.text, EMAIL: emailController.text??'', FCM_ID: token};
  print(" login request is ${data}");

  Response response = await post(getUserLoginApi, body: data, headers: headers).timeout(Duration(seconds: timeOut));

  print("url is ${getUserLoginApi}");

  var getdata = json.decode(response.body);

  print("login response is == ${getdata}");
  setSnackbar(getdata["message"].toString());//shows message

  if(getdata['data']  != null){
    if(getdata['data'][0]['username'] != null){
      print("login name is == ${getdata['data'][0]['username']}");
      prefs.setString('user_name', getdata['data'][0]['username']);}
    if(getdata['data'][0]['id'] != null){
      print("login name is == ${getdata['data'][0]['id']}");
      prefs.setString('user_id', getdata['data'][0]['id']);}

    if(getdata['data'][0]['email'] != null){
      print("login email is == ${getdata['data'][0]['email']}");
      prefs.setString('user_email', getdata['data'][0]['email']);
    }
    if(getdata['data'][0]['mobile'] != null){
      print("login mobile is == ${getdata['data'][0]['mobile']}");
      prefs.setString('user_mobile', getdata['data'][0]['mobile']);
    }
    if(getdata['data'][0]['country_code'] != null){
      print("login country_code is == ${getdata['data'][0]['country_code']}");
     countryName = "+${getdata['data'][0]['country_code']}";
    }

  }


  bool error = getdata["error"];
  String? msg = getdata["message"];
  int? otp;
  if(getdata["otp"]!= null){
   otp = getdata["otp"];
  }

  dynamic getData = getdata["data"];
  await buttonController!.reverse();
  print('_____________________');
  // setSnackbar(getdata["otp"].toString());
  if (error == true) {
    print(getdata);
    var i = getdata["data"][0];
    id = i[ID];
    fullName = i[USERNAME];
    email = i[EMAIL];
    mobile = i[MOBILE];
    city = i[CITY];
    area = i[AREA];
    address = i[ADDRESS];
    pincode = i[PINCODE];
    latitude = i[LATITUDE];
    longitude = i[LONGITUDE];
    image = i[IMAGE];

    CUR_USERID = id;
    // CUR_USERNAME = username;

    print('parameters $i');
    UserProvider userProvider =
    Provider.of<UserProvider>(this.context, listen: false);
    userProvider.setName(fullName ?? "");
    if(email != null)
      userProvider.setEmail(email ?? "");
    userProvider.setProfilePic(image ?? "");

    SettingProvider settingProvider =
    Provider.of<SettingProvider>(context, listen: false);

    settingProvider.saveUserDetail(id!, fullName, email, mobile, city, area,
        address, pincode, latitude, longitude, image, context);

    // Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                VerifyOtp(
                    title: getTranslated(context, 'SIGNIN_LBL')!,
                    otp: otp,
                    signUp: false,
                    countryCode: mobileController.text == "" ? "" : countryName,
                    mobileNumber: emailController.text != "" ? email.toString():
                    mobileController.text != "" ? mobile.toString(): "")
        ));
  } else {
    setSnackbar(msg!);
  }
}
  }

  // Future<void> getLoginPass() async {
  //   var data = {MOBILE: mobile, PASSWORD: password, FCM_ID: token};
  //   Response response =
  //       await post(getUserLoginPassApi, body: data, headers: headers)
  //           .timeout(Duration(seconds: timeOut));
  //   var getdata = json.decode(response.body);
  //   print(getdata);
  //   bool error = getdata["error"];
  //   String? msg = getdata["message"];
  //   await buttonController!.reverse();
  //
  //   if (error == false) {
  //     var i = getdata["data"][0];
  //     id = i[ID];
  //     fullName = i[USERNAME];
  //     email = i[EMAIL];
  //     mobile = i[MOBILE];
  //     city = i[CITY];
  //     area = i[AREA];
  //     address = i[ADDRESS];
  //     pincode = i[PINCODE];
  //     latitude = i[LATITUDE];
  //     longitude = i[LONGITUDE];
  //     image = i[IMAGE];
  //
  //     CUR_USERID = id;
  //     // CUR_USERNAME = username;
  //
  //     UserProvider userProvider =
  //         Provider.of<UserProvider>(this.context, listen: false);
  //     userProvider.setName(fullName ?? "");
  //     userProvider.setEmail(email ?? "");
  //     userProvider.setProfilePic(image ?? "");
  //
  //     SettingProvider settingProvider =
  //         Provider.of<SettingProvider>(context, listen: false);
  //
  //     settingProvider.saveUserDetail(id!, fullName, email, mobile, city, area,
  //         address, pincode, latitude, longitude, image, context);
  //
  //     Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
  //
  //     // Navigator.push(
  //     //     context,
  //     //     MaterialPageRoute(
  //     //         builder: (context) =>
  //     //             VerifyOtp(mobileNumber: mobile.toString())));
  //   } else {
  //     setSnackbar(msg!);
  //   }
  // }

  Widget chooseType() {
    return Row(
      children: [
        // Row(
        //   children: [
        //     Radio(
        //         value: "pass",
        //         groupValue: choose,
        //         onChanged: (val) {
        //           setState(() {
        //             choose = val;
        //           });
        //         }),
        //     Text("${getTranslated(context, 'PASSHINT_LBL')}"),
        //   ],
        // ),
       // otpOnOff ?
        Row(
          children: [
            Radio(
                value: "mobile",
                groupValue: choose,
                onChanged: (val) {
                  setState(() {
                    choose = val;
                    otpOnOff = true;
                    print("selected radio is == $choose");
                  });
                }),
            Text("${getTranslated(context, 'MOBILEHINT_LBL')}"),
            Radio(
                value: "email",
                groupValue: choose,
                onChanged: (val) {
                  setState(() {
                    choose = val;
                    otpOnOff = false;
                    print("selected radio is == $choose");
                  });
                }),
            Text("${getTranslated(context, 'EMAILHINT_LBL_OPT')}"),
          ],
        )
            //: Container()
      ],
    );
  }

  _subLogo() {
    return Expanded(
      flex: 4,
      child: Center(
        child: Image.asset(
          'assets/images/homelogo.png',
          scale: 4,
        ),
      ),
    );
  }

  signInTxt() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 30.0,
        ),
        child: Align(
          alignment: Alignment.center,
          child: new Text(
            getTranslated(context, 'SIGNIN_LBL')!,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.bold),
          ),
        ),
    );
  }

  setMobileNo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // if(choose == 'mobile')
        if(otpOnOff == true)
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.only(
              top: 30.0,
            ),
            child: Center(
              child: TextFormField(
                keyboardType: TextInputType.number,
                controller: mobileController,
                maxLength: 10,
                onSaved: (String? value) {
                  mobile = value;
                },
                onChanged: (val){
                  emailController.clear();
                },
                style: TextStyle(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  contentPadding: EdgeInsets.only(
                      left: 15, top: 15),
                  prefixIcon: Icon(
                    Icons.phone_android,
                    color: Theme.of(context).colorScheme.fontColor,
                    size: 20,
                  ),
                  hintText: "${getTranslated(context, 'MOBILEHINT_LBL')}",
                ),
              ),
            ),
          ),
        // Container(
        //   width: MediaQuery.of(context).size.width * 0.85,
        //   padding: EdgeInsets.only(
        //     top: 30.0,
        //   ),
        //   child: TextFormField(
        //     maxLength: 10,
        //     // onTap: (){
        //     //   setState(() {
        //     //     otpOnOff = true;
        //     //   });
        //     // },
        //     onFieldSubmitted: (v) {
        //       FocusScope.of(context).requestFocus(passFocus);
        //     },
        //     keyboardType: TextInputType.number,
        //     controller: mobileController,
        //     style: TextStyle(
        //
        //       color: Theme.of(context).colorScheme.fontColor,
        //       fontWeight: FontWeight.normal,
        //     ),
        //     focusNode: monoFocus,
        //     textInputAction: TextInputAction.next,
        //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        //     // validator: (val) => validateMob(
        //     //     val!,
        //     //     getTranslated(context, 'MOB_REQUIRED'),
        //     //     getTranslated(context, 'VALID_MOB')),
        //     onSaved: (String? value) {
        //       mobile = value;
        //     },
        //     decoration: InputDecoration(
        //       prefixIcon: Icon(
        //         Icons.phone_android,
        //         color: Theme.of(context).colorScheme.fontColor,
        //         size: 20,
        //       ),
        //       hintText: "${getTranslated(context, 'MOBILEHINT_LBL')}",
        //       counterText: "",
        //       hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
        //           color: Theme.of(context).colorScheme.fontColor,
        //           fontWeight: FontWeight.normal),
        //       filled: true,
        //       fillColor: Theme.of(context).colorScheme.white,
        //       contentPadding: EdgeInsets.symmetric(
        //         horizontal: 10,
        //         vertical: 5,
        //       ),
        //       focusedBorder: UnderlineInputBorder(
        //         borderSide: BorderSide(color: colors.primary),
        //         borderRadius: BorderRadius.circular(7.0),
        //       ),
        //       prefixIconConstraints: BoxConstraints(
        //         minWidth: 40,
        //         maxHeight: 20,
        //       ),
        //       enabledBorder: UnderlineInputBorder(
        //         borderSide:
        //             BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
        //         borderRadius: BorderRadius.circular(7.0),
        //       ),
        //     ),
        //   ),
        // ),

        // if(choose == 'email')
        if(otpOnOff == false)
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: EdgeInsets.only(
            top: 30.0,
          ),
          child:
          TextFormField(
              // onTap: (){
              //   setState(() {
              //     otpOnOff = false;
              //   });
              // },
            onChanged: (val){
              mobileController.clear();
            },
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
                fontWeight: FontWeight.normal,
              ),
            decoration:  InputDecoration(
                  prefixIcon: Icon(
                    Icons.mail_outline_outlined,
                    color: Theme.of(context).colorScheme.fontColor,
                    size: 20,
                  ),
              hintText: "${getTranslated(context, 'EMAILHINT_LBL')}",
            ),
            onSaved: (String? value) {
              email = value;
            },
          )
          // TextFormField(
          //   onTap: (){
          //     setState(() {
          //       otpOnOff = true;
          //     });
          //   },
          //   keyboardType: TextInputType.emailAddress,
          //   controller: emailController,
          //   style: TextStyle(
          //     color: Theme.of(context).colorScheme.fontColor,
          //     fontWeight: FontWeight.normal,
          //   ),
          //   focusNode: passFocus,
          //   textInputAction: TextInputAction.next,
          //   // validator: (val) => validateEmail(
          //   //     val!,
          //   //     getTranslated(context, 'EMAIL_REQUIRED'),
          //   //     getTranslated(context, 'VALID_EMAIL')),
          //   onSaved: (String? value) {
          //     email = value;
          //   },
          //   decoration: InputDecoration(
          //     prefixIcon: Icon(
          //       Icons.mail_outline_outlined,
          //       color: Theme.of(context).colorScheme.fontColor,
          //       size: 20,
          //     ),
          //     hintText: "${getTranslated(context, 'EMAILHINT_LBL')}",
          //     counterText: "",
          //     hintStyle: Theme.of(this.context).textTheme.subtitle2!.copyWith(
          //         color: Theme.of(context).colorScheme.fontColor,
          //         fontWeight: FontWeight.normal),
          //     filled: true,
          //     fillColor: Theme.of(context).colorScheme.white,
          //     contentPadding: EdgeInsets.symmetric(
          //       horizontal: 10,
          //       vertical: 5,
          //     ),
          //     focusedBorder: UnderlineInputBorder(
          //       borderSide: BorderSide(color: colors.primary),
          //       borderRadius: BorderRadius.circular(7.0),
          //     ),
          //     prefixIconConstraints: BoxConstraints(
          //       minWidth: 40,
          //       maxHeight: 20,
          //     ),
          //     enabledBorder: UnderlineInputBorder(
          //       borderSide:
          //           BorderSide(color: Theme.of(context).colorScheme.lightBlack2),
          //       borderRadius: BorderRadius.circular(7.0),
          //     ),
          //   ),
          // ),
        ),
      ],
    );
  }


  termAndPolicyTxt() {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
          bottom: 20.0, start: 25.0, end: 25.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'DONT_HAVE_AN_ACC')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SendOtp(
                    title: getTranslated(context, 'SEND_OTP_TITLE'),
                  ),
                ));
              },
              child: Text(
                getTranslated(context, 'SIGN_UP_LBL')!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ),
          )
        ],
      ),
    );
  }

  loginBtn() {
    return AppBtn(
      // title: choose == "otp" ? getTranslated(context, 'SEND_OTP_TITLE') : getTranslated(context, 'LOGIN'),
      title: getTranslated(context, 'LOGIN'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();
      },
    );
  }

  // _expandedBottomView() {
  //   return Expanded(
  //     flex: 6,
  //     child: Container(
  //       alignment: Alignment.bottomCenter,
  //       child: ScrollConfiguration(
  //           behavior: MyBehavior(),
  //           child: SingleChildScrollView(
  //             child: Form(
  //               key: _formkey,
  //               child: Card(
  //                 elevation: 0.5,
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(10)),
  //                 margin: EdgeInsetsDirectional.only(
  //                     start: 20.0, end: 20.0, top: 20.0),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     signInTxt(),
  //                     setMobileNo(),
  //                     // setPass(),
  //                     forgetPass(),
  //                     loginBtn(),
  //                     termAndPolicyTxt(),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           )),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          body: _isNetworkAvail
              ? Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: back(),
                    ),
                    Image.asset(
                      'assets/images/doodle.png',
                      color: colors.primary,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    getLoginContainer(),
                    getLogo(),
                  ],
                )
              : noInternet(context)),
    );
  }

  getLoginContainer() {
    return Positioned.directional(
      start: MediaQuery.of(context).size.width * 0.025,
      // end: width * 0.025,
      // top: width * 0.45,
      top: MediaQuery.of(context).size.height * 0.2, //original
      //    bottom: height * 0.1,
      textDirection: Directionality.of(context),
      child: ClipPath(
        clipper: ContainerClipper(),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.8),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.95,
          color: Theme.of(context).colorScheme.white,
          child: Form(
            key: _formkey,
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      setSignInLabel(),
                      chooseType(),
                      setMobileNo(),
                    //  choose == "pass" ? setPass() : Container(),
                      loginBtn(),
                      // termAndPolicyTxt(),
                      signUpLink(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Positioned(
      // textDirection: Directionality.of(context),
      left: (MediaQuery.of(context).size.width / 2) - 50,
      // right: ((MediaQuery.of(context).size.width /2)-55),

      top: (MediaQuery.of(context).size.height * 0.2) - 50,
      //  bottom: height * 0.1,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Image.asset(
          MyAssets.login_logo,

        ),
      ),
    );
  }

  Widget setSignInLabel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          getTranslated(context, 'SIGNIN_LBL')!,
          style: const TextStyle(
            color: colors.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget signUpLink() {
    return TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => SendOtp(
              title: getTranslated(context, 'SEND_OTP_TITLE'),
            ),
          ));
        },
        child: Text(
          "${getTranslated(context, 'CREATEACCOUNT')}",
          style: TextStyle(color: colors.primary),
        ));
  }

  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    //print("")
    Map parameter = Map();
    if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};

    apiBaseHelper.postAPICall(getOtpSetting, parameter).then((getdata) async {
      bool error = getdata["error"];
      String? msg = getdata["message"];

      if (!error) {
        print(getdata);
        var data = getdata["date"][0]["value"];

        otpOnOff = data == "off" ? false:true;

      } else {}
    }, onError: (error) {});
  }
}
