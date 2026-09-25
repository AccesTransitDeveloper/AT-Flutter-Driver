import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../models/responses/document/document_response.dart';
import '../../../models/responses/vehicle/vehicle_list_response.dart';
import '../../../models/responses/vehicle/vehicle_color_response.dart';
import '../../../viewmodels/document_viewmodel.dart';
import '../../../viewmodels/vehicle_viewmodel.dart';
import '../../bottomsheets/document_edit_bottom_sheet.dart';
import '../../item/document_grid_item.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toolbar.dart';

class AddEditVehicleScreen extends ConsumerStatefulWidget {
  final Vehicle? vehicle;

  const AddEditVehicleScreen({super.key, this.vehicle});

  @override
  ConsumerState<AddEditVehicleScreen> createState() =>
      _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends ConsumerState<AddEditVehicleScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _vehicleLicenseController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name);
    _vehicleLicenseController =
        TextEditingController(text: widget.vehicle?.vehicleLicense);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(vehicleViewModelProvider.notifier)
          .editVehicleItems(widget.vehicle);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _vehicleLicenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vehicleViewModelProvider);
    final vm = ref.read(vehicleViewModelProvider.notifier);
    final colors = context.colors;
    final isEdit = widget.vehicle != null;
    final isFieldsEnabled = state.isFieldsEnabled;
    final isReadOnly =
        state.isHubDriver || state.isPartnerDriver;
    // Per Kotlin: Vehicle Name, Accessibility, Fallback only check !isReadOnly
    final alwaysEnabled = !isReadOnly;
    // Plate, Color, Year, Vehicle Type, Brand, Model: disabled in edit mode
    final fieldEnabled = !isEdit && isFieldsEnabled && !isReadOnly;
    // Kotlin: disabled fields use 50% alpha text/icon colors
    final disabledTextStyle = TextStyle(color: colors.colorText.withValues(alpha: 0.35));
    final disabledIconColor = colors.colorPrimary.withValues(alpha: 0.5);

    // Listen for snackbar & navigation
    ref.listen<VehicleState>(vehicleViewModelProvider, (prev, next) {
      if (next.snackBarMessage.isNotEmpty &&
          prev?.snackBarMessage != next.snackBarMessage) {
        if (next.isSnackBarError) {
          context.showErrorSnackBar(next.snackBarMessage);
        } else {
          context.showSnackBar(next.snackBarMessage);
        }
        vm.clearSnackBar();
      }
      if (next.isNavigateBack && prev?.isNavigateBack != true) {
        context.pop();
      }
    });

    // Sync text controllers when details load (edit mode)
    if (isEdit && state.selectedVehicle != null) {
      if (_nameController.text.isEmpty && state.vehicleName != null) {
        _nameController.text = state.vehicleName!;
      }
      if (_vehicleLicenseController.text.isEmpty &&
          state.vehicleLicense != null) {
        _vehicleLicenseController.text = state.vehicleLicense!;
      }
    }

    return AppScaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              AppToolbar(
                title: isEdit
                    ? getString(
                        appStr.headingEditVehicle, 'heading_edit_vehicle')
                    : getString(
                        appStr.headingAddVehicle, 'heading_add_vehicle'),
              ),
              Expanded(
                child: state.isDataLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingL,
                        ),
                        children: [
                          // ── Enter your vehicle information ──
                          AppText.body(
                            getString(appStr.headingEnterVehicleInfo, 'heading_enter_vehicle_info'),
                            fontWeight: FontWeight.w600,
                            fontSize: AppTypos.textL,
                          ),
                          const SizedBox(height: AppDimens.paddingXL),

                          // ── Brand (dropdown) ──
                          _buildFieldLabel(getString(
                              appStr.descriptionBrand, 'description_brand')),
                          const SizedBox(height: AppDimens.paddingS),
                          AppTextField(
                            controller: TextEditingController(
                              text: state.selectedBrands?.name ?? '',
                            ),
                            hintText: getString(appStr.descriptionSelectBrand,
                                'description_select_brand'),
                            readOnly: true,
                            enabled: fieldEnabled,
                            textStyle: fieldEnabled ? null : disabledTextStyle,
                            onTap: fieldEnabled
                                ? () => _showBrandPicker(context, state, vm)
                                : null,
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              color: fieldEnabled ? colors.colorTextHint : disabledIconColor,
                            ),
                          ),

                          const SizedBox(height: AppDimens.paddingXL),

                          // ── Model (dropdown) ──
                          _buildFieldLabel(getString(
                              appStr.descriptionModel, 'description_model')),
                          const SizedBox(height: AppDimens.paddingS),
                          AppTextField(
                            controller: TextEditingController(
                              text: state.selectedModels?.name ?? '',
                            ),
                            hintText: getString(appStr.descriptionSelectModel,
                                'description_select_model'),
                            readOnly: true,
                            enabled: fieldEnabled,
                            textStyle: fieldEnabled ? null : disabledTextStyle,
                            onTap: fieldEnabled
                                ? () {
                                    if (state.selectedBrands == null) {
                                      vm.openModelBottomSheet();
                                      return;
                                    }
                                    _showModelPicker(context, state, vm);
                                  }
                                : null,
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              color: fieldEnabled ? colors.colorTextHint : disabledIconColor,
                            ),
                          ),

                          const SizedBox(height: AppDimens.paddingXL),

                          // ── Year (dropdown) ──
                          _buildFieldLabel(getString(
                              appStr.descriptionVehicleYear,
                              'description_vehicle_year')),
                          const SizedBox(height: AppDimens.paddingS),
                          AppTextField(
                            controller: TextEditingController(
                              text: state.vehicleYear ?? '',
                            ),
                            hintText: getString(appStr.descriptionSelectYear,
                                'description_select_year'),
                            readOnly: true,
                            enabled: fieldEnabled,
                            textStyle: fieldEnabled ? null : disabledTextStyle,
                            onTap: fieldEnabled
                                ? () => _showYearPicker(context, state, vm)
                                : null,
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              color: fieldEnabled ? colors.colorTextHint : disabledIconColor,
                            ),
                          ),

                          const SizedBox(height: AppDimens.paddingXL),

                          // -- Vehicle license number (digits only, per Kotlin) --
                          _buildFieldLabel(getString(appStr.hintVehicleLicense,
                              'hint_vehicle_license')),
                          const SizedBox(height: AppDimens.paddingS),
                          AppTextField(
                            controller: _vehicleLicenseController,
                            enabled: fieldEnabled,
                            textStyle: fieldEnabled ? null : disabledTextStyle,
                            keyboardType: TextInputType.text,
                            onChanged: vm.onVehicleLicenseChange,
                          ),

                          const SizedBox(height: AppDimens.paddingXL),

                          // ── Vehicle Name (always editable for normal drivers) ──
                          _buildFieldLabel(getString(
                              appStr.descriptionVehicleName,
                              'description_vehicle_name')),
                          const SizedBox(height: AppDimens.paddingS),
                          AppTextField(
                            controller: _nameController,
                            enabled: alwaysEnabled,
                            onChanged: vm.onVehicleNameChange,
                          ),

                          const SizedBox(height: AppDimens.paddingXL),

                          // ── Color ──
                          _buildFieldLabel(getString(
                              appStr.descriptionVehicleColor,
                              'description_vehicle_color')),
                          const SizedBox(height: AppDimens.paddingS),
                          AppTextField(
                            controller: TextEditingController(
                              text: state.vehicleColor ?? '',
                            ),
                            hintText: getString(
                                appStr.descriptionVehicleColor,
                                'description_vehicle_color'),
                            readOnly: true,
                            enabled: fieldEnabled,
                            textStyle: fieldEnabled ? null : disabledTextStyle,
                            onTap: fieldEnabled
                                ? () => _showColorPicker(context, state, vm)
                                : null,
                            suffixIcon: Icon(
                              Icons.arrow_drop_down,
                              color: fieldEnabled
                                  ? colors.colorTextHint
                                  : disabledIconColor,
                            ),
                          ),

                          const SizedBox(height: AppDimens.paddingXL),

                          // ── Vehicle Type ──
                          _buildFieldLabel(getString(
                              appStr.headingVehicleType,
                              'heading_vehicle_type')),
                          const SizedBox(height: AppDimens.paddingS),
                          _buildVehicleTypeSelector(
                              state, vm, colors, fieldEnabled),

                          // ── Accessibility (always toggleable for normal drivers) ──
                          if (state.accessibilityList != null &&
                              state.accessibilityList!.isNotEmpty) ...[
                            const SizedBox(height: AppDimens.paddingXXL),
                            _buildFieldLabel(getString(
                                appStr.headingProvidingAccessibility,
                                'heading_providing_accessibility')),
                            const SizedBox(height: AppDimens.paddingS),
                            ...List.generate(
                              state.accessibilityList!.length,
                              (index) => _buildCheckbox(
                                state.accessibilityList![index]
                                        .accessibility ??
                                    '',
                                state.accessibilityList![index].isChecked,
                                alwaysEnabled,
                                (_) =>
                                    vm.onAccessibilityChange(index, true),
                                colors,
                              ),
                            ),
                          ],

                          // ── Fallback Vehicles (always toggleable for normal drivers) ──
                          if (state.fallbackTypes != null &&
                              state.fallbackTypes!.isNotEmpty) ...[
                            const SizedBox(height: AppDimens.paddingXXL),
                            _buildFieldLabel(getString(
                                appStr.headingFallbackVehicles,
                                'heading_fallback_vehicles')),
                            const SizedBox(height: AppDimens.paddingS),
                            ...List.generate(
                              state.fallbackTypes!.length,
                              (index) => _buildCheckbox(
                                state.fallbackTypes![index].name ?? '',
                                state.fallbackTypes![index].isChecked,
                                alwaysEnabled,
                                (_) =>
                                    vm.onFallBackTypeChange(index, true),
                                colors,
                              ),
                            ),
                          ],

                          // ── Documents (only in edit mode when vehicleId exists) ──
                          if (isEdit && widget.vehicle?.id != null)
                            _VehicleDocumentSection(
                              vehicleId: widget.vehicle!.id!,
                            ),

                          // Bottom spacing
                          const SizedBox(height: AppDimens.paddingXXL),
                        ],
                      ),
              ),

              // ── Continue / Save button ──
              if (!isReadOnly)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.paddingL,
                    AppDimens.paddingS,
                    AppDimens.paddingL,
                    AppDimens.padding,
                  ),
                  child: AppFilledButton(
                    text: isEdit
                        ? getString(appStr.buttonSave, 'button_save')
                        : getString(appStr.buttonContinue, 'button_continue'),
                    isLoading: state.isLoading,
                    onPressed: vm.addUpdateVehicle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Field label ──────────────────────────────────────────────────

  Widget _buildFieldLabel(String text) {
    return AppText.body(
      text,
      fontWeight: FontWeight.w500,
      fontSize: AppTypos.text,
      color: context.colors.colorText,
    );
  }

  // ── Vehicle type selector chips ──────────────────────────────────

  Widget _buildVehicleTypeSelector(VehicleState state, VehicleViewModel vm,
      AppColorPalette colors, bool enabled) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Row(
      children: List.generate(
        state.vehicleTypeList.length,
        (index) => Padding(
          padding: const EdgeInsets.only(right: AppDimens.paddingS),
          child: ChoiceChip(
            label: AppText.body(
              state.vehicleTypeList[index],
              color: state.selectedVehicleTypeIndex == index
                  ? colors.colorSelectedText
                  : colors.colorText,
            ),
            selected: state.selectedVehicleTypeIndex == index,
            selectedColor: colors.colorPrimary,
            backgroundColor: colors.colorBackgroundGray,
            showCheckmark: false,
            onSelected: (_) {
              if (enabled) vm.onVehicleTypeSelect(index);
            },
            color: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return colors.colorPrimary;
              }
              return colors.colorBackgroundGray;
            }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
              side: BorderSide(
                color: state.selectedVehicleTypeIndex == index
                    ? colors.colorPrimary
                    : colors.colorTextHint,
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  // ── Checkbox row ────────────────────────────────────────────────

  Widget _buildCheckbox(String text, bool isChecked, bool enabled,
      ValueChanged<bool?> onChanged, AppColorPalette colors) {
    return InkWell(
      onTap: enabled ? () => onChanged(!isChecked) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingXS),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isChecked,
                onChanged: enabled ? onChanged : null,
                activeColor: colors.colorPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.paddingS),
            Expanded(
              child: AppText.body(
                text,
                color: enabled ? colors.colorText : colors.colorTextHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Brand picker bottom sheet ────────────────────────────────────

  void _showBrandPicker(
      BuildContext context, VehicleState state, VehicleViewModel vm) {
    final brands = state.brandsList ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (_) => _SearchablePickerSheet<Brand>(
        title: getString(
            appStr.descriptionSelectBrand, 'description_select_brand'),
        items: brands,
        selectedItem: state.selectedBrands,
        itemName: (brand) => brand.name ?? '',
        itemId: (brand) => brand.id ?? '',
        onSelected: (brand) {
          vm.onBrandSelectionChange(brand);
          vm.onBrandSelectedDone();
        },
      ),
    );
  }

  // ── Colour picker bottom sheet ───────────────────────────────────

  void _showColorPicker(
      BuildContext context, VehicleState state, VehicleViewModel vm) {
    final colorList = state.colorList ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (_) => _SearchablePickerSheet<VehicleColor>(
        title: getString(appStr.descriptionVehicleColor,
            'description_vehicle_color'),
        items: colorList,
        selectedItem: colorList
            .where((c) => c.name == state.vehicleColor)
            .firstOrNull,
        itemName: (color) => color.name ?? '',
        itemId: (color) => color.id ?? '',
        onSelected: vm.onVehicleColorSelect,
      ),
    );
  }

  // ── Model picker bottom sheet ────────────────────────────────────

  void _showModelPicker(
      BuildContext context, VehicleState state, VehicleViewModel vm) {
    final models = state.modelList ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (_) => _SearchablePickerSheet<VehicleModel>(
        title: getString(
            appStr.descriptionSelectModel, 'description_select_model'),
        items: models,
        selectedItem: state.selectedModels,
        itemName: (model) => model.name ?? '',
        itemId: (model) => model.id ?? '',
        onSelected: (model) {
          vm.onModelSelectionChange(model);
          vm.onModelSelectedDone();
        },
      ),
    );
  }

  // ── Year picker bottom sheet ─────────────────────────────────────

  void _showYearPicker(
      BuildContext context, VehicleState state, VehicleViewModel vm) {
    final currentYear = DateTime.now().year;
    final years = List.generate(30, (i) => (currentYear - i).toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.colorBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.padding),
        ),
      ),
      builder: (ctx) {
        final colors = ctx.colors;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimens.padding),
                  child: AppText.title(
                    getString(appStr.descriptionSelectYear,
                        'description_select_year'),
                    fontSize: AppTypos.textL,
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    itemCount: years.length,
                    itemBuilder: (context, index) {
                      final isSelected = years[index] == state.vehicleYear;
                      return InkWell(
                        onTap: () {
                          vm.onYearSelected(years[index]);
                          vm.onYearSelectedDone();
                          context.pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.padding,
                            vertical: AppDimens.paddingM,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.colorPrimary
                                    .withValues(alpha: 0.1)
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: AppText.body(
                                  years[index],
                                  color: isSelected
                                      ? colors.colorPrimary
                                      : colors.colorText,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check,
                                    color: colors.colorPrimary,
                                    size: AppDimens.iconSizeSmall),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Vehicle Document Section ─────────────────────────────────────────

class _VehicleDocumentSection extends ConsumerWidget {
  final String vehicleId;

  const _VehicleDocumentSection({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(vehicleDocumentProvider(vehicleId));
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.paddingXXL),
        AppText.body(
          getString(appStr.headingDocument, 'heading_document'),
          fontWeight: FontWeight.w600,
          fontSize: AppTypos.textL,
        ),
        const SizedBox(height: AppDimens.paddingM),

        if (state.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.paddingXL),
              child: CircularProgressIndicator(),
            ),
          )
        else if (state.documents == null || state.documents!.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingXL),
              child: AppText.body(
                getString(
                    appStr.errorNoDocumentFound, 'error_no_document_found'),
                color: colors.colorTextHint,
              ),
            ),
          )
        else
          MasonryGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppDimens.paddingM,
            crossAxisSpacing: AppDimens.paddingM,
            itemCount: state.documents!.length,
            itemBuilder: (context, index) {
              final document = state.documents![index];
              return DocumentGridItem(
                document: document,
                onTap: () => _showEditBottomSheet(
                    context, ref, document),
              );
            },
          ),
      ],
    );
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
            .read(vehicleDocumentProvider(vehicleId).notifier)
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

// ── Reusable searchable picker bottom sheet ──────────────────────────

class _SearchablePickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemName;
  final String Function(T) itemId;
  final ValueChanged<T> onSelected;

  const _SearchablePickerSheet({
    required this.title,
    required this.items,
    this.selectedItem,
    required this.itemName,
    required this.itemId,
    required this.onSelected,
  });

  @override
  State<_SearchablePickerSheet<T>> createState() =>
      _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final filteredItems = _query.isEmpty
        ? widget.items
        : widget.items
            .where((item) => widget
                .itemName(item)
                .toLowerCase()
                .contains(_query.toLowerCase()))
            .toList();

    final selectedId =
        widget.selectedItem != null ? widget.itemId(widget.selectedItem as T) : null;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: AppText.title(
                widget.title,
                fontSize: AppTypos.textL,
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.padding,
              ),
              child: AppTextField(
                controller: _searchController,
                hintText: getString(appStr.hintSearch, 'hint_search'),
                prefixIcon:
                    Icon(Icons.search, color: colors.colorTextHint),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: AppDimens.paddingS),
            const Divider(height: 1),
            Flexible(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.paddingXL),
                        child: AppText.body(
                          getString(appStr.descriptionNoResults, 'description_no_results'),
                          color: colors.colorTextHint,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final name = widget.itemName(item);
                        final id = widget.itemId(item);
                        final isSelected = id == selectedId;

                        return InkWell(
                          onTap: () {
                            context.pop();
                            widget.onSelected(item);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.padding,
                              vertical: AppDimens.paddingM,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.colorPrimary
                                      .withValues(alpha: 0.1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppText.body(
                                    name,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? colors.colorPrimary
                                        : colors.colorText,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check,
                                    color: colors.colorPrimary,
                                    size: AppDimens.iconSizeSmall,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
