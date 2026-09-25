import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/document_utils.dart';
import '../../data/api/server_config.dart';
import '../../models/responses/document/document_response.dart';
import '../widgets/app_text.dart';

class DocumentGridItem extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  final VoidCallback? onImageTap;

  const DocumentGridItem({
    super.key,
    required this.document,
    required this.onTap,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final documentDetail = document.documentDetail;
    final statusColor = DocumentUtils.getStatusColor(document.status, context: context);
    final statusText = DocumentUtils.getStatusText(document.status);
    final isMandatory = documentDetail?.isMandatory == true;

    final imageUrl =
        document.imageUrl != null && document.imageUrl!.isNotEmpty
            ? ServerConfig.getFullImageUrl(document.imageUrl)
            : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.colorBackground,
          borderRadius: BorderRadius.circular(AppDimens.paddingM),
          border: Border.all(color: colors.colorBackgroundGray, width: 1),
          boxShadow: [
            BoxShadow(
              color: colors.colorText.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Image
            GestureDetector(
              onTap: imageUrl != null && onImageTap != null
                  ? onImageTap
                  : null,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.paddingM),
                  topRight: Radius.circular(AppDimens.paddingM),
                ),
                child: AspectRatio(
                  aspectRatio: 1.2,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              _buildPlaceholder(colors),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(colors),
                        )
                      : _buildPlaceholder(colors),
                ),
              ),
            ),
            // Document Info
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AppText.body(
                          documentDetail?.name ?? '',
                          fontWeight: FontWeight.w600,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isMandatory) ...[
                        const SizedBox(width: 2),
                        AppText.caption(
                          '*',
                          color: colors.colorWarning,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingS, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AppText.caption(
                      statusText,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (document.uniqueCode != null &&
                      document.uniqueCode!.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.paddingS),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined,
                            size: 12, color: colors.colorText),
                        const SizedBox(width: 4),
                        Flexible(
                          child: AppText.caption(
                            document.uniqueCode!,
                            color: colors.colorText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (document.expiryDate != null &&
                      document.expiryDate!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.event_outlined,
                            size: 12, color: colors.colorText),
                        const SizedBox(width: 4),
                        AppText.caption(
                          DocumentUtils.formatExpiryDate(
                              document.expiryDate),
                          color: colors.colorText,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(dynamic colors) {
    return Container(
      color: colors.colorBackgroundGray,
      child: Center(
        child: Icon(
          Icons.description_outlined,
          size: 40,
          color: colors.colorText,
        ),
      ),
    );
  }
}
