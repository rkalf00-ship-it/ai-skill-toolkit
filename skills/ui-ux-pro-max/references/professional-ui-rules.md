# Common Rules for Professional UI

> Reference for the [ui-ux-pro-max](../SKILL.md) skill.
> Frequently overlooked issues that make UI look unprofessional.
> Scope: App UI (iOS / Android / React Native / Flutter), not desktop-web interaction patterns.

## Icons & Visual Elements

| Rule | Standard | Avoid | Why It Matters |
|------|----------|--------|----------------|
| **No Emoji as Structural Icons** | Vector icons (Lucide, react-native-vector-icons, @expo/vector-icons) | Emojis (palette / rocket / gear) for navigation, settings, system controls | Emojis are font-dependent, inconsistent across platforms, can't be controlled via tokens |
| **Vector-Only Assets** | SVG / platform vector icons that scale and theme | Raster PNG icons that blur or pixelate | Crisp rendering and dark / light mode adaptability |
| **Stable Interaction States** | Color, opacity, elevation transitions for press states | Layout-shifting transforms that move surrounding content | Prevents jitter and preserves perceived quality on mobile |
| **Correct Brand Logos** | Official brand assets and usage guidelines | Guessing logo paths, recoloring unofficially, modifying proportions | Brand misuse and legal / platform compliance |
| **Consistent Icon Sizing** | Icon-size design tokens (icon-sm / icon-md = 24pt / icon-lg) | Mixing arbitrary 20pt / 24pt / 28pt randomly | Visual rhythm and hierarchy |
| **Stroke Consistency** | Consistent stroke width within the same visual layer (e.g. 1.5px or 2px) | Mixing thick and thin stroke styles arbitrarily | Cohesion |
| **Filled vs Outline Discipline** | One icon style per hierarchy level | Mixing filled and outline icons at the same hierarchy | Semantic clarity |
| **Touch Target Minimum** | Minimum 44×44pt interactive area (use `hitSlop` if icon is smaller) | Small icons without expanded tap area | Accessibility |
| **Icon Alignment** | Align icons to text baseline; consistent padding | Misaligned icons or inconsistent surrounding spacing | Subtle visual imbalance |
| **Icon Contrast** | WCAG: 4.5:1 for small elements, 3:1 minimum for larger UI glyphs | Low-contrast icons that blend into background | Accessibility in light / dark modes |

## Interaction (App)

| Rule | Do | Don't |
|------|----|----- |
| **Tap feedback** | Pressed feedback (ripple / opacity / elevation) within 80–150ms | No visual response on tap |
| **Animation timing** | 150–300ms with platform-native easing | Instant transitions or slow animations (>500ms) |
| **Accessibility focus** | Screen reader focus order matches visual; descriptive labels | Unlabeled controls or confusing focus traversal |
| **Disabled state clarity** | Disabled semantics + reduced emphasis + no tap action | Controls that look tappable but do nothing |
| **Touch target minimum** | ≥44×44pt (iOS) or ≥48×48dp (Android); expand hit area for small icons | Tiny tap targets |
| **Gesture conflict prevention** | One primary gesture per region; no nested tap / drag conflicts | Overlapping gestures causing accidental actions |
| **Semantic native controls** | Native interactive primitives (`Button`, `Pressable`, platform equivalents) with proper a11y roles | Generic containers as primary controls without semantics |

## Light / Dark Mode Contrast

| Rule | Do | Don't |
|------|----|----- |
| **Surface readability (light)** | Cards / surfaces clearly separated from background with opacity / elevation | Overly transparent surfaces that blur hierarchy |
| **Text contrast (light)** | Body text contrast ≥4.5:1 against light surfaces | Low-contrast gray body text |
| **Text contrast (dark)** | Primary text ≥4.5:1, secondary text ≥3:1 on dark surfaces | Dark mode text that blends into background |
| **Border and divider visibility** | Separators visible in both themes | Theme-specific borders disappearing in one mode |
| **State contrast parity** | Pressed / focused / disabled states equally distinguishable in both themes | Defining states for one theme only |
| **Token-driven theming** | Semantic color tokens mapped per theme | Hardcoded per-screen hex values |
| **Scrim and modal legibility** | Modal scrim strong enough (typically 40–60% black) | Weak scrim that leaves background competing |

## Layout & Spacing

| Rule | Do | Don't |
|------|----|----- |
| **Safe-area compliance** | Respect top / bottom safe areas for fixed headers, tab bars, CTA bars | Fixed UI under notch, status bar, gesture area |
| **System bar clearance** | Spacing for status / navigation bars and gesture home indicator | Tappable content colliding with OS chrome |
| **Consistent content width** | Predictable content width per device class | Mixing arbitrary widths between screens |
| **8dp spacing rhythm** | 4 / 8dp spacing system for padding, gaps, sections | Random spacing increments |
| **Readable text measure** | Long-form text readable on large devices | Edge-to-edge paragraphs on tablets |
| **Section spacing hierarchy** | Vertical rhythm tiers (e.g. 16 / 24 / 32 / 48) by hierarchy | Similar UI levels with inconsistent spacing |
| **Adaptive gutters by breakpoint** | Increase horizontal insets on larger widths and in landscape | Same narrow gutter on all device sizes |
| **Scroll and fixed element coexistence** | Bottom / top content insets so lists aren't hidden behind fixed bars | Scroll content obscured by sticky headers / footers |
