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
}
