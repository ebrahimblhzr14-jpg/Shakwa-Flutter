import '../models/category_model.dart';
import '../models/priority_model.dart';
import '../models/status_model.dart';
import '../mock_data/mock_database.dart';

abstract class ManagementRepository {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> addCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);

  Future<List<PriorityModel>> getPriorities();
  Future<PriorityModel> addPriority(PriorityModel priority);
  Future<PriorityModel> updatePriority(PriorityModel priority);
  Future<void> deletePriority(String id);

  Future<List<StatusModel>> getStatuses();
  Future<StatusModel> addStatus(StatusModel status);
  Future<StatusModel> updateStatus(StatusModel status);
  Future<void> deleteStatus(String id);
}

class MockManagementRepository implements ManagementRepository {
  final MockDatabase _db = MockDatabase.instance;

  // Categories
  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_db.categories);
  }

  @override
  Future<CategoryModel> addCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newCat = category.copyWith(
      id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
    );
    _db.categories.add(newCat);
    return newCat;
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _db.categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _db.categories[index] = category;
      return category;
    }
    throw Exception('Category not found');
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.categories.removeWhere((c) => c.id == id);
  }

  // Priorities
  @override
  Future<List<PriorityModel>> getPriorities() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_db.priorities);
  }

  @override
  Future<PriorityModel> addPriority(PriorityModel priority) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newPrio = priority.copyWith(
      id: 'prio-${DateTime.now().millisecondsSinceEpoch}',
    );
    _db.priorities.add(newPrio);
    return newPrio;
  }

  @override
  Future<PriorityModel> updatePriority(PriorityModel priority) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _db.priorities.indexWhere((p) => p.id == priority.id);
    if (index != -1) {
      _db.priorities[index] = priority;
      return priority;
    }
    throw Exception('Priority not found');
  }

  @override
  Future<void> deletePriority(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.priorities.removeWhere((p) => p.id == id);
  }

  // Statuses
  @override
  Future<List<StatusModel>> getStatuses() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_db.statuses);
  }

  @override
  Future<StatusModel> addStatus(StatusModel status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newStatus = status.copyWith(
      id: 'stat-${DateTime.now().millisecondsSinceEpoch}',
    );
    _db.statuses.add(newStatus);
    return newStatus;
  }

  @override
  Future<StatusModel> updateStatus(StatusModel status) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _db.statuses.indexWhere((s) => s.id == status.id);
    if (index != -1) {
      _db.statuses[index] = status;
      return status;
    }
    throw Exception('Status not found');
  }

  @override
  Future<void> deleteStatus(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.statuses.removeWhere((s) => s.id == id);
  }
}
