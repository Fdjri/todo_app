# 🎀 Workaholic — Coquette To-Do List App Implementation

> Build a playful coquette-themed to-do list Flutter app with Clean Architecture, BLoC state management, Lottie animations, dark theme, and sound effects.

---

## Background & Context

The project has two existing design documents:
- [implementation_plan.md](file:///d:/Private/Firly/workaholic/implementation_plan.md) — Full PRD with features, data models, and architecture
- [design_system.md](file:///d:/Private/Firly/workaholic/design_system.md) — Visual design specs (colors, typography, components, layouts)

### Key Changes from Original Plan
The user has requested the following modifications:

| Original Plan | User's Request |
|---------------|----------------|
| Shadcn UI (`ShadApp`) | **MaterialApp** (standard Flutter) |
| Riverpod or BLoC (open question) | **Flutter BLoC** (confirmed) |
| `flutter_animate` (code-based) | **Lottie** (pre-designed JSON animations) |
| Dark mode (open question) | **Dark theme** (confirmed, must include) |
| Sound effects (open question) | **Sound effects** (confirmed, `audioplayers`) |
| Manual directory creation | **fca-cli** for clean architecture scaffolding |

> [!IMPORTANT]
> Since the user chose **Flutter BLoC** + **Lottie** + **Dark theme** + **Sound effects**, these override the original plan's open questions. We also drop `shadcn_ui` and use standard **MaterialApp** with custom coquette theming, since Lottie and BLoC work seamlessly with Material.

---

## Phase 1: Project Scaffolding with fca-cli

Use `npx fca-cli@latest` to scaffold the clean architecture features:

```bash
# Scaffold 4 features
npx fca-cli@latest add-feature task
npx fca-cli@latest add-feature category
npx fca-cli@latest add-feature notification
npx fca-cli@latest add-feature gamification
```

Then add specific components within each feature:

### Task Feature
```bash
npx fca-cli@latest add-entity task task
npx fca-cli@latest add-entity task sub_task
npx fca-cli@latest add-model task task
npx fca-cli@latest add-model task sub_task
npx fca-cli@latest add-data-source task task_local
npx fca-cli@latest add-repository task task
npx fca-cli@latest add-use-case task get_all_tasks task
npx fca-cli@latest add-use-case task add_task task
npx fca-cli@latest add-use-case task update_task task
npx fca-cli@latest add-use-case task delete_task task
npx fca-cli@latest add-use-case task toggle_task_completion task
npx fca-cli@latest add-use-case task toggle_subtask_completion task
npx fca-cli@latest add-use-case task get_tasks_by_category task
npx fca-cli@latest add-bloc task task
npx fca-cli@latest add-page task home
npx fca-cli@latest add-page task task_detail
npx fca-cli@latest add-page task add_task
npx fca-cli@latest add-widget task task_card
npx fca-cli@latest add-widget task task_list
npx fca-cli@latest add-widget task sub_task_item
npx fca-cli@latest add-widget task priority_selector
npx fca-cli@latest add-widget task quick_add_fab
npx fca-cli@latest add-widget task category_filter_bar
```

### Category Feature
```bash
npx fca-cli@latest add-entity category category
npx fca-cli@latest add-model category category
npx fca-cli@latest add-data-source category category_local
npx fca-cli@latest add-repository category category
npx fca-cli@latest add-use-case category get_all_categories category
npx fca-cli@latest add-use-case category add_category category
npx fca-cli@latest add-use-case category delete_category category
npx fca-cli@latest add-bloc category category
npx fca-cli@latest add-widget category category_chip
npx fca-cli@latest add-widget category category_picker_sheet
```

### Notification Feature
```bash
npx fca-cli@latest add-data-source notification notification_local
npx fca-cli@latest add-repository notification notification
npx fca-cli@latest add-use-case notification schedule_notification notification
npx fca-cli@latest add-use-case notification cancel_notification notification
npx fca-cli@latest add-use-case notification schedule_alarm notification
npx fca-cli@latest add-bloc notification notification
npx fca-cli@latest add-page notification alarm_screen
```

### Gamification Feature
```bash
npx fca-cli@latest add-entity gamification streak
npx fca-cli@latest add-entity gamification achievement
npx fca-cli@latest add-entity gamification user_stats
npx fca-cli@latest add-model gamification streak
npx fca-cli@latest add-model gamification achievement
npx fca-cli@latest add-model gamification user_stats
npx fca-cli@latest add-data-source gamification gamification_local
npx fca-cli@latest add-repository gamification gamification
npx fca-cli@latest add-use-case gamification get_current_streak gamification
npx fca-cli@latest add-use-case gamification update_streak gamification
npx fca-cli@latest add-use-case gamification add_xp gamification
npx fca-cli@latest add-use-case gamification get_user_level gamification
npx fca-cli@latest add-use-case gamification check_achievements gamification
npx fca-cli@latest add-bloc gamification gamification
npx fca-cli@latest add-widget gamification streak_counter
npx fca-cli@latest add-widget gamification level_badge
npx fca-cli@latest add-widget gamification achievement_card
npx fca-cli@latest add-widget gamification xp_progress_bar
```

---

## Phase 2: Dependencies (pubspec.yaml)

### [MODIFY] [pubspec.yaml](file:///d:/Private/Firly/workaholic/pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^9.0.0
  equatable: ^2.0.7

  # Local Storage
  shared_preferences: ^2.3.0

  # Dependency Injection
  get_it: ^8.0.0

  # Notifications
  flutter_local_notifications: ^18.0.0
  android_alarm_manager_plus: ^4.0.0
  timezone: ^0.10.0
  permission_handler: ^11.0.0

  # Animations (Lottie)
  lottie: ^3.3.1

  # Sound Effects
  audioplayers: ^6.1.0

  # Utilities
  uuid: ^4.0.0
  intl: ^0.19.0

  # Fonts
  google_fonts: ^6.2.0

  # Home Screen Widget
  home_widget: ^0.7.0
```

### Assets Setup

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/lottie/
    - assets/sounds/
    - assets/images/
```

Lottie animation files to include:
- `confetti.json` — Task completion celebration
- `sparkle.json` — Level up / achievement unlock
- `bow_loading.json` — Loading indicator
- `empty_state.json` — Cute empty state animation
- `alarm_pulse.json` — Alarm screen pulsing

Sound effect files:
- `task_complete.mp3` — Soft satisfying chime
- `level_up.mp3` — Achievement fanfare
- `button_tap.mp3` — Subtle tap feedback
- `delete.mp3` — Soft swoosh for deletion

---

## Phase 3: Core Layer

### [NEW] `lib/core/constants/app_colors.dart`
Coquette color palette with **both light and dark mode** tokens as specified in design system:
- Light: Rose Pink `#E8A0BF`, Warm White `#FFF8F9`, Gold `#C9A96E`, etc.
- Dark (Midnight Coquette): `#1A1118`, `#241920`, `#D4789C`, etc.

### [NEW] `lib/core/constants/app_typography.dart`
Google Fonts: `Playfair Display`, `Nunito`, `Dancing Script` with the full type scale from design system.

### [NEW] `lib/core/constants/app_strings.dart`
Motivational quotes pool, UI string constants, category defaults.

### [NEW] `lib/core/constants/app_assets.dart`
Centralized paths for Lottie files, sound files, images.

### [NEW] `lib/core/theme/coquette_theme.dart`
Full `ThemeData` for light mode with coquette colors, custom `ColorScheme`, input decorations, card themes.

### [NEW] `lib/core/theme/dark_theme.dart`
Full `ThemeData` for dark mode (Midnight Coquette — deep wine/burgundy tones).

### [NEW] `lib/core/theme/theme_bloc.dart`
BLoC for toggling between light/dark themes.

### [NEW] `lib/core/services/sound_service.dart`
Singleton service using `audioplayers` for playing sound effects on task completion, level up, etc.

### [NEW] `lib/core/widgets/`
- `confetti_overlay.dart` — Lottie confetti animation overlay
- `progress_ring.dart` — Animated circular progress with CustomPainter
- `bow_divider.dart` — Decorative bow divider using CustomPaint
- `empty_state.dart` — Lottie empty state with random motivational quotes
- `mood_selector.dart` — Emoji mood picker
- `pearl_checkbox.dart` — Custom coquette-style circular checkbox
- `coquette_card.dart` — Styled card with lace border + pink shadows

### [NEW] `lib/core/utils/`
- `date_formatter.dart` — Date/time formatting helpers
- `id_generator.dart` — UUID generation
- `json_helper.dart` — JSON encode/decode utilities

### [NEW] `lib/core/errors/failures.dart`
Failure/exception classes for clean architecture error handling.

---

## Phase 4: Feature Implementation

### Task Feature (Core)
Implement full CRUD with sub-tasks. Each file generated by fca-cli will be filled with:

- **Entities**: `TaskEntity` + `SubTaskEntity` with all fields from PRD
- **Models**: JSON serialization for SharedPreferences
- **DataSource**: SharedPreferences CRUD with JSON encoding
- **Repository**: Abstract interface + implementation
- **Use Cases**: 7 use cases (get all, add, update, delete, toggle, filter)
- **BLoC**: `TaskBloc` with events/states for loading, CRUD, filtering, completion
- **Pages**:
  - `HomePage` — Main dashboard with greeting, progress ring, streak, category tabs, task list, FAB
  - `AddTaskPage` — Bottom sheet form for creating tasks
  - `TaskDetailPage` — Detail view with sub-tasks, edit, delete
- **Widgets**: Task card (swipe gestures), task list, sub-task item, priority selector, quick-add FAB, category filter bar

### Category Feature
- **Entity/Model**: Category with emoji + color
- **Pre-defined 8 categories** seeded on first launch
- **Custom categories** with emoji and color picker
- **BLoC**: Category loading, adding, deleting

### Notification Feature
- **flutter_local_notifications** setup with 2 channels
- **Schedule/cancel** notifications per task
- **Alarm screen** full-screen notification for urgent tasks
- **Custom notification sound** (soft chime)

### Gamification Feature
- **Streak tracking** (consecutive days)
- **XP/Level system** (7 levels from Newbie to CEO Energy)
- **Achievement badges** (milestones)
- **BLoC**: Manages streaks, XP, level, achievements reactively
- **Widgets**: Streak counter, level badge, achievement card, XP progress bar

---

## Phase 5: App Shell & Routing

### [MODIFY] [main.dart](file:///d:/Private/Firly/workaholic/lib/main.dart)
Initialize: GetIt DI, notification service, timezone, sound service → run `MaterialApp`.

### [NEW] `lib/app.dart`
Root `MaterialApp` with:
- BLoC providers for all features + theme
- Coquette theme (light/dark based on ThemeBloc)
- Route configuration

### [NEW] `lib/injection_container.dart`
GetIt setup registering all datasources, repos, use cases, and blocs.

### [NEW] `lib/config/routes/app_router.dart`
Named routes for all pages.

---

## Phase 6: Lottie Animations

Download/create Lottie JSON files for:
1. **Confetti burst** — plays on task completion
2. **Sparkle/star** — level up celebration
3. **Empty box with bow** — empty state cute animation
4. **Pulsing alarm** — alarm screen background
5. **Loading bow** — loading indicator

These will be stored in `assets/lottie/` and played via the `lottie` package with `LottieBuilder.asset()`.

---

## Phase 7: Sound Effects

Using `audioplayers` package:
- Generate simple sound effect placeholder files
- `SoundService` singleton with methods: `playTaskComplete()`, `playLevelUp()`, `playButtonTap()`, `playDelete()`
- Triggered from BLoC events or widget callbacks

---

## Phase 8: Dark Theme

- `ThemeBloc` with `ToggleThemeEvent` and states `LightThemeState` / `DarkThemeState`
- Theme preference persisted in SharedPreferences
- Settings page or toggle in home page header
- Dark palette: Velvet Night `#1A1118`, Dark Plum `#241920`, Warm Rose `#D4789C`

---

## Verification Plan

### Build & Run
```bash
flutter pub get
flutter run
```

### Manual Verification
1. Task CRUD — create, edit, complete, delete tasks
2. Sub-tasks — individual completion, parent auto-complete
3. Categories — filter, create custom, verify display
4. Dark theme — toggle, verify all screens look correct
5. Lottie animations — confetti on complete, empty state, loading
6. Sound effects — chime on task complete, level up sound
7. Gamification — streaks, XP, level, achievements
8. Notifications — schedule, fire, alarm screen

### Automated Tests
```bash
flutter test
```

---

## Open Questions

> [!IMPORTANT]
> **Home Screen Widget**: The home widget requires native Android XML layouts + Kotlin code. Should we include this in the initial build, or defer to a later phase? It adds significant complexity.

> [!NOTE]
> **Lottie files**: For the Lottie animations, I'll create custom JSON files programmatically (simple particle/confetti effects). For more elaborate animations, you could later replace them with LottieFiles.com downloads.

> [!NOTE]
> **Sound files**: I'll generate minimal placeholder sound effects. You can later replace them with custom audio from freesound.org or similar.
