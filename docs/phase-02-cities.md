# Phase 02 — Offline City Data

The bundled `assets/cities/major_cities.json` contains 120 city records from
GeoNames `cities15000` and its `alternateNamesV2` Arabic names. Coordinates,
English transliterations, country codes, elevation when available, and IANA
timezones come from GeoNames. Country names are localized in this dataset.
Six places without an Arabic alternate name in that extract use a manually
supplied Arabic transliteration; this is documented in the dataset-generation
notes below.

## Attribution and license

GeoNames data is provided under CC BY 4.0. Attribute GeoNames with a link to
[GeoNames](https://www.geonames.org/). The relevant terms excerpt is saved at
[`legal/evidence/geonames-export-terms-2026-10-08.txt`](../legal/evidence/geonames-export-terms-2026-10-08.txt).
The asset checksum and evidence snapshot hash are recorded in
[`legal/assets.yaml`](../legal/assets.yaml).

Source files:

- [GeoNames `cities15000.zip`](https://download.geonames.org/export/dump/cities15000.zip)
- [GeoNames `alternateNamesV2.zip`](https://download.geonames.org/export/dump/alternateNamesV2.zip)
- [GeoNames terms](https://www.geonames.org/export/)

## Selection

| Group | Count | Cities |
|---|---:|---|
| Prayer-time reference cities | 8 | Mecca, Cairo, Riyadh, Karachi, Jakarta, London, Istanbul, Tromsø |
| Major cities in Muslim-majority countries | 40 | Dubai, Abu Dhabi, Sharjah, Doha, Amman, Tunis, Rabat, Algiers, Khartoum, Baghdad, Damascus, Beirut, Sanaa, Muscat, Kuwait City, Manama, Tripoli, Nouakchott, Mogadishu, Kabul, Tehran, Baku, Tashkent, Dhaka, Colombo, Kuala Lumpur, Madinah, East Jerusalem, Jeddah, Alexandria, Lahore, Islamabad, Peshawar, Faisalabad, Mashhad, Isfahan, Herat, Mazar-e Sharif, Dushanbe, Bishkek |
| Major global cities | 40 | New York City, Paris, Tokyo, Sydney, Toronto, Berlin, Madrid, Rome, Moscow, Beijing, Singapore, Los Angeles, Chicago, San Francisco, Vancouver, Montreal, Melbourne, Auckland, Hong Kong, Seoul, Bangkok, Delhi, Mumbai, Sao Paulo, Mexico City, Buenos Aires, Johannesburg, Nairobi, Lagos, Accra, Addis Ababa, Casablanca, Barcelona, Amsterdam, Vienna, Zurich, Brussels, Stockholm, Oslo, Washington, D.C. |
| Additional regional cities | 32 | Mosul, Basrah, Najaf, Karbala, Aleppo, Homs, Gaza, Nablus, Hebron, Luxor, Aswan, Taiz, Aden, Al Hudaydah, Erbil, Sulaymaniyah, Kirkuk, Multan, Quetta, Sialkot, Gujranwala, Hyderabad, Chattogram, Sylhet, Khulna, Yogyakarta, Surabaya, Bandung, Medan, Makassar, Fes, Marrakesh |
| **Total** | **120** | |

City IDs are stable lowercase ASCII slugs. `mecca` uses the GeoNames Makkah
record with the familiar English display alias "Mecca"; its coordinates and
other location fields are unchanged. `tromso` uses GeoNames' ASCII spelling for
Tromsø. East Jerusalem uses the GeoNames West Bank country code and its
`Asia/Hebron` timezone. Washington is the District of Columbia record, not one
of the same-named US cities.

## Arabic names without an alternate-name record

The GeoNames Arabic alternate-name extract did not contain an Arabic label for
these six selected records. The following Arabic transliterations were supplied
for display and are not represented as GeoNames alternate names:

| City | Arabic label |
|---|---|
| Dushanbe | دوشنبه |
| Gujranwala | غوجرانواله |
| Makassar | ماكاسار |
| Multan | ملتان |
| Sialkot | سيالكوت |
| Washington, D.C. | واشنطن |

## Generation and loading

The bundled file has schema version 1 and was generated on 2026-10-08. Its
shape is described by [`assets/cities/schema.json`](../assets/cities/schema.json).
`City` is a pure-Dart domain model; `CitiesLoader` loads the bundled JSON through
an injected `AssetBundle` and caches its parsed immutable list in memory. App
bootstrap initializes the full timezone database so every GeoNames IANA
identifier, including linked zones, is available to the calculator.
