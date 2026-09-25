import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/responses/home/additional_terms_item.dart';
import '../../../viewmodels/additional_terms_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';

class AdditionalTermsScreen extends ConsumerStatefulWidget {
  final AdditionalTermsItem termsItem;

  const AdditionalTermsScreen({
    super.key,
    required this.termsItem,
  });

  @override
  ConsumerState<AdditionalTermsScreen> createState() =>
      _AdditionalTermsScreenState();
}

class _AdditionalTermsScreenState
    extends ConsumerState<AdditionalTermsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(additionalTermsViewModelProvider.notifier)
          .setTermsItem(widget.termsItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(additionalTermsViewModelProvider);
    final colors = context.colors;

    // Listen for acceptance success
    ref.listen<AdditionalTermsState>(additionalTermsViewModelProvider,
        (previous, next) {
      if (next.isAccepted && previous?.isAccepted != true) {
        context.goBack(true);
      }
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        context.showErrorSnackBar(next.errorMessage!);
        ref.read(additionalTermsViewModelProvider.notifier).clearError();
      }
    });

    final termsHtml = widget.termsItem.terms ?? '';

    return AppScaffold(
      appBar: AppBar(
        title: AppText.body(
          widget.termsItem.title ??
              getString(appStr.headingAdditionalTerms, 'heading_additional_terms'),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: colors.colorBackground,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: colors.colorBackground,
      body: Column(
        children: [
          // Terms content
          Expanded(
            child: termsHtml.isNotEmpty
                ? InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: _wrapHtml(termsHtml, colors),
                    ),
                    initialSettings: InAppWebViewSettings(
                      transparentBackground: true,
                      javaScriptEnabled: false,
                    ),
                  )
                : Center(
                    child: AppText.body(
                      getString(appStr.errorNoTermsAvailable, 'error_no_terms_available'),
                      color: colors.colorTextHint,
                    ),
                  ),
          ),

          // Accept button
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: AppDimens.padding,
              right: AppDimens.padding,
              top: AppDimens.paddingM,
              bottom: MediaQuery.of(context).padding.bottom + AppDimens.paddingM,
            ),
            decoration: BoxDecoration(
              color: colors.colorBackground,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: AppFilledButton(
              text: getString(appStr.buttonAccept, 'button_accept'),
              isLoading: state.isLoading,
              onPressed: state.isLoading
                  ? null
                  : () => ref
                      .read(additionalTermsViewModelProvider.notifier)
                      .acceptTerms(),
            ),
          ),
        ],
      ),
    );
  }

  String _wrapHtml(String content, AppColorPalette colors) {
    return '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  body {
    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
    font-size: 14px;
    line-height: 1.6;
    padding: 16px;
    margin: 0;
    color: #333;
  }
</style>
</head>
<body>
$content
</body>
</html>
''';
  }
}
