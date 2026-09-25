import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';

/// A screen for viewing images with zoom and pan capabilities
class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  final double _minScale = 1.0;
  final double _maxScale = 4.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();

    Matrix4 endMatrix;
    if (currentScale > _minScale) {
      endMatrix = Matrix4.identity();
    } else {
      endMatrix = Matrix4.diagonal3Values(2.0, 2.0, 1.0);
    }

    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: endMatrix,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animation!.addListener(() {
      _transformationController.value = _animation!.value;
    });

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppScaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTap: _onDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: _minScale,
              maxScale: _maxScale,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: colors.colorSelectedText,
                    ),
                  ),
                  errorWidget: (context, url, error) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        color: colors.colorSelectedText,
                        size: 64,
                      ),
                      const SizedBox(height: AppDimens.padding),
                      AppText.body(
                        getString(appStr.descriptionFailedToLoadImage,
                            'description_failed_to_load_image'),
                        color: colors.colorSelectedText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppDimens.padding,
            left: AppDimens.padding,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
              ),
              child: IconButton(
                onPressed: () => context.goBack(),
                icon: Icon(
                  Icons.close,
                  color: colors.colorSelectedText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
