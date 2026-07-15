import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_settings/core/constants/icons.dart';
import 'package:mechanix_settings/core/theme/app_theme.dart';
import 'package:mechanix_settings/features/wireless/data/models/enums.dart';
import 'package:mechanix_settings/core/widgets/custom_divider.dart';
import 'package:mechanix_settings/core/widgets/custom_icon_button.dart';
import 'package:mechanix_settings/core/widgets/custom_image_asset.dart';
import 'package:mechanix_settings/core/widgets/custom_text_field.dart';
import 'package:mechanix_settings/features/wireless/blocs/wireless_bloc.dart';
import 'package:mechanix_settings/features/wireless/presentation/widgets/security_selection.dart';
import 'package:mechanix_settings/l10n/app_localizations.dart';

class AddNetworkBottomSheet extends StatefulWidget {
  const AddNetworkBottomSheet({super.key});

  @override
  State<AddNetworkBottomSheet> createState() => _AddNetworkBottomSheetState();
}

class _AddNetworkBottomSheetState extends State<AddNetworkBottomSheet> {
  final _nameController = TextEditingController();

  WirelessSecurity _security = WirelessSecurity.wpa2Wpa3;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onAdd() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      return;
    }

    context.read<WirelessBloc>().add(
      AddNetworkEvent(name, _security),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(color: AppColors.backgroundVariantDark),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.addWireless,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              CustomIconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const CustomDivider(verticalPadding: 12),

          /// Network name
          CustomTextField(
            controller: _nameController,
            hintText: l10n.hintName,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onAdd(),
            prefixIcon: const CustomImage(
              assetPath: SettingIcons.wireless,
              size: 18,
              color: AppColors.onSurfaceVariantDark,
            ),
          ),

          const SizedBox(height: 12),

          /// Security row
          InkWell(
            onTap: () async {
              final result = await Navigator.push<WirelessSecurity>(
                context,
                MaterialPageRoute(
                  builder: (_) => SecuritySelectionScreen(selected: _security),
                ),
              );

              if (result != null) {
                setState(() {
                  _security = result;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.security,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    _security.localizedLabel(l10n),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showAddNetworkBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => const AddNetworkBottomSheet(),
  );
}
