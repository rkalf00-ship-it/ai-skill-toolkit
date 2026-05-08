# Pre-Delivery Checklist

> Reference for the [ui-ux-pro-max](../SKILL.md) skill.
> Verify before delivering UI code. Scope: App UI (iOS / Android / React Native / Flutter).

## Visual Quality

- [ ] No emojis used as icons (use SVG instead)
- [ ] All icons come from a consistent icon family and style
- [ ] Official brand assets are used with correct proportions and clear space
- [ ] Pressed-state visuals do not shift layout bounds or cause jitter
- [ ] Semantic theme tokens are used consistently (no per-screen hardcoded hex)

## Interaction

- [ ] All tappable elements provide clear pressed feedback (ripple / opacity / elevation)
- [ ] Touch targets meet minimum size (≥44×44pt iOS, ≥48×48dp Android)
- [ ] Micro-interaction timing stays in 150–300ms with native-feeling easing
- [ ] Disabled states are visually clear and non-interactive
- [ ] Screen reader focus order matches visual order; interactive labels are descriptive
- [ ] Gesture regions avoid nested / conflicting interactions (tap / drag / back-swipe conflicts)

## Light / Dark Mode

- [ ] Primary text contrast ≥4.5:1 in both light and dark mode
- [ ] Secondary text contrast ≥3:1 in both modes
- [ ] Dividers / borders and interaction states distinguishable in both modes
- [ ] Modal / drawer scrim opacity preserves foreground legibility (typically 40–60% black)
- [ ] Both themes tested before delivery (not inferred from a single theme)

## Layout

- [ ] Safe areas respected for headers, tab bars, bottom CTA bars
- [ ] Scroll content not hidden behind fixed / sticky bars
- [ ] Verified on small phone, large phone, tablet (portrait + landscape)
- [ ] Horizontal insets / gutters adapt by device size and orientation
- [ ] 4 / 8dp spacing rhythm maintained across component / section / page levels
- [ ] Long-form text measure readable on larger devices

## Accessibility

- [ ] All meaningful images / icons have accessibility labels
- [ ] Form fields have labels, hints, clear error messages
- [ ] Color is not the only indicator
- [ ] Reduced motion and dynamic text size supported without layout breakage
- [ ] Accessibility traits / roles / states (selected, disabled, expanded) announced correctly
