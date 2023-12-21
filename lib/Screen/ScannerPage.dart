import 'dart:convert';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/newSellerModel.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/QrScanner.dart';
import 'package:eshop_multivendor/Screen/Search.dart';
import 'package:eshop_multivendor/Screen/dashboard_restaurant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import 'SubCategory.dart';

class ScannerPage extends StatefulWidget {
  final String? title;
  final sellerId;
  final catId;
  final sellerData;

  ScannerPage({this.catId,this.title,this.sellerData,this.sellerId});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {

  TextEditingController codeController = TextEditingController();

  bool isCode = false;

  NewSellerModel? checkResult;

  checkCode()async{
    print("working here");
    var headers = {
      'Cookie': 'ci_session=037e475492e22b22dc37efe636bf60a361575fa8'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${baseUrl}check_qrcode'));
    request.fields.addAll({
      'qrcode': codeController.text,
      'user_id': CUR_USERID.toString(),
    });
    print("parameter here  enter code ${request.fields}");
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    print("status code here ${response.statusCode == 200}");
    if (response.statusCode == 200) {
      var finalResult = await response.stream.bytesToString();
      final jsonResponse = NewSellerModel.fromJson(json.decode(finalResult));

      if(jsonResponse.error == false) {

        checkResult = jsonResponse;

        print("ooooooooooo${jsonResponse.date}");

        if(checkResult?.date != null){
          print("seller id before send ${checkResult!.date![0].userId}");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) =>
              RestaurantDashboard(title: widget.title.toString(),
                sellerId: checkResult!.date![0].userId.toString(),
                sellerData: json.encode(checkResult!.date![0]),
                subCatName: checkResult!.date![0].username.toString(),//newly added 11 aug
                subCatAddress: checkResult!.date![0].address.toString(),//newly added 11 aug
                subCatLogo: checkResult!.date![0].logo.toString(),//newly added 11 aug
                showAll: true,)));

          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>
          //     RestaurantDashboard(
          //       title: checkResult!.date![0].username.toString() ,
          //       sellerId: checkResult!.date![0].userId ,
          //       sellerData: checkResult!.date![0],
          //       showAll: true,
          //     )));
        }else{
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 60),
            content: new Text(
              jsonResponse.message.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.black),
            ),
            backgroundColor: Theme.of(context).colorScheme.white,
            elevation: 1.0,
          ));
          Navigator.pop(context);
        }

      }
      else{

        ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 60),
          content: new Text(
            'Entered code is Incorrect',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.black),
          ),
          backgroundColor: Theme.of(context).colorScheme.white,
          elevation: 1.0,
        ));
        Navigator.pop(context);
      }
    }
    else {
      print(response.reasonPhrase);
    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // appBar: getAppBar("${widget.title}", context),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.pop(context,true),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: colors.primary,
                  ),
                ),
              ),
            );
          },
        ),
        title: Text(
          '${widget.title}',
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
        ),
        actions: <Widget>[
          IconButton(
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

          Selector<UserProvider, String>(
            builder: (context, data, child) {
              return IconButton(
                icon: Stack(
                  children: [
                    Center(
                        child: SvgPicture.asset(
                          imagePath + "appbarCart.svg",
                          color: colors.primary,
                        )),
                    (data != null && data.isNotEmpty && data != "0")
                        ? new Positioned(
                      bottom: 20,
                      right: 0,
                      child: Container(
                        //  height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: colors.primary),
                        child: new Center(
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: new Text(
                              data,
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.white),
                            ),
                          ),
                        ),
                      ),
                    )
                        : Container()
                  ],
                ),
                onPressed: () {
                  CUR_USERID != null
                      ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cart(
                        fromBottom: false,
                      ),
                    ),
                  )
                      : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Login(),
                    ),
                  );
                },
              );
            },
            selector: (_, homeProvider) => homeProvider.curCartCount,
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: ()async{
          Navigator.pop(context,true);
          return false;
        },
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 12,vertical: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.center,
                    width: 150,
                    height: 150,
                    child: Image.asset('assets/images/grcode.png',fit:BoxFit.fill,color: Theme.of(context).colorScheme.black,)),
               SizedBox(height: 10,),
                Text("${getTranslated(context, 'ScanOrEnterCode')}",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
                  SizedBox(height: 40,),
                Align(
                  alignment: Alignment.center,
                  child: MaterialButton(
                    onPressed: () async{
                      print("widget.title in scanner is ${widget.title}");
                    await Navigator.push(context, MaterialPageRoute(builder: (context) => QRViewExample(title: widget.title,sellerData: widget.sellerData,catId: widget.catId,sellerId: widget.sellerId,)));
                      Navigator.pop(context,true);
                    },child: Text("${getTranslated(context, 'ScanQrCode')}",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w600),),color: colors.primary,),
                ),
                SizedBox(height: 20,),
                Align(
                  alignment: Alignment.center,
                  child: MaterialButton(onPressed: (){
                    setState(() {
                      isCode = !isCode;
                    });
                  },child: Text("${getTranslated(context, 'EnterCode')}",style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w600),),color: colors.primary,),
                ),


               isCode == true ? Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black)
                  ),
                  child: Column(
                    children: [
                      Text("${getTranslated(context, 'EnterPincodeHere')}",style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: codeController,
                        style: TextStyle(color: Colors.grey),
                        keyboardType: TextInputType.number,
                        maxLength: 9,
                        decoration: InputDecoration(
                          hintText: "${getTranslated(context, 'EnterPincodeHere')}",
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.black)
                          )
                        ),
                      ),
                        SizedBox(height: 20,),
                      MaterialButton(onPressed: (){
                       if(codeController.text.isEmpty){
                         var snackBar = SnackBar(
                           content: Text('Enter valid code!'),
                         );
                         ScaffoldMessenger.of(context).showSnackBar(snackBar);
                       }
                       else{
                         checkCode();
                       }
                      },child: Text("${getTranslated(context, 'submit')}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 15),),color: colors.primary,shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                      ),)
                    ],
                  ),
                ) : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
