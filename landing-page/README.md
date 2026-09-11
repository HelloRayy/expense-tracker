# Jajan Tracker — Landing Page Architecture

Production-grade, Awwwards-styled landing page for **Jajan Tracker** (Android 0-friction expense tracker).

## 📁 Architecture & File Layout

```
landing-page/
├── index.html                  # Semantic, clean entry point (< 700 lines)
├── src/
│   ├── motion.ts               # Master motion orchestrator (Lenis + GSAP kinetic engine)
│   ├── showcase.ts             # Raycast Extension Highlight reel & category capsule controller
│   ├── hero.ts                 # Hero preview screen switcher
│   ├── components/
│   │   ├── keyboard-canvas.ts  # Mounts & activates tactile keyboard canvas
│   │   └── keyboard.html       # 1:1 authentic Raycast physical keyboard layout markup
│   ├── styles/
│   │   ├── motion-interactive.css # Awwwards smooth transitions, header blur, glare & FAQ accordion
│   │   ├── raycast-download.css   # "Get Your Time Back" download card container & typography
│   │   ├── raycast-showcase.css   # Extension Highlight reel, cards & active backdrop tokens
│   │   └── pen-dev-utilities.css  # Atomic positional & layout utilities
│   └── vite-env.d.ts           # Vite client & raw asset types
├── public/
│   └── static/                 # Static brand assets, fonts, icons, and base stylesheets
├── scripts/
│   ├── analyze-diff.js         # Pixelmatch visual diff test runner
│   ├── build-local-clone.js    # Local clone validator
│   └── capture-target.js       # Target baseline capture utility
└── package.json
```

## 🎯 Key Sections in `index.html`

1. **Header / Navigation (`#header`)**: Sticky navigation with dynamic backdrop blur (`16px`) and automatic light/dark theme contrast.
2. **Hero (`#hero`)**: High-impact heading, 1-tap download CTA, social proof badge, and interactive 4-screen preview switcher (`src/hero.ts`).
3. **Compatibility Badges (`.customers`)**: Android 10–15, ShopeePay Nudge radar, and SQLite privacy indicators.
4. **Section 1: Download Hub (`#download`)**: 1:1 Raycast download card with physical keyboard background canvas (`src/components/keyboard-canvas.ts`).
5. **Section 2: Extension Reel (`#fitur`)**: 1:1 Raycast carousel with category capsule pills, sliding active backdrop, and 12px reel gap (`src/showcase.ts`).
6. **Section 3: FAQ (`#faq`)**: Accessible accordion with fluid height spring animation and chevron rotation.
7. **Section 4: Call to Action (`#cta`)**: Direct APK download and GitHub repository links.
8. **Footer**: MIT license notice, quick links, and theme toggle.

## ⚡ Motion & Interaction Engine (`src/motion.ts`)

- **Lenis Smooth Scroll**: Inertial momentum wheel scrolling synchronized with GSAP ScrollTrigger ticker.
- **Top Reading Progress Bar**: 2.5px gradient line (`#awwwards-scroll-progress`) tracking scroll percentage.
- **Ambient Cursor Spotlight**: Trailing glow physics following mouse movements across dark cards.
- **3D Card Perspective Tilt**: Real-time cursor coordinates `--card-mouse-x` / `--card-mouse-y` for specular sheen & rotational tilt.
- **Magnetic Spring Buttons**: Elastic spring physics on button hovers (`gsap.to` with `elastic.out`).
- **Draggable Momentum Reel Track**: Smooth grab/drag physics on `#showcaseTrack`.

## 🛠️ Development & Build Commands

- **Start Dev Server**: `npm run dev`
- **Typecheck & Production Build**: `npm run build` (`tsc -b && vite build`)
- **Lint**: `npm run lint` (`oxlint`)
- **Preview Dist**: `npm run preview`
