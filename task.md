# 🎀 Workaholic — Build Tasks

## Phase 1: Project Scaffolding with fca-cli
- [x] Scaffold task feature
- [x] Scaffold category feature
- [x] Scaffold notification feature
- [x] Scaffold gamification feature
- [x] Add all entities, models, datasources, repos, use cases, blocs, pages, widgets
- [x] Clean up duplicate fca-cli scaffold files

## Phase 2: Dependencies
- [x] Update pubspec.yaml with all dependencies
- [x] Create asset directories (lottie, sounds, images)
- [x] Run flutter pub get

## Phase 3: Core Layer
- [x] app_colors.dart
- [x] app_typography.dart
- [x] app_strings.dart
- [x] app_assets.dart
- [x] coquette_theme.dart (light)
- [x] dark_theme.dart
- [x] theme_bloc.dart
- [x] sound_service.dart
- [x] Core widgets (confetti, progress ring, bow divider, empty state, pearl checkbox, coquette card)
- [x] Core utils (date formatter, id generator)
- [x] failures.dart

## Phase 4: Feature Implementation
- [x] Task entity & models (task_entity.dart, task_model.dart)
- [x] Task datasource & repository (task_local_datasource.dart, task_repository.dart, task_repository_impl.dart)
- [x] Task BLoC (task_bloc.dart — events, states, bloc combined)
- [x] Task pages (home_page.dart, add_task_page.dart, task_detail_page.dart)
- [x] Task widgets — all implemented:
  - [x] task_card_widget.dart
  - [x] task_list_widget.dart
  - [x] sub_task_item_widget.dart
  - [x] priority_selector_widget.dart
  - [x] quick_add_fab_widget.dart
  - [x] category_filter_bar_widget.dart
- [x] Category entity, model, datasource, repo, BLoC
- [x] Category widgets — all implemented:
  - [x] category_chip_widget.dart
  - [x] category_picker_sheet_widget.dart
- [x] Notification alarm screen — implemented:
  - [x] alarm_screen_page.dart (full-screen alarm with Lottie + sound)
- [x] Gamification entity, datasource, BLoC
- [x] Gamification widgets — all implemented:
  - [x] streak_counter_widget.dart
  - [x] level_badge_widget.dart
  - [x] achievement_card_widget.dart
  - [x] xp_progress_bar_widget.dart

## Phase 5: App Shell & Routing
- [x] injection_container.dart
- [x] app.dart
- [x] main.dart

## Phase 6: Lottie Animations
- [x] Create Lottie JSON files (confetti, sparkle, loading_bow, empty_state)
- [x] Wire up confetti overlay (in home_page.dart)
- [x] Wire up empty state animation (in empty_state.dart)

## Phase 7: Sound Effects
- [x] Create sound service (sound_service.dart)
- [x] Create placeholder sound files (.wav)
- [x] Wire up sound triggers (in home_page, task_detail_page)

## Phase 8: Dark Theme
- [x] ThemeBloc implementation (theme_bloc.dart)
- [x] Theme persistence (SharedPreferences)
- [x] Dark mode toggle button (in home_page header)

## Verification
- [x] Fix test/widget_test.dart (references WorkaholicApp correctly)
- [x] flutter analyze — 0 issues found ✅
- [x] Fix android/app/build.gradle.kts — enable core library desugaring (flutter_local_notifications)
- [x] Set minSdk = 21 (required by android_alarm_manager_plus)
- [x] flutter build apk --debug — ✅ BUILD SUCCESSFUL
  - APK: build\app\outputs\flutter-apk\app-debug.apk

## 🎀 PROJECT COMPLETE!
