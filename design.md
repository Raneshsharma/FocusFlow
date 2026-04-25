Explain all the screens with the features they will have. and also the colors, typography, fonts etc.For all the screens

● Here's the full, consolidated FocusFlow design and feature reference:

  ---
  FocusFlow — Complete App Reference

  Colors · Typography · Screens · Features

  ---
  Part 1: Visual Design System

  ---
  Brand Concept

  ▎ "Meet your brain where it is."

  FocusFlow is built for ADHD and neurodivergent brains. The visual system reflects this — calm and structured without being clinical, warm without being childish,
  premium without being cold. It feels like a trusted system, not a productivity lecture.

  Tagline: Stack Every Advantage. (borrowed from EliteStack brand — reinforces the "layer upon layer" philosophy)
  Feel: Calm, spacious, non-judgmental. Like a good coach who knows your game but never yells at you.

  ---
  Color Palette

  ┌───────────────────┬───────────────┬─────────┬─────────────────────────────────────────────────────────┐
  │       Role        │     Name      │   Hex   │                          Usage                          │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Primary           │ Deep Slate    │ #1A1A2E │ Headers, active states, primary actions                 │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Primary Variant   │ Navy          │ #16213E │ Hover states, secondary emphasis                        │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Accent            │ Warm Amber    │ #F5B800 │ CTAs, highlights, active chips, FAB                     │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Accent Secondary  │ Electric Teal │ #0F969C │ Energy chip "Deep", rest elements                       │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Surface           │ Off-White     │ #F8F9FA │ Card backgrounds, screen backgrounds                    │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Surface Alt       │ Cool Gray     │ #EEF0F4 │ Anytime Pool background, input fields                   │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Block Past        │ Muted Gray    │ #D1D5DB │ Past M/A/E block background                             │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Block Current     │ Warm White    │ #FFFFFF │ Active M/A/E block with left accent border              │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Block Future      │ Surface White │ #F8F9FA │ Future M/A/E block                                      │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Text Primary      │ Charcoal      │ #1A1A2E │ Headings, body text                                     │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Text Secondary    │ Slate Gray    │ #64748B │ Subtitles, labels, metadata                             │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Text Muted        │ Light Gray    │ #9CA3AF │ Past block text, placeholder                            │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Success           │ Signal Green  │ #22C55E │ Completion states, "showed up" chip                     │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Energy Quick      │ Warm Amber    │ #FFD9A8 │ ⚡ Quick chip background                                │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Energy Deep       │ Soft Sage     │ #C4E8D4 │ 🧠 Deep chip background                                 │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Energy Low        │ Soft Blue     │ #A8C5E2 │ 🪫 Low energy chip background                           │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Error / Low Score │ Crimson       │ #DC2626 │ Only for critical errors (delete confirm, sync failure) │
  ├───────────────────┼───────────────┼─────────┼─────────────────────────────────────────────────────────┤
  │ Rest Zone         │ Deep Teal     │ #0D4F4F │ Rest screen hero background, wind-down mode             │
  └───────────────────┴───────────────┴─────────┴─────────────────────────────────────────────────────────┘

  Rules:
  - Bright, playful colors (coral, mint, pastel) are avoided — this is a focus tool, not a lifestyle app
  - Rest screen uses muted, cooler tones to signal a different mental mode
  - Dark mode shifts primary surfaces to Deep Slate #1A1A2E with Light text on Dark

  ---
  Typography

  ┌─────────────────┬────────────────┬─────────┬─────────────────┬─────────────┐
  │      Role       │      Font      │  Size   │     Weight      │ Line Height │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ Display         │ Montserrat     │ 48–64px │ ExtraBold (800) │ tight       │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ H1              │ Montserrat     │ 32–36px │ ExtraBold (800) │ tight       │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ H2              │ Montserrat     │ 24–28px │ Bold (700)      │ snappy      │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ H3              │ Montserrat     │ 18–20px │ SemiBold (600)  │ normal      │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ Body Large      │ Inter          │ 16px    │ Regular (400)   │ relaxed     │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ Body            │ Inter          │ 14px    │ Regular (400)   │ relaxed     │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ Caption / Label │ Inter          │ 12px    │ Medium (500)    │ normal      │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ Score / Timer   │ JetBrains Mono │ 14–24px │ Regular (400)   │ mono        │
  ├─────────────────┼────────────────┼─────────┼─────────────────┼─────────────┤
  │ Section Header  │ Montserrat     │ 14px    │ SemiBold (600)  │ normal      │
  └─────────────────┴────────────────┴─────────┴─────────────────┴─────────────┘

  Font Pairing Rationale:
  - Montserrat — geometric, sharp, confident. Used for headings and UI labels. Communicates structure without being stiff.
  - Inter — highly readable at small sizes. Used for body text, form inputs, metadata.
  - JetBrains Mono — used for timers, counters, scores. Monospace precision for time-related elements.

  Fallback Stack:
  font-family: 'Montserrat', 'Inter', 'JetBrains Mono', system-ui, -apple-system, sans-serif

  Accessibility:
  - Minimum body text: 14px (i.e., never below 14px for readability)
  - Caption text: 12px, Medium weight (never below 12px)
  - All text passes WCAG AA contrast ratio (4.5:1 minimum for body, 3:1 for large text)

  ---
  Spacing System (8pt Grid)

  ┌───────────┬───────┬───────────────────────────────────┐
  │   Token   │ Value │               Usage               │
  ├───────────┼───────┼───────────────────────────────────┤
  │ space-xs  │ 4px   │ Icon padding, tight gaps          │
  ├───────────┼───────┼───────────────────────────────────┤
  │ space-sm  │ 8px   │ Chip padding, inline element gaps │
  ├───────────┼───────┼───────────────────────────────────┤
  │ space-md  │ 16px  │ Card padding, standard gaps       │
  ├───────────┼───────┼───────────────────────────────────┤
  │ space-lg  │ 24px  │ Section padding, screen margins   │
  ├───────────┼───────┼───────────────────────────────────┤
  │ space-xl  │ 32px  │ Major section gaps                │
  ├───────────┼───────┼───────────────────────────────────┤
  │ space-2xl │ 48px  │ Screen top/bottom padding         │
  └───────────┴───────┴───────────────────────────────────┘

  Component-specific spacing:
  - Card padding: space-md (16px all sides)
  - Card gap in grid: space-sm (8px)
  - Section gap: space-lg (24px)
  - Screen horizontal margin: space-lg (24px on mobile)
  - FAB bottom offset: 72dp above bottom nav

  ---
  Elevation & Shadows

  ┌─────────────┬─────────────────────────────┬────────────────────────────┐
  │    Level    │           Shadow            │           Usage            │
  ├─────────────┼─────────────────────────────┼────────────────────────────┤
  │ Elevation 0 │ No shadow                   │ Flat cards, past blocks    │
  ├─────────────┼─────────────────────────────┼────────────────────────────┤
  │ Elevation 1 │ 0 1px 2px rgba(0,0,0,0.05)  │ Subtle card distinction    │
  ├─────────────┼─────────────────────────────┼────────────────────────────┤
  │ Elevation 2 │ 0 2px 4px rgba(0,0,0,0.1)   │ Default task cards         │
  ├─────────────┼─────────────────────────────┼────────────────────────────┤
  │ Elevation 3 │ 0 4px 8px rgba(0,0,0,0.12)  │ FAB, bottom sheets, modals │
  ├─────────────┼─────────────────────────────┼────────────────────────────┤
  │ Elevation 4 │ 0 8px 16px rgba(0,0,0,0.15) │ Full-screen sheets         │
  └─────────────┴─────────────────────────────┴────────────────────────────┘

  ---
  Icons

  - Library: Lucide Icons
  - Stroke weight: stroke-1.5 — slightly lighter for premium feel
  - Size standard: 24dp (default), 32dp (on Rest break cards), 20dp (inline with text)
  - No mascot, no illustration. All functional.
  - Custom icons needed: Energy chips (⚡, 🧠, 🪫) use a custom-drawn or OpenMoji set for consistency

  ---
  Motion Principles

  ┌────────────────────────────┬─────────────────────────────────────────────────────┐
  │          Context           │                      Behavior                       │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ Hover states               │ hover:shadow-md, hover:scale-[1.01], 150ms ease     │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ Timer counter              │ 0 → final count, 800ms ease-out                     │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ Completion glow            │ Success color → 200ms fade-in → card fade-out 400ms │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ Toast notifications        │ Slide-in from top-right, 3s auto-dismiss            │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ FAB press                  │ Scale 0.95x, 100ms                                  │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ Now indicator pulse        │ Opacity 0.7 → 1.0, 2s loop, ease-in-out             │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ Body Double breathing dots │ Opacity 0.6 → 1.0, 2s loop                          │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ Rest hero animation        │ Subtle cloud/wave float, very slow                  │
  ├────────────────────────────┼─────────────────────────────────────────────────────┤
  │ Reduced motion mode        │ All animations disabled; fades become instant swaps │
  └────────────────────────────┴─────────────────────────────────────────────────────┘

  Rule: Motion serves clarity, never decorates.

  ---
  Component System

  Button System

  ┌───────────┬───────────────────┬───────────────────────────────────────────────────────────────┐
  │  Variant  │        Use        │                             Style                             │
  ├───────────┼───────────────────┼───────────────────────────────────────────────────────────────┤
  │ Primary   │ Main CTAs         │ bg-amber-500 text-brand-navy hover:bg-amber-400 font-semibold │
  ├───────────┼───────────────────┼───────────────────────────────────────────────────────────────┤
  │ Secondary │ Secondary actions │ bg-brand-steel text-white hover:bg-blue-800                   │
  ├───────────┼───────────────────┼───────────────────────────────────────────────────────────────┤
  │ Ghost     │ Tertiary actions  │ text-brand-navy hover:text-amber-600                          │
  ├───────────┼───────────────────┼───────────────────────────────────────────────────────────────┤
  │ Danger    │ Delete, unlink    │ text-red-600 hover:text-red-700                               │
  ├───────────┼───────────────────┼───────────────────────────────────────────────────────────────┤
  │ Disabled  │ Any state         │ opacity-50 cursor-not-allowed                                 │
  ├───────────┼───────────────────┼───────────────────────────────────────────────────────────────┤
  │ FAB       │ Primary action    │ bg-amber-500 text-brand-navy, 56dp circle, elevation 3        │
  └───────────┴───────────────────┴───────────────────────────────────────────────────────────────┘

  Card System

  ┌────────────────────────┬────────────────────────────────────────────────────────────────────────────┐
  │          Type          │                                   Style                                    │
  ├────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
  │ Task Card (in block)   │ White bg, rounded-2xl (16dp corners), elevation 2, shadow-sm               │
  ├────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
  │ Session Card (Library) │ White bg, rounded-xl, elevation 1, full-width, left accent border on hover │
  ├────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
  │ Template Card          │ White bg, rounded-xl, elevation 1, star icon top-right                     │
  ├────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
  │ Rest Break Card        │ Off-white bg, rounded-2xl, subtle teal left border, 32dp icons             │
  ├────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
  │ Hero Card (Rest)       │ Full-width gradient card, Rest Zone color, generous padding                │
  ├────────────────────────┼────────────────────────────────────────────────────────────────────────────┤
  │ Archive Card           │ Deep Slate bg, white text, gold left-border on active milestones           │
  └────────────────────────┴────────────────────────────────────────────────────────────────────────────┘

  Chip System

  ┌───────────────────────┬────────────────────────────────────────────────────────────────────┐
  │         Chip          │                               Style                                │
  ├───────────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Energy: Quick (⚡)    │ Warm Amber bg #FFD9A8, amber text, rounded-full, 12px Inter Medium │
  ├───────────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Energy: Deep (🧠)     │ Soft Sage bg #C4E8D4, teal text, rounded-full                      │
  ├───────────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Energy: Low (🪫)      │ Soft Blue bg #A8C5E2, slate text, rounded-full                     │
  ├───────────────────────┼────────────────────────────────────────────────────────────────────┤
  │ "Focus mode" toggle   │ Outlined pill, brand-navy border, tap to fill amber                │
  ├───────────────────────┼────────────────────────────────────────────────────────────────────┤
  │ "You showed up today" │ Signal Green bg, white text, no counter — just presence            │
  ├───────────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Active tab            │ Amber underline, 2dp, animated slide between tabs                  │
  └───────────────────────┴────────────────────────────────────────────────────────────────────┘

  ---
  Part 2: Screens

  ---
  Screen 1: Focus (Timeline)

  The heart of the app — opens every single time

  > **Note**: This screen was previously called "Today" in legacy implementations. The correct name is **Focus** — it reflects the app's ADHD-friendly approach where time zones (Morning, Afternoon, Evening) help users focus on what matters, not on rigid scheduling.

  What It Is

  A visual flow of the day divided into Morning, Afternoon, and Evening. Tasks are placed, not scheduled. Below the blocks sits the Anytime Pool — tasks surfaced by
  energy state, not order.

  Philosophy: Time is a flow, not a grid. The system moves with you.

  Header Bar

  ┌────────────────────────────┬────────────────────────────────────────────────────────────┬──────────────────────────────────────────────────────────────┐
  │          Element           │                         Appearance                         │                           Behavior                           │
  ├────────────────────────────┼────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
  │ Date                       │ "Wednesday, April 23" — Montserrat Bold 18px, left-aligned │ Context anchor. Not a clickable nav.                         │
  ├────────────────────────────┼────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
  │ Focus mode toggle          │ Pill chip, "Focus mode" — 12px Inter Medium                │ Tap → expands M/A/E blocks into 30-min slots                 │
  ├────────────────────────────┼────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
  │ "You showed up today" chip │ Signal Green pill, white text, no counter                  │ Appears after ≥1 task completed. Persistent presence signal. │
  ├────────────────────────────┼────────────────────────────────────────────────────────────┼──────────────────────────────────────────────────────────────┤
  │ Settings icon              │ Gear icon, 24dp, top right                                 │ Navigates to Profile/Settings                                │
  └────────────────────────────┴────────────────────────────────────────────────────────────┴──────────────────────────────────────────────────────────────┘

  Design decisions:
  - Date is large but not dominant — context, not headline
  - Focus mode is a toggle within the same screen, not a separate view — keeps mental model unified
  - No notification bell in header — reminders are ambient, not pushed

  ---
  Morning / Afternoon / Evening Blocks

  ┌──────────────────┬───────────────────────────────────────────────────────────────────────────┐
  │     Element      │                                Description                                │
  ├──────────────────┼───────────────────────────────────────────────────────────────────────────┤
  │ Section header   │ "Morning" / "Afternoon" / "Evening" — Montserrat SemiBold 14px, uppercase │
  ├──────────────────┼───────────────────────────────────────────────────────────────────────────┤
  │ Time range label │ "5 AM – 11:59 AM" — shown on first view, collapses on scroll              │
  ├──────────────────┼───────────────────────────────────────────────────────────────────────────┤
  │ Task cards       │ Floating cards positioned within the block                                │
  ├──────────────────┼───────────────────────────────────────────────────────────────────────────┤
  │ Now indicator    │ Animated pulse bar + dot when current time falls in this block            │
  ├──────────────────┼───────────────────────────────────────────────────────────────────────────┤
  │ Block height     │ Adapts to content density — communicates "how full is my day" at a glance │
  └──────────────────┴───────────────────────────────────────────────────────────────────────────┘

  Block States:

  ┌─────────┬────────────────────────────────────────────────────────────────────────────────────┐
  │  State  │                                       Visual                                       │
  ├─────────┼────────────────────────────────────────────────────────────────────────────────────┤
  │ Past    │ Muted Gray bg #D1D5DB, task card text in Text Muted #9CA3AF, cards non-interactive │
  ├─────────┼────────────────────────────────────────────────────────────────────────────────────┤
  │ Current │ White bg with amber left accent border (4dp), now indicator pulses here            │
  ├─────────┼────────────────────────────────────────────────────────────────────────────────────┤
  │ Future  │ Surface White bg #F8F9FA, full vividness, all interactions active                  │
  └─────────┴────────────────────────────────────────────────────────────────────────────────────┘

  ---
  Now Indicator

  ┌────────────────┬──────────────────────────────────────────────────────────────────┬─────────────────────────────────────────────────┐
  │    Element     │                            Appearance                            │                    Behavior                     │
  ├────────────────┼──────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
  │ Horizontal bar │ 3dp height, Amber #F5B800, spans full block width                │ Slow pulse: opacity 0.7 → 1.0, 2s loop          │
  ├────────────────┼──────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
  │ Dot            │ 8dp circle, Amber, left edge of bar                              │ Follows bar, scrolls with content               │
  ├────────────────┼──────────────────────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
  │ Position       │ Anchored to exact vertical position of current time within block │ 10:30 AM → bar at 10:30 position within Morning │
  └────────────────┴──────────────────────────────────────────────────────────────────┴─────────────────────────────────────────────────┘

  Why it exists: ADHD time blindness. The now indicator makes "where am I in the day" visible at a glance.

  Reduced motion mode: Bar appears without pulse, opacity fixed at 0.9.

  ---
  Task Cards (inside blocks)

  ┌─────────────────┬───────────────────────────────┬─────────────────────────────────────────────────────────────────┐
  │     Element     │       Where it appears        │                             Purpose                             │
  ├─────────────────┼───────────────────────────────┼─────────────────────────────────────────────────────────────────┤
  │ Task name       │ Top, full width, Inter 14px   │ Primary content. Wraps to 2 lines max.                          │
  ├─────────────────┼───────────────────────────────┼─────────────────────────────────────────────────────────────────┤
  │ Energy chip     │ Bottom left, inline with name │ Shows ⚡/🧠/🪫 chip if set. No chip if "None."                  │
  ├─────────────────┼───────────────────────────────┼─────────────────────────────────────────────────────────────────┤
  │ Time label      │ Bottom right                  │ Shows placed time: "9:30 AM." Anytime tasks have no time label. │
  ├─────────────────┼───────────────────────────────┼─────────────────────────────────────────────────────────────────┤
  │ Completed state │ —                             │ Green glow 200ms → card fades 400ms → removed                   │
  └─────────────────┴───────────────────────────────┴─────────────────────────────────────────────────────────────────┘

  Card States:

  ┌───────────────────────┬─────────────────────────────────────┬─────────────────────────┐
  │         State         │               Visual                │       Interaction       │
  ├───────────────────────┼─────────────────────────────────────┼─────────────────────────┤
  │ Default               │ White bg, 16dp corners, elevation 2 │ Tap → Task Detail sheet │
  ├───────────────────────┼─────────────────────────────────────┼─────────────────────────┤
  │ Past                  │ Muted Gray bg, muted text           │ No interaction          │
  ├───────────────────────┼─────────────────────────────────────┼─────────────────────────┤
  │ Completed             │ Green glow → fade-out               │ Removed from view       │
  ├───────────────────────┼─────────────────────────────────────┼─────────────────────────┤
  │ Selected (Focus mode) │ Amber border 2dp, scale 1.02x       │ Dragging enabled        │
  └───────────────────────┴─────────────────────────────────────┴─────────────────────────┘

  Tap vs Long Press:
  - Tap → Task Detail sheet (edit, complete, delete)
  - Long press → Quick complete. No sheet needed. Power user shortcut.

  ---
  Anytime Pool

  What it is: Tasks with no fixed slot. A floating "pick what matches your state" holding area. One of FocusFlow's most differentiated UX features.

  Mental model: "Here are your options. Match your current state. Pick what feels right."

  Structure:

  ┌────────────────────────────────────────────────────────────────────┐
  │ ANYTIME                                                            │
  ├────────────────────────────────────────────────────────────────────┤
  │  [⚡ Quick (3)]  [🧠 Deep (2)]  [🪫 Low energy (4)]                  │
  │                                                                    │
  │  [Task Card] [Task Card] [Task Card]                               │
  │  [Task Card] [Task Card] [Task Card]                               │
  └────────────────────────────────────────────────────────────────────┘

  Energy Filter Chips:

  ┌───────────────┬──────┬────────────────────┬───────────────────────────┬───────────────────────────────────────┐
  │     Chip      │ Icon │       Color        │          Meaning          │              "I feel..."              │
  ├───────────────┼──────┼────────────────────┼───────────────────────────┼───────────────────────────────────────┤
  │ ⚡ Quick      │ ⚡   │ Warm Amber #FFD9A8 │ Under 10 minutes          │ Restless, need to move, short window  │
  ├───────────────┼──────┼────────────────────┼───────────────────────────┼───────────────────────────────────────┤
  │ 🧠 Deep       │ 🧠   │ Soft Sage #C4E8D4  │ Needs focus or creativity │ Focused, clear, ready to dive in      │
  ├───────────────┼──────┼────────────────────┼───────────────────────────┼───────────────────────────────────────┤
  │ 🪫 Low energy │ 🪫   │ Soft Blue #A8C5E2  │ Easy, low-effort          │ Tired, overwhelmed, just do something │
  └───────────────┴──────┴────────────────────┴───────────────────────────┴───────────────────────────────────────┘

  Multi-select logic:
  - None active → All Anytime tasks shown
  - ⚡ Quick + 🧠 Deep active → Tasks matching EITHER chip
  - ⚡ Quick + 🧠 Deep + 🪫 Low → Same as none (all shown)

  Count on each chip:
  Number updates in real-time as tasks are completed or added. Example: [⚡ Quick (3)] means 3 Quick-tagged tasks are in the pool right now.

  No order. No #1, #2, #3. The user scans → identifies their state → picks.

  ---
  Body Double Pill

  Appears on the timeline when a body double session is active:

  ┌──────────────────────────────────────────────────────────────┐
  │ 🔵 ●  ●  ●  Focusing (25 min)                          [✕]  │
  └──────────────────────────────────────────────────────────────┘

  ┌──────────────┬──────────────────────────────────────────────────┬────────────────────────┐
  │   Element    │                    Appearance                    │        Behavior        │
  ├──────────────┼──────────────────────────────────────────────────┼────────────────────────┤
  │ Three dots   │ Animated breathing opacity 0.6 → 1.0, 2s loop    │ Subtle presence signal │
  ├──────────────┼──────────────────────────────────────────────────┼────────────────────────┤
  │ Timer label  │ "Focusing for 25 minutes" — updates every minute │ —                      │
  ├──────────────┼──────────────────────────────────────────────────┼────────────────────────┤
  │ Close button │ [✕]                                              │ Ends session           │
  └──────────────┴──────────────────────────────────────────────────┴────────────────────────┘

  Position: Anchored below the current M/A/E block. Floats over content without obscuring it.
  Tap behavior: Expands to full Body Double control sheet.
  Inactive: Not visible at all. No clutter.

  ---
  FAB (+)

  ┌───────────┬──────────────────────────────────────────────────────┐
  │  Element  │                        Detail                        │
  ├───────────┼──────────────────────────────────────────────────────┤
  │ Size      │ 56dp circle                                          │
  ├───────────┼──────────────────────────────────────────────────────┤
  │ Position  │ 16dp from right edge, 72dp above bottom nav          │
  ├───────────┼──────────────────────────────────────────────────────┤
  │ Color     │ Amber #F5B800, white "+" icon                        │
  ├───────────┼──────────────────────────────────────────────────────┤
  │ Elevation │ 6dp shadow                                           │
  ├───────────┼──────────────────────────────────────────────────────┤
  │ Tap       │ Opens Task Capture bottom sheet, keyboard auto-shows │
  └───────────┴──────────────────────────────────────────────────────┘

  States:

  ┌─────────┬────────────────────────────────┐
  │  State  │             Visual             │
  ├─────────┼────────────────────────────────┤
  │ Default │ Amber bg, white "+"            │
  ├─────────┼────────────────────────────────┤
  │ Pressed │ Amber dark, scale 0.95x, 100ms │
  ├─────────┼────────────────────────────────┤
  │ Loading │ Spinner replaces "+", disabled │
  └─────────┴────────────────────────────────┘

  ---
  Pull-to-Refresh

  - Standard Material pull-down gesture
  - Amber spinner
  - Re-queries Room DB for latest state (multi-instance sync post-MVP)
  - Reduced motion: fade instead of spring animation

  ---
  ---
  Screen 2: Flow

  Where active focus sessions happen

  What It Is

  Flow is the screen that appears while you're working. It's not a planning screen — it's a doing screen. It shows one task, one timer, one objective. Everything else
  disappears. When you're in Flow, the world becomes the task.

  Philosophy: Focus is not about more. It's about less.

  ---
  Header Bar

  ┌───────────────┬────────────────────────────────────────────┬────────────────────────────────────────────────────────────┐
  │    Element    │                 Appearance                 │                          Behavior                          │
  ├───────────────┼────────────────────────────────────────────┼────────────────────────────────────────────────────────────┤
  │ Exit / Back   │ Arrow icon, top left                       │ One-tap exit from Flow mode. Confirms: "End this session?" │
  ├───────────────┼────────────────────────────────────────────┼────────────────────────────────────────────────────────────┤
  │ Session label │ "Flow Session" — Montserrat 14px, centered │ Shows session type (Focus Flow / Deep Work / Body Double)  │
  ├───────────────┼────────────────────────────────────────────┼────────────────────────────────────────────────────────────┤
  │ Session timer │ JetBrains Mono 18px, centered below label  │ Running clock: "23:14"                                     │
  ├───────────────┼────────────────────────────────────────────┼────────────────────────────────────────────────────────────┤
  │ Pause button  │ Pause icon, right side                     │ Pauses session timer + optional Pomodoro                   │
  └───────────────┴────────────────────────────────────────────┴────────────────────────────────────────────────────────────┘

  Design decisions:
  - Header is intentionally minimal during Flow — no distractions
  - Exit is present but not prominent — subtle, not alarming
  - Timer is the visual anchor, not a countdown panic

  ---
  Active Task Display

  Hero section — takes 60% of screen:

  ┌────────────────────────────────────────────────────────────────────┐
  │                                                                    │
  │                    📋                                              │
  │                                                                    │
  │     "Redesign the hero section with new copy"                     │
  │                                                                    │
  │              ⚡ Quick · Est. 8 min                                  │
  │                                                                    │
  │                    ━━━━●━━━━━━━━━━━━━━━━━━                          │
  │                      4:23 elapsed                                  │
  │                                                                    │
  └────────────────────────────────────────────────────────────────────┘

  ┌────────────────┬─────────────────────────────────────────────┬─────────────────────────────────────────────────────────┐
  │    Element     │                 Appearance                  │                        Behavior                         │
  ├────────────────┼─────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Task name      │ Montserrat Bold 24px, centered, max 3 lines │ Primary focus — large, clear                            │
  ├────────────────┼─────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Energy tag     │ Chip below name                             │ Shows ⚡/🧠/🪫 with label + estimated time              │
  ├────────────────┼─────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Progress bar   │ Horizontal bar below, Amber fill            │ Visual progress — not time-based, task-completion-based │
  ├────────────────┼─────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Elapsed time   │ JetBrains Mono 14px, below bar              │ "4:23 elapsed" — not countdown, elapsed time            │
  ├────────────────┼─────────────────────────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Objective note │ Below elapsed — Inter 14px italic           │ If a note was added: "Focus on the CTA button only"     │
  └────────────────┴─────────────────────────────────────────────┴─────────────────────────────────────────────────────────┘

  Progress bar logic:
  - The bar fills as the user marks sub-sections or increments progress manually
  - Not a time-based countdown — progress is marked manually or via sub-tasks
  - If no sub-tasks: bar fills to 100% when user taps "Mark Complete"

  ---
  Session Timer Modes

  ┌────────────┬───────────────────────────────────────────────────────┬─────────────────────────────────────────────┐
  │    Mode    │                     How it works                      │                   Visual                    │
  ├────────────┼───────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
  │ Open-ended │ No timer. User works until done. Tap "Mark Complete." │ Only elapsed time shown                     │
  ├────────────┼───────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
  │ Pomodoro   │ 25-min work / 5-min break cycles, auto-advance        │ Cycles shown: "🍅 2/4", current cycle timer │
  ├────────────┼───────────────────────────────────────────────────────┼─────────────────────────────────────────────┤
  │ Deep Work  │ 50-min focus block, no interruptions tracked          │ Full-screen minimal mode                    │
  └────────────┴───────────────────────────────────────────────────────┴─────────────────────────────────────────────┘

  Pomodoro controls (if active):

  [◀ Prev]  [⏸️ Pause]  [▶▶ Skip Break]  [⏭ Next]      🍅 2/4

  Break state:
  When a Pomodoro break triggers automatically:
  - Screen shifts to calm Rest mini-mode
  - "5-minute break" suggestion card appears
  - User can snooze or start break

  ---
  Focus Mode Expanded View

  When Focus mode toggle is on in the header:

  ┌────────────────────────────────────────────────────────────────────┐
  │ FOCUS MODE · Morning Block                                          │
  ├────────────────────────────────────────────────────────────────────┤
  │                                                                    │
  │  Morning · 9:00 AM – 11:59 AM                                      │
  │                                                                    │
  │  ┌──────────────────────────────────────────────────────────────┐  │
  │  │ [🔵 Selected Task Name]                                      │  │
  │  │ Estimated: 30 min                                            │  │
  │  └──────────────────────────────────────────────────────────────┘  │
  │                                                                    │
  │  Unscheduled tasks in Focus window:                                │
  │  [Task] [Task] [Task]                                              │
  │                                                                    │
  │  [Mark Complete ✓]                                                 │
  │                                                                    │
  └────────────────────────────────────────────────────────────────────┘

  - Selected task card gets amber border + scale
  - Other tasks in the Focus window shown as small chips below
  - User can swap selected task by tapping another chip
  - Dragging enabled to reorder within the block

  ---
  Mark Complete / Session End

  "Mark Complete" button (bottom):

  ┌────────────────────────────────────────────────────────────────────┐
  │                     [✓ Mark Complete]                               │
  └────────────────────────────────────────────────────────────────────┘

  On tap:
  1. Success animation: green pulse on card
  2. Session summary card slides up:

  ┌────────────────────────────────────────────────────────────────────┐
  │                    Session Complete                                │
  │                                                                    │
  │  Task: "Redesign hero section"                                     │
  │  Time: 34 min · Est. 30 min                                        │
  │  Energy: ⚡ Quick                                                  │
  │                                                                    │
  │  [Add a quick note about this session]                             │
  │  [Save & Exit]                                                     │
  │                                                                    │
  └────────────────────────────────────────────────────────────────────┘

  Save & Exit behavior:
  - Session saved to Library → Saved Sessions
  - Returns to Today screen
  - Task card removed from timeline
  - "You showed up today" chip appears in header

  "Add a quick note" field:
  - Soft-text input: "What clicked? What was hard?" — 280 char soft limit
  - Saves to Session Notes in Library
  - User can skip (button still active — skip is always available)

  ---
  Body Double Flow State

  When Body Double is active during a Flow session:

  ┌────────────────────────────────────────────────────────────────────┐
  │                                                                    │
  │  🔵 ●  ●  ●  Body Double active · You + 1 partner                 │
  │                                                                    │
  │  "Redesign the hero section"                                       │
  │  ⚡ Quick · 34 min elapsed                                         │
  │                                                                    │
  │  [Share status: Focusing ☑️]  [Leave session]                       │
  │                                                                    │
  └────────────────────────────────────────────────────────────────────┘

  - Partner presence shown as avatar dots: "You + 1 partner" / "You + 2 partners"
  - Status sharing toggle: "Focusing" / "Break" / "Away"
  - "Leave session" confirms before exiting
  - Partner names shown on hover/tap: "Sarah is in the room"

  ---
  Session Types in Flow

  ┌──────────────┬─────────────────────────────────────────────────────────┬──────────────────────────────────┬─────────────┐
  │ Session Type │                      How to start                       │            Timer mode            │ Body Double │
  ├──────────────┼─────────────────────────────────────────────────────────┼──────────────────────────────────┼─────────────┤
  │ Quick Win    │ Tap task in Anytime Pool → "Start now"                  │ Open-ended                       │ Optional    │
  ├──────────────┼─────────────────────────────────────────────────────────┼──────────────────────────────────┼─────────────┤
  │ Focus Block  │ Place task in M/A/E block → "Start"                     │ Open-ended or Deep Work (50 min) │ Optional    │
  ├──────────────┼─────────────────────────────────────────────────────────┼──────────────────────────────────┼─────────────┤
  │ Deep Work    │ Select Deep task → "Enter Deep Work"                    │ 50-min block                     │ Optional    │
  ├──────────────┼─────────────────────────────────────────────────────────┼──────────────────────────────────┼─────────────┤
  │ Body Double  │ Body Double screen → "Find a partner" or "Host session" │ Open-ended                       │ Required    │
  └──────────────┴─────────────────────────────────────────────────────────┴──────────────────────────────────┴─────────────┘

  ---
  ---
  Screen 3: Library

  "Your ADHD arsenal" — saved, organized, reusable

  What It Is

  Where everything you've saved, built, and created lives. Not tasks for today — the reusable parts of your system. Templates, session history, favorite tasks, reflection
   notes, achievement archive, and external resources.

  Why it matters: ADHD brains need a launchpad, not a blank slate. Library means you never start from zero.

  ---
  Header Bar

  ┌──────────────┬─────────────────────────────────────────────────┬─────────────────────────────────────────────────┐
  │   Element    │                   Appearance                    │                    Behavior                     │
  ├──────────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
  │ Screen title │ "Library" — Montserrat Bold 24px, left-aligned  │ Anchor                                          │
  ├──────────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
  │ Search icon  │ Magnifying glass, 24dp, top right               │ Opens inline search across all Library sections │
  ├──────────────┼─────────────────────────────────────────────────┼─────────────────────────────────────────────────┤
  │ Subtitle     │ "Stack what works" — Inter 12px, Text Secondary │ Soft brand hook                                 │
  └──────────────┴─────────────────────────────────────────────────┴─────────────────────────────────────────────────┘

  ---
  Section Navigation Tabs

  Horizontally scrollable tab strip below header:

  [📋 Sessions] [🧱 Templates] [⭐ Favorites] [📝 Notes] [🏆 Archive] [🔗 Resources]

  ┌──────────────────┬───────────────────────────────────────────────────────────────┐
  │     Element      │                           Behavior                            │
  ├──────────────────┼───────────────────────────────────────────────────────────────┤
  │ Tab label        │ Icon + name, tap → scrolls section into view + highlights tab │
  ├──────────────────┼───────────────────────────────────────────────────────────────┤
  │ Active indicator │ 2dp amber underline, animated slide between tabs              │
  ├──────────────────┼───────────────────────────────────────────────────────────────┤
  │ Badge count      │ Small bubble on tab if section has content                    │
  └──────────────────┴───────────────────────────────────────────────────────────────┘

  Scroll behavior: Tabs scroll horizontally if overflow. Tapping a tab smooth-scrolls list AND switches the "All" view.

  ---
  📋 Saved Sessions

  What it is: Chronological list of past focus and Flow sessions — auto-saved snapshots of moments that worked.

  Card layout:

  ┌────────────────────────────────────────────────────────────────────┐
  │ 📅 Wednesday, April 23 · Morning Block                             │
  │ ─────────────────────────────────────────────────────────────────  │
  │ 🔵 Deep Work Session · 47 min · 3 tasks completed                 │
  │ Tags: #deepwork #morning #productivity                             │
  │ [View] [Replay Pattern]                                            │
  └────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────┬─────────────────────────────────────────────────────────┐
  │         Element         │                         Purpose                         │
  ├─────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Date + block label      │ Context for when                                        │
  ├─────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Session type + duration │ Core info                                               │
  ├─────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Tasks completed count   │ Win signal                                              │
  ├─────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Tags                    │ User or auto-generated                                  │
  ├─────────────────────────┼─────────────────────────────────────────────────────────┤
  │ View                    │ Opens full session detail sheet                         │
  ├─────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Replay Pattern          │ Suggests same block structure for today — user confirms │
  ├─────────────────────────┼─────────────────────────────────────────────────────────┤
  │ Overflow menu (⋮)       │ Delete, Edit tags, Export notes                         │
  └─────────────────────────┴─────────────────────────────────────────────────────────┘

  "Replay Pattern" flow:
  - Analyzes time of day + energy state
  - Suggests same block config for today/tomorrow
  - User confirms → tasks auto-populate matching energy-tagged tasks from pool
  - Never automatic. User always confirms.

  Empty state: "Your session history starts here. When you complete a focus or Flow session, it saves automatically."

  ---
  🧱 My Templates

  What it is: User-created block templates — reusable task + time configurations. "Morning Block Template" means you don't rebuild every day.

  Card layout:

  ┌────────────────────────────────────────────────────────────────────┐
  │ 🧱 Deep Work Morning                               [⭐]    [⋮]  │
  │ ─────────────────────────────────────────────────────────────────  │
  │ Morning block · 4 tasks · ~2.5 hrs                                │
  │ ⚡ 2  🧠 2  🪫 0                                                   │
  │ Tasks: "Review Slack", "Code review", "Write spec", "Inbox zero"  │
  │ Last used: 2 days ago · Used 12 times                              │
  │ [Apply Today] [Edit]                                               │
  └────────────────────────────────────────────────────────────────────┘

  ┌──────────────────────┬────────────────────────────────────────────────────┐
  │       Element        │                      Purpose                       │
  ├──────────────────────┼────────────────────────────────────────────────────┤
  │ Template name + star │ User-defined name; star = favorited                │
  ├──────────────────────┼────────────────────────────────────────────────────┤
  │ Energy breakdown     │ ⚡/🧠/🪫 counts                                    │
  ├──────────────────────┼────────────────────────────────────────────────────┤
  │ Task list            │ Collapsed list, tap to expand                      │
  ├──────────────────────┼────────────────────────────────────────────────────┤
  │ Usage metadata       │ "Last used" + "Used X times" — signals reliability │
  ├──────────────────────┼────────────────────────────────────────────────────┤
  │ Apply Today          │ Primary CTA — applies template to today's timeline │
  ├──────────────────────┼────────────────────────────────────────────────────┤
  │ Edit                 │ Opens template editor sheet                        │
  ├──────────────────────┼────────────────────────────────────────────────────┤
  │ Overflow menu        │ Duplicate, Delete, Share (future)                  │
  └──────────────────────┴────────────────────────────────────────────────────┘

  "Apply Today" flow:
  1. Tap "Apply Today"
  2. Confirmation sheet: "Apply 'Deep Work Morning' to your Morning block? This will add 4 tasks."
  3. Confirm → tasks added to Morning block with energy tags preserved
  4. Toast: "Morning block applied. Edit anytime."

  "Create Template" flow:
  - User selects 2+ tasks from any block
  - Long-press menu → "Save as Template" → name prompt → saved
  - System auto-suggests when same task cluster is used 3+ times in same time block

  Empty state: "No templates yet. Select tasks from your timeline and tap 'Save as Template' to build your first one."

  ---
  ⭐ Favorites

  What it is: Tasks starred at any point — quick-access pool for recurring tasks.

  Filter chips: Same energy system as Anytime Pool (⚡ Quick / 🧠 Deep / 🪫 Low) — multi-select.

  Card layout:

  ┌────────────────────────────────────────────────────────────────────┐
  │ 🔵 Review daily standup notes                                       │
  │ 🪫 Low energy · [Add to Anytime]                                   │
  └────────────────────────────────────────────────────────────────────┘

  ┌──────────────────┬────────────────────────────────────────────────┐
  │     Element      │                    Behavior                    │
  ├──────────────────┼────────────────────────────────────────────────┤
  │ Swipe left       │ Remove from Favorites (with undo toast)        │
  ├──────────────────┼────────────────────────────────────────────────┤
  │ "Add to Anytime" │ One-tap → task returns to Today's Anytime Pool │
  ├──────────────────┼────────────────────────────────────────────────┤
  │ Long press       │ Quick edit (change energy tag, rename)         │
  └──────────────────┴────────────────────────────────────────────────┘

  Empty state: "Star any task by tapping ☆ — it lands here for quick access anytime."

  ---
  📝 Session Notes

  What it is: Chronological journal of post-session reflections. Raw signals from focus sessions — what clicked, what drained you. Feeds into Pattern Insights (PRO).

  Card layout:

  ┌────────────────────────────────────────────────────────────────────┐
  │ 📅 April 23, 2026 · Morning Block · Deep Work Session            │
  │ ─────────────────────────────────────────────────────────────────  │
  │ "Finally cracked the auth flow after two false starts.           │
  │  The third attempt felt different — I started by                  │
  │  sketching instead of coding."                                     │
  │ Tags: #breakthrough #auth #sketching                              │
  │ Linked session: Deep Work Session · 47 min                        │
  │ [Edit] [View Session]                                              │
  └────────────────────────────────────────────────────────────────────┘

  | Element | Behavior |
  |---|---|---|
  | Date + session type | Context header |
  | Note text | User's reflection, multi-line, 280-char soft limit |
  | Tags | Auto-suggested from keywords + user-created |
  | Linked session | Tap → jumps to saved session |
  | Filter ▾ | All / Linked / Free-form / By date / By tag |
  | Search | Full-text search, highlights matches |

  Note creation: Triggered automatically after completing a focus block or Flow session. Soft prompt: "What clicked today?" or "What drained you?" — user can skip.

  Empty state: "No notes yet. After completing a session, a soft prompt invites you to capture what happened."

  ---
  🏆 Archive

  What it is: "No-shame" achievement record — quiet wins, streaks, milestones. 100% private. No leaderboards, no comparison, no punishment for breaks.

  Sub-sections:

  ┌─────────────────────┬───────────────────────────────────────────────────────────────────────────────────┐
  │     Sub-section     │                                      Content                                      │
  ├─────────────────────┼───────────────────────────────────────────────────────────────────────────────────┤
  │ Focus Archive       │ Total sessions, total time, longest session, energy distribution                  │
  ├─────────────────────┼───────────────────────────────────────────────────────────────────────────────────┤
  │ Body Double Archive │ Sessions, time, partner count, most productive day                                │
  ├─────────────────────┼───────────────────────────────────────────────────────────────────────────────────┤
  │ Milestones          │ First session, session counts, streaks — locked ones show aspirational next steps │
  └─────────────────────┴───────────────────────────────────────────────────────────────────────────────────┘

  Privacy badge: "Private 🔒" — always visible. No export to social.

  Milestone states:

  ┌─────────────┬──────────────────────────────────────────┐
  │    State    │                  Visual                  │
  ├─────────────┼──────────────────────────────────────────┤
  │ Unlocked    │ Full color, date shown, tappable         │
  ├─────────────┼──────────────────────────────────────────┤
  │ In progress │ Progress ring, "X more to unlock"        │
  ├─────────────┼──────────────────────────────────────────┤
  │ Locked      │ Grayed out, lock icon, aspirational only │
  └─────────────┴──────────────────────────────────────────┘

  Empty state: "Your archive builds quietly. Every session you complete — it all gets recorded here."

  ---
  🔗 Resources

  What it is: Personal bookmark library — study playlists, ambient sound sources, productivity articles, ADHD tools.

  Category system: Study Music / Tools / Articles / Apps / ADHD Resources / Custom

  Card layout:

  ┌────────────────────────────────────────────────────────────────────┐
  │ 🔵 Lo-fi Girl — YouTube                                  [⋮]      │
  │ lo-fi.beats · Ambient focus music                                   │
  │ Category: Study Music · Added Apr 20                             │
  │ [Open] [Move to category]                                          │
  └────────────────────────────────────────────────────────────────────┘

  Adding a resource: FAB "+" → URL input → app auto-fetches title + domain + favicon → user adds description + category → saved.

  Empty state: "Add your study playlists, focus tools, and helpful articles — everything stays organized right here."

  ---
  Library FAB (+)

  ┌───────────────┬──────────────────────────────────┐
  │    Section    │            FAB opens             │
  ├───────────────┼──────────────────────────────────┤
  │ Sessions tab  │ No action (auto-saved)           │
  ├───────────────┼──────────────────────────────────┤
  │ Templates tab │ Template creator sheet           │
  ├───────────────┼──────────────────────────────────┤
  │ Favorites tab │ No action (favorited from tasks) │
  ├───────────────┼──────────────────────────────────┤
  │ Notes tab     │ Note capture sheet               │
  ├───────────────┼──────────────────────────────────┤
  │ Archive tab   │ No action                        │
  ├───────────────┼──────────────────────────────────┤
  │ Resources tab │ Resource URL input sheet         │
  └───────────────┴──────────────────────────────────┘

  ---
  ---
  Screen 4: Rest

  "The Off Switch" — intentional recovery

  What It Is

  Rest is intentional recovery, not the absence of productivity. For ADHD brains, rest is a skill that needs scaffolding. The entire Rest screen is designed to make rest
  feel purposeful, not lazy.

  Philosophy: Rest is where reload happens.

  Visual tone: Distinctly calmer than the rest of the app. Centered title, cooler palette, slower animations, more whitespace.

  ---
  Header Bar

  ┌──────────────────────┬─────────────────────────────────────────┬───────────────────────────────────┐
  │       Element        │               Appearance                │             Behavior              │
  ├──────────────────────┼─────────────────────────────────────────┼───────────────────────────────────┤
  │ Screen title         │ "Rest" — Montserrat Bold 24px, centered │ Signals mode change               │
  ├──────────────────────┼─────────────────────────────────────────┼───────────────────────────────────┤
  │ Ambient sound toggle │ Speaker icon, top right                 │ One-tap ambient soundscape on/off │
  ├──────────────────────┼─────────────────────────────────────────┼───────────────────────────────────┤
  │ Settings icon        │ Gear icon, far right                    │ Profile/Settings                  │
  └──────────────────────┴─────────────────────────────────────────┴───────────────────────────────────┘

  Key difference from other headers: Title is centered (not left-aligned) — signals transition, not navigation.

  ---
  Hero Rest Suggestion Card

  First thing visible — large, calming card with context-aware message:

  ┌────────────────────────────────────────────────────────────────────┐
  │                                                                    │
  │                         ☁️                                        │
  │                                                                    │
  │            "You've been at it for 3 hours.                        │
  │             Time for a real reset."                               │
  │                                                                    │
  │               [Start a 5-min break →]                              │
  │                                                                    │
  └────────────────────────────────────────────────────────────────────┘

  ┌─────────────────┬──────────────────────────────────────────────────────────────┐
  │     Element     │                            Detail                            │
  ├─────────────────┼──────────────────────────────────────────────────────────────┤
  │ Visual          │ Subtle animated cloud/wave — ambient, not stimulating        │
  ├─────────────────┼──────────────────────────────────────────────────────────────┤
  │ Suggestion text │ Context-aware based on time of day + recent activity         │
  ├─────────────────┼──────────────────────────────────────────────────────────────┤
  │ Primary CTA     │ "Start a 5-min break →" — one-tap opens Micro-Break selector │
  └─────────────────┴──────────────────────────────────────────────────────────────┘

  Context-aware messages:

  ┌───────────────┬───────────────────┬────────────────────────────────────────────────────────────────────┐
  │     Time      │     Condition     │                              Message                               │
  ├───────────────┼───────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Morning       │ After ≥1 session  │ "You're already building momentum. A micro-break protects it."     │
  ├───────────────┼───────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Morning       │ No sessions yet   │ "No rush. Rest before you start, so you're sharp when you begin."  │
  ├───────────────┼───────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Midday        │ After 2+ hours    │ "Lunch isn't optional. Neither is stepping away."                  │
  ├───────────────┼───────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Midday        │ Low energy signal │ "Eating while working is working. Try eating while resting."       │
  ├───────────────┼───────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Afternoon     │ After 2+ hours    │ "The afternoon drag is real. A 5-minute reset changes everything." │
  ├───────────────┼───────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Evening       │ Session count ≥ 3 │ "You've done the work. Wind down, not wind out."                   │
  ├───────────────┼───────────────────┼────────────────────────────────────────────────────────────────────┤
  │ Evening       │ Any               │ "The day is wrapped. This is your signal to stop."                 │
  ├───────────────┼───────────────────┼────────────────────────────────────────────────────────────────────┤
  │ After session │ Any               │ "Session complete. Before you start the next — pause here."        │
  └───────────────┴───────────────────┴────────────────────────────────────────────────────────────────────┘

  Swipe down on hero card: Dismisses suggestion for today (resets tomorrow).

  ---
  🔄 Micro-Breaks

  What it is: Horizontal scrollable list of short (30s–5min) guided breaks. Atomic, single-action resets.

  [🧘 Neck Stretch · 60s] [👀 20-20-20 Eye Rest · 30s] [🚶 Desk Walk · 2min] [☕ Water Break · 60s] [🫁 Deep Breath · 90s] [💆 Jaw Release · 60s]

  ┌──────────────────────┬──────────┬─────────────────────────────────────────────────────────────────────────────┐
  │        Break         │ Duration │                                 Instruction                                 │
  ├──────────────────────┼──────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ 🧘 Neck Stretch      │ 60s      │ "Slowly tilt head right. Hold 15s. Left. 15s. Forward. 15s. Roll once."     │
  ├──────────────────────┼──────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ 👀 20-20-20 Eye Rest │ 30s      │ "Look at something 20 feet away. Hold 20 seconds. Blink naturally. Repeat." │
  ├──────────────────────┼──────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ 🚶 Desk Walk         │ 2 min    │ "Stand up. Walk to a different room. Look at something not a screen."       │
  ├──────────────────────┼──────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ ☕ Water Break       │ 60s      │ "Get water. Don't chug. Sip slowly. Stay standing for the full minute."     │
  ├──────────────────────┼──────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ 🫁 Deep Breath       │ 90s      │ "Inhale 4s. Hold 4s. Exhale 6s. Repeat. Your choice of count."              │
  ├──────────────────────┼──────────┼─────────────────────────────────────────────────────────────────────────────┤
  │ 💆 Jaw Release       │ 60s      │ "Open jaw wide. Hold 5s. Close. Massage jaw muscles for 20s."               │
  └──────────────────────┴──────────┴─────────────────────────────────────────────────────────────────────────────┘

  Tap behavior: Card expands to full-screen Rest mode → timer starts → guided instruction → completion animation → returns to Rest.

  "See all ▸": Opens bottom sheet with all breaks, duration filter (Under 1 min / 1–3 min / 3–5 min), favorite pinning.

  ---
  🌬️ Breathing Timer

  What it is: Box breathing and alternate breathing exercises. Standalone tool accessible from Rest or Focus.

  Visual:

  ┌────────────────────────────────────────────────────────────────────┐
  │                         ○ ○ ○ ○ ○                                  │
  │                                                                    │
  │                      "Breathe In..."                              │
  │                       "Hold..."                                   │
  │                      "Breathe Out..."                             │
  │                                                                    │
  │                        [2:30]                                    │
  │                                                                    │
  │         [◀ 2 min]  [⏸️ Pause]  [▶ Start]  [5 min ▶]                │
  └────────────────────────────────────────────────────────────────────┘

  ┌──────────────────┬─────────────────────────────────────────────────────┐
  │     Element      │                      Behavior                       │
  ├──────────────────┼─────────────────────────────────────────────────────┤
  │ Expanding circle │ Synchronized with breath phases                     │
  ├──────────────────┼─────────────────────────────────────────────────────┤
  │ Phase label      │ "Breathe In...", "Hold...", "Breathe Out..."        │
  ├──────────────────┼─────────────────────────────────────────────────────┤
  │ Timer controls   │ Start/Pause toggle, duration presets (2/5/10 min)   │
  ├──────────────────┼─────────────────────────────────────────────────────┤
  │ Haptic feedback  │ Optional subtle pulse on phase transitions          │
  ├──────────────────┼─────────────────────────────────────────────────────┤
  │ Sound            │ Optional bell on phase transitions (off by default) │
  └──────────────────┴─────────────────────────────────────────────────────┘

  Patterns:

  ┌────────────────────┬─────────────────────────┬──────────────────────────────────────┐
  │      Pattern       │         Timing          │               Best for               │
  ├────────────────────┼─────────────────────────┼──────────────────────────────────────┤
  │ Box Breathing      │ 4-4-4-4                 │ General calm, pre-focus centering    │
  ├────────────────────┼─────────────────────────┼──────────────────────────────────────┤
  │ 4-7-8 Relaxation   │ 4-7-8                   │ Evening wind-down, sleep preparation │
  ├────────────────────┼─────────────────────────┼──────────────────────────────────────┤
  │ Physiological Sigh │ 2x inhale + long exhale │ Acute stress, mid-day reset          │
  └────────────────────┴─────────────────────────┴──────────────────────────────────────┘

  Completion: Gentle chime (if sound on) → session logged to Rest streak.

  ---
  🧘 Wind-Down Routine

  What it is: Guided end-of-day sequence — 3 steps that transition the brain out of work mode.

  Visual:

  ┌────────────────────────────────────────────────────────────────────┐
  │ WIND-DOWN                                                         │
  ├────────────────────────────────────────────────────────────────────┤
  │                                                                    │
  │  Step 1 · Screen Off                                              │
  │  "Put your phone face down for 5 minutes."                        │
  │  ○ ○ ○ ○ ○ ─── 5:00                                              │
  │                                                                    │
  │  Step 2 · One Win                                                 │
  │  "What's one thing you did today you're glad about?"             │
  │  [________________________]                                       │
  │                                                                    │
  │  Step 3 · Tomorrow Preview                                        │
  │  "What's the one thing you want to tackle first tomorrow?"       │
  │  [________________________]                                      │
  │                                                                    │
  │                     [Finish Wind-Down]                            │
  │                                                                    │
  └────────────────────────────────────────────────────────────────────┘

  ┌──────────────────┬─────────────────┬─────────────────────────────────────────────────────────────┐
  │       Step       │    Duration     │                        What it does                         │
  ├──────────────────┼─────────────────┼─────────────────────────────────────────────────────────────┤
  │ Screen Off       │ 5 min countdown │ Phone face down. Optional reminder if picked up early.      │
  ├──────────────────┼─────────────────┼─────────────────────────────────────────────────────────────┤
  │ One Win          │ No timer        │ Free-text → saves to Session Notes tagged #daily-reflection │
  ├──────────────────┼─────────────────┼─────────────────────────────────────────────────────────────┤
  │ Tomorrow Preview │ No timer        │ Free-text → auto-promotes to Morning block                  │
  └──────────────────┴─────────────────┴─────────────────────────────────────────────────────────────┘

  Auto-trigger: Can be set to fire at a user-defined time (e.g., 8 PM daily). Notification: "Ready to wind down?" — snooze 15/30 min or start.

  Visual treatment during Wind-Down:
  - Dark mode auto-activates
  - Warm color palette (Deep Teal + Amber)
  - Screen brightness dims with step progression

  ---
  🔊 Ambient Sound Mixer

  What it is: A mixer, not a player. Layer multiple ambient tracks simultaneously, dial in exactly the soundscape you need.

  Tracks:

  ┌──────────────┬──────┬──────────────────────────────────────────┐
  │    Track     │ Icon │                 Best for                 │
  ├──────────────┼──────┼──────────────────────────────────────────┤
  │ Rain         │ 🌧️   │ General focus, sleep                     │
  ├──────────────┼──────┼──────────────────────────────────────────┤
  │ Fireplace    │ 🔥   │ Evening rest                             │
  ├──────────────┼──────┼──────────────────────────────────────────┤
  │ Café Chatter │ ☕   │ Mild background, combats silence fatigue │
  ├──────────────┼──────┼──────────────────────────────────────────┤
  │ Ocean Waves  │ 🌊   │ Wind-down                                │
  ├──────────────┼──────┼──────────────────────────────────────────┤
  │ Brown Noise  │ 🍃   │ Deep focus, masking                      │
  ├──────────────┼──────┼──────────────────────────────────────────┤
  │ Forest       │ 🌲   │ Calm, nature                             │
  ├──────────────┼──────┼──────────────────────────────────────────┤
  │ Lo-fi Beat   │ 🎵   │ Creative work                            │
  └──────────────┴──────┴──────────────────────────────────────────┘

  Each track: Volume slider 0–100%. Default 0% (off).

  Controls:

  ┌───────────────┬──────────────────────────────────────────────────────────────────┐
  │    Element    │                             Behavior                             │
  ├───────────────┼──────────────────────────────────────────────────────────────────┤
  │ Save Mix      │ Name the custom mix → saved                                      │
  ├───────────────┼──────────────────────────────────────────────────────────────────┤
  │ Mix presets   │ System: "Rain + Fireplace," "Ocean + Forest" · User custom saves │
  ├───────────────┼──────────────────────────────────────────────────────────────────┤
  │ Master volume │ Global slider                                                    │
  ├───────────────┼──────────────────────────────────────────────────────────────────┤
  │ Timer         │ "Play for 30 min / 1 hr / Until I stop"                          │
  ├───────────────┼──────────────────────────────────────────────────────────────────┤
  │ Reset all     │ One-tap clears all tracks to 0%                                  │
  └───────────────┴──────────────────────────────────────────────────────────────────┘

  Floating mini-player: When ambient is playing but user navigates away:

  ┌────────────────────────────────────────────────────────────┐
  │ 🔊 Rain · Brown Noise    [◀] [⏸️] [▶] [✕]                  │
  └────────────────────────────────────────────────────────────┘

  ---
  📝 Today's Reflection

  What it is: Soft-prompt reflection that appears on Rest after a session is completed.

  ┌────────────────────────────────────────────────────────────────────┐
  │ TODAY'S REFLECTION                                               │
  ├────────────────────────────────────────────────────────────────────┤
  │  "What clicked today?"                                           │
  │  [________________________________________________________]     │
  │                                                                    │
  │  "What drained you?"                                             │
  │  [________________________________________________________]     │
  │                                                                    │
  │                    [Save Reflection]                               │
  └────────────────────────────────────────────────────────────────────┘

  Prompts are context-aware:

  ┌─────────────────┬────────────────────────────────────────────────────────────────┬────────────────────────────┐
  │      After      │                            Prompt 1                            │          Prompt 2          │
  ├─────────────────┼────────────────────────────────────────────────────────────────┼────────────────────────────┤
  │ Focus session   │ "What clicked today?"                                          │ "What drained you?"        │
  ├─────────────────┼────────────────────────────────────────────────────────────────┼────────────────────────────┤
  │ Body double     │ "How did the session feel?"                                    │ "Would you do it again?"   │
  ├─────────────────┼────────────────────────────────────────────────────────────────┼────────────────────────────┤
  │ Morning block   │ "Morning done. How's the day shaping up?"                      │ "What's your energy like?" │
  ├─────────────────┼────────────────────────────────────────────────────────────────┼────────────────────────────┤
  │ No sessions yet │ "No sessions today. Want to capture anything before you rest?" │ —                          │
  └─────────────────┴────────────────────────────────────────────────────────────────┴────────────────────────────┘

  Behavior: Saves to Session Notes → tagged #daily-reflection. User can skip all questions — no nagging.

  States:

  ┌────────────────────────┬────────────────────────────────────────────────────┐
  │         State          │                       Visual                       │
  ├────────────────────────┼────────────────────────────────────────────────────┤
  │ Active (after session) │ Card visible, "Save" button active                 │
  ├────────────────────────┼────────────────────────────────────────────────────┤
  │ Skipped                │ Card hidden until next session                     │
  ├────────────────────────┼────────────────────────────────────────────────────┤
  │ Already reflected      │ "Reflected ✓" chip replaces card, tap to view/edit │
  └────────────────────────┴────────────────────────────────────────────────────┘

  ---
  🔥 Rest Streak

  What it is: A positive rest counter — tracks days you gave yourself genuine rest. Anti-shame mechanic: rewards rest, not just productivity.

  ┌────────────────────────────────────────────────────────────────────┐
  │                           🔥 14                                  │
  │                       Days of real rest                          │
  │                                                                    │
  │  ● ● ● ● ● ● ● ● ● ● ● ● ● ● ○ ○ ○ ○ ○ ○                         │
  │                                                                    │
  │  This week: 5/7 days                                              │
  └────────────────────────────────────────────────────────────────────┘

  What counts as a rest day:
  - Completing Wind-Down routine, OR
  - Completing 2+ Breathing sessions, OR
  - Completing 3+ Micro-Breaks

  Anti-shaming rules:
  - Streak does NOT break if you miss a day — shows "Last rest: 3 days ago"
  - No red warnings, no penalty language
  - Never shared, never compared
  - Past rest days are never retroactively counted

  Milestones: First rest · 1 week · 2 weeks · 1 month · 100 days (locked, aspirational)

  ---
  Rest FAB (+)

  Radial menu with 4 quick options:

                [Breathing]
                     ↑
                     │
  [Templates]  ←  [+]  →  [Micro-Break]
                     ↓
               [Reflection]

  ┌─────────────┬──────────────────────────────────┐
  │   Option    │              Opens               │
  ├─────────────┼──────────────────────────────────┤
  │ Breathing   │ Breathing Timer (Patterns sheet) │
  ├─────────────┼──────────────────────────────────┤
  │ Micro-Break │ Break selector sheet             │
  ├─────────────┼──────────────────────────────────┤
  │ Templates   │ Saved custom routines            │
  ├─────────────┼──────────────────────────────────┤
  │ Reflection  │ Quick reflection input           │
  └─────────────┴──────────────────────────────────┘

  Design rationale: Rest needs to be faster to access than starting a focus session. The radial menu gives one-tap access to all rest tools.

  ---
  Part 3: Navigation & System

  ---
  Bottom Navigation Bar

  ┌─────────┬───────────────────────┬─────────┬───────────────────┐
  │   Tab   │         Icon          │  Label  │ Color when active │
  ├─────────┼───────────────────────┼─────────┼───────────────────┤
  │ Focus   │ Target/crosshair icon │ Focus   │ Amber #F5B800     │
  ├─────────┼───────────────────────┼─────────┼───────────────────┤
  │ Flow    │ Play/stream icon      │ Flow    │ Amber #F5B800     │
  ├─────────┼───────────────────────┼─────────┼───────────────────┤
  │ Library │ Bookmark grid icon    │ Library │ Amber #F5B800     │
  ├─────────┼───────────────────────┼─────────┼───────────────────┤
  │ Rest    │ Moon/leaf icon        │ Rest    │ Amber #F5B800     │
  └─────────┴───────────────────────┴─────────┴───────────────────┘

  Design:
  - 4 tabs only — no more, no less
  - Active tab: Amber icon + label
  - Inactive tab: Slate Gray icon, no label
  - Height: 56dp
  - Safe area padding: 8dp bottom on notched devices
  - No notification dots on any tab

  ---
  Task Detail Sheet (Bottom Sheet)

  Triggered by tapping any task card:

  ┌────────────────────────────────────────────────────────────────────┐
  │                                                                    │
  │  ─── (drag handle) ───                                             │
  │                                                                    │
  │  Task name (editable)                                              │
  │                                                                    │
  │  ┌────────────────────────────────────────────────────────────┐    │
  │  │ Energy: [⚡ Quick] [🧠 Deep] [🪫 Low] [None]              │    │
  │  └────────────────────────────────────────────────────────────┘    │
  │                                                                    │
  │  Estimated time: [___] min                                        │
  │  Note: [________________________]                                 │
  │  Tags: [+] Add tag                                                │
  │                                                                    │
  │  Move to: [Morning ▾] [Afternoon ▾] [Evening ▾] [Anytime ▾]      │
  │                                                                    │
  │  [⭐ Add to Favorites]                                             │
  │  [Mark Complete ✓]                                                │
  │  [🗑️ Delete]                                                       │
  │                                                                    │
  └────────────────────────────────────────────────────────────────────┘

  Drag handle: Bottom sheet can be dragged up for more detail, down to dismiss.
  Priority field: One-tap priority selector (High / Medium / Low) — shown as colored dot on task card if set.
  Link to role: Can optionally link this task to a specific job role from the Resume module.

  ---
  Task Capture Sheet (FAB Sheet)

  Opens when FAB (+) is tapped on Today screen:

  ┌────────────────────────────────────────────────────────────────────┐
  │                                                                    │
  │  ─── (drag handle) ───                                             │
  │                                                                    │
  │  [What do you want to do?]                                         │
  │                                                                    │
  │  ┌────────────────────────────────────────────────────────────┐    │
  │  │                                                             │    │
  │  │                                                             │    │
  │  └─────────────────────────────────────────────────────────────┘    │
  │                                                                    │
  │  Energy: [⚡ Quick] [🧠 Deep] [🪫 Low] [None]                     │
  │  Estimated time: [___] min                                         │
  │                                                                    │
  │  [Save & Add to Anytime ✓]                                         │
  │                                                                    │
  └────────────────────────────────────────────────────────────────────┘

  - Keyboard auto-shows on open
  - Auto-focus on text field
  - Quick energy tag selection below text field
  - "Save & Add to Anytime" is the primary action (default destination)

  ---
  Color Summary (Full Palette)

  Primary        #1A1A2E  (Deep Slate)       — Headers, active states
  Primary Var    #16213E  (Navy)             — Hover states
  Accent         #F5B800  (Warm Amber)       — CTAs, FAB, active chips
  Accent Alt     #0F969C  (Electric Teal)     — Energy Deep, rest elements
  Surface        #F8F9FA  (Off-White)         — Card backgrounds
  Surface Alt   #EEF0F4  (Cool Gray)         — Input fields, Anytime Pool
  Block Past     #D1D5DB  (Muted Gray)        — Past M/A/E blocks
  Block Current  #FFFFFF  (White)            — Active block
  Block Future  #F8F9FA  (Surface White)      — Future block
  Text Primary  #1A1A2E  (Charcoal)          — Headings, body
  Text Secondary #64748B  (Slate Gray)        — Subtitles, metadata
  Text Muted    #9CA3AF  (Light Gray)        — Past block text
  Success       #22C55E  (Signal Green)      — Completion states
  Energy Quick  #FFD9A8  (Warm Amber Light)  — ⚡ chip bg
  Energy Deep   #C4E8D4  (Soft Sage)          — 🧠 chip bg
  Energy Low    #A8C5E2  (Soft Blue)          — 🪫 chip bg
  Error         #DC2626  (Crimson)           — Critical errors only
  Rest Zone     #0D4F4F  (Deep Teal)         — Rest hero, wind-down mode

  ---
  Typography Summary

  Montserrat  ExtraBold (800)  — Display, H1, screen titles
  Montserrat  Bold (700)      — H2, section headers
  Montserrat  SemiBold (600) — H3, section labels, tab names
  Inter       Regular (400)   — Body text, form inputs, metadata
  Inter       Medium (500)    — Labels, captions, chips
  JetBrains Mono (400)       — Timers, counters, elapsed time