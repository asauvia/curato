# Curato Design System Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the warm-paper token values in all five Curato frontend apps with the new "modern luxury showroom" tokens (paper/ink/stone/hairline/muted/brass/moss/oxide + Fraunces display type), write the canonical token reference doc, and remove the scaffold/template artifacts identified in the spec.

**Architecture:** One canonical Markdown token reference (`docs/design-system/tokens.md`) is transcribed from the approved spec. Each of the three Flutter apps gets its `app_colors.dart` constants updated to the new hex values plus two new constants (`brass`, `oxide`), and its `app_theme.dart` display/heading text styles switched from Instrument Sans to Fraunces (body text and button/card shapes are unchanged — they already match the spec). Each of the two React apps gets its CSS custom properties updated to the new values (HSL triplets for `curato-reseller`'s Tailwind v4 `@theme`, plain hex for `user-reseller`'s hand-written CSS) and its font-loading `<link>`/`@import` updated to also load Fraunces. A final cleanup task removes duplicate/scaffold files flagged in the spec.

**Tech Stack:** Flutter/Dart (Material 3, `google_fonts`) for `curato-ecom`, `curato-vendor`, `curato-admin`; React 19 + Vite + TypeScript + Tailwind CSS v4 for `curato-reseller`; React + Vite + hand-written CSS for `user-reseller`.

**Spec:** `docs/superpowers/specs/2026-10-22-design-system-design.md`

## Global Constraints

- Exact token values (from the spec, do not deviate): `paper #F7F4EF`, `ink #16130F`, `stone #ECE7DF`, `hairline #DAD2C4`, `muted #6B6257`, `brass #A6823E`, `moss #4A6B4D`, `oxide #A23B2E`.
- Equivalent HSL triplets (precomputed for the Tailwind v4 app, `curato-reseller`, which stores colors as HSL): `paper 37.5 33.3% 95.3%`, `ink 34.3 18.9% 7.3%`, `stone 36.9 25.5% 90.0%`, `hairline 38.2 22.9% 81.2%`, `muted 33.0 10.3% 38.0%`, `brass 39.2 45.6% 44.7%`, `moss 125.5 18.2% 35.5%`, `oxide 6.7 55.8% 40.8%`.
- Typography: Fraunces (Google Fonts) for display/heading text only; Instrument Sans stays for body/UI text; JetBrains Mono stays for data/mono text. No task changes body text styling.
- Buttons stay pill-shaped and cards stay hairline-border/no-shadow in every app — these already match the spec; no task should change button or card *shape*.
- No new test framework, build pipeline, or token-generation tooling is introduced (per the spec's non-goals). The two React apps have no existing test runner — their tasks verify via `grep` against exact expected values and a successful build/typecheck command, not a unit test framework.
- `flutter` is not installed in this working environment. Every Flutter task's test-running steps (`flutter test`) require a Flutter SDK; if one isn't available when a task is executed, skip the run-and-confirm steps' tool invocation and instead manually re-read the diff against this plan's pinned values before committing — note this explicitly when it happens.
- Reusable component variants implied by the spec's "Components" section (a brass-outline button, a "plinth" product card) are documented as patterns in `docs/design-system/tokens.md` for the per-app specs to build and use — this plan does not build them as standalone, unconsumed components (YAGNI: nothing in this plan's scope would call them yet).

## Review Focus

- Legacy color aliases in `curato-ecom/lib/core/constants/app_colors.dart` (e.g. `maroonFestive`, `creamBg`) are defined as `static const Color x = foreground;`/`= background;` — a test must confirm at least one alias resolves to the *new* ink/paper value, not just the primary-named constants, since a mis-edit could leave an alias pointing at an old literal.
- `curato-admin/lib/core/theme/app_theme.dart`'s `colorScheme.error` is a hardcoded `Color(0xFFDC2626)` literal, not wired to `AppColors` at all — it must be explicitly updated to the new oxide value or it will silently keep the old bright-red error color after this change.
- `user-reseller/src/index.css`'s `--accent-gold` is a hardcoded hex literal that duplicates `--text`'s value (not a `var()` reference) — it must be updated alongside `--text`/`--accent` or it will silently drift from the new ink value.
- `curato-reseller/src/index.css` has several tokens the spec explicitly leaves untouched (`--destructive-foreground`, `--chart-4`, `--chart-5`) — the task must confirm these exact values are still present unchanged after the edit, guarding against an overly broad find-and-replace.
- Deleting the eight duplicate `*copy*.dart` files in `curato-ecom` must not break compilation — verified by confirming zero import references to any of them exist before deletion (already confirmed once during planning; the task re-confirms it as a repeatable step).

---

### Task 1: Canonical token reference document

**Files:**
- Create: `docs/design-system/tokens.md`

**Interfaces:**
- Produces: the canonical token table (names, hex values, HSL equivalents, roles) and the typography/layout/motion/component-pattern reference that every later task in this plan, and every future per-app spec, cites by token name.

- [ ] **Step 1: Write `docs/design-system/tokens.md`**

Transcribe, verbatim, from the approved spec (`docs/superpowers/specs/2026-10-22-design-system-design.md`):
- The full color token table (8 rows: `paper`, `ink`, `stone`, `hairline`, `muted`, `brass`, `moss`, `oxide` — hex, role, notes) plus the HSL equivalents from this plan's Global Constraints section, in a second column or sub-table.
- The Typography section (Fraunces for display/headings with `WONK=0`, Instrument Sans for UI/body, JetBrains Mono for data).
- The Spacing/layout/motion principles section.
- The Components section (brass-outline button, plinth card), explicitly labeled as "patterns for per-app specs to implement" rather than already-built code.

- [ ] **Step 2: Verify against the spec**

Read `docs/design-system/tokens.md` back and confirm every hex value matches the spec's table exactly (character-for-character) and every HSL value matches this plan's Global Constraints section.

- [ ] **Step 3: Commit**

```bash
git add docs/design-system/tokens.md
git commit -m "docs: add canonical design-system token reference"
```

---

### Task 2: `curato-ecom` tokens and display typography

**Files:**
- Modify: `curato-ecom/lib/core/constants/app_colors.dart`
- Modify: `curato-ecom/lib/core/theme/app_theme.dart`
- Create: `curato-ecom/test/design_tokens_test.dart`

**Interfaces:**
- Consumes: hex values from Global Constraints.
- Produces: `AppColors.brass` (`Color(0xFFA6823E)`), `AppColors.oxide` (`Color(0xFFA23B2E)`) — new constants later tasks/specs may reference by these exact names.

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curato_user/core/constants/app_colors.dart';
import 'package:curato_user/core/theme/app_theme.dart';

void main() {
  test('design tokens use the modern-luxury-showroom palette', () {
    expect(AppColors.background, const Color(0xFFF7F4EF));
    expect(AppColors.foreground, const Color(0xFF16130F));
    expect(AppColors.muted, const Color(0xFFECE7DF));
    expect(AppColors.mutedForeground, const Color(0xFF6B6257));
    expect(AppColors.border, const Color(0xFFDAD2C4));
    expect(AppColors.signal, const Color(0xFF4A6B4D));
    expect(AppColors.brass, const Color(0xFFA6823E));
    expect(AppColors.oxide, const Color(0xFFA23B2E));
    // legacy alias must track the new foreground value, not a stale literal
    expect(AppColors.maroonFestive, const Color(0xFF16130F));
    expect(AppColors.creamBg, const Color(0xFFF7F4EF));
  });

  test('display headings use Fraunces, body text keeps Instrument Sans', () {
    final textTheme = AppTheme.lightTheme.textTheme;
    expect(textTheme.displayLarge?.fontFamily, contains('Fraunces'));
    expect(textTheme.displayMedium?.fontFamily, contains('Fraunces'));
    expect(textTheme.titleLarge?.fontFamily, contains('Fraunces'));
    expect(textTheme.bodyMedium?.fontFamily, contains('Instrument Sans'));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/design_tokens_test.dart` (from `curato-ecom/`)
Expected: FAIL — `brass`/`oxide` are undefined and the display styles still report `'Instrument Sans'`.

- [ ] **Step 3: Update `app_colors.dart`**

Change the six base constants' hex literals to: `background = 0xFFF7F4EF`, `foreground = 0xFF16130F`, `muted = 0xFFECE7DF`, `mutedForeground = 0xFF6B6257`, `border = 0xFFDAD2C4`, `signal = 0xFF4A6B4D`. Add two new constants, `brass = Color(0xFFA6823E)` and `oxide = Color(0xFFA23B2E)`, placed near `signal`. Update the `grey` swatch's five tokens that duplicate these same colors: `grey50 = 0xFFF7F4EF`, `grey100 = 0xFFECE7DF`, `grey300 = 0xFFDAD2C4`, `grey600 = 0xFF6B6257`, `grey900 = 0xFF16130F` (and the matching entries inside the `MaterialColor grey` map). Leave `grey400`/`grey500`/`grey700`/`grey800` and the `red*`/`green*`/`blue*` swatches untouched — they aren't part of this token system. All "legacy name" aliases (`maroonFestive`, `creamBg`, etc.) already reference `foreground`/`background` and need no separate edit.

- [ ] **Step 4: Update `app_theme.dart`**

In the `textTheme` block, change `displayLarge`, `displayMedium`, and `titleLarge` from `GoogleFonts.instrumentSans(...)` to `GoogleFonts.fraunces(...)`, keeping each entry's existing `fontWeight`/`letterSpacing`/`color` arguments unchanged. Leave every other text style (including all `bodyLarge`/`bodyMedium` usage from `GoogleFonts.instrumentSansTextTheme()`) untouched.

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/design_tokens_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add curato-ecom/lib/core/constants/app_colors.dart curato-ecom/lib/core/theme/app_theme.dart curato-ecom/test/design_tokens_test.dart
git commit -m "feat(ecom): adopt modern-luxury-showroom tokens and Fraunces display type"
```

---

### Task 3: `curato-vendor` tokens and display typography

**Files:**
- Modify: `curato-vendor/lib/core/constants/app_colors.dart`
- Modify: `curato-vendor/lib/core/theme/app_theme.dart`
- Create: `curato-vendor/test/design_tokens_test.dart`

**Interfaces:**
- Consumes: hex values from Global Constraints.
- Produces: `AppColors.brass` (`Color(0xFFA6823E)`), `AppColors.oxide` (`Color(0xFFA23B2E)`).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curato_vendor/core/constants/app_colors.dart';
import 'package:curato_vendor/core/theme/app_theme.dart';

void main() {
  test('design tokens use the modern-luxury-showroom palette', () {
    expect(AppColors.primary, const Color(0xFF16130F));
    expect(AppColors.secondary, const Color(0xFF6B6257));
    expect(AppColors.background, const Color(0xFFF7F4EF));
    expect(AppColors.surface, const Color(0xFFF7F4EF));
    expect(AppColors.muted, const Color(0xFFECE7DF));
    expect(AppColors.border, const Color(0xFFDAD2C4));
    expect(AppColors.signal, const Color(0xFF4A6B4D));
    expect(AppColors.error, const Color(0xFFA23B2E));
    expect(AppColors.brass, const Color(0xFFA6823E));
    expect(AppColors.oxide, const Color(0xFFA23B2E));
  });

  test('display headings use Fraunces, body text keeps Instrument Sans', () {
    final textTheme = AppTheme.lightTheme.textTheme;
    expect(textTheme.displayLarge?.fontFamily, contains('Fraunces'));
    expect(textTheme.displayMedium?.fontFamily, contains('Fraunces'));
    expect(textTheme.displaySmall?.fontFamily, contains('Fraunces'));
    expect(textTheme.bodyMedium?.fontFamily, contains('Instrument Sans'));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/design_tokens_test.dart` (from `curato-vendor/`)
Expected: FAIL — `brass`/`oxide` undefined, `error` still the old Material red, display styles still report `'Instrument Sans'`.

- [ ] **Step 3: Update `app_colors.dart`**

Change `primary = 0xFF16130F`, `secondary = 0xFF6B6257`, `background = 0xFFF7F4EF`, `surface = 0xFFF7F4EF`, `muted = 0xFFECE7DF`, `border = 0xFFDAD2C4`, `error = 0xFFA23B2E` (oxide — replaces the unrelated Material red this field previously held), `textPrimary = 0xFF16130F`, `textSecondary = 0xFF6B6257`, `signal = 0xFF4A6B4D`. Add `brass = Color(0xFFA6823E)` and `oxide = Color(0xFFA23B2E)` near `signal`. Leave `textLight`, `warning`, `info` untouched — not part of this token system.

- [ ] **Step 4: Update `app_theme.dart`**

Change `displayLarge`, `displayMedium`, and `displaySmall` in the `textTheme` block from `GoogleFonts.instrumentSans(...)` to `GoogleFonts.fraunces(...)`, keeping each entry's existing `color`/`fontWeight`/`letterSpacing` arguments unchanged. Leave `bodyLarge`/`bodyMedium` and the `appBarTheme.titleTextStyle` untouched.

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/design_tokens_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add curato-vendor/lib/core/constants/app_colors.dart curato-vendor/lib/core/theme/app_theme.dart curato-vendor/test/design_tokens_test.dart
git commit -m "feat(vendor): adopt modern-luxury-showroom tokens and Fraunces display type"
```

---

### Task 4: `curato-admin` tokens and display typography

**Files:**
- Modify: `curato-admin/lib/core/constants/app_colors.dart`
- Modify: `curato-admin/lib/core/theme/app_theme.dart`
- Create: `curato-admin/test/design_tokens_test.dart`

**Interfaces:**
- Consumes: hex values from Global Constraints.
- Produces: `AppColors.brass` (`Color(0xFFA6823E)`), `AppColors.oxide` (`Color(0xFFA23B2E)`).

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:curato_admin/core/constants/app_colors.dart';
import 'package:curato_admin/core/theme/app_theme.dart';

void main() {
  test('design tokens use the modern-luxury-showroom palette', () {
    expect(AppColors.background, const Color(0xFFF7F4EF));
    expect(AppColors.foreground, const Color(0xFF16130F));
    expect(AppColors.muted, const Color(0xFFECE7DF));
    expect(AppColors.mutedForeground, const Color(0xFF6B6257));
    expect(AppColors.border, const Color(0xFFDAD2C4));
    expect(AppColors.signal, const Color(0xFF4A6B4D));
    expect(AppColors.signalTint, const Color(0x1A4A6B4D));
    expect(AppColors.brass, const Color(0xFFA6823E));
    expect(AppColors.oxide, const Color(0xFFA23B2E));
  });

  test('display headings use Fraunces and the error color is oxide', () {
    final textTheme = AppTheme.lightTheme.textTheme;
    expect(textTheme.displayLarge?.fontFamily, contains('Fraunces'));
    expect(textTheme.displayMedium?.fontFamily, contains('Fraunces'));
    expect(textTheme.displaySmall?.fontFamily, contains('Fraunces'));
    expect(AppTheme.lightTheme.colorScheme.error, const Color(0xFFA23B2E));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/design_tokens_test.dart` (from `curato-admin/`)
Expected: FAIL — `brass`/`oxide` undefined, `colorScheme.error` still `0xFFDC2626`, no `displayLarge`/`displayMedium`/`displaySmall` override exists yet so they inherit Instrument Sans.

- [ ] **Step 3: Update `app_colors.dart`**

Change `background = 0xFFF7F4EF`, `foreground = 0xFF16130F`, `muted = 0xFFECE7DF`, `mutedForeground = 0xFF6B6257`, `border = 0xFFDAD2C4`, `signal = 0xFF4A6B4D`, `signalTint = 0x1A4A6B4D` (same `0x1A` alpha, new moss RGB). Add `brass = Color(0xFFA6823E)` and `oxide = Color(0xFFA23B2E)` near `signal`.

- [ ] **Step 4: Update `app_theme.dart`**

Change `textTheme: GoogleFonts.instrumentSansTextTheme()` to `GoogleFonts.instrumentSansTextTheme().copyWith(displayLarge: ..., displayMedium: ..., displaySmall: ...)`, adding three new `GoogleFonts.fraunces(color: AppColors.foreground, fontWeight: FontWeight.w400, letterSpacing: ...)` entries with `letterSpacing: -1.5`, `-1.0`, `-0.5` respectively (matching `curato-vendor`'s pattern, since this app has no prior display override to preserve). Change `colorScheme: ColorScheme.light(..., error: const Color(0xFFDC2626), ...)`'s `error` argument to `AppColors.oxide`.

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/design_tokens_test.dart`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add curato-admin/lib/core/constants/app_colors.dart curato-admin/lib/core/theme/app_theme.dart curato-admin/test/design_tokens_test.dart
git commit -m "feat(admin): adopt modern-luxury-showroom tokens and Fraunces display type"
```

---

### Task 5: `curato-reseller` CSS tokens and display typography

**Files:**
- Modify: `curato-reseller/src/index.css`

**Interfaces:**
- Consumes: HSL values from Global Constraints.
- Produces: `--color-brass` / `--brass-border` Tailwind theme entries other components can reference as `bg-brass`, `text-brass`, `border-brass-border`.

- [ ] **Step 1: Update the Google Fonts `@import` (line 1)**

Add Fraunces to the existing `@import url('https://fonts.googleapis.com/css2?family=...')` line so it reads:
`@import url('https://fonts.googleapis.com/css2?family=Fraunces:wght@400;500;600&family=Instrument+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap');`

- [ ] **Step 2: Update the `:root` HSL values**

Replace these existing values with the new ones (same variable names, new values only):
- `--background`, `--card`, `--sidebar-primary-foreground`, `--primary-foreground`, `--secondary`: `37.5 33.3% 95.3%` (paper)
- `--foreground`, `--card-foreground`, `--sidebar-foreground`, `--sidebar-primary`, `--sidebar-ring`, `--popover-foreground`, `--primary`, `--secondary-foreground`, `--accent-foreground`, `--ring`, `--chart-1`: `34.3 18.9% 7.3%` (ink)
- `--border`, `--input`, `--card-border`, `--sidebar-border`, `--popover-border`: `38.2 22.9% 81.2%` (hairline)
- `--muted`, `--accent`, `--sidebar-accent`: `36.9 25.5% 90.0%` (stone)
- `--muted-foreground`, `--chart-3`: `33.0 10.3% 38.0%` (muted text)
- `--signal`, `--chart-2`: `125.5 18.2% 35.5%` (moss)
- `--destructive`: `6.7 55.8% 40.8%` (oxide — replaces the old bright `0 84% 60%`)
- `--sidebar`, `--popover`: `37.5 33.3% 95.3%` (paper)

Do **not** change `--destructive-foreground` (`210 40% 98%`), `--chart-4` (`280 65% 60%`), or `--chart-5` (`340 75% 55%`) — they stay exactly as they are.

Add one new variable in the same block: `--brass: 39.2 45.6% 44.7%;`

- [ ] **Step 3: Change `--app-font-serif`**

Change `--app-font-serif: Georgia, serif;` to `--app-font-serif: 'Fraunces', Georgia, serif;`.

- [ ] **Step 4: Wire `--brass` into the `@theme inline` block**

Add, alongside the existing `--color-primary`/`--color-primary-border` pair:
```css
--color-brass: hsl(var(--brass));
--color-brass-border: var(--brass-border);
```
And alongside the existing `*-border` derivations at the bottom of `:root`, add:
```css
--brass-border: hsl(from hsl(var(--brass)) h s calc(l + var(--opaque-button-border-intensity)) / alpha);
```

- [ ] **Step 5: Apply Fraunces to headings site-wide**

In the `@layer base { h1, h2 { letter-spacing: -0.02em; } }` rule, add `@apply font-serif;` so headings pick up Fraunces via the now-updated `--app-font-serif` token without any page-level changes.

- [ ] **Step 6: Verify**

Run: `grep -c "39.2 45.6% 44.7%" curato-reseller/src/index.css` — expect `1` (the new `--brass` line).
Run: `grep -c "6.7 55.8% 40.8%" curato-reseller/src/index.css` — expect `1` (the updated `--destructive` line).
Run: `grep -c "210 40% 98%\|280 65% 60%\|340 75% 55%" curato-reseller/src/index.css` — expect `3` (confirms the three tokens that must stay untouched are still present verbatim).
Run: `npm run typecheck` (from `curato-reseller/`) — expect it to exit `0` (confirms the CSS change didn't break the Vite/TS build pipeline this app relies on).

- [ ] **Step 7: Commit**

```bash
git add curato-reseller/src/index.css
git commit -m "feat(reseller): adopt modern-luxury-showroom tokens and Fraunces display type"
```

---

### Task 6: `user-reseller` CSS tokens and display typography

**Files:**
- Modify: `user-reseller/src/index.css`
- Modify: `user-reseller/index.html`

**Interfaces:**
- Consumes: hex values from Global Constraints.
- Produces: `--brass` CSS variable other components can reference.

- [ ] **Step 1: Update `user-reseller/index.html`'s font `<link>`**

Add Fraunces to the existing Google Fonts `<link>` tag (line 11) so its `href` reads:
`https://fonts.googleapis.com/css2?family=Fraunces:wght@400;500;600&family=Instrument+Sans:wght@400..700&family=JetBrains+Mono:wght@400;500&display=swap`

- [ ] **Step 2: Update `user-reseller/src/index.css` hex values**

Replace these literal values (same variable names, new values only): `--bg: #f7f4ef;`, `--text: #16130f;`, `--text-h: #16130f;`, `--text-p: #6b6257;`, `--muted: #ece7df;`, `--border: #dad2c4;`, `--code-bg: #ece7df;`, `--card-bg: #f7f4ef;`, `--accent: #16130f;`, `--accent-fg: #f7f4ef;`, `--accent-gold: #16130f;` (stays the ink alias, now the new ink value), `--accent-secondary: #a23b2e;`, `--accent-bg: #ece7df;`, `--accent-border: #dad2c4;`, `--social-bg: #ece7df;`, `--signal: #4a6b4d;`, `--danger: #a23b2e;`, `--ring: rgba(22, 19, 15, 0.12);`.

Leave `--warning: #b7791f;` untouched — not part of this token system.

Add one new line in the same `:root` block: `--brass: #a6823e;`.

- [ ] **Step 3: Update the heading font stack**

Change `--heading: 'Instrument Sans', system-ui, -apple-system, 'Segoe UI', sans-serif;` to `--heading: 'Fraunces', Georgia, system-ui, serif;`. Leave `--sans` unchanged.

- [ ] **Step 4: Verify**

Run: `grep -c "#a6823e" user-reseller/src/index.css` — expect `1`.
Run: `grep -c "accent-gold: #16130f" user-reseller/src/index.css` — expect `1` (confirms the hardcoded `--accent-gold` literal was updated alongside `--text`, not left pointing at the old ink value).
Run: `grep -c "#b7791f" user-reseller/src/index.css` — expect `1` (confirms `--warning` is untouched).
Run: `npm run build` (from `user-reseller/`) — expect it to exit `0` (confirms the CSS/HTML edits didn't break the `tsc -b && vite build` pipeline).

- [ ] **Step 5: Commit**

```bash
git add user-reseller/src/index.css user-reseller/index.html
git commit -m "feat(user-reseller): adopt modern-luxury-showroom tokens and Fraunces display type"
```

---

### Task 7: Remove scaffold and template artifacts

**Files:**
- Delete: `curato-ecom/lib/core/constants/app_colors copy.dart`
- Delete: `curato-ecom/lib/features/home/presentation/pages/shop_page copy.dart`
- Delete: `curato-ecom/lib/features/home/presentation/pages/product_detail_page copy.dart`
- Delete: `curato-ecom/lib/features/home/presentation/pages/product_detail_page copy 2.dart`
- Delete: `curato-ecom/lib/features/home/presentation/pages/product_detail_page copy 3.dart`
- Delete: `curato-ecom/lib/features/home/presentation/widgets/curato_navbar copy.dart`
- Delete: `curato-ecom/lib/features/home/presentation/widgets/trending_items_section copy.dart`
- Delete: `curato-ecom/lib/features/home/presentation/widgets/daily_deals_section copy.dart`
- Delete: `user-reseller/src/assets/react.svg`
- Delete: `user-reseller/src/assets/vite.svg`
- Modify: `curato-ecom/README.md`
- Modify: `curato-ecom/web/index.html`

**Interfaces:** None — this task only removes dead files and dead content; it changes no code other tasks depend on.

- [ ] **Step 1: Confirm the eight `*copy*.dart` files are unreferenced**

Run: `grep -rn "copy.dart" curato-ecom/lib`
Expected: no output (no Dart file imports any of these by name).

- [ ] **Step 2: Delete the eight duplicate files**

```bash
git rm "curato-ecom/lib/core/constants/app_colors copy.dart" \
       "curato-ecom/lib/features/home/presentation/pages/shop_page copy.dart" \
       "curato-ecom/lib/features/home/presentation/pages/product_detail_page copy.dart" \
       "curato-ecom/lib/features/home/presentation/pages/product_detail_page copy 2.dart" \
       "curato-ecom/lib/features/home/presentation/pages/product_detail_page copy 3.dart" \
       "curato-ecom/lib/features/home/presentation/widgets/curato_navbar copy.dart" \
       "curato-ecom/lib/features/home/presentation/widgets/trending_items_section copy.dart" \
       "curato-ecom/lib/features/home/presentation/widgets/daily_deals_section copy.dart"
```

- [ ] **Step 3: Confirm `react.svg`/`vite.svg` are unreferenced, then delete them**

Run: `grep -rn "react.svg\|vite.svg" user-reseller/src user-reseller/index.html`
Expected: no output.

```bash
git rm user-reseller/src/assets/react.svg user-reseller/src/assets/vite.svg
```

- [ ] **Step 4: Replace `curato-ecom/README.md`'s boilerplate content**

Replace the entire file (currently the default Flutter template text) with:

```markdown
# Curato (customer storefront)

Flutter app for the Curato customer-facing storefront. Part of the Curato
platform — see the repository root [README](../README.md) for the full
system overview (backend, admin, vendor, reseller apps).
```

- [ ] **Step 5: Remove the stale previous-brand social links from `curato-ecom/web/index.html`**

In the JSON-LD `<script type="application/ld+json">` block, change:
```json
"sameAs": [
  "https://www.facebook.com/ojasindiasilver",
  "https://www.instagram.com/ojasindiab2b/",
  "https://www.youtube.com/@ojasindia6422"
],
```
to:
```json
"sameAs": [],
```

- [ ] **Step 6: Verify**

Run: `python3 -c "import json,re,pathlib; t=pathlib.Path('curato-ecom/web/index.html').read_text(); m=re.search(r'<script type=\"application/ld\\+json\">(.*?)</script>', t, re.S); json.loads(m.group(1)); print('valid JSON, sameAs =', json.loads(m.group(1))['sameAs'])"`
Expected: `valid JSON, sameAs = []`

Run: `find curato-ecom -iname "*copy*" ; find user-reseller/src/assets -iname "react.svg" -o -iname "vite.svg"`
Expected: no output (all ten files gone).

- [ ] **Step 7: Commit**

```bash
git add -A curato-ecom user-reseller
git commit -m "chore: remove scaffold artifacts (duplicate files, boilerplate README, stale social links, unused assets)"
```
