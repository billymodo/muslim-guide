import 'package:muslim_guide/features/prayer/domain/models/calculation_method.dart';

/// Default calculation method per ISO 3166-1 alpha-2 country code.
///
/// Phase 05-B country detection: when a city is picked while the method is
/// still implicit (the user never chose one), the mapped method is
/// auto-applied with an Undo SnackBar. Unknown codes return null (keep MWL).
///
/// Asr school and high-latitude rule have no country defaults: Asr is a
/// personal choice, and high-latitude rules apply to regions, not countries.
const Map<String, CalculationMethod> countryMethodMapping = {
  // Egypt — Egyptian General Authority of Survey (19.5 deg Fajr).
  'EG': CalculationMethod.egyptian,
  'LY': CalculationMethod.egyptian,
  'SD': CalculationMethod.egyptian,
  'SY': CalculationMethod.egyptian,
  // Gulf + Levant + Yemen — Umm al-Qura.
  'SA': CalculationMethod.ummAlQura,
  'AE': CalculationMethod.ummAlQura,
  'BH': CalculationMethod.ummAlQura,
  'KW': CalculationMethod.ummAlQura,
  'OM': CalculationMethod.ummAlQura,
  'QA': CalculationMethod.ummAlQura,
  'YE': CalculationMethod.ummAlQura,
  'JO': CalculationMethod.ummAlQura,
  'LB': CalculationMethod.ummAlQura,
  'PS': CalculationMethod.ummAlQura,
  'IQ': CalculationMethod.ummAlQura,
  // South Asia — Karachi.
  'PK': CalculationMethod.karachi,
  'IN': CalculationMethod.karachi,
  'BD': CalculationMethod.karachi,
  'LK': CalculationMethod.karachi,
  'AF': CalculationMethod.karachi,
  'MR': CalculationMethod.karachi,
  // North America — ISNA.
  'US': CalculationMethod.isna,
  'CA': CalculationMethod.isna,
  // Iran — Tehran.
  'IR': CalculationMethod.tehran,
  // North Africa (non-Egyptian default) — MWL keeps working; map to MWL
  // explicitly so the suggestion row stays silent.
  'MA': CalculationMethod.mwl,
  'DZ': CalculationMethod.mwl,
  'TN': CalculationMethod.mwl,
  // Turkey / Central Asia — MWL-compatible defaults.
  'TR': CalculationMethod.mwl,
  'AZ': CalculationMethod.mwl,
  'KG': CalculationMethod.mwl,
  'TJ': CalculationMethod.mwl,
  'UZ': CalculationMethod.mwl,
  // Southeast Asia — MWL-compatible defaults.
  'ID': CalculationMethod.mwl,
  'MY': CalculationMethod.mwl,
  'SG': CalculationMethod.mwl,
  'TH': CalculationMethod.mwl,
  // Sub-Saharan Africa — MWL-compatible defaults.
  'NG': CalculationMethod.mwl,
  'ET': CalculationMethod.mwl,
  'KE': CalculationMethod.mwl,
  'GH': CalculationMethod.mwl,
  'SO': CalculationMethod.mwl,
  'ZA': CalculationMethod.mwl,
  // Europe / East Asia / Oceania / Americas — MWL default.
  'GB': CalculationMethod.mwl,
  'FR': CalculationMethod.mwl,
  'DE': CalculationMethod.mwl,
  'NL': CalculationMethod.mwl,
  'BE': CalculationMethod.mwl,
  'AT': CalculationMethod.mwl,
  'CH': CalculationMethod.mwl,
  'IT': CalculationMethod.mwl,
  'ES': CalculationMethod.mwl,
  'SE': CalculationMethod.mwl,
  'NO': CalculationMethod.mwl,
  'RU': CalculationMethod.mwl,
  'CN': CalculationMethod.mwl,
  'JP': CalculationMethod.mwl,
  'KR': CalculationMethod.mwl,
  'HK': CalculationMethod.mwl,
  'AU': CalculationMethod.mwl,
  'NZ': CalculationMethod.mwl,
  'BR': CalculationMethod.mwl,
  'MX': CalculationMethod.mwl,
  'AR': CalculationMethod.mwl,
};
