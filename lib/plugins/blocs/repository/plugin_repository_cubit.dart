import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/plugins/models/plugin_repository.dart';
import 'package:Bloomee/plugins/services/plugin_repository_service.dart';

abstract class PluginRepositoryState {}

class PluginRepositoryInitial extends PluginRepositoryState {}

class PluginRepositoryLoading extends PluginRepositoryState {}

class PluginRepositoryLoaded extends PluginRepositoryState {
  final List<PluginRepositoryModel> repositories;
  PluginRepositoryLoaded(this.repositories);
}

class PluginRepositoryError extends PluginRepositoryState {
  final String message;
  PluginRepositoryError(this.message);
}

class PluginRepositoryCubit extends Cubit<PluginRepositoryState> {
  final PluginRepositoryService _service;

  PluginRepositoryCubit(this._service) : super(PluginRepositoryInitial());

  Future<void> loadRepositories() async {
    emit(PluginRepositoryLoading());
    try {
      final urls = await _service.getSavedRepositoryUrls();
      if (urls.isEmpty) {
        emit(PluginRepositoryLoaded([]));
        return;
      }

      final List<PluginRepositoryModel> results = [];
      for (final url in urls) {
        try {
          final repo = await _service.fetchRepository(url);
          results.add(repo);
        } catch (e) {
          log('Error fetching repo $url: $e');
          // We can still add a "failed" placeholder or just skip
        }
      }

      emit(PluginRepositoryLoaded(results));
    } catch (e) {
      emit(PluginRepositoryError('Failed to load repositories: $e'));
    }
  }

  Future<void> addRepository(String url) async {
    try {
      emit(PluginRepositoryLoading());
      // First verify it's valid
      await _service.fetchRepository(url);
      await _service.addRepositoryUrl(url);
      await loadRepositories();
    } catch (e) {
      emit(PluginRepositoryError('Invalid repository: $e'));
      // try reloading to restore previous state
      await loadRepositories();
    }
  }

  Future<void> removeRepository(String url) async {
    try {
      emit(PluginRepositoryLoading());
      await _service.removeRepositoryUrl(url);
      await loadRepositories();
    } catch (e) {
      emit(PluginRepositoryError('Failed to remove repository: $e'));
      await loadRepositories();
    }
  }
}
