# Release Pipeline



## Stages

Development

↓

Pull Request

↓

License Gate

↓

Quality Gate

↓

Build

↓

Release Verification

↓

Approved Release





## Gate Definitions



### License Gate

- Asset scan

- Hash verification

- Attribution check

- Expired review check



### Quality Gate

- `flutter analyze --fatal-infos`

- `flutter test`

- Project-specific checks (CI-012 … CI-018)



### Build

- `flutter build apk --debug`

- `flutter build apk --release` (على main فقط)



### Release Verification

- Migration test من آخر schema

- Manual device test

- THIRD_PARTY_NOTICES current



## Rule



لا مرحلة تتخطى سابقتها بصمت.



## Related

- `ci/00-ci-policy.md`

- `ci/01-ci-checks.md`

- `quality/05-release-checklist.md`



