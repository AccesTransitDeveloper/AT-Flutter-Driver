import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../models/responses/auth/country_response.dart';
import 'app_text.dart';

class CountryPickerOverlay extends StatefulWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final Offset position;
  final double width;
  final Function(Country) onCountrySelected;
  final VoidCallback onDismiss;

  const CountryPickerOverlay({
    super.key,
    required this.countries,
    this.selectedCountry,
    required this.position,
    required this.width,
    required this.onCountrySelected,
    required this.onDismiss,
  });

  @override
  State<CountryPickerOverlay> createState() => _CountryPickerOverlayState();
}

class _CountryPickerOverlayState extends State<CountryPickerOverlay> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  List<Country> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;
    _textController.addListener(_onSearchChanged);
    // Request focus after build to open keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onSearchChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _textController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countries;
      } else {
        _filteredCountries = widget.countries
            .where((country) => country.doesMatchSearchQuery(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;
    final maxHeight = availableHeight * 0.4;

    return Stack(
      children: [
        // Dismiss on tap outside
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Dropdown
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(AppDimens.paddingM),
            color: colors.colorBackground,
            child: Container(
              width: widget.width,
              constraints: BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                color: colors.colorBackground,
                borderRadius: BorderRadius.circular(AppDimens.paddingM),
                border: Border.all(
                  color: colors.colorText.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Invisible TextField for keyboard input
                  SizedBox(
                    height: 0,
                    child: Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        autofocus: true,
                        enableInteractiveSelection: false,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 1),
                      ),
                    ),
                  ),
                  // Country list
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.paddingM),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = _filteredCountries[index];
                          final isSelected =
                              widget.selectedCountry?.id == country.id;

                          return InkWell(
                            onTap: () => widget.onCountrySelected(country),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimens.padding,
                                vertical: AppDimens.paddingM,
                              ),
                              color: isSelected
                                  ? colors.colorPrimary.withValues(alpha: 0.1)
                                  : null,
                              child: Row(
                                children: [
                                  // Country name
                                  Expanded(
                                    child: AppText.body(
                                      country.name ?? '',
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),

                                  // Phone code
                                  AppText.body(
                                    country.displayPhoneCode,
                                    color: colors.colorText,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
