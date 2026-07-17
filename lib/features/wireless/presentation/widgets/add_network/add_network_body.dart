import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mechanix_settings/core/widgets/custom_text_field.dart';
import 'package:mechanix_settings/features/wireless/blocs/wireless_bloc.dart';
import 'package:mechanix_settings/features/wireless/data/models/enterprise_config.dart';
import 'package:mechanix_settings/features/wireless/data/models/enums.dart';
import 'package:mechanix_settings/features/wireless/presentation/widgets/add_network/enterprise_row.dart';
import 'package:mechanix_settings/features/wireless/presentation/widgets/add_network/enterprise_section.dart';
import 'package:mechanix_settings/features/wireless/presentation/widgets/add_network/security_selector.dart';
import 'package:mechanix_settings/l10n/app_localizations.dart';

class AddNetworkBody extends StatefulWidget {
  const AddNetworkBody({super.key});

  @override
  State<AddNetworkBody> createState() => AddNetworkBodyState();
}

class AddNetworkBodyState extends State<AddNetworkBody> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _identityController = TextEditingController();
  bool _obscurePassword = true;

  EnterpriseConfig _enterpriseConfig = const EnterpriseConfig();

  WirelessSecurity _security = WirelessSecurity.wpaWpa2Personal;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  Future<bool> connect() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      return false;
    }

    context.read<WirelessBloc>().add(
      AddNetworkEvent(
        name,
        _security,
        enterpriseConfig: _security == WirelessSecurity.wpawpa2Enterprise
            ? _enterpriseConfig
            : null,
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EnterpriseRow(
              label: l10n.networkName,
              child: CustomTextField(controller: _nameController, hintText: ""),
            ),

            const SizedBox(height: 20),

            SecuritySelector(
              security: _security,
              onChanged: (value) {
                setState(() {
                  _security = value;

                  if (_security != WirelessSecurity.wpawpa2Enterprise) {
                    _enterpriseConfig = const EnterpriseConfig();
                  }
                });
              },
            ),

            if (_security == WirelessSecurity.wpawpa2Enterprise) ...[
              const SizedBox(height: 24),

              EnterpriseSection(
                config: _enterpriseConfig,
                onChanged: (config) {
                  setState(() {
                    _enterpriseConfig = config;
                  });
                },
              ),
            ],

            if (_security == WirelessSecurity.leap) ...[
              const SizedBox(height: 24),

              EnterpriseRow(
                label: l10n.identity,
                child: CustomTextField(
                  controller: _identityController,
                  hintText: '',
                ),
              ),

              const SizedBox(height: 16),

              EnterpriseRow(
                label: l10n.password,
                child: CustomTextField(
                  controller: _passwordController,
                  hintText: '',
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
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
