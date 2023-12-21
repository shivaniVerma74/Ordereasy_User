import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/response_recomndet_products.dart';
import 'package:eshop_multivendor/Provider/FavoriteProvider.dart';
import 'package:eshop_multivendor/Screen/Cart.dart';
import 'package:eshop_multivendor/Screen/Dashboard.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/Login.dart';
import 'package:eshop_multivendor/Screen/Product_Detail.dart';
import 'package:eshop_multivendor/Screen/Seller_Details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Provider/UserProvider.dart';

class SubCategory extends StatefulWidget {
  final String title;
  final String? sellerId;
  final catId;
  final sellerData;
  final String? subCatName;
  final String? subCatAddress;
  final String? subCatLogo;

  const SubCategory({
        Key? key,
      required this.title,
      this.sellerId,
      this.sellerData,
    this.subCatName,
    this.subCatAddress,
    this.subCatLogo,
      this.catId})
      : super(key: key);

  @override
  State<SubCategory> createState() => _SubCategoryState();
}

class _SubCategoryState extends State<SubCategory> {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  dynamic subCatData = [];
  var recommendedProductsData = [];
  bool mount = false;
  late ResponseRecomndetProducts responseProducts;
  var newData;
  StreamController<dynamic> productStream = StreamController();
  var imageBase = "";
  List<TextEditingController> _controller = [];
  bool _isLoading = true, _isProgress = false;
  bool _isNetworkAvail = true;
  late SharedPreferences prefs;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.catId);
    print("sellerId is aa ${widget.sellerId}");
    print("catId is ${widget.catId}");
    getSubCategory(widget.sellerId, widget.catId);
    getRecommended(widget.sellerId);
  }

  @override
  void dispose() {
    super.dispose();
    productStream.close();
  }



  @override
  Widget build(BuildContext context) {
    print(imageBase);
    return Scaffold(
      // appBar: getAppBar(widget.title, context),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
                },
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
          widget.title,
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
        ),
        actions: <Widget>[

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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder<dynamic>(
                stream: productStream.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator());
                  }
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 90),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 60,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width / 40,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Recommended Products',
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w600),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 150,
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: snapshot.data["data"].length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 1.0,
                            childAspectRatio: 1.0,
                            mainAxisSpacing: 4.5,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            dynamic model = snapshot.data["data"][index];
                            return InkWell(
                              onTap: () => onTapGoDetails(
                                  index: index, response: snapshot.data!),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width / 50),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                  child: new Card(
                                      child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                        child: FadeInImage(
                                          image: CachedNetworkImageProvider(
                                            snapshot.data["data"][index]
                                                    ["image"]
                                                .toString(),
                                          ),
                                          fadeInDuration:
                                              Duration(milliseconds: 120),
                                          fit: BoxFit.cover,
                                          height: 120,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          // width: 120,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  erroWidget(120),
                                          placeholder: placeHolder(120),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            EdgeInsets.only(top: 5, left: 5),
                                        child: Text(
                                          snapshot.data["data"][index]["name"].toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                        Row(
                                        children: [
                                          SizedBox(width: 5,),
                                          Text(MONEY_TYPE),
                                          Text("${snapshot.data["data"][index]["min_max_price"]["max_special_price"]}"),
                                          Text(" ${snapshot.data["data"][index]["min_max_price"]["max_price"]}" , style: TextStyle(
                                            decoration: TextDecoration.lineThrough , fontSize: 10
                                          ),),
                                        ],
                                      ),
                                    ],
                                  )),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );

                  // new
                }),
            // InkWell(
            //   onTap: () {
            //     Product model = Product.fromJson(newData["data"][0]);
            //     Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => ProductDetail(
            //               index: 0,
            //               model: model,
            //               secPos: 0,
            //               list: false,
            //             )));
            //   },
            //   child: Container(
            //     height: 60.0,
            //     width: 60.0,
            //     color: Colors.orange,
            //     child: Text("dsddd"),
            //   ),
            // ),
            mount
                ? subCatData.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: subCatData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            child: ListTile(
                              onTap: () {

                                print("checking data before going in ${widget.sellerData}");
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SellerProfile(
                                          search: false,
                                              sellerID: widget.sellerId,
                                              subCatId: subCatData[index]["id"],
                                              sellerData: subCatData[index],
                                          subCatName: widget.subCatName,
                                          subCatAddress: widget.subCatAddress,
                                          subCatLogo: widget.subCatLogo,
                                            )));
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    "$imageBase${subCatData[index]["image"] ?? ""}"),
                              ),
                              title: Text(subCatData[index]["name"] ?? "",
                                style: Theme.of(
                                    context)
                                    .textTheme
                                    .caption!
                                    .copyWith(
                                  color: Theme.of(
                                      context)
                                      .colorScheme
                                      .fontColor,
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          );
                        },
                      )
                    : Center(child: Text("No Sub Category"))
                : Text(""),
          ],
        ),
      ),
    );
  }

  getSubCategory(sellerId, catId) async {
    var parm = {};
    if (catId != null) {
      parm = {"seller_id": "$sellerId", "cat_id": "$catId"};
    } else {
      parm = {"seller_id": "$sellerId"};
    }
      print("mmmmmmmmmmmmmmm ${parm}");
    apiBaseHelper.postAPICall(getSubCatBySellerId, parm).then((value) {
      setState(() {
        subCatData = value["recommend_products"];
        imageBase = value["image_path"];
        mount = true;

        print("subCatData is ${subCatData.length}");
        // print("subCatData at 0 index is ${subCatData[0]}");
      });
    });
  }

  getRecommended(sellerId) async {
    // var parm = {"seller_id": "$sellerId"};
    // try {
    var parm = {"seller_id": sellerId};
    print("subcategory screen request ${parm}");
    var data = await apiBaseHelper.postAPINew(recommendedProductapi, parm);
    newData = data;
    setState(() {});
    // responseProducts = ResponseRecomndetProducts.fromJson(newData);
    if (newData["data"].isNotEmpty) {
      productStream.sink.add(newData);
    } else {
      productStream.sink.addError("");
    }
    // } catch (e) {
    //   productStream.sink.addError('ddd');
    // }
  }

  onTapGoDetails({response, index}) {
    Product model = Product.fromJson(response["data"][0]);
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProductDetail(
              index: index,
              model: model,
              secPos: 0,
              list: false,
            )));
  }

}
