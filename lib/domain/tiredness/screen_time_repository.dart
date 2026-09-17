import 'screen_time_state.dart';

abstract class ScreenTimeRepository {
  Future<ScreenTimeState> get();
  Future<void> save(ScreenTimeState state);
}
