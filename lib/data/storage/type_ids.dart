/// Central registry of Hive typeIds for TypeAdapters.
///
/// لا يُعاد استخدام أي typeId أبداً، حتى بعد حذف النوع.
/// يُحجز كل typeId إلى الأبد بمجرد تعيينه.
///
/// القيم البدائية (String وint وbool) لا تحتاج typeIds،
/// وتُخزَّن مباشرةً في `Box<dynamic>`.
class TypeIds {
  new _();

  // 0-99: أُطر العمل والنظام (لا تستخدم).
  // 100-199: بيانات المستخدم والتفضيلات.
  // 200-299: بيانات وصف المحتوى.
  // 300-399: التقدم والعلامات المرجعية.
  // 400+: محجوزة للمستقبل.
  //
  // لا توجد typeIds معيّنة حاليًا؛ القيم البدائية لا تحتاج adapters.
  // التالي المتاح: 100.
  // static const int prayerLog = 100;
  // static const int quranBookmark = 101;
}
