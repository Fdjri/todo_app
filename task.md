# Material → shadcn_flutter Migration

## Phase 1: Foundation
- [x] `pubspec.yaml` — shadcn_flutter sudah ada
- [x] `shadcn_theme.dart` — sudah ada (akan di-enhance)
- [x] `theme_bloc.dart` — sudah ada ChangeThemeColor + ChangeFontStyle
- [x] `coquette_theme.dart` — sudah parameterized
- [x] `dark_theme.dart` — sudah parameterized
- [x] `app_typography.dart` — sudah font family swappable
- [x] `app.dart` — MaterialApp → ShadcnApp

## Phase 2: Core Widgets
- [x] `permission_onboarding_dialog.dart` — Dialog/Button → shadcn
- [x] `coquette_card.dart` — → shadcn Card
- [x] `empty_state.dart` — typography update

## Phase 3: Task Feature
- [x] `add_task_page.dart` — TextField/Select/Switch/Button
- [x] `task_detail_page.dart` — Scaffold/AppBar/Dialog/Button/Progress
- [x] `home_page.dart` — SnackBar→Toast, Chip, IconButton, Progress
- [x] `task_card_widget.dart` — LinearProgressIndicator → Progress
- [x] `sub_task_item_widget.dart` — IconButton → shadcn
- [x] `quick_add_fab_widget.dart` — FAB → shadcn Button
- [x] `category_filter_bar_widget.dart` — Chip → shadcn

## Phase 4: Shell & Pages
- [x] `main_shell.dart` — Scaffold/FAB/BottomSheet
- [x] `history_page.dart` — Scaffold/BottomSheet
- [x] `settings_page.dart` — Switch/Select/Divider + wire ThemeBloc

## Phase 5: Alarm
- [x] `alarm_page.dart` — Scaffold update

## Phase 6: Verify
- [x] `flutter analyze` — bersih ✅
