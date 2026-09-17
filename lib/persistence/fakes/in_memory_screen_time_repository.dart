import '../../domain/tiredness/screen_time_repository.dart';
import '../../domain/tiredness/screen_time_state.dart';

class InMemoryScreenTimeRepository implements ScreenTimeRepository {
  ScreenTimeState? _state;

  @override
  Future<ScreenTimeState> get() async {
    return _state ??= ScreenTimeState.initial(DateTime.now());
  }

  @override
  Future<void> save(ScreenTimeState state) async {
    _state = state;
  }
}
