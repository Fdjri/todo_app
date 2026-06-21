import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/gamification_local_datasource.dart';
import '../../domain/entities/user_stats_entity.dart';

// ─── Events ───
abstract class GamificationEvent extends Equatable {
  const GamificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadStats extends GamificationEvent {}

class TaskCompleted extends GamificationEvent {}

class SubtaskCompleted extends GamificationEvent {}

class UpdateStreak extends GamificationEvent {}

class SetMood extends GamificationEvent {
  final String mood;
  const SetMood(this.mood);
  @override
  List<Object?> get props => [mood];
}

// ─── States ───
abstract class GamificationState extends Equatable {
  const GamificationState();
  @override
  List<Object?> get props => [];
}

class GamificationInitial extends GamificationState {}

class GamificationLoaded extends GamificationState {
  final UserStatsEntity stats;
  final bool justLeveledUp;
  final UserLevel? previousLevel;

  const GamificationLoaded({
    required this.stats,
    this.justLeveledUp = false,
    this.previousLevel,
  });

  @override
  List<Object?> get props => [stats, justLeveledUp];
}

// ─── BLoC ───
class GamificationBloc extends Bloc<GamificationEvent, GamificationState> {
  final GamificationLocalDataSource dataSource;

  GamificationBloc({required this.dataSource}) : super(GamificationInitial()) {
    on<LoadStats>(_onLoadStats);
    on<TaskCompleted>(_onTaskCompleted);
    on<SubtaskCompleted>(_onSubtaskCompleted);
    on<UpdateStreak>(_onUpdateStreak);
    on<SetMood>(_onSetMood);
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<GamificationState> emit) async {
    final stats = dataSource.getStats();
    emit(GamificationLoaded(stats: stats));
  }

  Future<void> _onTaskCompleted(
      TaskCompleted event, Emitter<GamificationState> emit) async {
    final oldStats = dataSource.getStats();
    final oldLevel = oldStats.level;
    final newStats = await dataSource.addTaskXP();
    final newLevel = newStats.level;

    emit(GamificationLoaded(
      stats: newStats,
      justLeveledUp: newLevel != oldLevel,
      previousLevel: oldLevel,
    ));
  }

  Future<void> _onSubtaskCompleted(
      SubtaskCompleted event, Emitter<GamificationState> emit) async {
    final newStats = await dataSource.addSubtaskXP();
    emit(GamificationLoaded(stats: newStats));
  }

  Future<void> _onUpdateStreak(
      UpdateStreak event, Emitter<GamificationState> emit) async {
    final newStats = await dataSource.updateStreak();
    emit(GamificationLoaded(stats: newStats));
  }

  Future<void> _onSetMood(SetMood event, Emitter<GamificationState> emit) async {
    final newStats = await dataSource.setMood(event.mood);
    emit(GamificationLoaded(stats: newStats));
  }
}
