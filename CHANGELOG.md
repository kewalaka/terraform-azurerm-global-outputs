# Changelog

## 1.0.2

- Migrated to kewalaka github organisation and publish to Terraform registry

## 1.0.1

### Fixed

- Changed `writes.outputs` type from `map(string)` to `any` (with validation) to allow mixed value types — strings, objects, and lists can coexist in the same outputs map. The module already serialises values with `jsonencode` on write and deserialises with `jsondecode` on read, so the previous type constraint was unnecessarily restrictive.

## 1.0.0

- Initial release.
