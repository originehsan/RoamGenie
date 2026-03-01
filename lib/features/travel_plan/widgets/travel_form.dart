import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_loader.dart';

/// TravelForm — StatefulWidget (needed for controllers, date state, form key).
///
/// Inputs:
///   - Source / Destination IATA (with autocomplete)
///   - Departure + Return dates (date picker)
///   - Budget
///   - Flight class (dropdown)
///   - Preferences (free text)
class TravelForm extends StatefulWidget {
  /// Single loading type — determines if/how the button shows loading.
  /// RULE: only buttonLoading shows dots; screenLoading keeps button normal.
  final LoadingType loadingType;
  final void Function({
    required String source,
    required String destination,
    required String departureDate,
    required String returnDate,
    required String budget,
    required String flightClass,
    required String preferences,
  }) onSubmit;

  const TravelForm({
    super.key,
    required this.loadingType,
    required this.onSubmit,
  });

  @override
  State<TravelForm> createState() => _TravelFormState();
}

class _TravelFormState extends State<TravelForm> {
  final _formKey = GlobalKey<FormState>();
  final _sourceCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _prefCtrl = TextEditingController();

  DateTime? _departureDate;
  DateTime? _returnDate;
  String _flightClass = 'Economy';

  @override
  void dispose() {
    _sourceCtrl.dispose();
    _destCtrl.dispose();
    _budgetCtrl.dispose();
    _prefCtrl.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Future<void> _pickDate(bool isDeparture) async {
    final now = DateTime.now();
    final initial = isDeparture
        ? (_departureDate ?? now.add(const Duration(days: 3)))
        : (_returnDate ?? (_departureDate ?? now).add(const Duration(days: 7)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      // ── Beautiful calendar theme ───────────────────────────────────────
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,       // selected day bg, header bg
            onPrimary: Colors.white,           // selected day text
            surface: Colors.white,             // dialog bg
            onSurface: AppColors.textPrimary,  // default day text
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            // Rounded corners
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 12,
            shadowColor: AppColors.primary.withValues(alpha: 0.25),
            surfaceTintColor: Colors.transparent,
            dividerColor: Colors.transparent,
            // Header (uses colorScheme.primary for bg automatically)
            headerBackgroundColor: AppColors.primary,
            headerForegroundColor: Colors.white,
            headerHeadlineStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            headerHelpStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
            // Day cells
            dayStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            todayBorder:
                const BorderSide(color: AppColors.primary, width: 1.5),
            // Action buttons
            cancelButtonStyle: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            confirmButtonStyle: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14),
            ),
            // Year picker
            yearStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    setState(() {
      if (isDeparture) {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      } else {
        _returnDate = picked;
      }
    });
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Select date';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_departureDate == null || _returnDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select departure and return dates.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSubmit(
      source: _sourceCtrl.text.trim().toUpperCase(),
      destination: _destCtrl.text.trim().toUpperCase(),
      departureDate: _departureDate!.toIso8601String().split('T')[0],
      returnDate: _returnDate!.toIso8601String().split('T')[0],
      budget: _budgetCtrl.text.trim(),
      flightClass: _flightClass,
      preferences: _prefCtrl.text.trim(),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: AppDecorations.card,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ──
            _CardHeader(),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Route row ──
                  _SectionLabel('ROUTE'),
                  const SizedBox(height: 8),
                  Row(
                    // crossAxisAlignment.end so swap button aligns
                    // with the INPUT fields, not with the labels above them.
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _IataField(
                          label: 'From',
                          hint: 'DEL',
                          icon: Icons.flight_takeoff_rounded,
                          controller: _sourceCtrl,
                          validator: (v) => (v == null || v.trim().length < 3)
                              ? 'Enter 3-letter code'
                              : null,
                        ),
                      ),
                      // bottom padding pushes ⇄ centre to match field centre:
                      // field_center_from_bottom = 48/2 = 24 → pad = 24 - 18 = 6
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _SwapButton(
                          onTap: () {
                            final tmp = _sourceCtrl.text;
                            _sourceCtrl.text = _destCtrl.text;
                            _destCtrl.text = tmp;
                            setState(() {});
                          },
                        ),
                      ),
                      Expanded(
                        child: _IataField(
                          label: 'To',
                          hint: 'BOM',
                          icon: Icons.flight_land_rounded,
                          controller: _destCtrl,
                          validator: (v) => (v == null || v.trim().length < 3)
                              ? 'Enter 3-letter code'
                              : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Dates ──
                  _SectionLabel('DATES'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTile(
                          label: 'Departure',
                          icon: Icons.calendar_today_rounded,
                          value: _formatDate(_departureDate),
                          isSelected: _departureDate != null,
                          onTap: () => _pickDate(true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateTile(
                          label: 'Return',
                          icon: Icons.event_rounded,
                          value: _formatDate(_returnDate),
                          isSelected: _returnDate != null,
                          onTap: () => _pickDate(false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Budget + Class row ──
                  // Both cells use the same label-above-field structure so
                  // the actual input fields sit flush at the same height.
                  _SectionLabel('BUDGET & CLASS'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount (₹)',
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            _buildInputField(
                              controller: _budgetCtrl,
                              hint: 'e.g. 50000',
                              prefixIcon: Icons.account_balance_wallet_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ClassSelector(
                          value: _flightClass,
                          onChanged: (v) => setState(() => _flightClass = v),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Preferences ──
                  _SectionLabel('PREFERENCES (OPTIONAL)'),
                  const SizedBox(height: 8),
                  _buildInputField(
                    controller: _prefCtrl,
                    hint: 'e.g. Beach vacation, vegetarian food, adventure...',
                    prefixIcon: Icons.tune_rounded,
                    maxLines: 2,
                  ),

                  const SizedBox(height: 24),

                  // ── Submit button ──
                  _SubmitButton(
                    loadingType: widget.loadingType,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall,
        prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.textMuted),
        filled: true,
        fillColor: AppColors.surfaceGrey,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide:
              const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}

// ── Sub-widgets (private, stateless) ─────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.travel_explore,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plan Your Trip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'AI-powered itinerary in seconds',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.labelMedium);
  }
}

class _SwapButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SwapButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(Icons.swap_horiz_rounded,
              color: AppColors.primary, size: 18),
        ),
      ),
    );
  }
}

class _IataField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const _IataField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final codes = kIataMap.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Autocomplete<String>(
          optionsBuilder: (v) {
            if (v.text.isEmpty) return const [];
            final q = v.text.toUpperCase();
            return codes
                .where((c) => c.startsWith(q))
                .take(5);
          },
          onSelected: (s) => controller.text = s,
          fieldViewBuilder: (ctx, fCtrl, focusNode, _) {
            // Sync the autocomplete internal controller with our controller
            if (fCtrl.text != controller.text) fCtrl.text = controller.text;
            fCtrl.addListener(() => controller.text = fCtrl.text);
            return TextFormField(
              controller: fCtrl,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.characters,
              maxLength: 3,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 1.5,
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall
                    .copyWith(letterSpacing: 1.5),
                prefixIcon:
                    Icon(icon, size: 16, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceGrey,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide:
                      const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
              validator: validator,
            );
          },
          optionsViewBuilder: (ctx, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: AppColors.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(
                        height: 1, color: AppColors.divider),
                    itemBuilder: (ctx, i) {
                      final code = options.elementAt(i);
                      return InkWell(
                        onTap: () => onSelected(code),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(code,
                                  style: AppTextStyles.titleMedium
                                      .copyWith(
                                          color: AppColors.primary,
                                          fontSize: 13)),
                              Text(iataToCity(code),
                                  style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 15,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Flight Class Selector (modal bottom sheet) ─────────────────────────────

// Data for each flight class option
class _ClassOption {
  final String label;
  final String subtitle;
  final IconData icon;
  const _ClassOption(
      {required this.label, required this.subtitle, required this.icon});
}

const _classOptions = [
  _ClassOption(
    label: 'Economy',
    subtitle: 'Best value for money',
    icon: Icons.airline_seat_recline_normal_rounded,
  ),
  _ClassOption(
    label: 'Premium Economy',
    subtitle: 'Extra legroom & comfort',
    icon: Icons.airline_seat_recline_extra_rounded,
  ),
  _ClassOption(
    label: 'Business',
    subtitle: 'Lie-flat seats & lounge',
    icon: Icons.business_center_rounded,
  ),
  _ClassOption(
    label: 'First',
    subtitle: 'Ultimate luxury experience',
    icon: Icons.workspace_premium_rounded,
  ),
];

class _ClassSelector extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;

  const _ClassSelector(
      {required this.value, required this.onChanged});

  Future<void> _openSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClassSheet(current: value),
    );
    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final opt = _classOptions.firstWhere((o) => o.label == value,
        orElse: () => _classOptions.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _openSheet(context),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(opt.icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Modal Bottom Sheet content ────────────────────────────────────────

class _ClassSheet extends StatefulWidget {
  final String current;
  const _ClassSheet({required this.current});

  @override
  State<_ClassSheet> createState() => _ClassSheetState();
}

class _ClassSheetState extends State<_ClassSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20, top: 8),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Title
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.flight_class_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Flight Class',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Select your preferred cabin class',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Options
          ...List.generate(_classOptions.length, (i) {
            final opt = _classOptions[i];
            final isSelected = opt.label == _selected;
            return GestureDetector(
              onTap: () => setState(() => _selected = opt.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.divider,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Icon badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        opt.icon,
                        color: isSelected
                            ? Colors.white
                            : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Labels
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            opt.subtitle,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Checkmark
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 20)
                    else
                      const Icon(Icons.radio_button_unchecked_rounded,
                          color: AppColors.divider, size: 20),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0099CC)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context, _selected),
                child: Text(
                  'Confirm — $_selected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final LoadingType loadingType;
  final VoidCallback onPressed;

  const _SubmitButton(
      {required this.loadingType, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isButtonLoading = loadingType == LoadingType.button;
    // Disable during ANY loading, but only show dots during button loading.
    // During screen loading the button stays normal (screen has the loader).
    final isDisabled = loadingType != LoadingType.none;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDisabled
              ? null
              : const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0099CC)]),
          color: isDisabled ? AppColors.divider : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
          ),
          child: isButtonLoading
              ? const ButtonDotLoader()
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Generate Travel Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
