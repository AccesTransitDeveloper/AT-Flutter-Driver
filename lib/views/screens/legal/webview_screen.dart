import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/webview_data_model.dart';
import '../../../viewmodels/webview_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';

/// Main WebView Screen - equivalent to Kotlin's WebViewScreen composable
/// Handles ViewModel state and navigation callbacks
class WebViewScreen extends ConsumerStatefulWidget {
  final WebViewDataModel? webViewData;
  final void Function(String?)? onNavigateWithPaymentData;

  const WebViewScreen({
    super.key,
    this.webViewData,
    this.onNavigateWithPaymentData,
  });

  @override
  ConsumerState<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ConsumerState<WebViewScreen> {
  @override
  void initState() {
    super.initState();
    // Set webViewData to ViewModel ONCE in initState - prevents infinite rebuild loop
    // equivalent to viewModel.onEvent(WebViewUIEvent.WebURL(webViewData))
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(webViewViewModelProvider.notifier).setWebViewData(widget.webViewData);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // NavigationLaunchEffect equivalent - handles navigation based on state
    ref.listen<WebViewState>(webViewViewModelProvider, (previous, next) {
      if (previous?.isNavigateToBackScreen != next.isNavigateToBackScreen) {
        debugPrint('💳 WebViewScreen: Navigate triggered - ${next.webViewMessage}');
        widget.onNavigateWithPaymentData?.call(next.webViewMessage);
      }
      if (previous?.isPaymentDone != next.isPaymentDone && next.isPaymentDone) {
        debugPrint('💳 WebViewScreen: Navigate triggered via socket');
        widget.onNavigateWithPaymentData?.call(next.webViewMessage);
      }
    });

    final viewState = ref.watch(webViewViewModelProvider);
    final title = widget.webViewData?.name ?? '';

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: colors.colorBackground,
        surfaceTintColor: colors.colorBackground,
        title: AppText.body(
          title,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.colorText),
          onPressed: () => context.goBack(),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _WebViewContent(
          webViewData: widget.webViewData,
          showLoading: viewState.isLoading,
          onLoading: (isLoading) {
            ref.read(webViewViewModelProvider.notifier).setLoading(isLoading);
          },
          onWebViewMessage: (message) {
            ref.read(webViewViewModelProvider.notifier).onWebViewMessage(message);
          },
        ),
      ),
    );
  }
}

/// WebView Content - equivalent to Kotlin's WebViewContent composable
/// Contains the actual WebView or PDF viewer
class _WebViewContent extends StatefulWidget {
  final WebViewDataModel? webViewData;
  final bool showLoading;
  final void Function(bool) onLoading;
  final void Function(String) onWebViewMessage;

  const _WebViewContent({
    required this.webViewData,
    required this.showLoading,
    required this.onLoading,
    required this.onWebViewMessage,
  });

  @override
  State<_WebViewContent> createState() => _WebViewContentState();
}

class _WebViewContentState extends State<_WebViewContent> {
  /// JavaScript bridge script - equivalent to Kotlin's WebAppInterface
  /// Creates Android.showToast that mimics @JavascriptInterface
  static const String _webAppInterfaceScript = '''
    (function() {
      if (typeof window.Android === 'undefined') {
        window.Android = {};
      }
      // Equivalent to @JavascriptInterface fun showToast(message: String)
      window.Android.showToast = function(message) {
        console.log('Android.showToast called with: ' + message);
        window.flutter_inappwebview.callHandler('showToast', message);
      };
      window.Android.postMessage = function(message) {
        console.log('Android.postMessage called with: ' + message);
        window.flutter_inappwebview.callHandler('showToast', message);
      };
      console.log('Android bridge initialized successfully');
    })();
  ''';

  /// Check if URL is a PDF - equivalent to webUrl()?.webURL?.endsWith(".pdf")
  bool get _isPdfUrl {
    final webUrl = widget.webViewData?.webURL;
    return webUrl != null && webUrl.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        // Equivalent to: if (webUrl()?.webURL?.endsWith(".pdf") == true) PDFViewer(...) else AndroidView(WebView...)
        if (_isPdfUrl)
          PDFViewer(url: widget.webViewData!.webURL!)
        else
          _buildWebView(),

        // Equivalent to: if (showLoading()) AppContentLoader(...)
        if (widget.showLoading)
          Center(
            child: CircularProgressIndicator(color: colors.colorPrimary),
          ),
      ],
    );
  }

  /// Build WebView - equivalent to AndroidView(factory = { WebView(context).apply { ... } })
  Widget _buildWebView() {
    final webViewData = widget.webViewData;

    // Determine initial data
    URLRequest? initialUrlRequest;
    InAppWebViewInitialData? initialData;

    // Equivalent to: if (webUrl()?.webURL?.isBlank() == false) loadUrl(...) else loadDataWithBaseURL(...)
    if (webViewData?.webURL != null && webViewData!.webURL!.isNotEmpty) {
      final decodedUrl = Uri.decodeFull(webViewData.webURL!);
      debugPrint('💳 WebView: Loading URL - $decodedUrl');
      initialUrlRequest = URLRequest(url: WebUri(decodedUrl));
    } else if (webViewData?.webContent != null && webViewData!.webContent!.isNotEmpty) {
      final decodedContent = Uri.decodeFull(webViewData.webContent!);
      debugPrint('💳 WebView: Loading HTML content (${decodedContent.length} chars)');
      // Equivalent to: loadDataWithBaseURL("https://fake.origin/", ...)
      initialData = InAppWebViewInitialData(
        data: decodedContent,
        baseUrl: WebUri('https://fake.origin/'),
        mimeType: 'text/html',
        encoding: 'utf-8',
      );
    }

    return InAppWebView(
      initialUrlRequest: initialUrlRequest,
      initialData: initialData,
      // Inject WebAppInterface script at DOCUMENT_START
      initialUserScripts: UnmodifiableListView([
        UserScript(
          source: _webAppInterfaceScript,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        ),
      ]),
      // Equivalent to WebView settings
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true, // settings.javaScriptEnabled = true
        domStorageEnabled: true, // settings.domStorageEnabled = true
        mediaPlaybackRequiresUserGesture: false, // settings.mediaPlaybackRequiresUserGesture = false
        allowsInlineMediaPlayback: true,
        useWideViewPort: true, // settings.useWideViewPort = true
        loadWithOverviewMode: true, // settings.loadWithOverviewMode = true
        supportZoom: true, // settings.setSupportZoom(true)
        builtInZoomControls: true, // settings.builtInZoomControls = true
        displayZoomControls: false, // settings.displayZoomControls = false
        allowFileAccess: true, // settings.allowFileAccess = true
        allowContentAccess: true, // settings.allowContentAccess = true
      ),
      // Equivalent to: addJavascriptInterface(WebAppInterface { onWebViewMessage.invoke(message) }, "Android")
      onWebViewCreated: (controller) {
        controller.addJavaScriptHandler(
          handlerName: 'showToast',
          callback: (args) {
            final message = args.isNotEmpty ? args[0]?.toString() : null;
            debugPrint('💳 WebView: showToast received - $message');
            if (message != null) {
              widget.onWebViewMessage(message);
            }
            return null;
          },
        );
      },
      onLoadStart: (controller, url) {
        debugPrint('💳 WebView: Page started - $url');
        widget.onLoading(true);
      },
      onLoadStop: (controller, url) {
        debugPrint('💳 WebView: Page finished - $url');
        widget.onLoading(false);
      },
      // Equivalent to CustomWebChromeClient.onProgressChanged
      onProgressChanged: (controller, progress) {
        widget.onLoading(progress < 100);
      },
      // Equivalent to CustomWebViewClient.shouldOverrideUrlLoading
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final url = navigationAction.request.url?.toString() ?? '';
        // Equivalent to: if (request.url.toString().startsWith("https://standard.paystack.co/close"))
        if (url.startsWith('https://standard.paystack.co/close')) {
          debugPrint('💳 WebView: Paystack close URL detected');
          return NavigationActionPolicy.ALLOW;
        }
        return NavigationActionPolicy.ALLOW;
      },
      onReceivedError: (controller, request, error) {
        debugPrint('💳 WebView error: ${error.description}');
      },
      onConsoleMessage: (controller, consoleMessage) {
        debugPrint('💳 WebView console: ${consoleMessage.message}');
      },
    );
  }
}

/// PDF Viewer - equivalent to Kotlin's PDFViewer composable
/// Uses flutter_pdfview similar to bouquet's VerticalPDFReader
class PDFViewer extends StatefulWidget {
  final String url;

  const PDFViewer({super.key, required this.url});

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  String? _localPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _downloadPdf();
  }

  /// Download PDF from remote URL - equivalent to ResourceType.Remote(pdfUrl)
  Future<void> _downloadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_pdf.pdf');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('💳 PDF: Error downloading - $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colors.colorPrimary),
      );
    }

    if (_localPath == null) {
      return Center(
        child: AppText.body(getString(appStr.errorPdfLoadFailed, 'error_pdf_load_failed')),
      );
    }

    // Equivalent to: VerticalPDFReader(state = pdfState, modifier = Modifier.fillMaxSize())
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      fitPolicy: FitPolicy.BOTH,
      onRender: (pages) {
        debugPrint('💳 PDF: Rendered $pages pages');
      },
      onError: (error) {
        debugPrint('💳 PDF error: $error');
      },
      onPageError: (page, error) {
        debugPrint('💳 PDF page $page error: $error');
      },
    );
  }
}
