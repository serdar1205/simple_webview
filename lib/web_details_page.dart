import 'package:flutter/material.dart';
import 'package:internet_connectivity_checker/internet_connectivity_checker.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'constants.dart';

class WebDetailsPage extends StatefulWidget {
  const WebDetailsPage({super.key,});

  @override
  State<WebDetailsPage> createState() => _WebDetailsPageState();
}

class _WebDetailsPageState extends State<WebDetailsPage> {
  int? progres;
  WebViewController? webViewController;

  bool canGoBack = false, canGoForward = false;
  bool hasInternet = false;

  void updateNavigationButtons() async {
    if (webViewController != null) {
      canGoBack = await webViewController!.canGoBack();
      canGoForward = await webViewController!.canGoForward();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    // if (WebView.platform is AndroidWebView) {
    //   WebView.platform = SurfaceAndroidWebView();
    // }
  }

  @override
  Widget build(BuildContext context) {
    //print(hasInternet);
    return ConnectivityBuilder(
      builder: (ConnectivityStatus status) {
        if (status == ConnectivityStatus.online) {
          hasInternet = true;
          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: canGoBack
                      ? () {
                    if (webViewController != null) {
                      webViewController!.goBack();
                      updateNavigationButtons();
                    }
                  }
                      : null,
                  icon: const Icon(Icons.keyboard_arrow_left),
                ),
                IconButton(
                  onPressed: canGoForward
                      ? () {
                    if (webViewController != null) {
                      webViewController!.goForward();
                      updateNavigationButtons();
                    }
                  }
                      : null,
                  icon: const Icon(Icons.keyboard_arrow_right),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  onPressed: () {
                    if (webViewController != null) {
                      webViewController!.reload();
                    }
                  },
                  icon: const Icon(Icons.restart_alt),
                ),
              ],
              bottom: progres != null && progres! < 100
                  ? PreferredSize(
                preferredSize: const Size(double.infinity, 4),
                child: LinearProgressIndicator(
                  value: progres!.ceilToDouble() / 100,
                  color: Colors.blue,
                ),
              )
                  : null,
            ),
            body: WebView(
              initialUrl: baseUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onProgress: (progress) {
                setState(() {
                  progres = progress;
                });
              },
              onWebResourceError: (error) {
                print('WebResourceError: $error');
              },
              onWebViewCreated: (controller) {
                webViewController = controller;
                updateNavigationButtons();

              },
              onPageStarted: (url) async {
                updateNavigationButtons();
                // if (url.contains('myapp.com')) {
                //  Future.delayed(Duration(milliseconds: 300),(){
                //    webViewController!.runJavascript(
                //        "document.getElementsByTagName('footer')[0].style.display='none'"
                //    );
                //  });
                // }
              },
              onPageFinished: (url) {
             //   updateNavigationButtons();
              },
              gestureNavigationEnabled: true,
            ),
          );
        } else if (status == ConnectivityStatus.offline) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Check connection',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      //checkInternetConnection();
                      if (hasInternet) {
                      webViewController?.reload();
                         }
                    },
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        } else {
          // status == ConnectivityStatus.checking
          return const Scaffold(
            body: Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
      },
    );
  }
}
