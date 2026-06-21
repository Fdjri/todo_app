# 🎀 Workaholic — Design System (Design MD)

> Visual language specification for the Coquette To-Do List experience.

---

## 1. Design Philosophy

The **Coquette** aesthetic merges French femininity with modern minimalism. Think: **soft but not weak, decorative but not cluttered, playful but not childish.**

### Mood Keywords
`romantic` · `delicate` · `empowering` · `luxe-casual` · `whimsical` · `self-care`

### Visual References
- Soft ribbon bows as UI accents
- Pearl-like circular elements (radio buttons, checkboxes, avatars)
- Lace-inspired border patterns on cards
- Watercolor wash backgrounds
- Gold foil accent details

---

## 2. Color System

### 2.1 Primary Palette

```
┌─────────────────────────────────────────────────────────────┐
│  LIGHT MODE                                                  │
│                                                              │
│  ██ Primary       #E8A0BF  Rose Pink                        │
│  ██ Primary Dark  #D4789C  Dusty Rose                       │
│  ██ Blush         #F5D5E0  Cotton Candy                     │
│  ██ Cream         #FCE4EC  Cream Pink                       │
│  ██ Background    #FFF8F9  Warm Porcelain                   │
│  ██ Surface       #FFFFFF  Pure White                       │
│  ██ Gold Accent   #C9A96E  Antique Gold                     │
│  ██ Text Primary  #3D2232  Deep Plum                        │
│  ██ Text Body     #5A4350  Muted Mauve                      │
│  ██ Text Hint     #A68E9A  Soft Lavender                    │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│  DARK MODE (Midnight Coquette)                               │
│                                                              │
│  ██ Primary       #D4789C  Warm Rose                        │
│  ██ Primary Dark  #C0577A  Deep Rose                        │
│  ██ Blush         #3D2232  Dark Wine                        │
│  ██ Cream         #2A1822  Burgundy Black                   │
│  ██ Background    #1A1118  Velvet Night                     │
│  ██ Surface       #241920  Dark Plum                        │
│  ██ Gold Accent   #D4B87A  Warm Gold                        │
│  ██ Text Primary  #FFF0F5  Lavender Blush                   │
│  ██ Text Body     #D4AEBE  Pink Mist                        │
│  ██ Text Hint     #8A6B7A  Twilight Mauve                   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Semantic Colors

| Purpose | Light | Dark |
|---------|-------|------|
| Success (completed) | `#A8D8B9` Sage Green | `#6DAF85` Forest |
| Warning (overdue) | `#FFD4A8` Peach | `#E5A66B` Amber |
| Error (delete) | `#E57373` Coral | `#CF6679` Rose Red |
| Info | `#B8CCE3` Baby Blue | `#7BA3CC` Steel Blue |

### 2.3 Category Colors

| Category | Color | Emoji |
|----------|-------|-------|
| Self Care | `#F5D5E0` | 🧖 |
| Work | `#D4C5F9` | 💼 |
| Study | `#B8CCE3` | 📚 |
| Errands | `#FFD4A8` | 🛒 |
| Social | `#FFB3BA` | 👯 |
| Health | `#A8D8B9` | 🏃‍♀️ |
| Creative | `#F9E4B7` | 🎨 |
| Home | `#C9DCD2` | 🏠 |

---

## 3. Typography

### 3.1 Font Stack

```
Headings:    Playfair Display (serif)     — Weight: 600, 700
Body:        Nunito (sans-serif, rounded) — Weight: 400, 600, 700
Accent:      Dancing Script (cursive)     — Weight: 400, 700
Monospace:   JetBrains Mono              — For timestamps
```

### 3.2 Type Scale

| Style | Font | Size | Weight | Line Height | Usage |
|-------|------|------|--------|-------------|-------|
| Display | Playfair Display | 28sp | 700 | 1.3 | Greeting "Hey, queen! 👑" |
| H1 | Playfair Display | 24sp | 700 | 1.3 | Page titles |
| H2 | Playfair Display | 20sp | 600 | 1.3 | Section headers |
| H3 | Nunito | 18sp | 700 | 1.4 | Card titles |
| Body | Nunito | 16sp | 400 | 1.5 | Task descriptions |
| Body Bold | Nunito | 16sp | 700 | 1.5 | Emphasis text |
| Caption | Nunito | 14sp | 400 | 1.4 | Timestamps, metadata |
| Small | Nunito | 12sp | 600 | 1.3 | Badges, labels |
| Quote | Dancing Script | 18sp | 400 | 1.5 | Motivational quotes |
| Quote Large | Dancing Script | 24sp | 700 | 1.3 | Empty state messages |

---

## 4. Spacing & Sizing

### 4.1 Spacing Scale (8pt grid)

```
xxs:   4dp
xs:    8dp
sm:    12dp
md:    16dp
lg:    24dp
xl:    32dp
xxl:   48dp
```

### 4.2 Border Radius

```
xs:    4dp   — Small chips, tags
sm:    8dp   — Buttons, inputs
md:    12dp  — Cards
lg:    16dp  — Bottom sheets
xl:    24dp  — Rounded containers
full:  999dp — Circular elements (FAB, avatars)
```

### 4.3 Icon Sizes

```
xs:    16dp  — Inline icons
sm:    20dp  — Button icons
md:    24dp  — Standard icons
lg:    32dp  — Feature icons
xl:    48dp  — Empty state illustrations
hero:  64dp  — Achievement badges
```

---

## 5. Component Specifications

### 5.1 Task Card (`ShadCard`)

```
┌────────────────────────────────────────────┐
│  ┌──┐                                      │
│  │✓ │  Buy groceries for dinner   🛒       │
│  └──┘  Due today at 5:00 PM               │
│        ━━━━━━━━━━━━━ 2/3 subtasks          │
│        ┌─┐ Vegetables  ┌─┐ Fruits          │
│        └─┘ ✓           └─┘                  │
│                              ⚡ High        │
└────────────────────────────────────────────┘

• Background: surface color
• Border: 1dp solid blush color, rounded md (12dp)
• Shadow: 0dp 2dp 8dp rgba(232,160,191, 0.15)
• Checkbox: circular (pearl-style), primary color fill
• Priority indicator: colored dot (bottom-right)
  - Low: sage  |  Medium: blush  |  High: peach  |  Urgent: coral pulse
• Swipe left: delete (coral bg + trash icon)
• Swipe right: complete (sage bg + check icon)
• On complete: checkbox fills with confetti burst, card fades with scale-down
```

### 5.2 Quick Add FAB

```
     ┌─────┐
     │  +  │  56dp circular
     │ 🎀  │  Bow icon overlay (subtle)
     └─────┘
     
• Background: gradient(primary → primaryDark)
• Shadow: 0dp 4dp 12dp rgba(232,160,191, 0.4)
• Icon: + with rotate animation on tap
• Long press: shows quick-add tooltip "Add a task, bestie!"
• Idle animation: subtle floating bounce (2dp vertical, 3s loop)
```

### 5.3 Category Filter Bar

```
┌──────────────────────────────────────────────────────────┐
│  [All ✨] [Self Care 🧖] [Work 💼] [Study 📚] [+ Add]  │
└──────────────────────────────────────────────────────────┘

• Horizontal scroll
• Active: filled primary with white text
• Inactive: outlined with blush border, body text color
• Each chip: rounded-full, padding sm horizontal, xs vertical
• "+ Add" chip: dashed border, hint text color
```

### 5.4 Progress Ring (Daily Completion)

```
        ╭──────╮
       ╱  72%   ╲
      │  ✨      │   60dp diameter
       ╲        ╱    Ring: 6dp stroke
        ╰──────╯     
      Today's vibe

• Track color: blush (light) / dark wine (dark)
• Progress color: animated gradient (primary → gold accent)
• Center: completion percentage with sparkle emoji
• Below: "Today's vibe" caption
• Animation: ease-in-out fill on data load (800ms)
• At 100%: ring turns gold, sparkle animation plays
```

### 5.5 Streak Counter

```
  🔥 7 days streak!
  ━━━━━━━━━━━━━━━

• Inline with greeting header
• Flame emoji scales up briefly when streak increments
• Text: Nunito Bold, gold accent color
• Below 3 days: no fire, shows "Start your streak! ✨"
• 7+ days: 🔥🔥 double fire
• 30+ days: 🔥🔥🔥 triple fire + gold badge glow
```

### 5.6 Empty State

```
  ┌───────────────────────────────┐
  │                               │
  │        🎀                     │
  │    ╱╲  ╱╲  ╱╲               │
  │                               │
  │  "No tasks yet, bestie!       │
  │   Time to slay your day ✨"   │
  │                               │
  │  [ + Add your first task ]    │
  │                               │
  └───────────────────────────────┘

• Dancing Script font for quote
• Soft fade-in animation
• Random quotes from pool:
  - "All caught up! You ate that 💅"
  - "Main character energy — no tasks pending ✨"
  - "Queen of getting things done 👑"
  - "Your to-do list? ✅ Defeated."
  - "Time to add new goals, bestie 🎯"
```

### 5.7 Level Badge

```
  ┌─────────────────────────────┐
  │  👸 Lv.5 Boss Babe          │
  │  ▓▓▓▓▓▓▓▓░░░░ 720/1000 XP  │
  └─────────────────────────────┘

Levels:
  Lv.1  (0-99 XP)      🌱 Newbie
  Lv.2  (100-299 XP)   💫 Rising Star
  Lv.3  (300-599 XP)   💪 Go-Getter
  Lv.4  (600-999 XP)   🔥 Hustler
  Lv.5  (1000-1499 XP) 💼 Boss Babe
  Lv.6  (1500-2499 XP) 👑 Queen
  Lv.7  (2500+ XP)     ✨ CEO Energy

• XP rewards: +10 per task, +5 per subtask, +25 streak bonus/day
• Level up: gold confetti animation + toast "Level up! You're now a Boss Babe! 💼"
```

---

## 6. Animations & Micro-interactions

| Action | Animation | Duration | Easing |
|--------|-----------|----------|--------|
| Task complete | Checkbox fill → confetti burst → card scale 0.95 → fade | 600ms | easeOutBack |
| Task add | Slide up from bottom + fade in | 350ms | easeOutCubic |
| Task delete | Slide out left + fade | 300ms | easeInCubic |
| FAB idle | Float up/down 2dp | 3000ms loop | easeInOutSine |
| FAB press | Scale 0.9 → 1.0 + icon rotate 90° | 200ms | easeOutBack |
| Progress ring fill | Arc draw from 0 to value | 800ms | easeOutCubic |
| Streak increment | Flame emoji scale 1.0 → 1.3 → 1.0 | 400ms | easeOutBack |
| Category tab switch | Fade cross + slide content | 250ms | easeInOut |
| Page transition | Shared axis (horizontal) | 300ms | easeInOutCubic |
| Level up | Gold confetti + badge pulse + toast slide up | 1200ms | spring |
| Pull to refresh | Bow icon rotates as pulling indicator | variable | linear |

---

## 7. Decorative Motifs

### 7.1 Bow Divider
```
    ╲    ╱
     ╲  ╱
━━━━━ ╲╱ ━━━━━
      ╱╲
     ╱  ╲

• Used as section divider
• Drawn via CustomPaint
• Stroke: 1.5dp, primary color with 0.3 opacity
• Width: fills parent, bow centered
```

### 7.2 Pearl Checkbox
```
  ┌───┐    ┌───┐
  │ ○ │ →  │ ● │
  └───┘    └───┘
  
• Unchecked: circle outline, blush border, pearl-like shine gradient
• Checked: filled primary with subtle inner glow
• Transition: scale bounce + fill animation
• Size: 24dp
```

### 7.3 Ribbon Badge (Priority)
```
  ┌──────┐
  │ High │╲
  │      │ ╲  (ribbon fold effect)
  └──────┘  │
            │
• Used for priority labels
• Background: priority color
• Right edge: ribbon fold shadow
• Text: white, Small style
```

---

## 8. Screen Layouts

### 8.1 Home Page

```
┌─────────────────────────────────────────┐
│ Status Bar                               │
├─────────────────────────────────────────┤
│                                          │
│  Hey, queen! 👑            🔥 7 days    │
│  Friday, June 20                         │
│                                          │
│     ╭──────╮    Lv.5 Boss Babe 💼       │
│    ╱  72%   ╲   ▓▓▓▓▓▓░░ 720/1000      │
│   │  ✨      │                           │
│    ╲        ╱                            │
│     ╰──────╯                             │
│                                          │
│  ── 🎀 ──────────────────── 🎀 ──       │
│                                          │
│  [All✨] [Self Care🧖] [Work💼] [...]   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │ ○  Buy groceries         🛒     │   │
│  │    Due today 5:00PM   ⚡High     │   │
│  │    ━━━━━━━━━ 2/3                 │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │ ● ̶F̶i̶n̶i̶s̶h̶ ̶r̶e̶p̶o̶r̶t̶         💼     │   │
│  │    Completed ✓             Done  │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │ ○  Yoga session          🏃‍♀️     │   │
│  │    Tomorrow 7:00AM   💚Low       │   │
│  └──────────────────────────────────┘   │
│                                          │
│                              ┌─────┐    │
│                              │  +  │    │
│                              │ 🎀  │    │
│                              └─────┘    │
│                                          │
├─────────────────────────────────────────┤
│  🏠 Home    📊 Stats    ⚙️ Settings    │
└─────────────────────────────────────────┘
```

### 8.2 Add Task Sheet (Bottom Sheet)

```
┌─────────────────────────────────────────┐
│  ── handle ──                            │
│                                          │
│  ✨ New Task                             │
│  ────────────────────────                │
│                                          │
│  Title *                                 │
│  ┌──────────────────────────────────┐   │
│  │ What do you need to do, babe?    │   │
│  └──────────────────────────────────┘   │
│                                          │
│  Description                             │
│  ┌──────────────────────────────────┐   │
│  │ Add details...                    │   │
│  │                                   │   │
│  └──────────────────────────────────┘   │
│                                          │
│  Category        Priority                │
│  ┌─────────┐     ┌─────────┐           │
│  │ Work 💼 ▾│    │ High ⚡ ▾│           │
│  └─────────┘     └─────────┘           │
│                                          │
│  Due Date         Due Time               │
│  ┌─────────┐     ┌─────────┐           │
│  │ 📅 Today │    │ 🕐 5:00  │           │
│  └─────────┘     └─────────┘           │
│                                          │
│  [Today] [Tomorrow] [Next Week]          │
│                                          │
│  🔔 Reminder   [ toggle ON ]            │
│  ⏰ Alarm       [ toggle OFF ]           │
│                                          │
│  Sub-tasks                               │
│  ┌──────────────────────────────────┐   │
│  │ + Add sub-task                    │   │
│  └──────────────────────────────────┘   │
│  ○ Buy vegetables                        │
│  ○ Get milk                              │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │       ✨ Add Task ✨              │   │
│  └──────────────────────────────────┘   │
│                                          │
└─────────────────────────────────────────┘
```

### 8.3 Alarm Screen (Full-screen)

```
┌─────────────────────────────────────────┐
│                                          │
│                                          │
│                                          │
│              ⏰                          │
│         (pulsing glow)                   │
│                                          │
│        It's time, bestie!                │
│                                          │
│     "Buy groceries for dinner"           │
│           🛒 Errands                     │
│          5:00 PM today                   │
│                                          │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │         ✅ Mark Done              │   │
│  └──────────────────────────────────┘   │
│                                          │
│  ┌──────────────────────────────────┐   │
│  │         ⏰ Snooze (15m)           │   │
│  └──────────────────────────────────┘   │
│                                          │
│         [ Dismiss ]                      │
│                                          │
│                                          │
└─────────────────────────────────────────┘

• Background: gradient(primaryDark → background)
• Alarm icon: pulsing scale animation with glow
• Vibration: pattern vibration while showing
• Sound: soft chime loop (coquette style)
```

### 8.4 Home Screen Widget

```
┌────────────────────────────────────────┐
│  🎀 Workaholic           72% ╭─╮      │
│  ─────────────────────────── │ │      │
│  ○ Buy groceries        5PM  ╰─╯      │
│  ● ̶F̶i̶n̶i̶s̶h̶ ̶r̶e̶p̶o̶r̶t̶      ✓           │
│  ○ Yoga session     7AM tmr           │
│  ─────────────────────────────────────│
│  🔥 7 days  |  3 tasks left today     │
└────────────────────────────────────────┘

• Background: semi-transparent surface with blur
• Border: 1dp blush rounded lg
• Progress ring: mini (24dp) aligned right
• Text: Nunito, compact spacing
• Tap opens app to home page
• Tap checkbox: toggles task completion via home_widget
```

---

## 9. Shadcn UI Component Mapping

| App Element | Shadcn Component | Customization |
|-------------|-----------------|---------------|
| Task card | `ShadCard` | Coquette border, pearl shadow |
| Add task form | `ShadForm` + `ShadInput` | Rose pink focus ring |
| Category selector | `ShadSelect` | Emoji prefixed options |
| Date picker | `ShadDatePicker` | Pink calendar accent |
| Time picker | `ShadTimePicker` | Rose highlight |
| Priority selector | `ShadRadioGroup` | Custom colored dots |
| Notification toggle | `ShadSwitch` | Primary color thumb |
| Task checkbox | `ShadCheckbox` | Pearl-style circular |
| Confirmation dialog | `ShadDialog` | Bow divider header |
| Success toast | `ShadToast` / Sonner | Green success with emoji |
| Bottom sheet | `ShadSheet` | Rounded top corners |
| Tab bar | `ShadTabs` | Pill-shaped, filled active |
| Tooltip | `ShadTooltip` | Blush background |
| Progress bar | `ShadProgress` | Gradient fill |
| Badges | `ShadBadge` | Ribbon-style variant |

---

## 10. Accessibility

- All colors meet WCAG AA contrast ratio (4.5:1 for text)
- Touch targets minimum 48dp × 48dp
- Semantic labels on all interactive elements
- Screen reader support for progress, streaks, achievements
- Reduced motion: disable all loop animations when system preference set
- Font scaling: supports up to 200% system font size
