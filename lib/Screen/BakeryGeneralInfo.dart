import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BakeryGeneralInfo extends StatefulWidget {
  final sellerData;
  BakeryGeneralInfo({Key? key, required this.sellerData}) : super(key: key);

  @override
  State<BakeryGeneralInfo> createState() => _BakeryGeneralInfoState();
}

class _BakeryGeneralInfoState extends State<BakeryGeneralInfo> {
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
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Column(
         // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //SizedBox(height: 15),
            if(genData?['qrcode'] != null)
           Padding(
             padding: const EdgeInsets.only(top: 20),
             child: Container(
              child: Image.network(
                "${genData?['qrcode']}",
              // version: QrVersions.auto,
        ),
          ),
           ),
            SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bakery Name:  ",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                width: 130,
                                child: Text("${genData?['username']}",maxLines: 1,overflow: TextOverflow.ellipsis,),
                              ),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              Text("Email:  ",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text("${genData?['email']}"),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              Text("Mobile:  ",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Text("${genData?['mobile']}"),
                            ],
                          ),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              Text("Address:  ",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                              Container(
                                width: 140,
                                  child: Text("${genData?['address']}", overflow: TextOverflow.ellipsis,
                                 )),
                            ],
                          ),
                          SizedBox(height: 5,),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child:
                          genData?['logo'] != null?
                          CachedNetworkImage(imageUrl: genData?['logo'], height: 70, width: 70, fit: BoxFit.contain,): Text("")
                      )
                    )
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
