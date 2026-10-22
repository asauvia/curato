# Curato Design System Foundation — Design Spec

Status: Approved for implementation planning
Author: Claude Code (with Utkarsh Verma)
Date: 2026-10-22

## Context

Curato is a six-codebase furniture/home-décor marketplace (ASAUViA): three Flutter apps (`curato-ecom` customer storefront, `curato-admin`, `curato-vendor`), two React/Vite apps (`curato-reseller`, `user-reseller`), and a Node/Express/MongoDB backend. All five frontend apps already share one deliberate "warm paper / ink" editorial theme (`#FAFAF9` background, `#0C0806` ink, Instrument Sans, hairline borders, no drop shadows), defined independently in each app's own theme files (`app_colors.dart`/`app_theme.dart` for Flutter, `index.css` `@theme` block for React).

Despite being custom, the overall product reads as templated: leftover scaffold artifacts (`app_colors copy.dart`, `shop_page copy.dart`, duplicate `product_detail_page copy 2/3.dart`), a default Flutter boilerplate `README.md` in `curato-ecom`, unremoved Vite starter assets (`react.svg`, `vite.svg`) in `user-reseller`, and a `curato-reseller` structure that visibly follows the generic shadcn/Replit-scaffold shape (wouter + TanStack Query + `components.json`) rather than a considered one. There is also no single source of truth for the shared tokens — each app's theme file was hand-written independently and can drift.

This spec defines a refreshed design system — "modern luxury showroom" — as the shared foundation that every app will be redesigned against, one app at a time, in later work.

## Goals

- Define one canonical, versioned token set (color, type, spacing, motion, component rules) that both the Flutter and React apps implement.
- Push the existing warm-neutral identity toward a "modern luxury showroom" feel: dramatic, materially-grounded (wood/brass/stone), confident negative space — without discarding the brand equity already built into the current palette and Instrument Sans usage.
- Remove template/scaffold tells that undercut the "original, non-templated" goal (duplicate files, boilerplate README, unused starter assets) as part of adopting the new tokens.
- Produce a design reference that subsequent per-app specs (`curato-ecom`, `user-reseller`, `curato-reseller`, `curato-vendor`, `curato-admin`, in that order) can implement against without re-deriving the system each time.

## Non-goals

- This spec does not redesign any individual app's pages, navigation, or information architecture — that happens in each app's own follow-up spec.
- No new product features, backend changes, or copy/content rewrites beyond what's needed to demonstrate the tokens (e.g., sample component states).
- No automated design-token build pipeline (e.g., Style Dictionary) connecting Flutter and React — the two ecosystems don't share a build step today, and introducing one is out of scope. Tokens are defined once in a canonical document and manually mirrored into each stack's native theme format, same as the current (per-app) setup.

## Design tokens

### Color

| Token | Hex | Role | Notes |
|---|---|---|---|
| `paper` | `#F7F4EF` | Primary background | Warmer/more linen than current `#FAFAF9` |
| `ink` | `#16130F` | Primary text; background for dramatic "gallery" sections | Warmer, deeper black than current `#0C0806` |
| `stone` | `#ECE7DF` | Muted panels, secondary surfaces | Replaces current `#F1F0ED` |
| `hairline` | `#DAD2C4` | Borders — the only separator device, no drop shadows | Replaces current `#DCDBD6` |
| `muted` | `#6B6257` | Secondary/supporting text | Replaces current `#5C534D` |
| `brass` | `#A6823E` | Signature accent: primary purchase CTAs, price emphasis, active/selected states | New. Used sparingly — reserved for moments that should feel premium, never as a default UI color. Deliberately a metallic brass, not the generic AI-cliché terracotta (`#D97757`-family). |
| `moss` | `#4A6B4D` | Success / in-stock / confirmation | Replaces current bright `#2C965D` with a deeper, more material tone |
| `oxide` | `#A23B2E` | Destructive / errors | Replaces current `#B42318` / `hsl(0 84% 60%)` with a deeper clay-oxide red, consistent with the material palette |

All tokens need light-mode values only for v1 (none of the five apps currently implement dark mode); the token document should still name them so dark-mode values can be added later without renaming.

### Typography

- **Display/headings**: Fraunces (Google Fonts, variable). Use `WONK=0` for a refined rather than quirky character, moderate optical size, weight 500–600 for most headings, 400 reserved for the largest hero moments. This is the primary new distinctive element — the thing to protect from dilution as per-app specs are implemented.
- **UI/body**: Instrument Sans (unchanged) — keeps continuity with the current system and stays legible in data-dense admin/vendor screens.
- **Data/mono**: JetBrains Mono (unchanged) — SKUs, prices in tables, order IDs.
- Type scale: follow Elements-of-Typographic-Style-style ratios (not a flat arbitrary scale); exact step values to be finalized per-app since Flutter (`TextTheme`) and web CSS (`clamp()`/rem) express scales differently, but the *ratio* and *pairing rule* (serif for display, sans for UI, mono for data) is fixed here.

### Spacing, layout, and motion

- Favor generous, asymmetric whitespace over symmetric card grids for merchandising/marketing surfaces (storefront home, product detail); data-dense internal tools (admin/vendor tables) keep denser, grid-aligned layouts — the "showroom" language applies to customer-facing and reseller-facing surfaces, not to operational data tables.
- Introduce full-bleed `ink`-background sections as a deliberate device to stage a single product or moment "under gallery light," contrasted against surrounding `paper` sections. Use sparingly — one or two per page, not as a default section background.
- Motion: one deliberate, orchestrated moment per key screen (e.g., a soft image reveal on product-detail load) rather than uniform fade-in-on-scroll treatments on every section or hover-lift on every card. Respect `prefers-reduced-motion` on web; Flutter apps should gate equivalent animations behind an accessibility-appropriate check.

### Components

- Buttons remain pill-shaped (`StadiumBorder`/`border-radius: 999px`) — continuity with the current system. Add a new **brass-outline** variant: brass border and text on `paper`, inverts to filled brass on hover/press. Reserved for the single primary purchase/conversion action per screen (Add to Cart, Checkout, Become a Vendor) — not a general-purpose secondary button style.
- Cards/panels keep hairline borders, no drop shadows (unchanged principle — already correct and distinctive, keep it).
- New **plinth card** pattern for product tiles: generous internal padding around product photography so the image reads as an object staged on a pedestal rather than cropped tight into a grid cell. Applies to storefront and reseller product grids; admin/vendor product-management tables are unaffected.

## Cross-stack propagation

Flutter and the two React apps have no shared build step, so this spec does not introduce one. Instead:

1. `docs/design-system/tokens.md` becomes the canonical, human-maintained source of truth for every token in this spec (the table above, transcribed there verbatim as the implementation starting point).
2. Flutter apps (`curato-ecom`, `curato-vendor`, `curato-admin`) implement the tokens in each app's own `lib/core/constants/app_colors.dart` and `lib/core/theme/app_theme.dart`, replacing current values 1:1.
3. React apps (`curato-reseller`, `user-reseller`) implement the tokens as CSS custom properties — `curato-reseller`'s existing `@theme` block in `src/index.css` gets updated in place; `user-reseller` (no Tailwind) gets equivalent CSS variables added to its global stylesheet.
4. Any future token change is made in `docs/design-system/tokens.md` first, then propagated manually to each app — same discipline as today, just with one documented source instead of five independently-drifting ones.

## Cleanup included in this pass

As part of adopting the new tokens (not a separate initiative):

- Delete duplicate/scratch files: `curato-ecom/lib/core/constants/app_colors copy.dart`, `shop_page copy.dart`, `product_detail_page copy.dart`/`copy 2.dart`/`copy 3.dart`, `help_page copy.dart` (confirm each is superseded by its non-`copy` counterpart before deleting).
- Replace `curato-ecom/README.md` boilerplate Flutter text with a real project README (or at minimum point to the root README).
- Remove unused Vite scaffold assets from `user-reseller/src/assets/` (`react.svg`, `vite.svg`) once confirmed unreferenced.
- Update `curato-ecom/web/index.html` social links referencing "the previous brand" (flagged in root README as a known gap) — defer the actual link destinations to the `curato-ecom` app-level spec if new links aren't yet known; at minimum remove dead/wrong ones here.

## Sequencing for follow-on work

This spec covers the foundation only. Each app below gets its own brainstorming pass (clarifying questions, short design or spec as appropriate to its size, approval) before implementation, in this order:

1. `curato-ecom` (customer storefront) — highest visibility, Flutter.
2. `user-reseller` (link-share storefront) — smallest React app, no component library to reconcile.
3. `curato-reseller` (reseller dashboard) — larger React app, shadcn/Radix component overrides.
4. `curato-vendor` — Flutter, operational/data-dense.
5. `curato-admin` — Flutter, operational/data-dense, implemented last since it's ASAUViA-internal-only.

## Testing / validation

- No automated visual regression tooling exists in this repo today; introducing one is out of scope for this spec.
- Validation is manual: for each app's implementation, take before/after screenshots of key screens and confirm against this spec's token table and principles before marking that app's redesign complete.
- Flutter: existing default counter widget tests are boilerplate and unrelated to this work; no test changes required by this spec.

## Open questions (non-blocking)

- Exact numeric type scale (step ratio, rem/sp values) will be finalized during the `curato-ecom` app-level spec, the first consumer of this system, rather than guessed here in the abstract.
- Dark mode is explicitly deferred; token names are chosen to accommodate it later without renames.
