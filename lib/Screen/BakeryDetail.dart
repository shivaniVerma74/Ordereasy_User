import 'dart:convert';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Screen/BakeryGeneralInfo.dart';
import 'package:eshop_multivendor/Screen/BakeryWebInfo.dart';
import 'package:flutter/material.dart';

class BakeryDetail extends StatefulWidget {
  final sellerData;
  BakeryDetail({Key? key, this.sellerData}) : super(key: key);

  @override
  State<BakeryDetail> createState() => _BakeryDetailState();
}

class _BakeryDetailState extends State<BakeryDetail> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    print("sellerData____________${jsonDecode(widget.sellerData)}");
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
         // titleSpacing: 0,
          backgroundColor: Theme.of(context).colorScheme.white,
          leading: Builder(
            builder: (BuildContext context) {
              return InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: colors.primary,
                ),
              );
            },
          ),
          title: Text(
            "Bakery Details",
            style: TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
          ),
          bottom: TabBar(
            controller: tabController,
            labelColor: colors.primary,
            unselectedLabelColor: Theme.of(context)
                .colorScheme.lightBlack2,
            indicator: ShapeDecoration(

              shape: UnderlineInputBorder(

                  borderSide: BorderSide(
                      color: colors.primary,
                      width: 3,
                      style: BorderStyle.solid),
              ),
            ),
            tabs: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'General Info',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Web Info',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
            onTap: (index) {
              tabController.index = index;
              setState(() {});
            },
          ),
        ),
        body: TabBarView(
          controller: tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            ///1st Index
            BakeryGeneralInfo(sellerData: widget.sellerData),

            ///2nd index
            BakeryWebInfo(sellerData: widget.sellerData)
          ],
        ),
      ),
    );
  }
}
