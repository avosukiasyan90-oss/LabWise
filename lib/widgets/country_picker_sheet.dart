import 'package:flutter/material.dart';

import '../data/countries.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Searchable country list. Returns the chosen country name, or null.
Future<String?> showCountryPicker(
  BuildContext context, {
  String? selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CountryPickerSheet(selected: selected),
  );
}

class _CountryPickerSheet extends StatefulWidget {
  const _CountryPickerSheet({this.selected});

  final String? selected;

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kCountries;
    return kCountries
        .where((c) => c.toLowerCase().contains(q))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);
    final results = _filtered;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.selectCountry,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  controller: _controller,
                  autofocus: false,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchCountry,
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noCountryMatch(_query),
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const Divider(
                          height: 1,
                          color: AppColors.line,
                        ),
                        itemBuilder: (context, index) {
                          final country = results[index];
                          final isSelected = country == widget.selected;
                          return ListTile(
                            title: Text(country),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.teal,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, country),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
