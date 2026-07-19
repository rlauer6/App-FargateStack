# App::FargateStack 1.1.0 Release Notes

**Released:** Sun Jul 19 2026  
**Author:** Rob Lauer <rclauer@gmail.com>

---

## Overview

Version 1.1.0 marks the first **production-ready release** of
`App::FargateStack`. This release focuses on build system
modernization, dependency consolidation, and code cleanup. The
framework's public API and feature set remain unchanged.

---

## What's New

### New Files

- `README.md.in` — Markdown template source for generated documentation
- `cpanfile` — Standard CPAN dependency declaration file
- `project.mk`, `config.mk`, `deps.mk` — Modular build configuration
- `test-requires.skip` — Mechanism to suppress unwanted test dependencies
- `.includes/git.mk`, `.includes/help.mk`, `.includes/perl.mk`, `.includes/release-notes.mk`, `.includes/update.mk`, `.includes/upgrade.mk`, `.includes/version.mk` — Modular Makefile includes installed by `CPAN::Maker::Bootstrapper`
- `examples/minimal-multi-tasks.yaml`, `examples/multi-tasks.yml`, `examples/my-cron-job.yml` — New configuration examples

---

## Changes

### Build System Overhaul

The `Makefile` has been completely rewritten using
`CPAN::Maker::Bootstrapper` conventions. Key improvements include:

- Automatic discovery of source files, tests, and binary scripts via
  `find`
- Integrated dependency scanning via `scandeps-static.pl` (when
  available)
- Support for `perltidy` and `perlcritic` linting passes during builds
- CI build support via Docker using a configurable `builder` script
- New targets: `quick`, `test`, `check`, `build-ci`, `workflow`,
  `modulino`, `basedir`
- Version management delegated to `.includes/version.mk`

### Dependency Management

- `requires` file updated with **explicit minimum version
  constraints** for all runtime dependencies
- New hard dependency on `CLI::Simple` >= 2.1.0,
  `CLI::Simple::Constants` >= 2.1.0, and `CLI::Simple::Utils` >= 2.1.0
- `cpanfile` generated from `requires` and `test-requires`

### `CLI::Simple::Utils` Integration

The `choose` and `toCamelCase`/`ToCamelCase` utility functions,
previously implemented locally in `App::FargateStack::Builder::Utils`,
have been removed in favour of importing them directly from
`CLI::Simple::Utils`. Affected modules:

- `App::FargateStack` — now imports `choose`, `toCamelCase` from `CLI::Simple::Utils`
- `App::ECS` — now imports `choose` from `CLI::Simple::Utils`
- `App::FargateStack::AutoscalingConfig` — likewise
- `App::FargateStack::Builder::IAM` — likewise
- `App::FargateStack::Builder::TaskDefinition` — likewise
- `App::FargateStack::Checker` — likewise
- `App::FargateStack::CloudTrail` — likewise
- `App::FargateStack::Constants` — `choose` now imported from `CLI::Simple::Utils`; local definition removed
- `App::FargateStack::Builder::Utils` — local `choose`, `ToCamelCase`, `toCamelCase`, and `slurp_file` implementations removed; `CLI::Simple::Utils` used instead

### `buildspec.yml` Updates

- Key naming normalised from underscore style (`pm_module`,
  `test_requires`) to hyphen style (`pm-module`, `test-requires`) to
  align with current `cpan-maker` conventions
- `postamble` reference removed
- Repository and bugtracker URLs updated to HTTPS
- `exe-files` replaces `scripts` as the path key for binary scripts

### `bin/app-fargatestack` Simplification

`The modulino launcher script has been rewritten to use a minimal,
direct invocation pattern:

```bash
MODULINO_WRAPPER=app-fargatestack perl $MODULE_PATH "$@"
```

The previous complex bash logic for resolving module paths and
handling `CARP_ALWAYS` has been removed.

### Documentation

- `README.md` regenerated from POD source
- `App::FargateStack::Pod` — added `=encoding utf8` declaration;
  version string now interpolated at build time
- `App::FargateStack::Checker` — added `=encoding utf8` declaration
- `App::FargateStack::Builder::Utils` — `=head2 choose` documentation
  block removed (function no longer lives here)

### Code Tidying

Minor whitespace and formatting adjustments across:

- `App::EFS`
- `App::FargateStack::Builder::LogGroup`
- `App::FargateStack::Builder::Secrets`
- `App::FargateStack::Builder::WafV2`
- `App::FargateStack::Builder::Utils`

---

## Removed

| Item | Reason |
|------|--------|
| `bin/app-FargateStack` | Replaced by simplified `bin/app-fargatestack` modulino wrapper |
| `install-deps` | Replaced by standard `cpanfile` workflow |
| `build-requires` | Superseded by `CPAN::Maker::Bootstrapper` build infrastructure |
| `version.mk` | Replaced by `.includes/version.mk` |
| `packages` | No longer needed; dependency scanning is integrated into `Makefile` |
| `postamble` | Removed; symlink installation handled differently |
| `requires.in` | Replaced by automated scanning |
| `t/01-test-utils.t` | Removed; tested functions (`ToCamelCase`, `toCamelCase`) now live in `CLI::Simple::Utils` |

---

## Upgrading

This release requires `CLI::Simple` >= 2.1.0. Ensure your environment
has an up-to-date `CLI::Simple` before upgrading:

```bash
cpanm CLI::Simple
```

If you were previously relying on `App::FargateStack::Builder::Utils`
exporting `choose`, `ToCamelCase`, or `toCamelCase`, update your code
to import these from `CLI::Simple::Utils` instead.

---

## Bug Reports

Please report issues at: [https://github.com/rlauer6/App-FargateStack/issues](https://github.com/rlauer6/App-FargateStack/issues)
