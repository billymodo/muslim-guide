# Phase 02 — Reference City Validation

## Purpose and status

This document defines the reference-city matrix for validating `PrayerCalculator`.
The reference date, source snapshots, and measured results have not yet been
fully collected. Use `2026-10-07` as the shared reference date. No measured
prayer-time values or PASS results are asserted here.

Calculation-method defaults are a product decision, not a city mapping:
MWL remains the user default under DEC-0028. The method in this matrix is used
only to select the matching reference calculation for validation.

## Reference matrix

| City | Coordinates | Reference method | Reference source | Source status |
|---|---|---|---|---|
| Mecca | 21.42°N, 39.83°E | Umm al-Qura | Umm al-Qura Calendar | Exact source URL and dated values pending |
| Cairo | 30.04°N, 31.24°E | Egyptian | Egyptian General Authority of Survey — [esa.gov.eg](https://www.esa.gov.eg/) | Official authority identified; dated prayer-time table pending |
| Riyadh | 24.71°N, 46.68°E | Umm al-Qura | Umm al-Qura Calendar | Exact source URL and dated values pending |
| Karachi | 24.86°N, 67.01°E | Karachi | University of Islamic Sciences, Karachi | Exact source URL and dated values pending |
| Jakarta | 6.21°S, 106.85°E | MWL | Kemenag — primary reference; Aladhan MWL — secondary verification | Official schedule URL, date-specific values, and source resolution pending |
| London | 51.51°N, 0.13°W | MWL | Aladhan MWL timings — secondary verification only | Date-specific response pending; not an official primary reference |
| Istanbul | 41.01°N, 28.98°E | MWL | Aladhan MWL timings — secondary verification only | Date-specific response pending; Diyanet is not used for PASS/FAIL |
| Tromsø | 69.65°N, 18.96°E | MWL + selected high-latitude rule | Aladhan timings — secondary verification only | Date, high-latitude rule, and response pending |

Aladhan's method metadata is available at
<https://api.aladhan.com/v1/methods>. Secondary data is for verification only;
it does not replace a primary reference or establish reuse rights.

### Jakarta — MWL (Test Method) vs Kemenag (Primary Reference)

**Coordinates:** 6.21°S, 106.85°E  
**Test Method:** MWL  
**Primary Reference:** Kemenag, Indonesia's Ministry of Religious Affairs —
[bimasislam.kemenag.go.id](https://bimasislam.kemenag.go.id)  
**Secondary Verification:** Aladhan MWL  
**Test date:** 2026-10-07

**Verification:** One-time manual comparison against the Kemenag schedule.

**Source time resolution:** To be recorded during verification.

**Result:** Pending implementation and manual verification — record `PASS` or
documented contextual differences only.

Kemenag prayer-time values are **not stored in this repository** because the
asset is marked `redistribution_allowed: false`. The application's own
computed values for `2026-10-07` may be stored as a regression baseline; record
only the manual verification outcome here.

Re-verify if the algorithm, reference date, or Kemenag method changes.

Kemenag is the PASS/FAIL source for Jakarta. A difference beyond the approved
margin is recorded as a contextual difference, not an automatic failure; open
OD-0027 to investigate only if such a difference is observed. Aladhan is a
secondary check and cannot override the Kemenag result. Kemenag data is
identified for testing only and is not to be redistributed.

## Accuracy margins

| Prayer/time type | Latitude | Allowed difference |
|---|---:|---:|
| Algorithmic solar noon (Dhuhr) | 0°–60° | ±30 seconds |
| Published-reference Dhuhr | 0°–60° | ±1 minute |
| Asr, Maghrib, Sunrise | 0°–60° | ±1 minute |
| Fajr, Isha | 0°–45° | ±2 minutes |
| Fajr, Isha | 45°–60° | ±3 minutes |
| All prayer times | 60°+ | ±5 minutes |

The published source's time resolution must be recorded before applying a
margin. A source that publishes only whole minutes cannot establish an
algorithmic ±30-second Dhuhr result; use the published-reference ±1-minute
criterion for that comparison.

The algorithmic solar-noon check uses the Meeus-based equations documented by
the official [NOAA Solar Calculator](https://gml.noaa.gov/grad/solcalc/calcdetails.html).
Implement the formula locally in the test code; do not add a package or store
NOAA/Kemenag source times in the repository.

## Per-city result tables

For each city, record the exact test date, source URL, access date, timezone,
coordinates, reference method, Asr method, high-latitude rule, and source time
resolution. Calculate the signed difference as `ours - reference`.

### Mecca — Umm al-Qura

| Prayer | Ours | Reference | Δ | Margin | Status |
|---|---|---|---|---|---|
| Fajr | Pending | Pending | Pending | ±2m | NOT RUN |
| Sunrise | Pending | Pending | Pending | ±1m | NOT RUN |
| Dhuhr | Pending | Pending | Pending | ±30s | NOT RUN |
| Asr | Pending | Pending | Pending | ±1m | NOT RUN |
| Maghrib | Pending | Pending | Pending | ±1m | NOT RUN |
| Isha | Pending | Pending | Pending | ±2m | NOT RUN |

### Cairo — Egyptian

| Prayer | Ours | Reference | Δ | Margin | Status |
|---|---|---|---|---|---|
| Fajr | Pending | Pending | Pending | ±2m | NOT RUN |
| Sunrise | Pending | Pending | Pending | ±1m | NOT RUN |
| Dhuhr | Pending | Pending | Pending | ±30s | NOT RUN |
| Asr | Pending | Pending | Pending | ±1m | NOT RUN |
| Maghrib | Pending | Pending | Pending | ±1m | NOT RUN |
| Isha | Pending | Pending | Pending | ±2m | NOT RUN |

Repeat the same six-row result table for Riyadh, Karachi, Jakarta, London,
Istanbul, and Tromsø, applying the latitude-specific margins above. Any failed
official-reference cell requires review of the calculation or reference
configuration before acceptance. For Jakarta, apply the contextual-difference
and OD-0027 procedure above instead of treating a Kemenag difference as an
automatic failure.

## DST and high-latitude checks

- London DST checks use `2026-03-29` (start) and `2026-10-25` (end) in
  `Europe/London`.
- Tromsø checks each of MiddleOfNight, SeventhOfNight, TwilightAngle, and None
  on `2026-06-21` and `2026-12-21`. Record whether each rule produces defined
  Fajr/Isha values.

## Exclusions

Diyanet prayer times are not included in the reference comparisons. Its
published times use calculation parameters that have not been verified for this
project; adding the Diyanet method is deferred by OD-0026.
