import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:eshop_multivendor/Model/cityModel.dart';
import 'package:http/http.dart' as http;
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Helper/app_assets.dart';
import 'package:eshop_multivendor/Helper/cropped_container.dart';
import 'package:eshop_multivendor/Provider/SettingProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';

class SignUp extends StatefulWidget {
  final mobile;
  final countryCode;
  const SignUp({Key? key, this.mobile, this.countryCode}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> with TickerProviderStateMixin {
  bool? _showPassword = false;
  bool visible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final ccodeController = TextEditingController();
  final passwordController = TextEditingController();
  final referController = TextEditingController();
  int count = 1;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  String? name,
      email,
      password,
      mobile,
      id,
      countrycode,
      city,
      area,
      pincode,
      address,
      latitude,
      longitude,
      referCode,
      friendCode;
  FocusNode? nameFocus,
      emailFocus,
      passFocus = FocusNode(),
      referFocus = FocusNode();
  bool _isNetworkAvail = true;
  Animation? buttonSqueezeanimation;

  AnimationController? buttonController;

  void validateAndSubmit() async {
    if (validateAndSave()) {
      _playAnimation();
      checkNetwork();
    }
  }

  getUserDetails() async {
    SettingProvider settingsProvider = Provider.of<SettingProvider>(context, listen: false);
    mobile = await settingsProvider.getPrefrence(MOBILE);
    countrycode = await settingsProvider.getPrefrence(COUNTRY_CODE);
    if (mounted) setState(() {});
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<void> checkNetwork() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (referCode != null) getRegisterUser();
    } else {
      Future.delayed(Duration(seconds: 2)).then((_) async {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
        await buttonController!.reverse();
      });
    }
  }

    List<String> cityList = [];


  CityModel? cityModel;

  getCities()async{
    cityList.clear();
    var headers = {
      'Cookie': 'ci_session=2341e5a4799528ac8f108317abbac407eb31cb1e'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}get_cities'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = CityModel.fromJson(json.decode(finalResult));
      setState(() {
        cityModel = jsonResponse;
      });

    }
    else {
      print(response.reasonPhrase);
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

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    buttonController!.dispose();
    super.dispose();
  }

  String? selectedCity;

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height/1.1),
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
      ),
      elevation: 1.0,
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
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

  Future<void> getRegisterUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();



    try {
      var data = {
        MOBILE: widget.mobile,
        NAME: name,
        EMAIL: email,
        // PASSWORD: password,
        COUNTRY_CODE: widget.countryCode,
        REFERCODE: referController.text,
        'city':selectedCity.toString(),
       // FRNDCODE: friendCode
      };
      print("sign_up_request==${data.toString()}");
      Response response =
          await post(getUserSignUpApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);
      print("sign_up_response==${getdata}");

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

      }


      bool error = getdata["error"];
      String? msg = getdata["message"];
      await buttonController!.reverse();
      if (!error) {
        setSnackbar(getTranslated(context, 'REGISTER_SUCCESS_MSG')!);
        var i = getdata["data"][0];

        id = i[ID];
        name = i[USERNAME];
        email = i[EMAIL];
        mobile = i[MOBILE];
        //countrycode=i[COUNTRY_CODE];
        CUR_USERID = id;

        // CUR_USERNAME = name;

        UserProvider userProvider = context.read<UserProvider>();
        userProvider.setName(name ?? "");

        SettingProvider settingProvider = context.read<SettingProvider>();
        settingProvider.saveUserDetail(id!, name, email, mobile, city, area,
            address, pincode, latitude, longitude, "", context);

        Navigator.pushNamedAndRemoveUntil(context, "/home", (r) => false);
      } else {
        print(msg);
        setSnackbar(msg!);
      }
      if (mounted) setState(() {});
    } on TimeoutException catch (_) {
      setSnackbar(getTranslated(context, 'somethingMSg')!);
      await buttonController!.reverse();
    }
  }

  Widget registerTxt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(getTranslated(context, 'USER_REGISTER_DETAILS')!,
            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 25)),
      ),
    );
  }

  setUserName() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        controller: nameController,
        focusNode: nameFocus,
        textInputAction: TextInputAction.next,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) => validateUserName(
            val!,
            getTranslated(context, 'USER_REQUIRED'),
            getTranslated(context, 'USER_LENGTH')),
        onSaved: (String? value) {
          name = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, nameFocus!, emailFocus);
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.account_circle_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'NAMEHINT_LBL'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
          //   borderRadius: BorderRadius.circular(10.0),
          // ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setEmail() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        focusNode: emailFocus,
        textInputAction: TextInputAction.next,
        controller: emailController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        validator: (val) => validateEmail(
            val!,
            getTranslated(context, 'EMAIL_REQUIRED'),
            getTranslated(context, 'VALID_EMAIL')),
        onSaved: (String? value) {
          email = value;
        },
        onFieldSubmitted: (v) {
          _fieldFocusChange(context, emailFocus!, passFocus);
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.alternate_email_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'EMAILHINT_LBL_OPT'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
          //   borderRadius: BorderRadius.circular(10.0),
          // ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  setRefer() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: 10.0,
        start: 15.0,
        end: 15.0,
      ),
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: referFocus,
        controller: referController,
        style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontWeight: FontWeight.normal),
        onSaved: (String? value) {
          friendCode = value;
        },
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: colors.primary),
            borderRadius: BorderRadius.circular(7.0),
          ),
          prefixIcon: Icon(
            Icons.card_giftcard_outlined,
            color: Theme.of(context).colorScheme.fontColor,
            size: 17,
          ),
          hintText: getTranslated(context, 'REFER'),
          hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
              color: Theme.of(context).colorScheme.fontColor,
              fontWeight: FontWeight.normal),
          // filled: true,
          // fillColor: Theme.of(context).colorScheme.lightWhite,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
          //   borderRadius: BorderRadius.circular(10.0),
          // ),
          enabledBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.fontColor),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }

  // setPass() {
  //   return Padding(
  //       padding: EdgeInsetsDirectional.only(start: 15.0, end: 15.0, top: 10.0),
  //       child: TextFormField(
  //         keyboardType: TextInputType.text,
  //         obscureText: !_showPassword!,
  //         focusNode: passFocus,
  //         onFieldSubmitted: (v) {
  //           _fieldFocusChange(context, passFocus!, referFocus);
  //         },
  //         textInputAction: TextInputAction.next,
  //         style: TextStyle(
  //             color: Theme.of(context).colorScheme.fontColor,
  //             fontWeight: FontWeight.normal),
  //         controller: passwordController,
  //         validator: (val) => validatePass(
  //             val!,
  //             getTranslated(context, 'PWD_REQUIRED'),
  //             getTranslated(context, 'PWD_LENGTH')),
  //         onSaved: (String? value) {
  //           password = value;
  //         },
  //         decoration: InputDecoration(
  //           focusedBorder: UnderlineInputBorder(
  //             borderSide: BorderSide(color: colors.primary),
  //             borderRadius: BorderRadius.circular(7.0),
  //           ),
  //           prefixIcon: SvgPicture.asset(
  //             "assets/images/password.svg",
  //             height: 17,
  //             width: 17,
  //             color: Theme.of(context).colorScheme.fontColor,
  //           ),
  //           // Icon(
  //           //   Icons.lock_outline,
  //           //   color: Theme.of(context).colorScheme.lightBlack2,
  //           //   size: 17,
  //           // ),
  //           hintText: getTranslated(context, 'PASSHINT_LBL'),
  //           hintStyle: Theme.of(context).textTheme.subtitle2!.copyWith(
  //               color: Theme.of(context).colorScheme.fontColor,
  //               fontWeight: FontWeight.normal),
  //           // filled: true,
  //           // fillColor: Theme.of(context).colorScheme.lightWhite,
  //           contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  //           prefixIconConstraints: BoxConstraints(minWidth: 40, maxHeight: 25),
  //           // focusedBorder: OutlineInputBorder(
  //           //   borderSide: BorderSide(color: Theme.of(context).colorScheme.fontColor),
  //           //   borderRadius: BorderRadius.circular(10.0),
  //           // ),
  //           enabledBorder: UnderlineInputBorder(
  //             borderSide:
  //                 BorderSide(color: Theme.of(context).colorScheme.fontColor),
  //             borderRadius: BorderRadius.circular(10.0),
  //           ),
  //         ),
  //       ));
  // }

  setCity() {
    return Container(
      padding: EdgeInsets.only(left: 20,right: 20,top: 10),
      child: cityModel == null ? Center(child: CircularProgressIndicator(),) : DropdownButton(
        // Initial Value
        isExpanded: true,
        value: selectedCity,
        // Down Arrow Icon
        icon:  Icon(Icons.keyboard_arrow_down),
        hint: Text("${getTranslated(context, 'CITYSELECT_LBL')}",style: TextStyle(fontSize: 13),),
        // Array list of items
        items: cityModel!.data!.map((items) {
          return DropdownMenuItem(
            value: items.id.toString(),
            child: Text(items.name.toString(), style: TextStyle(color: Theme.of(context).colorScheme.black,),),
          );
        }).toList(),
        // After selecting the desired option,it will
        // change button value to selected value
        onChanged: (String? newValue) {
          setState(() {
            selectedCity = newValue!;
          });
        },
      ),
    );
  }

  showPass() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 30.0,
          end: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Checkbox(
              value: _showPassword,
              checkColor: Theme.of(context).colorScheme.fontColor,
              activeColor: Theme.of(context).colorScheme.lightWhite,
              onChanged: (bool? value) {
                if (mounted)
                  setState(() {
                    _showPassword = value;
                  });
              },
            ),
            Text(getTranslated(context, 'SHOW_PASSWORD')!,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                    fontWeight: FontWeight.normal))
          ],
        ));
  }

  verifyBtn() {
    return AppBtn(
      title: getTranslated(context, 'SAVE_LBL'),
      btnAnim: buttonSqueezeanimation,
      btnCntrl: buttonController,
      onBtnSelected: () async {
        validateAndSubmit();

      },
    );
  }

  loginTxt() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: 25.0,
        end: 25.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(getTranslated(context, 'ALREADY_A_CUSTOMER')!,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.normal)),
          InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => Login(),
                ));
              },
              child: Text(
                getTranslated(context, 'LOG_IN_LBL')!,
                style: Theme.of(context).textTheme.caption!.copyWith(
                    color: Theme.of(context).colorScheme.fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  backBtn() {
    return Platform.isIOS
        ? Container(
            padding: EdgeInsetsDirectional.only(top: 20.0, start: 10.0),
            alignment: AlignmentDirectional.topStart,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: InkWell(
                  child: Icon(Icons.keyboard_arrow_left, color: colors.primary),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ))
        : Container();
  }

  expandedBottomView() {
    return Expanded(
        flex: 8,
        child: Container(
          alignment: Alignment.bottomCenter,
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
                child: Form(
              key: _formkey,
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsetsDirectional.only(
                    start: 20.0, end: 20.0, top: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    registerTxt(),

                    setUserName(),
                    setEmail(),
                    // setPass(),
                    setRefer(),
                    showPass(),
                    verifyBtn(),
                    loginTxt(),
                  ],
                ),
              ),
            )),
          ),
        ));
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
    getUserDetails();
    Future.delayed(Duration(milliseconds: 200),(){
      return getCities();
    });
    buttonController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: Interval(
        0.0,
        0.150,
      ),
    ));

    generateReferral();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: _isNetworkAvail
            ? Stack(
                children: [
                  backBtn(),
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
                  //getBgImage(),
                  getLoginContainer(),
                  getLogo(),
                ],
              )
            : noInternet(context));
  }

  Future<void> generateReferral() async {
    String refer = getRandomString(8);

    try {
      var data = {
        REFERCODE: refer,
      };

      Response response =
          await post(validateReferalApi, body: data, headers: headers)
              .timeout(Duration(seconds: timeOut));

      var getdata = json.decode(response.body);

      bool error = getdata["error"];

      if (!error) {
        referCode = refer;
        REFER_CODE = refer;
        if (mounted) setState(() {});
      } else {
        if (count < 5) generateReferral();
        count++;
      }
    } on TimeoutException catch (_) {}
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

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
                    maxHeight: MediaQuery.of(context).size.height * 2.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.10,
                      ),
                      registerTxt(),

                      setUserName(),
                      setEmail(),
                      // setPass(),
                      setCity(),
                      setRefer(),
                      //showPass(),
                      verifyBtn(),
                      loginTxt(),
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
}
