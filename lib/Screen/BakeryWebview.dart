import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';



class BakeryWebview extends StatefulWidget {
  final url;
  BakeryWebview({Key? key,  required this.url}) : super(key: key);

  @override
  State<BakeryWebview> createState() => _BakeryWebviewState();
}

class _BakeryWebviewState extends State<BakeryWebview> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.white,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: EdgeInsets.all(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(4),
                onTap: () => Navigator.of(context).pop(),
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
          "Bakery Web Info",
          style: TextStyle(color: colors.primary, fontWeight: FontWeight.normal),
        ),
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: '${widget.url}',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
          onProgress: (int progress) {
            print("WebView is loading (progress : $progress%)");
          },
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
        );
      }),
      // floatingActionButton: favoriteButton(),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
         setSnackbar('${message.message}', context);
        });
  }

  // Widget favoriteButton() {
  //   return FutureBuilder<WebViewController>(
  //       future: _controller.future,
  //       builder: (BuildContext context,
  //           AsyncSnapshot<WebViewController> controller) {
  //         if (controller.hasData) {
  //           return FloatingActionButton(
  //             onPressed: () async {
  //               final String url = (await controller.data!.currentUrl())!;
  //               setSnackbar('${url}', context);
  //             },
  //             child: const Icon(Icons.favorite),
  //           );
  //         }
  //         return Container();
  //       });
  // }
}

// enum MenuOptions {
//   showUserAgent,
//   listCookies,
//   clearCookies,
//   addToCache,
//   listCache,
//   clearCache,
//   navigationDelegate,
// }
//
// class SampleMenu extends StatelessWidget {
//   SampleMenu(this.controller);
//
//   final Future<WebViewController> controller;
//   final CookieManager cookieManager = CookieManager();
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<WebViewController>(
//       future: controller,
//       builder:
//           (BuildContext context, AsyncSnapshot<WebViewController> controller) {
//         return PopupMenuButton<MenuOptions>(
//           onSelected: (MenuOptions value) {
//             switch (value) {
//               case MenuOptions.showUserAgent:
//                 _onShowUserAgent(controller.data!, context);
//                 break;
//               case MenuOptions.listCookies:
//                 _onListCookies(controller.data!, context);
//                 break;
//               case MenuOptions.clearCookies:
//                 _onClearCookies(context);
//                 break;
//               case MenuOptions.addToCache:
//                 _onAddToCache(controller.data!, context);
//                 break;
//               case MenuOptions.listCache:
//                 _onListCache(controller.data!, context);
//                 break;
//               case MenuOptions.clearCache:
//                 _onClearCache(controller.data!, context);
//                 break;
//               case MenuOptions.navigationDelegate:
//                 _onNavigationDelegateExample(controller.data!, context);
//                 break;
//             }
//           },
//           itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
//             PopupMenuItem<MenuOptions>(
//               value: MenuOptions.showUserAgent,
//               child: const Text('Show user agent'),
//               enabled: controller.hasData,
//             ),
//             const PopupMenuItem<MenuOptions>(
//               value: MenuOptions.listCookies,
//               child: Text('List cookies'),
//             ),
//             const PopupMenuItem<MenuOptions>(
//               value: MenuOptions.clearCookies,
//               child: Text('Clear cookies'),
//             ),
//             const PopupMenuItem<MenuOptions>(
//               value: MenuOptions.addToCache,
//               child: Text('Add to cache'),
//             ),
//             const PopupMenuItem<MenuOptions>(
//               value: MenuOptions.listCache,
//               child: Text('List cache'),
//             ),
//             const PopupMenuItem<MenuOptions>(
//               value: MenuOptions.clearCache,
//               child: Text('Clear cache'),
//             ),
//             const PopupMenuItem<MenuOptions>(
//               value: MenuOptions.navigationDelegate,
//               child: Text('Navigation Delegate example'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _onShowUserAgent(
//       WebViewController controller, BuildContext context) async {
//     // Send a message with the user agent string to the Toaster JavaScript channel we registered
//     // with the WebView.
//     await controller.evaluateJavascript(
//         'Toaster.postMessage("User Agent: " + navigator.userAgent);');
//   }
//
//   void _onListCookies(
//       WebViewController controller, BuildContext context) async {
//     final String cookies =
//     await controller.evaluateJavascript('document.cookie');
//     // ignore: deprecated_member_use
//     Scaffold.of(context).showSnackBar(SnackBar(
//       content: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           const Text('Cookies:'),
//           _getCookieList(cookies),
//         ],
//       ),
//     ));
//   }
//
//   void _onAddToCache(WebViewController controller, BuildContext context) async {
//     await controller.evaluateJavascript(
//         'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
//     // ignore: deprecated_member_use
//     Scaffold.of(context).showSnackBar(const SnackBar(
//       content: Text('Added a test entry to cache.'),
//     ));
//   }
//
//   void _onListCache(WebViewController controller, BuildContext context) async {
//     await controller.evaluateJavascript('caches.keys()'
//         '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
//         '.then((caches) => Toaster.postMessage(caches))');
//   }
//
//   void _onClearCache(WebViewController controller, BuildContext context) async {
//     await controller.clearCache();
//     // ignore: deprecated_member_use
//     Scaffold.of(context).showSnackBar(const SnackBar(
//       content: Text("Cache cleared."),
//     ));
//   }
//
//   void _onClearCookies(BuildContext context) async {
//     final bool hadCookies = await cookieManager.clearCookies();
//     String message = 'There were cookies. Now, they are gone!';
//     if (!hadCookies) {
//       message = 'There are no cookies.';
//     }
//     // ignore: deprecated_member_use
//     Scaffold.of(context).showSnackBar(SnackBar(
//       content: Text(message),
//     ));
//   }
//
//   void _onNavigationDelegateExample(
//       WebViewController controller, BuildContext context) async {
//     final String contentBase64 =
//     base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
//     await controller.loadUrl('data:text/html;base64,$contentBase64');
//   }
//
//   Widget _getCookieList(String cookies) {
//     if (cookies == null || cookies == '""') {
//       return Container();
//     }
//     final List<String> cookieList = cookies.split(';');
//     final Iterable<Text> cookieWidgets =
//     cookieList.map((String cookie) => Text(cookie));
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       mainAxisSize: MainAxisSize.min,
//       children: cookieWidgets.toList(),
//     );
//   }
// }
//
// class NavigationControls extends StatelessWidget {
//   const NavigationControls(this._webViewControllerFuture)
//       : assert(_webViewControllerFuture != null);
//
//   final Future<WebViewController> _webViewControllerFuture;
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<WebViewController>(
//       future: _webViewControllerFuture,
//       builder:
//           (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
//         final bool webViewReady =
//             snapshot.connectionState == ConnectionState.done;
//         final WebViewController controller = snapshot.data!;
//         return Row(
//           children: <Widget>[
//             IconButton(
//               icon: const Icon(Icons.arrow_back_ios),
//               onPressed: !webViewReady
//                   ? null
//                   : () async {
//                 if (await controller.canGoBack()) {
//                   await controller.goBack();
//                 } else {
//                   // ignore: deprecated_member_use
//                   Scaffold.of(context).showSnackBar(
//                     const SnackBar(content: Text("No back history item")),
//                   );
//                   return;
//                 }
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.arrow_forward_ios),
//               onPressed: !webViewReady
//                   ? null
//                   : () async {
//                 if (await controller.canGoForward()) {
//                   await controller.goForward();
//                 } else {
//                   // ignore: deprecated_member_use
//                   Scaffold.of(context).showSnackBar(
//                     const SnackBar(
//                         content: Text("No forward history item")),
//                   );
//                   return;
//                 }
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.replay),
//               onPressed: !webViewReady
//                   ? null
//                   : () {
//                 controller.reload();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }