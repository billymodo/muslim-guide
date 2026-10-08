# CR-0009 — geolocator package

**Status:** APPROVED
**Date:** 2026-10-08
**Phase:** 02

**Decision:** إضافة `geolocator 14.1.1` (MIT) كتبعية مباشرة.

**Reason:** Phase 02 Task 3 — Location Service (GPS + manual fallback).

**Scope:**
- `ACCESS_FINE_LOCATION` + `ACCESS_COARSE_LOCATION`
- لا background location
- Fallback يدوي عند رفض الصلاحية

**Verified:**
- pub.dev: `geolocator 14.1.1`
- License: MIT (compatible with project MIT)
- Dart SDK: `^3.5.0` ✅
- Flutter SDK: `>=2.8.0` ✅

**Approved By:** User
