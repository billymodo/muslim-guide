# CR-0008 — timezone package

**Status:** APPROVED
**Date:** 2026-10-07
**Phase:** 01

**Decision:** Add `timezone 0.11.1` (BSD-2-Clause) as an exact direct dependency.

**Reason:** Phase 01 bootstrap requires the IANA timezone database for
`tz.initializeTimeZones()` and the temporary `Asia/Riyadh` location.

**Verification:** `timezone 0.11.1` was published on 2026-06-29 and supports
Dart SDK `^3.10.0`, compatible with the project's Dart SDK 3.13.4.

**Consequences:**
- `Asia/Riyadh` is temporary until Phase 02.
- Phase 02 will add `flutter_timezone` to read the system timezone (OD-0025).

**Approved By:** User
