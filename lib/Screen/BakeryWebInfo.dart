import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Screen/BakeryWebview.dart';
import 'package:flutter/material.dart';


class BakeryWebInfo extends StatefulWidget {
  final sellerData;
  BakeryWebInfo({Key? key,  required this.sellerData}) : super(key: key);

  @override
  State<BakeryWebInfo> createState() => _BakeryWebInfoState();
}

class _BakeryWebInfoState extends State<BakeryWebInfo> {
  Map? genData;
  bool loading=false;


  getData() {
    setState(() {
      loading = true;
    });
    genData =  jsonDecode(widget.sellerData);
    print("sellerData_in_detail_tab__________${jsonDecode(widget.sellerData)}");
    loading = false;
    setState(() {
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:
      loading == true? Center(child: CircularProgressIndicator(),):
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 15),


            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                        genData?['national_identity_card'] != null?
                        CachedNetworkImage(imageUrl: imageUrl+genData?['national_identity_card'], height: 150, width: MediaQuery.of(context).size.width, fit: BoxFit.cover,): Text("")
                    ),
                    SizedBox(height: 15,),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Click here:  ",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BakeryWebview(url: genData?['store_url'],)));
                          },
                          child: Text("${genData?['store_url']}",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, decoration: TextDecoration.underline, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
