import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:muslim_guide/app/theme/app_spacing.dart';
import 'package:muslim_guide/features/location/domain/location_permission_status.dart';
import 'package:muslim_guide/features/prayer/application/location_provider.dart';
import 'package:muslim_guide/features/prayer/domain/models/city.dart';
import 'package:muslim_guide/l10n/app_localizations.dart';

/// Location picker: search bundled cities or use the current GPS position.
class LocationPickerScreen extends ConsumerStatefulWidget {
  /// Creates the location picker screen.
  const new({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

/// GPS failure surfaced to the user, localized while building the screen.
enum _GpsMessage {
  /// The user denied the location permission.
  denied,

  /// The service is disabled or the fix could not be obtained.
  failed,
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  bool _locating = false;

  _GpsMessage? _gpsMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final gpsMessage = _gpsMessage;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.location_picker_title)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.l,
                AppSpacing.s,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: localizations.location_picker_search_hint,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.s,
                AppSpacing.l,
                AppSpacing.s,
              ),
              child: Column(
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _locating ? null : _useGps,
                    icon: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                    label: Text(localizations.location_picker_use_gps),
                  ),
                  if (gpsMessage != null) ...[
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      _gpsMessageText(localizations, gpsMessage),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildCityList(localizations)),
          ],
        ),
      ),
    );
  }

  String _gpsMessageText(AppLocalizations localizations, _GpsMessage message) {
    return switch (message) {
      _GpsMessage.denied => localizations.location_picker_permission_denied,
      _GpsMessage.failed => localizations.location_picker_gps_error,
    };
  }

  Widget _buildCityList(AppLocalizations localizations) {
    return FutureBuilder<List<City>>(
      future: ref.watch(citiesLoaderProvider).load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  localizations.splash_error,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.m),
                FilledButton(
                  onPressed: () => ref.invalidate(citiesLoaderProvider),
                  child: Text(localizations.splash_retry),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final filtered = _filter(snapshot.data!, _query);
        if (filtered.isEmpty) {
          return Center(
            child: Text(
              localizations.location_picker_empty,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final city = filtered[index];
            final isArabic =
                Localizations.localeOf(context).languageCode == 'ar';
            return ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(isArabic ? city.nameAr : city.nameEn),
              onTap: () => _selectCity(city.id),
            );
          },
        );
      },
    );
  }

  /// Case-insensitive filter over both city names (ar/en).
  List<City> _filter(List<City> cities, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return cities;
    }
    final lowered = trimmed.toLowerCase();
    return cities
        .where(
          (city) =>
              city.nameAr.contains(trimmed) ||
              city.nameEn.toLowerCase().contains(lowered),
        )
        .toList();
  }

  Future<void> _selectCity(String cityId) async {
    await ref.read(locationProvider.notifier).selectCity(cityId);
    if (mounted) {
      _close();
    }
  }

  Future<void> _useGps() async {
    setState(() {
      _locating = true;
      _gpsMessage = null;
    });
    try {
      final service = ref.read(locationServiceProvider);
      var permission = await service.checkPermission();
      if (permission == LocationPermissionStatus.denied) {
        permission = await service.requestPermission();
      }
      if (permission == LocationPermissionStatus.granted) {
        final fix = await service.getCurrentLocation();
        await ref
            .read(locationProvider.notifier)
            .selectCoordinates(
              latitude: fix.latitude,
              longitude: fix.longitude,
            );
        if (mounted) {
          _close();
        }
      } else if (mounted) {
        setState(() {
          _gpsMessage = permission == LocationPermissionStatus.serviceDisabled
              ? _GpsMessage.failed
              : _GpsMessage.denied;
        });
      }
    } on Object {
      if (mounted) {
        setState(() => _gpsMessage = _GpsMessage.failed);
      }
    } finally {
      if (mounted) {
        setState(() => _locating = false);
      }
    }
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/prayer');
    }
  }
}
