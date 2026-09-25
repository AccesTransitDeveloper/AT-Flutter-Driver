import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../viewmodels/feedback_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toolbar.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final bool isFromHistory;

  const FeedbackScreen({
    super.key,
    required this.bookingId,
    this.isFromHistory = true,
  });

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _commentController = TextEditingController();
  late final FeedbackParams _params;

  @override
  void initState() {
    super.initState();
    _params = FeedbackParams(
      bookingId: widget.bookingId,
      isFromHistory: widget.isFromHistory,
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(feedbackViewModelProvider(_params));
    final viewModel = ref.read(feedbackViewModelProvider(_params).notifier);

    ref.listen(feedbackViewModelProvider(_params), (previous, next) {
      // Navigate back (from history)
      if (next.isNavigateBack && !(previous?.isNavigateBack ?? false)) {
        context.goBack(true);
      }
      // Navigate to home (from trip completion)
      if (next.isNavigateToHome && !(previous?.isNavigateToHome ?? false)) {
        context.navigateToHome();
      }
      // Show error snackbar (for submit failures)
      if (next.error != null && next.error != previous?.error && next.booking != null) {
        context.showErrorSnackBar(next.error!);
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(
                  appStr.headingFeedback, 'heading_feedback'),
            ),

            // Content
            Expanded(
              child: state.isLoading && state.booking == null
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.booking == null
                      ? Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(AppDimens.padding),
                            child: AppText.body(
                              state.error!,
                              color: colors.colorTextHint,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.padding,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: AppDimens.paddingXL),

                              // Customer avatar
                              _buildCustomerAvatar(colors, state),

                              const SizedBox(height: AppDimens.paddingM),

                              // Customer name
                              AppText.title(
                                state.customerName.isNotEmpty
                                    ? state.customerName
                                    : getString(appStr.descriptionCustomer, 'description_customer'),
                                fontWeight: FontWeight.w600,
                              ),

                              // Distance · Time
                              if (state.distance != null || state.time != null) ...[
                                const SizedBox(
                                    height: AppDimens.paddingXS),
                                AppText.body(
                                  _buildDistanceTimeText(state),
                                  color: colors.colorTextHint,
                                ),
                              ],

                              const SizedBox(height: AppDimens.paddingXL),

                              // Rating subtitle
                              AppText.body(
                                getString(
                                    appStr
                                        .subHeadingRateYourRideExperience,
                                    'sub_heading_rate_your_ride_experience'),
                                fontWeight: FontWeight.w500,
                              ),

                              const SizedBox(height: AppDimens.paddingM),

                              // Star rating row
                              _buildStarRating(
                                  colors, state, viewModel),

                              const SizedBox(height: AppDimens.paddingS),

                              // Rating label
                              AppText.caption(
                                _getRatingLabel(state.selectedRating),
                                color: colors.colorTextHint,
                              ),

                              const SizedBox(height: AppDimens.paddingXL),

                              // Comment section
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AppText.body(
                                  getString(appStr.subHeadingComment,
                                      'sub_heading_comment'),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: AppDimens.paddingS),

                              AppTextField(
                                controller: _commentController,
                                hintText: getString(
                                    appStr.hintWriteYourRideExperience,
                                    'hint_write_your_ride_experience'),
                                maxLines: 4,
                                onChanged: viewModel.updateComment,
                              ),

                              const SizedBox(height: AppDimens.paddingXL),
                            ],
                          ),
                        ),
            ),

            // Bottom action buttons
            if (!state.isLoading || state.booking != null)
              _buildBottomButtons(colors, state, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerAvatar(
      AppColorPalette colors, FeedbackState state) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: colors.colorBackgroundGray,
        shape: BoxShape.circle,
      ),
      child: state.customerImageUrl != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: state.customerImageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Icon(
                  Icons.person,
                  color: colors.colorTextHint,
                  size: 40,
                ),
                errorWidget: (_, _, _) => Icon(
                  Icons.person,
                  color: colors.colorTextHint,
                  size: 40,
                ),
              ),
            )
          : Icon(
              Icons.person,
              color: colors.colorTextHint,
              size: 40,
            ),
    );
  }

  Widget _buildStarRating(
    AppColorPalette colors,
    FeedbackState state,
    FeedbackViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= state.selectedRating;

        return GestureDetector(
          onTap: () => viewModel.selectRating(starNumber),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingS,
            ),
            child: Icon(
              isSelected
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              size: 44,
              color: isSelected
                  ? colors.colorPrimary
                  : colors.colorTextHint,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButtons(
    AppColorPalette colors,
    FeedbackState state,
    FeedbackViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppFilledButton(
            text: getString(appStr.buttonSubmit, 'button_submit'),
            isLoading: state.isLoading,
            onPressed: viewModel.submitRating,
          ),
          const SizedBox(height: AppDimens.paddingS),
          AppOutlinedButton(
            text: getString(
                appStr.buttonMaybeLater, 'button_maybe_later'),
            onPressed:
                state.isLoading ? null : () => viewModel.skipRating(),
          ),
        ],
      ),
    );
  }

  String _buildDistanceTimeText(FeedbackState state) {
    final parts = <String>[];
    final distance = state.distance;
    if (distance != null && distance > 0) {
      final unit = (state.distanceUnit == 2)
          ? getString(appStr.descriptionDistanceUnitMi, 'description_distance_unit_mi')
          : getString(appStr.descriptionDistanceUnitKm, 'description_distance_unit_km');
      parts.add('${distance.toStringAsFixed(1)} $unit');
    }
    final time = state.time;
    if (time != null && time > 0) {
      final unit = getString(appStr.descriptionMinutesUnit, 'description_minutes_unit');
      parts.add('$time $unit');
    }
    return parts.join(' · ');
  }

  String _getRatingLabel(int rating) {
    return switch (rating) {
      1 => getString(
          appStr.descriptionRateAwful, 'description_rate_awful'),
      2 => getString(
          appStr.descriptionRateSad, 'description_rate_sad'),
      3 => getString(
          appStr.descriptionRateGood, 'description_rate_good'),
      4 => getString(
          appStr.descriptionRateVeryGood, 'description_rate_very_good'),
      5 => getString(
          appStr.descriptionRateExcellent, 'description_rate_excellent'),
      _ => '',
    };
  }
}
