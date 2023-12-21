
import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:developer';

import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:http/http.dart' as http;
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Screen/ProductList.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart';

class SellerProfile extends StatefulWidget {
  final String? sellerID,
      sellerName,
      sellerImage,
      sellerRating,
      storeDesc,
      sellerStoreName , subCatId;
  final String? subCatName;
  final String? subCatAddress;
  final String? subCatLogo;

  final sellerData;
  final search;
  final extraData;

  SellerProfile(
      {Key? key,
      this.sellerID,
        this.subCatName,
        this.subCatAddress,
        this.subCatLogo,
      this.sellerName,
      this.sellerImage,
      this.sellerRating,
      this.storeDesc,
      this.sellerStoreName, this.subCatId, this.sellerData, this.search, this.extraData})
      : super(key: key);

  @override
  State<SellerProfile> createState() => _SellerProfileState();
}

class _SellerProfileState extends State<SellerProfile>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();
  late TabController _tabController;
  bool isLoading = false;
  bool isDescriptionVisible = false;


  @override
  void initState() {
    print("checking data here  ${widget.subCatName}");


    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title:
        widget.search?
        Text("${widget.sellerName}" , style: TextStyle(color: colors.primary),):
      Text("${widget.subCatName}" , style: TextStyle(color: colors.primary),)

      ),
      body:
      isLoading == true? Center(child: CircularProgressIndicator()):
      Material(
        child:
        Column(
          children: [
            widget.search
                ? Container(
              child: Card(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(widget.sellerImage!),
                    ),
                    title: Text("${widget.sellerName}".toUpperCase()),
                    subtitle: Text(
                      "${widget.extraData['address']}",
                      maxLines: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: colors.primary,
                            ),
                            Text("${widget.extraData["rating"]}")
                          ],
                        ),
                        widget.extraData["estimated_time"] !=""?
                        Column(
                          children: [
                            Text("Delivery Time"),
                            Text(
                              "${widget.extraData["estimated_time"]}",
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ):Container(),
                        widget.extraData["food_person"] !=""?
                        Column(
                          children: [
                            Text("₹/Person"),
                            Text("${widget.extraData["food_person"]}"),
                          ],
                        ):Container()
                      ],),
                  ),
                ],),
              ),
            )
                : Stack(
                  children: [
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(imageUrl+widget.sellerData!['image']),
                          fit: BoxFit.fill
                        )
                      ),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        width: MediaQuery.of(context).size.width * 0.35,
                        color: Colors.black.withOpacity(0.5),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(widget.subCatLogo.toString()),
                              ),
                              title: Text("${widget.subCatName}".toUpperCase(),
                                style: TextStyle(
                                  color: colors.whiteTemp
                                ),
                              ),
                              subtitle: Text(
                                "${widget.subCatAddress}",
                                maxLines: 2,
                                style: TextStyle(
                                    color: colors.whiteTemp
                                ),
                              ),
                            ),
                            // ListTile(title: Text("Address"), subtitle: Text("${widget.sellerData.address}"),),
                            // Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Column(
                            //         children: [
                            //           Icon(
                            //             Icons.star_rounded,
                            //             color: colors.primary,
                            //           ),
                            //           Text("${widget.sellerData.seller_rating}",
                            //             style: TextStyle(
                            //                 color: colors.whiteTemp
                            //             ),
                            //           )
                            //         ],
                            //       ),
                            //       widget.sellerData.estimated_time !=""?
                            //       Column(
                            //         children: [
                            //           Text("Delivery Time",
                            //             style: TextStyle(
                            //                 color: colors.whiteTemp
                            //             ),
                            //           ),
                            //           Text(
                            //             "${widget.sellerData.estimated_time}",
                            //             style: TextStyle(color: Colors.green),
                            //           ),
                            //         ],
                            //       ):Container(),
                            //       widget.sellerData.food_person !=""?
                            //       Column(
                            //         children: [
                            //           Text("₹/Person",
                            //             style: TextStyle(
                            //                 color: colors.whiteTemp
                            //             ),
                            //           ),
                            //           Text("${widget.sellerData.food_person}",
                            //             style: TextStyle(
                            //                 color: colors.whiteTemp
                            //             ),
                            //           ),
                            //         ],
                            //       ):Container()
                            //     ],),
                            // ),
                            SizedBox(height: 10,)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            Expanded(
              child: ProductList(
                fromSeller: true,
                name: "",
                id: widget.sellerID,
                subCatId: widget.subCatId,
                tag: false,
              ),
            ),
          ],
        ),
      ),
    );

    DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: getAppBar(getTranslated(context, 'SELLER_DETAILS')!, context),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: getTranslated(context, 'DETAILS')!),
                  Tab(text: getTranslated(context, 'PRODUCTS')),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    detailsScreen(),
                    ProductList(
                      fromSeller: true,
                      name: "",
                      id: widget.sellerID,
                      tag: false,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar:
      ),
    );
  }

  // Future fetchSellerDetails() async {
  //   var parameter = {};
  //   final sellerData = await apiBaseHelper.postAPICall(getSellerApi, parameter);
  //   List<Seller> sellerDetails = [];
  //   bool error = sellerData["error"];
  //   String? msg = sellerData["message"];
  //   if (!error) {
  //     var data = sellerData["data"];
  //     sellerDetails =
  //         (data as List).map((data) => Seller.fromJson(data)).toList();
  //   } else {
  //     setSnackbar(msg!, context);
  //   }
  //
  //   return sellerDetails;
  // }

  Widget detailsScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: CircleAvatar(
              radius: 80,
              backgroundColor: colors.primary,
              backgroundImage: NetworkImage(widget.sellerImage!),
              // child: ClipRRect(
              //   borderRadius: BorderRadius.circular(40),
              //   child: FadeInImage(
              //     fadeInDuration: Duration(milliseconds: 150),
              //     image: NetworkImage(widget.sellerImage!),
              //
              //     fit: BoxFit.cover,
              //     placeholder: placeHolder(100),
              //     imageErrorBuilder: (context, error, stackTrace) =>
              //         erroWidget(100),
              //   ),
              // )
            ),
          ),
          getHeading(widget.sellerStoreName!),
          SizedBox(
            height: 5,
          ),
          Text(
            widget.sellerName!,
            style: TextStyle(
                color: Theme.of(context).colorScheme.lightBlack2, fontSize: 16),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: colors.primary),
                      child: Icon(
                        Icons.star,
                        color: Theme.of(context).colorScheme.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      widget.sellerRating!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            color: colors.primary),
                        child: Icon(
                          Icons.description,
                          color: Theme.of(context).colorScheme.white,
                          size: 30,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isDescriptionVisible = !isDescriptionVisible;
                        });
                      },
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'DESCRIPTION')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: colors.primary),
                          child: Icon(
                            Icons.list_alt,
                            color: Theme.of(context).colorScheme.white,
                            size: 30,
                          ),
                        ),
                        onTap: () => _tabController
                            .animateTo((_tabController.index + 1) % 2)),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      getTranslated(context, 'PRODUCTS')!,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.lightBlack2,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
              visible: isDescriptionVisible,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 8,
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: colors.primary)),
                child: SingleChildScrollView(
                    child: Text(
                  (widget.storeDesc != "" || widget.storeDesc != null)
                      ? "${widget.storeDesc}"
                      : getTranslated(context, "NO_DESC")!,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack2),
                )),
              ))
        ],
      ),
    );
    // return FutureBuilder(
    //     future: fetchSellerDetails(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         // If we got an error
    //         if (snapshot.hasError) {
    //           return Center(
    //             child: Text(
    //               '${snapshot.error} Occured',
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           );
    //
    //           // if we got our data
    //         } else if (snapshot.hasData) {
    //           // Extracting data from snapshot object
    //           var data = snapshot.data;
    //           print("data is $data");
    //
    //           return Center(
    //             child: Text(
    //               'Hello',
    //               style: TextStyle(fontSize: 18),
    //             ),
    //           );
    //         }
    //       }
    //       return shimmer();
    //     });
  }

  Widget getHeading(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headline6!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.fontColor,
          ),
    );
  }

  Widget getRatingBarIndicator(var ratingStar, var totalStars) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: RatingBarIndicator(
        rating: ratingStar,
        itemBuilder: (context, index) => const Icon(
          Icons.star_outlined,
          color: colors.yellow,
        ),
        itemCount: totalStars,
        itemSize: 20.0,
        direction: Axis.horizontal,
        unratedColor: Colors.transparent,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
