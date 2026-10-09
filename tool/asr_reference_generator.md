# ASR Reference Fixture Generator

> How `test/fixtures/asr_reference.json` golden values are produced.
> Reference: **PrayTimes.js v2.5 (LGPL)** — https://praytimes.org/code/v2/js/PrayTimes.js

## 1. Fetch the source (offline use)

```powershell
Invoke-WebRequest -Uri 'https://praytimes.org/code/v2/js/PrayTimes.js' `
  -OutFile "$env:TEMP\PrayTimes.js"
(Get-FileHash "$env:TEMP\PrayTimes.js" -Algorithm SHA256).Hash.ToLower()
```

Expected SHA256 (recorded in the fixture header):

```
f0e8442410446b1bf2db613bdebd3aa3aef5cdf5483068fbd9212d5acaa180fd
```

If the hash differs, the upstream file changed — do **not** regenerate until
the change is reviewed (update the fixture header + this document together).

## 2. Run it

The file is a browser script (no `module.exports`). Load it in Node:

```js
const fs = require('fs');
eval(fs.readFileSync(process.env.TEMP + '/PrayTimes.js', 'utf8'));

const pt = new PrayTimes('MWL');
pt.adjust({ asr: 'Standard', dhuhr: 0 });
pt.getFormattedTime = (t) => t.toFixed(6); // raw decimal hours

const t = pt.getTimes([Y, M, D], [lat, lng], tzHours, dstHours, '24h');
// Convert decimal hours -> HH:MM:SS for the golden_asr field.
// Intermediates (optional): pt.julian(Y,M,D) - lng/360 (+ 13/24 for Asr).
```

Inputs for every case live in `test/fixtures/asr_reference.json`:
`date`, `lat`, `lng`, `timezone` (IANA — derive `tzHours`/`dstHours` for the
date; remember DST rules, e.g. London 2026-10-25 is GMT after the switch).

## 3. Update the fixture

1. Regenerate `golden_asr` for every case you touch (or add new cases).
2. Keep `reference_*` columns informational only (they are NOT asserted —
   secondary sources proved unstable; see `docs/od-0028-asr-investigation.md`).
3. Update `generator.generated_at` and re-verify the SHA256.
4. Run `flutter test test/features/prayer/domain/prayer_asr_reference_test.dart`.

## 4. Licensing reminder

- **Do NOT commit `PrayTimes.js` itself** (LGPL — source stays upstream/out-of-tree).
- Committing generated **values** (this fixture) with attribution is fine.
- Never remove the `source` / `source_url` / `sha256` provenance fields.
