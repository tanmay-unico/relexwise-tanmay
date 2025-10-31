import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/videos_repository.dart';

sealed class VideosState {}
class VideosInitial extends VideosState {}
class VideosLoading extends VideosState {}
class VideosLoaded extends VideosState {
  final List<dynamic> videos;
  VideosLoaded(this.videos);
}
class VideosError extends VideosState {
  final String message;
  VideosError(this.message);
}

class VideosCubit extends Cubit<VideosState> {
  final VideosRepository repository;
  VideosCubit(this.repository) : super(VideosInitial());

  Future<void> load({bool refresh = false}) async {
    emit(VideosLoading());
    try {
      final videos = await repository.getLatestVideos(forceRefresh: refresh);
      emit(VideosLoaded(videos));
    } catch (_) {
      emit(VideosError('Failed to load videos. Please try again.'));
    }
  }
}


