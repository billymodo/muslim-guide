// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_name => 'دليل المسلم';

  @override
  String get app_tagline => 'رفيقك في العبادة';

  @override
  String get btn_start => 'ابدأ الآن';

  @override
  String get onboarding_choose_language => 'اختر اللغة';

  @override
  String get onboarding_continue => 'متابعة';

  @override
  String get language_arabic => 'العربية';

  @override
  String get language_english => 'English';

  @override
  String get splash_loading => 'جاري التهيئة';

  @override
  String get splash_error => 'فشل التهيئة';

  @override
  String get splash_retry => 'إعادة المحاولة';
}
