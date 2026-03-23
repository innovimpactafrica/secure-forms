import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secure_link/core/utils/user_session.dart';
import 'package:secure_link/features/client/data/services/archives_service.dart';
import 'archives_event.dart';
import 'archives_state.dart';

class ArchivesBloc extends Bloc<ArchivesEvent, ArchivesState> {
  final ArchivesService _service;

  ArchivesBloc({ArchivesService? service})
      : _service = service ?? ArchivesService(),
        super(const ArchivesInitial()) {
    on<LoadArchivesEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadArchivesEvent event,
    Emitter<ArchivesState> emit,
  ) async {
    emit(const ArchivesLoading());
    try {
      final token = UserSession.instance.accessToken;
      print('[ArchivesBloc] LoadArchives — type=${event.type} status=${event.status}');
      final archives = await _service.getArchives(
        accessToken: token,
        type: event.type,
        status: event.status,
      );
      print('[ArchivesBloc] ${archives.length} archive(s) chargée(s)');
      emit(ArchivesLoaded(archives));
    } catch (e) {
      print('[ArchivesBloc] ERREUR: $e');
      emit(ArchivesError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
