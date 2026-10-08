// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Muslim Guide';

  @override
  String get app_tagline => 'Your worship companion';

  @override
  String get btn_start => 'Get Started';

  @override
  String get onboarding_choose_language => 'Choose Language';

  @override
  String get onboarding_continue => 'Continue';

  @override
  String get language_arabic => 'العربية';

  @override
  String get language_english => 'English';

  @override
  String get splash_loading => 'Initializing';

  @override
  String get splash_error => 'Initialization failed';

  @override
  String get splash_retry => 'Retry';

  @override
  String get home_greeting => 'Peace be upon you';

  @override
  String get onboarding_save_error =>
      'Could not save your settings. Please try again.';

  @override
  String get language_arabic_semantics => 'Select Arabic language';

  @override
  String get language_english_semantics => 'Select English language';

  @override
  String get prayer_title => 'Prayer Times';

  @override
  String get prayer_fajr => 'Fajr';

  @override
  String get prayer_sunrise => 'Sunrise';

  @override
  String get prayer_dhuhr => 'Dhuhr';

  @override
  String get prayer_asr => 'Asr';

  @override
  String get prayer_maghrib => 'Maghrib';

  @override
  String get prayer_isha => 'Isha';

  @override
  String get sunrise_not_prayer => 'Not a prayer';

  @override
  String get prayer_no_location => 'No location set';

  @override
  String get prayer_set_location => 'Set location';

  @override
  String get prayer_calc_error => 'Could not calculate prayer times';

  @override
  String get prayer_retry => 'Retry';

  @override
  String get prayer_no_next_today => 'No more prayers today';

  @override
  String get prayer_time_unavailable => 'Unavailable';

  @override
  String get prayer_current_location => 'Current location';

  @override
  String get prayer_notification_settings => 'Notification settings';

  @override
  String get location_picker_title => 'Choose Location';

  @override
  String get location_picker_search_hint => 'Search for a city';

  @override
  String get location_picker_use_gps => 'Use my location';

  @override
  String get location_picker_permission_denied => 'Location permission denied';

  @override
  String get location_picker_empty => 'No results';

  @override
  String get location_picker_gps_error => 'Could not determine your location';

  @override
  String get prayer_settings_coming_soon => 'Coming soon';
}
