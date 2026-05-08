# Rule Categories — Full Reference

> Reference for the [ui-ux-pro-max](../SKILL.md) skill.
> Compact, queryable rule database. Use this when scripts are unavailable
> or when you need exhaustive coverage of a category.

## 1. Accessibility (CRITICAL)

- `color-contrast` — Minimum 4.5:1 for normal text (large text 3:1); Material Design
- `focus-states` — Visible focus rings on interactive elements (2-4px; Apple HIG, MD)
- `alt-text` — Descriptive alt text for meaningful images
- `aria-labels` — `aria-label` for icon-only buttons; `accessibilityLabel` in native (Apple HIG)
- `keyboard-nav` — Tab order matches visual order; full keyboard support (Apple HIG)
- `form-labels` — Use `<label>` with `for` attribute
- `skip-links` — Skip-to-main-content for keyboard users
- `heading-hierarchy` — Sequential h1→h6, no level skip
- `color-not-only` — Don't convey info by color alone (add icon / text)
- `dynamic-type` — Support system text scaling; avoid truncation as text grows (Apple Dynamic Type, MD)
- `reduced-motion` — Respect `prefers-reduced-motion`; reduce / disable animations when requested (Apple, MD)
- `voiceover-sr` — Meaningful `accessibilityLabel` / `accessibilityHint`; logical reading order (Apple HIG, MD)
- `escape-routes` — Cancel / back in modals and multi-step flows (Apple HIG)
- `keyboard-shortcuts` — Preserve system / a11y shortcuts; offer keyboard alternatives for drag-and-drop (Apple HIG)

## 2. Touch & Interaction (CRITICAL)

- `touch-target-size` — Min 44×44pt (Apple) / 48×48dp (Material); extend hit area beyond visual bounds if needed
- `touch-spacing` — Minimum 8px / 8dp gap between touch targets (Apple HIG, MD)
- `hover-vs-tap` — Use click / tap for primary interactions; don't rely on hover alone
- `loading-buttons` — Disable button during async operations; show spinner or progress
- `error-feedback` — Clear error messages near problem
- `cursor-pointer` — Add `cursor: pointer` to clickable elements (Web)
- `gesture-conflicts` — Avoid horizontal swipe on main content; prefer vertical scroll
- `tap-delay` — Use `touch-action: manipulation` to reduce 300ms delay (Web)
- `standard-gestures` — Use platform standard gestures consistently; don't redefine (swipe-back, pinch-zoom) (Apple HIG)
- `system-gestures` — Don't block system gestures (Control Center, back swipe, etc.) (Apple HIG)
- `press-feedback` — Visual feedback on press (ripple / highlight; MD state layers)
- `haptic-feedback` — Use haptic for confirmations and important actions; avoid overuse (Apple HIG)
- `gesture-alternative` — Don't rely on gesture-only interactions; provide visible controls for critical actions
- `safe-area-awareness` — Keep primary touch targets away from notch, Dynamic Island, gesture bar, screen edges
- `no-precision-required` — Avoid requiring pixel-perfect taps on small icons or thin edges
- `swipe-clarity` — Swipe actions must show clear affordance or hint (chevron, label, tutorial)
- `drag-threshold` — Use a movement threshold before starting drag to avoid accidental drags

## 3. Performance (HIGH)

- `image-optimization` — Use WebP / AVIF, responsive images (srcset / sizes), lazy load non-critical assets
- `image-dimension` — Declare width / height or use `aspect-ratio` to prevent layout shift (CWV: CLS)
- `font-loading` — Use `font-display: swap/optional` to avoid FOIT; reserve space to reduce shift (MD)
- `font-preload` — Preload only critical fonts; avoid overusing preload on every variant
- `critical-css` — Prioritize above-the-fold CSS (inline critical CSS or early-loaded stylesheet)
- `lazy-loading` — Lazy load non-hero components via dynamic import / route-level splitting
- `bundle-splitting` — Split code by route / feature (React Suspense / Next.js dynamic) to reduce initial load
- `third-party-scripts` — Load third-party scripts async / defer; audit and remove unnecessary ones (MD)
- `reduce-reflows` — Avoid frequent layout reads / writes; batch DOM reads then writes
- `content-jumping` — Reserve space for async content to avoid layout jumps (CWV: CLS)
- `lazy-load-below-fold` — Use `loading="lazy"` for below-the-fold images and heavy media
- `virtualize-lists` — Virtualize lists with 50+ items for memory and scroll performance
- `main-thread-budget` — Keep per-frame work under ~16ms for 60fps; move heavy tasks off main thread (HIG, MD)
- `progressive-loading` — Use skeleton / shimmer instead of long blocking spinners for >1s operations (Apple HIG)
- `input-latency` — Keep input latency under ~100ms for taps / scrolls (Material responsiveness standard)
- `tap-feedback-speed` — Provide visual feedback within 100ms of tap (Apple HIG)
- `debounce-throttle` — Use debounce / throttle for high-frequency events (scroll, resize, input)
- `offline-support` — Provide offline state messaging and basic fallback (PWA / mobile)
- `network-fallback` — Offer degraded modes for slow networks (lower-res images, fewer animations)

## 4. Style Selection (HIGH)

- `style-match` — Match style to product type (use `--design-system` for recommendations)
- `consistency` — Use same style across all pages
- `no-emoji-icons` — Use SVG icons (Heroicons, Lucide), not emojis
- `color-palette-from-product` — Choose palette from product / industry (search `--domain color`)
- `effects-match-style` — Shadows, blur, radius aligned with chosen style (glass / flat / clay etc.)
- `platform-adaptive` — Respect platform idioms (iOS HIG vs Material)
- `state-clarity` — Make hover / pressed / disabled states visually distinct while staying on-style (MD state layers)
- `elevation-consistent` — Consistent elevation / shadow scale; avoid random shadow values
- `dark-mode-pairing` — Design light / dark variants together to keep brand, contrast, style consistent
- `icon-style-consistent` — One icon set / visual language (stroke width, corner radius)
- `system-controls` — Prefer native / system controls over fully custom ones (Apple HIG)
- `blur-purpose` — Use blur to indicate background dismissal (modals, sheets), not as decoration (Apple HIG)
- `primary-action` — Each screen has only one primary CTA; secondary actions visually subordinate (Apple HIG)

## 5. Layout & Responsive (HIGH)

- `viewport-meta` — `width=device-width initial-scale=1` (never disable zoom)
- `mobile-first` — Design mobile-first, then scale up
- `breakpoint-consistency` — Use systematic breakpoints (e.g. 375 / 768 / 1024 / 1440)
- `readable-font-size` — Min 16px body text on mobile (avoids iOS auto-zoom)
- `line-length-control` — Mobile 35–60 chars per line; desktop 60–75 chars
- `horizontal-scroll` — No horizontal scroll on mobile; ensure content fits viewport
- `spacing-scale` — Use 4pt / 8dp incremental spacing system (Material Design)
- `touch-density` — Comfortable spacing for touch: not cramped, not causing mis-taps
- `container-width` — Consistent max-width on desktop (`max-w-6xl` / `7xl`)
- `z-index-management` — Define layered z-index scale (e.g. 0 / 10 / 20 / 40 / 100 / 1000)
- `fixed-element-offset` — Fixed navbar / bottom bar must reserve safe padding
- `scroll-behavior` — Avoid nested scroll regions that interfere with main scroll
- `viewport-units` — Prefer `min-h-dvh` over `100vh` on mobile
- `orientation-support` — Layout readable and operable in landscape
- `content-priority` — Show core content first on mobile; fold or hide secondary
- `visual-hierarchy` — Establish hierarchy via size, spacing, contrast — not color alone

## 6. Typography & Color (MEDIUM)

- `line-height` — 1.5–1.75 for body text
- `line-length` — Limit to 65–75 characters per line
- `font-pairing` — Match heading / body font personalities
- `font-scale` — Consistent type scale (e.g. 12 14 16 18 24 32)
- `contrast-readability` — Darker text on light backgrounds (e.g. slate-900 on white)
- `text-styles-system` — Use platform type system: iOS Dynamic Type / Material type roles (HIG, MD)
- `weight-hierarchy` — Bold headings (600–700), Regular body (400), Medium labels (500) (MD)
- `color-semantic` — Define semantic color tokens (primary, secondary, error, surface, on-surface) — not raw hex (Material color system)
- `color-dark-mode` — Dark mode uses desaturated / lighter tonal variants, not inverted; test contrast separately (HIG, MD)
- `color-accessible-pairs` — Foreground / background pairs meet 4.5:1 (AA) or 7:1 (AAA) (WCAG, MD)
- `color-not-decorative-only` — Functional color (error red, success green) must include icon / text (HIG, MD)
- `truncation-strategy` — Prefer wrapping over truncation; if truncating use ellipsis + tooltip / expand (Apple HIG)
- `letter-spacing` — Respect default letter-spacing per platform; avoid tight tracking on body text (HIG, MD)
- `number-tabular` — Use tabular / monospaced figures for data columns, prices, timers
- `whitespace-balance` — Use whitespace intentionally to group related items, separate sections (Apple HIG)

## 7. Animation (MEDIUM)

- `duration-timing` — 150–300ms for micro-interactions; complex transitions ≤400ms; avoid >500ms (MD)
- `transform-performance` — Use `transform` / `opacity` only; avoid animating `width` / `height` / `top` / `left`
- `loading-states` — Skeleton or progress indicator when loading exceeds 300ms
- `excessive-motion` — Animate 1–2 key elements per view max
- `easing` — `ease-out` for entering, `ease-in` for exiting; avoid linear for UI transitions
- `motion-meaning` — Every animation expresses a cause-effect relationship, not decoration (Apple HIG)
- `state-transition` — State changes (hover / active / expanded / collapsed / modal) animate smoothly, don't snap
- `continuity` — Page / screen transitions maintain spatial continuity (shared element, directional slide) (Apple HIG)
- `parallax-subtle` — Use parallax sparingly; respect reduced-motion; no disorientation (Apple HIG)
- `spring-physics` — Prefer spring / physics curves over linear or cubic-bezier for natural feel (Apple HIG)
- `exit-faster-than-enter` — Exit animations 60–70% of enter duration to feel responsive (MD motion)
- `stagger-sequence` — Stagger list / grid item entrance by 30–50ms per item (MD)
- `shared-element-transition` — Shared element / hero transitions for visual continuity between screens (MD, HIG)
- `interruptible` — Animations interruptible; user tap / gesture cancels in-progress (Apple HIG)
- `no-blocking-animation` — Never block user input during animation; UI stays interactive (Apple HIG)
- `fade-crossfade` — Crossfade for content replacement within the same container (MD)
- `scale-feedback` — Subtle scale (0.95–1.05) on press for tappable cards / buttons (HIG, MD)
- `gesture-feedback` — Drag, swipe, pinch must provide real-time visual response tracking the finger (MD)
- `hierarchy-motion` — Translate / scale direction expresses hierarchy: enter from below = deeper, exit upward = back (MD)
- `motion-consistency` — Unify duration / easing tokens globally
- `opacity-threshold` — Fading elements should not linger below opacity 0.2
- `modal-motion` — Modals / sheets animate from their trigger source (HIG, MD)
- `navigation-direction` — Forward = left / up; backward = right / down (HIG)
- `layout-shift-avoid` — Animations must not cause layout reflow / CLS; use `transform` for position changes

## 8. Forms & Feedback (MEDIUM)

- `input-labels` — Visible label per input (not placeholder-only)
- `error-placement` — Show error below the related field
- `submit-feedback` — Loading then success / error state on submit
- `required-indicators` — Mark required fields (e.g. asterisk)
- `empty-states` — Helpful message and action when no content
- `toast-dismiss` — Auto-dismiss toasts in 3–5s
- `confirmation-dialogs` — Confirm before destructive actions
- `input-helper-text` — Persistent helper text below complex inputs (Material Design)
- `disabled-states` — Reduced opacity (0.38–0.5) + cursor change + semantic attribute (MD)
- `progressive-disclosure` — Reveal complex options progressively (Apple HIG)
- `inline-validation` — Validate on blur (not keystroke); show error after user finishes input (MD)
- `input-type-keyboard` — Use semantic input types (email, tel, number) for correct mobile keyboard (HIG, MD)
- `password-toggle` — Show / hide toggle for password fields (MD)
- `autofill-support` — Use autocomplete / textContentType for system autofill (HIG, MD)
- `undo-support` — Allow undo for destructive or bulk actions (Apple HIG)
- `success-feedback` — Confirm completed actions with brief visual feedback (MD)
- `error-recovery` — Error messages include a clear recovery path (HIG, MD)
- `multi-step-progress` — Multi-step flows show step indicator; allow back navigation (MD)
- `form-autosave` — Long forms auto-save drafts to prevent data loss (Apple HIG)
- `sheet-dismiss-confirm` — Confirm before dismissing a sheet / modal with unsaved changes (Apple HIG)
- `error-clarity` — Error messages state cause + how to fix (HIG, MD)
- `field-grouping` — Group related fields logically (fieldset / legend or visual grouping) (MD)
- `read-only-distinction` — Read-only state visually and semantically different from disabled (MD)
- `focus-management` — After submit error, auto-focus the first invalid field (WCAG, MD)
- `error-summary` — For multiple errors, show summary at top with anchor links (WCAG)
- `touch-friendly-input` — Mobile input height ≥44px (Apple HIG)
- `destructive-emphasis` — Destructive actions use semantic danger color (red), separated from primary (HIG, MD)
- `toast-accessibility` — Toasts must not steal focus; use `aria-live="polite"` (WCAG)
- `aria-live-errors` — Form errors use `aria-live` region or `role="alert"` (WCAG)
- `contrast-feedback` — Error / success state colors meet 4.5:1 contrast (WCAG, MD)
- `timeout-feedback` — Request timeout shows clear feedback with retry option (MD)

## 9. Navigation Patterns (HIGH)

- `bottom-nav-limit` — Bottom navigation max 5 items; use labels with icons (Material Design)
- `drawer-usage` — Drawer / sidebar for secondary navigation, not primary actions (MD)
- `back-behavior` — Back navigation must be predictable, preserve scroll / state (Apple HIG, MD)
- `deep-linking` — All key screens reachable via deep link / URL (Apple HIG, MD)
- `tab-bar-ios` — iOS: bottom Tab Bar for top-level navigation (Apple HIG)
- `top-app-bar-android` — Android: Top App Bar with navigation icon for primary structure (MD)
- `nav-label-icon` — Both icon and text label; icon-only nav harms discoverability (MD)
- `nav-state-active` — Current location visually highlighted (color, weight, indicator) (HIG, MD)
- `nav-hierarchy` — Primary nav (tabs / bottom bar) vs secondary nav (drawer / settings) clearly separated (MD)
- `modal-escape` — Modals / sheets offer clear close / dismiss; swipe-down to dismiss on mobile (Apple HIG)
- `search-accessible` — Search easily reachable (top bar or tab); recent / suggested queries (MD)
- `breadcrumb-web` — Web: breadcrumbs for 3+ level deep hierarchies (MD)
- `state-preservation` — Navigating back restores scroll, filter state, input (HIG, MD)
- `gesture-nav-support` — Support system gesture navigation without conflict (HIG, MD)
- `tab-badge` — Badges sparingly to indicate unread / pending; clear after visit (HIG, MD)
- `overflow-menu` — When actions exceed space, use overflow menu instead of cramming (MD)
- `bottom-nav-top-level` — Bottom nav for top-level screens only; never nest sub-navigation (MD)
- `adaptive-navigation` — Large screens (≥1024px) prefer sidebar; small screens use bottom / top nav (Material Adaptive)
- `back-stack-integrity` — Never silently reset the navigation stack (HIG, MD)
- `navigation-consistency` — Navigation placement stays the same across all pages
- `avoid-mixed-patterns` — Don't mix Tab + Sidebar + Bottom Nav at the same hierarchy
- `modal-vs-navigation` — Modals must not be used for primary navigation flows (HIG)
- `focus-on-route-change` — After page transition, move focus to main content for screen readers (WCAG)
- `persistent-nav` — Core navigation reachable from deep pages (HIG, MD)
- `destructive-nav-separation` — Dangerous actions visually / spatially separated from normal nav items (HIG, MD)
- `empty-nav-state` — When a nav destination is unavailable, explain why (MD)

## 10. Charts & Data (LOW)

- `chart-type` — Match chart type to data type (trend → line, comparison → bar, proportion → pie / donut)
- `color-guidance` — Accessible color palettes; avoid red / green only pairs for colorblind users (WCAG, MD)
- `data-table` — Provide table alternative for accessibility (WCAG)
- `pattern-texture` — Supplement color with patterns, textures, shapes so data is distinguishable without color (WCAG, MD)
- `legend-visible` — Always show legend; position near the chart (MD)
- `tooltip-on-interact` — Provide tooltips / data labels on hover (Web) or tap (mobile) (HIG, MD)
- `axis-labels` — Label axes with units and readable scale; avoid truncated / rotated labels on mobile
- `responsive-chart` — Reflow or simplify on small screens
- `empty-data-state` — Meaningful empty state when no data exists ("No data yet" + guidance) (MD)
- `loading-chart` — Skeleton / shimmer placeholder while chart data loads
- `animation-optional` — Chart entrance animations respect `prefers-reduced-motion` (HIG)
- `large-dataset` — For 1000+ data points, aggregate or sample; provide drill-down (MD)
- `number-formatting` — Locale-aware formatting for numbers, dates, currencies (HIG, MD)
- `touch-target-chart` — Interactive chart elements ≥44pt tap area (Apple HIG)
- `no-pie-overuse` — Avoid pie / donut for >5 categories; switch to bar chart
- `contrast-data` — Data lines / bars vs background ≥3:1; data text labels ≥4.5:1 (WCAG)
- `legend-interactive` — Legends clickable to toggle series visibility (MD)
- `direct-labeling` — For small datasets, label values directly on the chart
- `tooltip-keyboard` — Tooltip content keyboard-reachable, not hover-only (WCAG)
- `sortable-table` — Data tables support sorting with `aria-sort` indicator (WCAG)
- `axis-readability` — Axis ticks not cramped; auto-skip on small screens
- `data-density` — Limit information density per chart; split into multiple charts if needed
- `trend-emphasis` — Emphasize data trends over decoration; avoid heavy gradients / shadows
- `gridline-subtle` — Grid lines low-contrast (e.g. gray-200) so they don't compete with data
- `focusable-elements` — Interactive chart elements keyboard-navigable (WCAG)
- `screen-reader-summary` — Provide text summary or `aria-label` describing the chart's key insight (WCAG)
- `error-state-chart` — Data load failure shows error message with retry, not broken / empty chart
- `export-option` — For data-heavy products, offer CSV / image export
- `drill-down-consistency` — Drill-down maintains a clear back-path and hierarchy breadcrumb
- `time-scale-clarity` — Time series charts label time granularity (day / week / month) and allow switching
