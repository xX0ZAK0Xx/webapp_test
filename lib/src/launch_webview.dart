import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart";
import "package:url_launcher/url_launcher.dart";

class LaunchWebView extends StatefulWidget {
  final String launchUrl;
  final String title;

  const LaunchWebView({super.key, required this.launchUrl, required this.title});

  @override
  LaunchWebViewState createState() => LaunchWebViewState();
}

class LaunchWebViewState extends State<LaunchWebView> {
  late final InAppWebViewController? _webViewController;
  late final PullToRefreshController _pullToRefreshController;

  final ValueNotifier<String> _currentUrl = ValueNotifier<String>('');
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);

  final InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      clearCache: true,
    ),
    android: AndroidInAppWebViewOptions(useHybridComposition: true),
    ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
  );

  @override
  void initState() {
    super.initState();
    _currentUrl.value = widget.launchUrl;

    _pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue),
      onRefresh: () async {
        if (Platform.isAndroid) {
          await _webViewController?.reload();
        } else if (Platform.isIOS) {
          final url = await _webViewController?.getUrl();
          if (url != null) {
            _webViewController?.loadUrl(urlRequest: URLRequest(url: url));
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _webViewController?.stopLoading();
    _currentUrl.dispose();
    _progress.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (await _webViewController?.canGoBack() ?? false) {
      _webViewController?.goBack();
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
          child: InAppWebView(
            initialUrlRequest:
                URLRequest(url: WebUri.uri(Uri.parse(_currentUrl.value))),
            initialOptions: options,
            pullToRefreshController: _pullToRefreshController,
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              if (url != null) _currentUrl.value = url.toString();
            },
            onLoadStop: (controller, url) async {
              _pullToRefreshController.endRefreshing();
              if (url != null) _currentUrl.value = url.toString();
            },
            onProgressChanged: (controller, progress) {
              _progress.value = progress / 100;
              if (progress == 100) {
                _pullToRefreshController.endRefreshing();
              }
            },
            shouldOverrideUrlLoading:
                (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri != null &&
                  !["http", "https", "file", "chrome", "data", "javascript", "about"]
                      .contains(uri.scheme)) {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT,
              );
            },
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_back),
              label: 'Back',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.refresh),
              label: 'Reload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.arrow_forward),
              label: 'Forward',
            ),
          ],
          onTap: (index) async {
            switch (index) {
              case 0:
                if (await _webViewController?.canGoBack() ?? false) {
                  _webViewController?.goBack();
                }
                break;
              case 1:
                _webViewController?.reload();
                break;
              case 2:
                if (await _webViewController?.canGoForward() ?? false) {
                  _webViewController?.goForward();
                }
                break;
            }
          },
        ),
      ),
    );
  }
}
