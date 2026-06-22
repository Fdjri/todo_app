# Migrasi Penuh Material → shadcn_flutter + Settings Fungsional

Migrasi **seluruh** komponen Material yang digunakan secara eksplisit di codebase ke komponen shadcn_flutter, sekaligus membuat Theme Selection dan Font Style di Settings benar-benar berfungsi.

---

## 1. Dependencies & App Root

#### [MODIFY] [pubspec.yaml](file:///D:/Private/Firly/workaholic/pubspec.yaml)
- Tambah `shadcn_flutter: ^0.0.52`

#### [MODIFY] [app.dart](file:///D:/Private/Firly/workaholic/lib/app.dart)
- `MaterialApp` → `ShadcnApp`
- Pass `materialTheme:` (existing Material ThemeData, untuk backward compat)
- Pass `theme:` (shadcn ThemeData Coquette)
- `navigatorKey:` tetap dipertahankan

#### [NEW] [shadcn_theme.dart](file:///D:/Private/Firly/workaholic/lib/core/theme/shadcn_theme.dart)
- Helper untuk membuat `shadcn_flutter.ThemeData` yang cocok dengan palette Coquette (light + dark)
- Map warna Coquette ke color scheme shadcn

---

## 2. ThemeBloc — Support Theme Color + Font Style (Fungsional)

#### [MODIFY] [theme_bloc.dart](file:///D:/Private/Firly/workaholic/lib/core/theme/theme_bloc.dart)
- Tambah event `ChangeThemeColor(int colorIndex)` dan `ChangeFontStyle(String fontFamily)`
- State `ThemeState` menyimpan `colorIndex`, `fontFamily`, `isDarkMode`
- Simpan ke SharedPreferences agar persisten antar restart

#### [MODIFY] [coquette_theme.dart](file:///D:/Private/Firly/workaholic/lib/core/theme/coquette_theme.dart)
- Refactor `lightTheme` → `lightTheme({Color? primaryOverride, String? fontFamily})`
- Generate ThemeData berdasarkan warna dan font pilihan user

#### [MODIFY] [dark_theme.dart](file:///D:/Private/Firly/workaholic/lib/core/theme/dark_theme.dart)
- Sama: refactor menjadi method dengan parameter

#### [MODIFY] [app_typography.dart](file:///D:/Private/Firly/workaholic/lib/core/constants/app_typography.dart)
- Refactor agar font family bisa di-swap (`Playfair Display` / `Nunito` / `Dancing Script`)

---

## 3. Komponen per File — Migrasi Material → shadcn

### Halaman & Shell

#### [MODIFY] [main_shell.dart](file:///D:/Private/Firly/workaholic/lib/presentation/main_shell.dart)
| Material | → shadcn |
|---|---|
| `Scaffold` | `Scaffold` dari shadcn (atau tetap Material jika shadcn belum punya) |
| `FloatingActionButton` | shadcn `Button` variant primary + custom shape |
| `showModalBottomSheet` | shadcn `showSheet` / `Sheet` |

#### [MODIFY] [home_page.dart](file:///D:/Private/Firly/workaholic/lib/features/task/presentation/pages/home_page.dart)
| Material | → shadcn |
|---|---|
| `ScaffoldMessenger.showSnackBar` + `SnackBar` | shadcn `showToast` / `Toast` |
| `FilterChip` | shadcn `Toggle` / `Chip` |
| `IconButton` | shadcn `IconButton` / `Button.icon` |
| `LinearProgressIndicator` | shadcn `Progress` |

#### [MODIFY] [task_detail_page.dart](file:///D:/Private/Firly/workaholic/lib/features/task/presentation/pages/task_detail_page.dart)
| Material | → shadcn |
|---|---|
| `Scaffold` + `AppBar` | shadcn `Scaffold` / `AppBar` (atau wrapper) |
| `IconButton` (delete) | shadcn `Button.icon` variant destructive |
| `AlertDialog` + `showDialog` | shadcn `showDialog` / `AlertDialog` |
| `TextButton` | shadcn `Button` variant outline |
| `FilledButton` | shadcn `Button` variant destructive |
| `LinearProgressIndicator` | shadcn `Progress` |

#### [MODIFY] [add_task_page.dart](file:///D:/Private/Firly/workaholic/lib/features/task/presentation/pages/add_task_page.dart)
| Material | → shadcn |
|---|---|
| `TextField` (×3) | shadcn `TextField` |
| `DropdownButton<String>` (category) | shadcn `Select<String>` |
| `DropdownButton<TaskPriority>` (priority) | shadcn `Select<TaskPriority>` |
| `Switch` (alarm) | shadcn `Switch` |
| `ActionChip` (date shortcuts) | shadcn `Chip` / `Toggle` |
| `FilledButton` (submit) | shadcn `Button` variant primary |
| `IconButton` (add subtask) | shadcn `Button.icon` |

#### [MODIFY] [history_page.dart](file:///D:/Private/Firly/workaholic/lib/presentation/history_page.dart)
| Material | → shadcn |
|---|---|
| `Scaffold` | shadcn Scaffold wrapper |
| `showModalBottomSheet` | shadcn `showSheet` |

#### [MODIFY] [settings_page.dart](file:///D:/Private/Firly/workaholic/lib/presentation/settings_page.dart)
| Material | → shadcn |
|---|---|
| `Scaffold` | shadcn Scaffold |
| `Switch.adaptive` (×3) | shadcn `Switch` |
| `DropdownButton<String>` (font, sound) | shadcn `Select<String>` |
| `Divider` | shadcn `Separator` |
| Theme color picker → **wire ke `ThemeBloc.add(ChangeThemeColor(i))`** |
| Font style select → **wire ke `ThemeBloc.add(ChangeFontStyle(family))`** |

### Core Widgets

#### [MODIFY] [permission_onboarding_dialog.dart](file:///D:/Private/Firly/workaholic/lib/core/widgets/permission_onboarding_dialog.dart)
| Material | → shadcn |
|---|---|
| `Dialog` | shadcn `AlertDialog` / `Dialog` |
| `FilledButton` | shadcn `Button` variant primary |
| `TextButton` | shadcn `Button` variant ghost |
| `showDialog` | shadcn `showDialog` |

#### [MODIFY] [coquette_card.dart](file:///D:/Private/Firly/workaholic/lib/core/widgets/coquette_card.dart)
| Material | → shadcn |
|---|---|
| Custom card container | shadcn `Card` |

#### [MODIFY] [empty_state.dart](file:///D:/Private/Firly/workaholic/lib/core/widgets/empty_state.dart)
- Ganti `Text` styling ke shadcn typography extensions jika applicable

### Task Widgets

#### [MODIFY] [task_card_widget.dart](file:///D:/Private/Firly/workaholic/lib/features/task/presentation/widgets/task_card_widget.dart)
| Material | → shadcn |
|---|---|
| `LinearProgressIndicator` | shadcn `Progress` |

#### [MODIFY] [sub_task_item_widget.dart](file:///D:/Private/Firly/workaholic/lib/features/task/presentation/widgets/sub_task_item_widget.dart)
| Material | → shadcn |
|---|---|
| `IconButton` (delete) | shadcn `Button.icon` variant ghost/destructive |

#### [MODIFY] [quick_add_fab_widget.dart](file:///D:/Private/Firly/workaholic/lib/features/task/presentation/widgets/quick_add_fab_widget.dart)
| Material | → shadcn |
|---|---|
| `FloatingActionButton` | shadcn `Button` with circular shape |

#### [MODIFY] [category_filter_bar_widget.dart](file:///D:/Private/Firly/workaholic/lib/features/task/presentation/widgets/category_filter_bar_widget.dart)
| Material | → shadcn |
|---|---|
| Custom category chip | shadcn `Chip` / `Toggle` |

### Alarm Feature

#### [MODIFY] [alarm_page.dart](file:///D:/Private/Firly/workaholic/lib/features/alarm/alarm_page.dart)
| Material | → shadcn |
|---|---|
| `Scaffold` | shadcn Scaffold (atau tetap custom karena full-screen alarm) |

---

## 4. Komponen yang TETAP custom (tidak diganti)

| Widget | Alasan |
|---|---|
| `PearlCheckbox` | Custom animated checkbox dengan TweenSequence bounce — tidak ada equivalent shadcn |
| `BowDivider` | Custom divider dekoratif Coquette — bukan Divider standar |
| `ProgressRing` | Custom painter circular — tidak ada equivalent shadcn |
| `NeonNavBar` | Custom neon-glow bottom nav — tidak ada equivalent shadcn |
| `ConfettiOverlay` | Custom Lottie animation — tidak ada equivalent shadcn |

---

## Verification Plan

### Automated Tests
```bash
flutter analyze
```
Harus clean (0 issues).

### Manual Verification
- ✅ Semua dropdown muncul sebagai shadcn Select (popover style)
- ✅ Semua toggle muncul sebagai shadcn Switch
- ✅ Dialog delete muncul sebagai shadcn AlertDialog
- ✅ Snackbar muncul sebagai shadcn Toast
- ✅ Buttons muncul sebagai shadcn Button variants
- ✅ Ubah Theme Color di Settings → warna app berubah langsung
- ✅ Ubah Font Style → font berubah di seluruh app
- ✅ Toggle dark mode → masih bekerja
- ✅ Restart app → semua settings tersimpan

> [!WARNING]
> Ini adalah perubahan besar yang menyentuh **hampir semua file UI** di project. Pastikan backup/commit dulu sebelum eksekusi.
