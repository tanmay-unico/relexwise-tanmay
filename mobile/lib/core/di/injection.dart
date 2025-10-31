import 'package:get_it/get_it.dart';
import '../data/videos/videos_remote_data_source.dart';
import '../data/videos/videos_local_data_source.dart';
import '../repositories/videos_repository.dart';
import '../repositories/videos_repository_impl.dart';
import '../../features/home/bloc/videos_cubit.dart';
import '../data/auth/auth_remote_data_source.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';
import '../../features/auth/viewmodels/auth_cubit.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Data sources
  getIt.registerLazySingleton<VideosRemoteDataSource>(() => VideosRemoteDataSourceImpl());
  getIt.registerLazySingleton<VideosLocalDataSource>(() => VideosLocalDataSourceImpl());

  // Repositories
  getIt.registerLazySingleton<VideosRepository>(() => VideosRepositoryImpl(
        remote: getIt<VideosRemoteDataSource>(),
        local: getIt<VideosLocalDataSource>(),
      ));
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remote: getIt<AuthRemoteDataSource>()));

  // Cubits/ViewModels
  getIt.registerFactory<VideosCubit>(() => VideosCubit(getIt<VideosRepository>()));
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()));
}

