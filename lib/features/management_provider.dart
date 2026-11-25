import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/category_model.dart';
import '../data/models/priority_model.dart';
import '../data/models/status_model.dart';
import '../data/repositories/management_repository.dart';

final managementRepositoryProvider = Provider<ManagementRepository>((ref) {
  return MockManagementRepository();
});

class ManagementNotifier extends StateNotifier<AsyncValue<void>> {
  final ManagementRepository _repository;

  ManagementNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> addCategory(CategoryModel category, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addCategory(category);
      ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCategory(CategoryModel category, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateCategory(category);
      ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCategory(String id, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteCategory(id);
      ref.invalidate(categoriesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPriority(PriorityModel priority, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addPriority(priority);
      ref.invalidate(prioritiesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePriority(PriorityModel priority, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updatePriority(priority);
      ref.invalidate(prioritiesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePriority(String id, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deletePriority(id);
      ref.invalidate(prioritiesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addStatus(StatusModel status, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.addStatus(status);
      ref.invalidate(statusesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(StatusModel status, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateStatus(status);
      ref.invalidate(statusesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteStatus(String id, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteStatus(id);
      ref.invalidate(statusesProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final managementActionProvider =
    StateNotifierProvider<ManagementNotifier, AsyncValue<void>>((ref) {
      final repo = ref.watch(managementRepositoryProvider);
      return ManagementNotifier(repo);
    });

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repo = ref.watch(managementRepositoryProvider);
  return repo.getCategories();
});

final prioritiesProvider = FutureProvider<List<PriorityModel>>((ref) async {
  final repo = ref.watch(managementRepositoryProvider);
  return repo.getPriorities();
});

final statusesProvider = FutureProvider<List<StatusModel>>((ref) async {
  final repo = ref.watch(managementRepositoryProvider);
  return repo.getStatuses();
});
