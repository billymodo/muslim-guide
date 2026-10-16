#!/usr/bin/env python3
"""Convert the verbatim Tanzil Uthmani text export to structured JSON."""

import hashlib
import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
STAGING = ROOT / "tool" / "tanzil"
SOURCE = STAGING / "quran-uthmani.txt"
METADATA = STAGING / "quran-data.xml"
OUTPUT = ROOT / "assets" / "content" / "quran" / "quran-uthmani.json"

VERSE_PATTERN = re.compile(r"^(\d+)\|(\d+)\|(.+)$")
EXPECTED_SURAH_COUNT = 114
EXPECTED_VERSE_COUNT = 6236


def parse_verses(path: Path) -> dict[int, list[dict[str, int | str]]]:
    verses: dict[int, list[dict[str, int | str]]] = {}

    with path.open(encoding="utf-8") as source_file:
        for line_num, raw_line in enumerate(source_file, start=1):
            line = raw_line.rstrip("\r\n")
            if not line.strip() or line.startswith("#"):
                continue

            match = VERSE_PATTERN.fullmatch(line)
            if match is None:
                raise ValueError(f"Invalid line at {line_num}: {line!r}")

            surah_id, verse_id = int(match.group(1)), int(match.group(2))
            if not 1 <= surah_id <= EXPECTED_SURAH_COUNT:
                raise ValueError(f"Invalid surah id at line {line_num}: {surah_id}")

            surah_verses = verses.setdefault(surah_id, [])
            expected_verse_id = len(surah_verses) + 1
            if verse_id != expected_verse_id:
                raise ValueError(
                    f"Nonsequential verse id at line {line_num}: "
                    f"surah {surah_id}, expected {expected_verse_id}, got {verse_id}"
                )

            # Keep the source verse text exactly as supplied; do not normalize it.
            surah_verses.append({"id": verse_id, "text": match.group(3)})

    return verses


def parse_metadata(path: Path) -> list[dict[str, int | str]]:
    root = ET.parse(path).getroot()
    surahs: list[dict[str, int | str]] = []

    for element in root.findall("./suras/sura"):
        revelation = element.get("type")
        if revelation not in {"Meccan", "Medinan"}:
            raise ValueError(f"Unexpected revelation type: {revelation!r}")

        surahs.append(
            {
                "id": int(element.attrib["index"]),
                "name_ar": element.attrib["name"],
                "name_en": element.attrib["ename"],
                "name_transliteration": element.attrib["tname"],
                "verse_count": int(element.attrib["ayas"]),
                "revelation": revelation.lower(),
                "order": int(element.attrib["order"]),
            }
        )

    return surahs


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source_file:
        for chunk in iter(lambda: source_file.read(1024 * 1024), b""):
            digest.update(chunk)
    return f"sha256:{digest.hexdigest()}"


def build_quran() -> dict[str, object]:
    verses = parse_verses(SOURCE)
    metadata = parse_metadata(METADATA)

    if len(verses) != EXPECTED_SURAH_COUNT:
        raise ValueError(
            f"Expected {EXPECTED_SURAH_COUNT} surahs in text, got {len(verses)}"
        )
    if len(metadata) != EXPECTED_SURAH_COUNT:
        raise ValueError(
            f"Expected {EXPECTED_SURAH_COUNT} surahs in metadata, got {len(metadata)}"
        )
    if [surah["id"] for surah in metadata] != list(
        range(1, EXPECTED_SURAH_COUNT + 1)
    ):
        raise ValueError("Metadata surah ids must be unique and ordered from 1 to 114")

    surahs: list[dict[str, object]] = []
    for surah in metadata:
        surah_id = int(surah["id"])
        surah_verses = verses.get(surah_id, [])
        expected_count = int(surah["verse_count"])
        if len(surah_verses) != expected_count:
            raise ValueError(
                f"Surah {surah_id}: expected {expected_count} verses, "
                f"got {len(surah_verses)}"
            )
        surahs.append({**surah, "verses": surah_verses})

    total_verses = sum(len(surah["verses"]) for surah in surahs)
    if total_verses != EXPECTED_VERSE_COUNT:
        raise ValueError(
            f"Expected {EXPECTED_VERSE_COUNT} total verses, got {total_verses}"
        )

    return {
        "version": 1,
        "source": "Tanzil.net",
        "source_version": "1.1",
        "source_date": "2021-02",
        "license": "CC BY 3.0",
        "terms_of_use": [
            "Do not modify the Quran text.",
            "Clearly identify Tanzil Project as the source.",
            "Link to https://tanzil.net so users can track updates.",
            "Tanzil developer FAQ states its resources are for non-commercial use.",
        ],
        "attribution": (
            "Tanzil Quran Text — Copyright (C) 2007-2026 Tanzil Project — "
            "License: Creative Commons Attribution 3.0"
        ),
        "attribution_url": "https://tanzil.net",
        "captured_at": "2026-10-16",
        "checksum_source": sha256(SOURCE),
        "total_verses": total_verses,
        "surahs": surahs,
    }


def main() -> None:
    for input_path in (SOURCE, METADATA):
        if not input_path.is_file():
            raise FileNotFoundError(f"Required input not found: {input_path}")

    result = build_quran()
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT.open("w", encoding="utf-8", newline="\n") as output_file:
        json.dump(result, output_file, ensure_ascii=False, indent=2)
        output_file.write("\n")

    print(f"Written: {OUTPUT.relative_to(ROOT)}")
    print(f"Surahs: {len(result['surahs'])}")
    print(f"Total verses: {result['total_verses']}")
    print(f"Source checksum: {result['checksum_source']}")
    print(f"Output size: {OUTPUT.stat().st_size} bytes")
    print(f"Output checksum: {sha256(OUTPUT)}")


if __name__ == "__main__":
    main()
