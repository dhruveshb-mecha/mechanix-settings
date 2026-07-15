import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:nm/nm.dart';

import 'package:mechanix_settings/core/utils/app_logger.dart';
import 'package:mechanix_settings/features/wireless/data/models/enums.dart';
import 'package:mechanix_settings/features/wireless/data/utils/network_manager_utils.dart';

class WifiParser {
  static Future<bool> parseSecurity({
    required String name,
    NetworkManagerAccessPoint? ap,
    NetworkManagerSettingsConnection? connection,
    Map<String, Map<String, DBusValue>>? settings,
  }) async {
    if (ap != null) {
      return ap.wpaFlags.isNotEmpty || ap.rsnFlags.isNotEmpty;
    }

    if (settings != null) {
      return settings.containsKey('802-11-wireless-security');
    }

    if (connection != null) {
      try {
        final connectionSettings = await connection.getSettings();
        return connectionSettings.containsKey('802-11-wireless-security');
      } catch (e, stack) {
        AppLogger.e(
          'Failed to read security settings for "$name".',
          error: e,
          stack: stack,
        );
      }
    }

    return false;
  }

  static int parseSignalLevel(NetworkManagerAccessPoint? ap) {
    if (ap == null) return 0;

    if (ap.strength > 75) return 3;
    if (ap.strength > 45) return 2;
    if (ap.strength > 15) return 1;

    return 0;
  }

  static IPv4SettingsResult parseIPv4Settings(
    Map<String, Map<String, DBusValue>>? settings,
  ) {
    var ipConfigType = IPv4ConfigType.automatic;
    var ipAddress = '';
    var subnetMask = '';
    var router = '';

    var dnsConfigType = DNSConfigType.automatic;
    List<String> dnsServers = [];
    List<String> dnsSearchDomains = [];

    try {
      final ipv4 = settings?['ipv4'];

      if (ipv4 == null) {
        return IPv4SettingsResult(
          ipConfigType: ipConfigType,
          ipAddress: ipAddress,
          subnetMask: subnetMask,
          router: router,
          dnsConfigType: dnsConfigType,
          dnsServers: dnsServers,
          dnsSearchDomains: dnsSearchDomains,
        );
      }

      final method = ipv4['method']?.toNative();

      ipConfigType = method == 'manual'
          ? IPv4ConfigType.manual
          : IPv4ConfigType.automatic;

      final addressData = ipv4['address-data'];

      if (addressData is DBusArray && addressData.children.isNotEmpty) {
        final first = addressData.children.first;

        if (first is DBusDict) {
          final address = first.children[const DBusString('address')]
              ?.toNative();

          final prefix = first.children[const DBusString('prefix')]?.toNative();

          if (address is String) {
            ipAddress = address;
          }

          if (prefix is int) {
            subnetMask = NetworkManagerUtils.prefixToSubnetMask(prefix);
          }
        }
      }

      final gateway = ipv4['gateway']?.toNative();

      if (gateway is String) {
        router = gateway;
      }

      final ignoreAutoDns = ipv4['ignore-auto-dns']?.toNative();

      dnsConfigType = ignoreAutoDns == true
          ? DNSConfigType.manual
          : DNSConfigType.automatic;

      if (dnsConfigType == DNSConfigType.manual) {
        final dns = ipv4['dns'];

        if (dns is DBusArray) {
          dnsServers = dns.children.map((child) {
            final value = child.toNative();

            if (value is int) {
              return NetworkManagerUtils.uint32ToIp(value);
            }

            return value.toString();
          }).toList();
        }

        final dnsSearch = ipv4['dns-search'];

        if (dnsSearch is DBusArray) {
          dnsSearchDomains = dnsSearch.children
              .map((child) => child.toNative().toString())
              .toList();
        }
      }
    } catch (e, stack) {
      AppLogger.e('Failed to parse IPv4 settings.', error: e, stack: stack);
    }

    return IPv4SettingsResult(
      ipConfigType: ipConfigType,
      ipAddress: ipAddress,
      subnetMask: subnetMask,
      router: router,
      dnsConfigType: dnsConfigType,
      dnsServers: dnsServers,
      dnsSearchDomains: dnsSearchDomains,
    );
  }

  static bool parseAutoConnect(Map<String, Map<String, DBusValue>>? settings) {
    try {
      final value = settings?['connection']?['autoconnect']?.toNative();

      return value is bool ? value : true;
    } catch (e, stack) {
      AppLogger.e('Failed to parse autoconnect.', error: e, stack: stack);
      return true;
    }
  }

  static bool parseLowDataMode(Map<String, Map<String, DBusValue>>? settings) {
    try {
      final value = settings?['connection']?['metered']?.toNative();

      return value is int && value == 1;
    } catch (e, stack) {
      AppLogger.e('Failed to parse metered state.', error: e, stack: stack);
      return false;
    }
  }
}

@immutable
class IPv4SettingsResult {
  final IPv4ConfigType ipConfigType;
  final String ipAddress;
  final String subnetMask;
  final String router;
  final DNSConfigType dnsConfigType;
  final List<String> dnsServers;
  final List<String> dnsSearchDomains;

  const IPv4SettingsResult({
    required this.ipConfigType,
    required this.ipAddress,
    required this.subnetMask,
    required this.router,
    required this.dnsConfigType,
    required this.dnsServers,
    required this.dnsSearchDomains,
  });
}
