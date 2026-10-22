# Curato Design Tokens

Canonical, human-maintained source of truth for the Curato "modern luxury showroom" design system. Source spec: `docs/superpowers/specs/2026-10-22-design-system-design.md`.

Every app implements these tokens manually in its own native theme format (Flutter: `lib/core/constants/app_colors.dart` and `lib/core/theme/app_theme.dart`; React: CSS custom properties). Any token change is made here first, then propagated to each app.

## Color

All tokens currently define light-mode values only. Dark-mode values will be added later under the same token names, without renaming.

| Token | Hex | HSL (Tailwind v4 / `curato-reseller`) | Role | Notes |
|---|---|---|---|---|
| `paper` | `#F7F4EF` | `37.5 33.3% 95.3%` | Primary background | Warmer/more linen than current `#FAFAF9` |
| `ink` | `#16130F` | `34.3 18.9% 7.3%` | Primary text; background for dramatic "gallery" sections | Warmer, deeper black than current `#0C0806` |
| `stone` | `#ECE7DF` | `36.9 25.5% 90.0%` | Muted panels, secondary surfaces | Replaces current `#F1F0ED` |
| `hairline` | `#DAD2C4` | `38.2 22.9% 81.2%` | Borders — the only separator device, no drop shadows | Replaces current `#DCDBD6` |
| `muted` | `#6B6257` | `33.0 10.3% 38.0%` | Secondary/supporting text | Replaces current `#5C534D` |
| `brass` | `#A6823E` | `39.2 45.6% 44.7%` | Signature accent: primary purchase CTAs, price emphasis, active/selected states | New. Used sparingly — reserved for moments that should feel premium, never as a default UI color. Deliberately a metallic brass, not the generic AI-cliché terracotta (`#D97757`-family). |
| `moss` | `#4A6B4D` | `125.5 18.2% 35.5%` | Success / in-stock / confirmation | Replaces current bright `#2C965D` with a deeper, more material tone |
| `oxide` | `#A23B2E` | `6.7 55.8% 40.8%` | Destructive / errors | Replaces current `#B42318` / `hsl(0 84% 60%)` with a deeper clay-oxide red, consistent with the material palette |

HSL values are the equivalents of the hex values above, used by `curato-reseller`'s Tailwind v4 `@theme` block, which stores colors as HSL triplets.

## Typography

- **Display/headings — Fraunces** (Google Fonts, variable). Use `WONK=0` for a refined rather than quirky character, moderate optical size, weight 500–600 for most headings, 400 reserved for the largest hero moments. This is the primary new distinctive element — the thing to protect from dilution as per-app specs are implemented.
- **UI/body — Instrument Sans** (unchanged). Keeps continuity with the current system and stays legible in data-dense admin/vendor screens.
- **Data/mono — JetBrains Mono** (unchanged). SKUs, prices in tables, order IDs.

**Type scale:** follow Elements-of-Typographic-Style-style ratios (not a flat arbitrary scale). Exact step values to be finalized per-app since Flutter (`TextTheme`) and web CSS (`clamp()`/rem) express scales differently. The ratio and the pairing rule (serif for display, sans for UI, mono for data) are fixed here.

## Spacing, layout, and motion

**Layout**

- Favor generous, asymmetric whitespace over symmetric card grids for merchandising/marketing surfaces (storefront home, product detail).
- Data-dense internal tools (admin/vendor tables) keep denser, grid-aligned layouts. The "showroom" language applies to customer-facing and reseller-facing surfaces, not to operational data tables.
- Full-bleed `ink`-background sections stage a single product or moment "under gallery light," contrasted against surrounding `paper` sections. Use sparingly: one or two per page, not as a default section background.

**Motion**

- One deliberate, orchestrated moment per key screen (e.g., a soft image reveal on product-detail load), rather than uniform fade-in-on-scroll treatments on every section or hover-lift on every card.
- Respect `prefers-reduced-motion` on web. Flutter apps gate equivalent animations behind an accessibility-appropriate check.

## Components (patterns for per-app specs to implement)

The patterns below are design rules for the per-app specs to implement. They are not built components in this repository yet.

- **Buttons** remain pill-shaped (`StadiumBorder` / `border-radius: 999px`), for continuity with the current system.
  - **Brass-outline variant (pattern):** brass border and text on `paper`; inverts to filled `brass` on hover/press. Reserved for the single primary purchase/conversion action per screen (Add to Cart, Checkout, Become a Vendor). Not a general-purpose secondary button style.
- **Cards/panels** keep hairline borders and no drop shadows. This principle is unchanged and already correct.
  - **Plinth card (pattern):** for product tiles. Generous internal padding around product photography, so the image reads as an object staged on a pedestal rather than cropped tight into a grid cell. Applies to storefront and reseller product grids. Admin/vendor product-management tables are unaffected.
