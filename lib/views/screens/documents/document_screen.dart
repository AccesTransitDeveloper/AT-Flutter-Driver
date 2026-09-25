import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/api/server_config.dart';
import '../../../models/responses/document/document_response.dart';
import '../../../models/webview_data_model.dart';
import '../../../viewmodels/document_viewmodel.dart';
import '../../bottomsheets/document_edit_bottom_sheet.dart';
import '../../item/document_grid_item.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_toolbar.dart';

class DocumentScreen extends ConsumerWidget {
  const DocumentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentViewModelProvider);

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(appStr.headingDocument, 'heading_document'),
            ),
            Expanded(
              child: _buildBody(context, ref, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    DocumentState state,
  ) {
    final colors = context.colors;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colors.colorText),
            const SizedBox(height: AppDimens.padding),
            AppText.body(state.error!, color: colors.colorText),
          ],
        ),
      );
    }

    final documents = state.documents;
    if (documents == null || documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 64, color: colors.colorText),
            const SizedBox(height: AppDimens.padding),
            AppText.body(
              getString(appStr.errorNoDocumentFound,
                  'error_no_document_found'),
              color: colors.colorText,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(documentViewModelProvider.notifier).refresh(),
      child: MasonryGridView.count(
        padding: const EdgeInsets.all(AppDimens.padding),
        crossAxisCount: 2,
        mainAxisSpacing: AppDimens.paddingM,
        crossAxisSpacing: AppDimens.paddingM,
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final doc = documents[index];
          return DocumentGridItem(
            document: doc,
            onTap: () => _showEditBottomSheet(context, ref, doc),
            onImageTap: () => _openDocument(context, doc),
          );
        },
      ),
    );
  }

  void _openDocument(BuildContext context, Document document) {
    final imageUrl = document.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return;

    final fullUrl = ServerConfig.getFullImageUrl(imageUrl);
    final isPdf = fullUrl.toLowerCase().endsWith('.pdf');

    if (isPdf) {
      context.navigateToWebView(
        webViewData: WebViewDataModel(
          webURL: fullUrl,
          webContent: null,
        ),
      );
    } else {
      context.navigateToImageViewer(imageUrl: fullUrl);
    }
  }

  void _showEditBottomSheet(
      BuildContext context, WidgetRef ref, Document document) {
    DocumentEditBottomSheet.show(
      context: context,
      document: document,
      onSubmit: ({
        required String documentId,
        String? filePath,
        String? expiryDate,
        String? uniqueCode,
      }) async {
        return ref
            .read(documentViewModelProvider.notifier)
            .uploadDocument(
              documentId: documentId,
              filePath: filePath,
              expiryDate: expiryDate,
              uniqueCode: uniqueCode,
            );
      },
    );
  }
}

