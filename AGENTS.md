# AGENTS.md — AI Assistant Guide for abap2UI5 layout-management

> This file follows the cross-tool AGENTS.md convention and is the single
> agent instruction file of this repository — `CLAUDE.md` only points here.

## Project Overview

Customizable table and form layouts with persistent variant management for
[abap2UI5](https://github.com/abap2UI5/abap2UI5) (`z2ui5_cl_layo_*`). Layout
variants are persisted to this addon's own database tables (`z2ui5_t_11`,
`z2ui5_t_12`).

**Language:** English — all code, comments, commit messages, PRs, issues and
documentation must be in English.

## Package Structure

| Package | Content |
|---|---|
| `src/01/` | Samples (`z2ui5_cl_layo_sample_*`) |
| `src/02/` | Variant management - an empty package for now |
| `src/03/` | Layout classes (`z2ui5_cl_layo_*`), the authorization hook `z2ui5_if_layo_auth`, the variant tables `z2ui5_t_11` / `z2ui5_t_12` and the vendored utility copies `z2ui5_cl_layo_context` / `z2ui5_cx_layo_error` (see "Utility Access") |

## Utility Access

`z2ui5_cl_layo_context` is a **renamed copy** of `zabaputil_cl_util_context`
from the [abap-util](https://github.com/abap-util/abap-util) master catalog,
**trimmed to the methods this addon uses** plus the private helpers, types
and class data those need; `z2ui5_cx_layo_error` is
`zabaputil_cx_util_error`, renamed and copied as-is. It is the convention of
the other addons (popups' `z2ui5_cl_popup_context`, range-filter's
`z2ui5_cl_sel_context`) and of the core (`z2ui5_cl_ui5_util_context`):
abapGit has no dependency management, so utilities are vendored, not
referenced.

1. **Never the legacy `z2ui5_cl_util*` / `z2ui5_cx_util_error`.** They left
   the core with its `src/99/01` for
   [abap2UI5-ext](https://github.com/abap2UI5/abap2UI5-ext); this addon used
   them until 2026-11 and needed abap2UI5-ext installed for it. Every utility
   call goes through `z2ui5_cl_layo_context`, and nothing of abap2UI5-ext is
   declared in the abaplint configs or cloned by `npm run unit`.
2. **New methods are added locally** to `z2ui5_cl_layo_context`; if abap-util
   already has the method, copy it from there with its private helpers. Keep
   what goes there generic - layout logic stays in the layout classes.
3. **Periodic AI sync-back** merges what was added or fixed here into
   abap-util. One deliberate difference to the master today: `ty_t_classes`
   has `WITH EMPTY KEY` (as in the core's copy), because abaplint's
   `avoid_use` refuses `DEFAULT KEY`.

## Dependencies

Installed alongside via abapGit; declared in the abaplint configs:

* [abap2UI5](https://github.com/abap2UI5/abap2UI5) — nothing else; the
  utilities are vendored, see "Utility Access"

## Coding Style

Follows the abap2UI5 core conventions (see its
[AGENTS.md](https://github.com/abap2UI5/abap2UI5/blob/main/AGENTS.md)): Clean
ABAP with Hungarian prefixes, backtick string literals, `xsdbool()`. After a
functional method call, do not read `sy-subrc` (it is undefined) — check the
returned value instead.

## Validation

Run `npm run check` before considering changes complete: it runs the same
abaplint, abap2UI5-linter and rename steps as CI, and all of them must pass.
CI:

* `abap-standard` / `abap-cloud` — lint against Standard ABAP
  (`abaplint.jsonc`) and ABAP Cloud (`.github/abaplint/abap_cloud.jsonc`)
* `check-abap2ui5` — the abap2UI5-linter over the app classes and their
  views (`abap2ui5lint.jsonc`)
* `publish-702` / `abap-702` — `publish-702` writes the downported `702`
  branch on every push to `main` (`npm run auto_downport`: `abaplint --fix`
  against `.github/abaplint/abap_702.jsonc`), and `abap-702` lints it
* `abap-unit` — the ABAP Unit tests on abap2UI5's transpiled Node runtime, the way abap2UI5 tests itself: `npm run unit` (`.github/scripts/unit.mjs`) copies the packages into a checkout of abap2UI5's `main`, downports, transpiles and runs the tests of this repository's classes
* `check-rename` — namespace-rename check (`npm run rename`, `.github/scripts/rename.mjs`)

All `.abap`/`.xml`/config files are LF-only (`.gitattributes` enforces it).

## Namespace rename

`npm run rename` (CI: `check-rename`) and the manual `build-rename` workflow
are abap2UI5's namespace rename for this addon - `.github/scripts/rename.mjs`,
the same file in every addon that has one. Every `z2ui5_` object becomes
`<name>_...`, for a customer name such as `ZMYUI5` or a registered namespace
such as `/CA2UI5/` (at most 10 characters), and so does every reference to
abap2UI5 and to the addons this one builds on: the branch `rename_<name>` runs
on an abap2UI5 renamed with the same name by its own `build-rename`. What
follows from it:

- Every object name has at most 25 characters (a transparent table
  11, an ICF node 10) - 30 minus what the longest new name adds.
- No literal names a `z2ui5_` object: the rename rewrites references, never a
  literal. Derive the name - from a typed reference, or behind the prefix of
  the class's own name.
- A change that spans several repositories: `RENAME_DEPS_FROM=<dir> npm run
  rename` takes the dependencies from the clones in `<dir>`.
