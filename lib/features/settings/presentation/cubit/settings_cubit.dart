import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';

class SettingsState {
  final bool dailyReminders;
  final bool urgentAlarms;

  SettingsState({
    required this.dailyReminders,
    required this.urgentAlarms,
  });

  SettingsState copyWith({
    bool? dailyReminders,
    bool? urgentAlarms,
  }) {
    return SettingsState(
      dailyReminders: dailyReminders ?? this.dailyReminders,
      urgentAlarms: urgentAlarms ?? this.urgentAlarms,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  final GetSettingsUseCase getSettings;
  final SaveSettingsUseCase saveSettings;

  SettingsCubit({
    required this.getSettings,
    required this.saveSettings,
  }) : super(SettingsState(
          dailyReminders: getSettings.getDailyReminders(),
          urgentAlarms: getSettings.getUrgentAlarms(),
        ));

  void toggleDailyReminders(bool value) async {
    await saveSettings.saveDailyReminders(value);
    emit(state.copyWith(dailyReminders: value));
  }

  void toggleUrgentAlarms(bool value) async {
    await saveSettings.saveUrgentAlarms(value);
    emit(state.copyWith(urgentAlarms: value));
  }
}
