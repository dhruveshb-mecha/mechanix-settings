import 'package:flutter/material.dart';
import 'package:mechanix_settings/core/widgets/custom_text_field.dart';
import 'package:mechanix_settings/features/wireless/data/models/enterprise_config.dart';
import 'package:mechanix_settings/features/wireless/presentation/widgets/add_network/enterprise_row.dart';
import 'package:mechanix_settings/l10n/app_localizations.dart';

class PwdSection extends StatefulWidget {
  final EnterpriseConfig config;
  final ValueChanged<EnterpriseConfig> onChanged;

  const PwdSection({super.key, required this.config, required this.onChanged});

  @override
  State<PwdSection> createState() => _PwdSectionState();
}

class _PwdSectionState extends State<PwdSection> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final config = widget.config;
    final onChanged = widget.onChanged;

    return Column(
      children: [
        EnterpriseRow(
          label: l10n.identity,
          child: CustomTextField(
            initialValue: config.identity,
            hintText: l10n.identity,
            onChanged: (value) {
              onChanged(config.copyWith(identity: value));
            },
          ),
        ),

        const SizedBox(height: 12),

        EnterpriseRow(
          label: l10n.password,
          child: CustomTextField(
            initialValue: config.password,
            hintText: l10n.password,
            obscureText: _obscurePassword,

            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),

            onChanged: (value) {
              onChanged(config.copyWith(password: value));
            },
          ),
        ),
      ],
    );
  }
}
