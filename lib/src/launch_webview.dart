// // ignore_for_file: deprecated_member_use

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LaunchWebView extends StatefulWidget {
//   final String launchUrl;
//   final String title;

//   const LaunchWebView({
//     super.key,
//     required this.launchUrl,
//     required this.title,
//   });

//   @override
//   LaunchWebViewState createState() => LaunchWebViewState();
// }

// class LaunchWebViewState extends State<LaunchWebView> {
//   final GlobalKey webViewKey = GlobalKey();
//   InAppWebViewController? webViewController;
//   late PullToRefreshController pullToRefreshController;
//   double loadingProgress = 0;

//   @override
//   void initState() {
//     super.initState();

//     pullToRefreshController = PullToRefreshController(
//       onRefresh: () async {
//         if (Platform.isAndroid) {
//           webViewController?.reload();
//         } else if (Platform.isIOS) {
//           webViewController?.loadUrl(
//             urlRequest: URLRequest(url: await webViewController?.getUrl()),
//           );
//         }
//       },
//     );
//   }

//   Future<bool> _onWillPop() async {
//     if (await webViewController?.canGoBack() ?? false) {
//       webViewController?.goBack();
//       return false;
//     } else {
//       return await _showExitConfirmationDialog();
//     }
//   }

//   Future<bool> _showExitConfirmationDialog() async {
//     return await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Exit App'),
//         content: const Text('Do you want to close the app?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('No'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Yes'),
//           ),
//         ],
//       ),
//     ) ??
//     false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           title: Text(widget.title),
//         ),
//         body: InAppWebView(
//           key: webViewKey,
//           initialUrlRequest: URLRequest(
//               url: WebUri.uri(
//                   Uri.parse(widget.launchUrl))), // Corrected line
//           pullToRefreshController: pullToRefreshController,
//           onWebViewCreated: (controller) {
//             webViewController = controller;
//           },
//           onLoadStart: (controller, url) {
//             setState(() {
//               loadingProgress = 0;
//             });
//           },
//           onLoadStop: (controller, url) async {
//             pullToRefreshController.endRefreshing();
//             setState(() {
//               loadingProgress = 1.0;
//             });
//           },
//           onLoadError: (controller, url, code, message) {
//             pullToRefreshController.endRefreshing();
//           },
//           onProgressChanged: (controller, progress) {
//             setState(() {
//               loadingProgress = progress / 100;
//             });
//           },
//           androidOnPermissionRequest: (controller, origin, resources) async {
//             return PermissionRequestResponse(
//               resources: resources,
//               action: PermissionRequestResponseAction.GRANT,
//             );
//           },
//           shouldOverrideUrlLoading: (controller, navigationAction) async {
//             final uri = navigationAction.request.url;
//             if (uri != null && !["http", "https"].contains(uri.scheme)) {
//               if (await canLaunch(uri.toString())) {
//                 await launch(uri.toString());
//                 return NavigationActionPolicy.CANCEL;
//               }
//             }
//             return NavigationActionPolicy.ALLOW;
//           },
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: deprecated_member_use

import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart";
import "package:url_launcher/url_launcher.dart";

class LaunchWebView extends StatefulWidget {
  final String launchUrl;
  final String title;

  const LaunchWebView(
      {super.key, required this.launchUrl, required this.title});

  @override
  LaunchWebViewState createState() => LaunchWebViewState();
}

class LaunchWebViewState extends State<LaunchWebView> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    url = widget.launchUrl;

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    webViewController?.stopLoading();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (await webViewController?.canGoBack() ?? false) {
      webViewController?.goBack();
      return false;
    } else {
      return await _showExitConfirmationDialog();
    }
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to close the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ??
    false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(widget.title),
          ),
          body: SafeArea(
        child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  androidOnPermissionRequest:
                      (controller, origin, resources) async {
                    return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    var uri = navigationAction.request.url;
      
                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri?.scheme)) {
                      if (await canLaunch(url)) {
                        await launch(
                          url,
                        );
      
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
      
                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {},
                  onCloseWindow: (controller) {},
                ),
              ],
            ),
          ),
        ]),
      )),
    );
  }
}
