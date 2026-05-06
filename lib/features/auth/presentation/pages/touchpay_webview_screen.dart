import 'package:flutter/material.dart';
import 'package:quick_forms/core/utils/app_colors.dart';
import 'package:quick_forms/core/utils/app_constants.dart';
import 'package:quick_forms/core/utils/app_routes.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TouchpayWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String reference;

  const TouchpayWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.reference,
  });

  @override
  State<TouchpayWebViewScreen> createState() => _TouchpayWebViewScreenState();
}

class _TouchpayWebViewScreenState extends State<TouchpayWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // L'URL de retour contient la référence — on détecte la fin du paiement
  static const String _returnUrlPattern = '/payments/touchpay/return';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (_) => setState(() => _isLoading = false),
        onNavigationRequest: (request) {
          // Détecter la redirection de retour TouchPay
          if (request.url.contains(_returnUrlPattern)) {
            _onPaymentComplete();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _onPaymentComplete() {
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.clientHome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backArrowColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: const Icon(Icons.arrow_back,
                color: AppColors.white, size: AppConstants.iconSizeMedium),
          ),
        ),
        title: const Text(
          'Paiement sécurisé',
          style: TextStyle(
            fontSize: AppConstants.fontSizeMedium,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.paddingMedium),
            child: Row(
              children: const [
                Icon(Icons.lock_outline,
                    size: AppConstants.iconSizeSmall,
                    color: AppColors.planCheckGreen),
                SizedBox(width: 4),
                Text(
                  'Sécurisé',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeRegular,
                    color: AppColors.planCheckGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.backArrowColor),
            ),
        ],
      ),
    );
  }
}
