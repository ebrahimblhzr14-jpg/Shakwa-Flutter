import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/priority_model.dart';
import '../../../data/models/status_model.dart';
import '../../management_provider.dart';

class ManagementScreen extends ConsumerStatefulWidget {
  const ManagementScreen({super.key});

  @override
  ConsumerState<ManagementScreen> createState() => _ManagementScreenState();
}

class _ManagementScreenState extends ConsumerState<ManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Add / Edit Category Dialog
  void _showCategoryDialog([CategoryModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusLG,
          ),
          title: Text(
            existing == null ? AppStrings.addNewCategory : 'تعديل التصنيف',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'اسم التصنيف',
                  controller: nameCtrl,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'الوصف التوضيحي',
                  controller: descCtrl,
                  maxLines: 2,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  if (existing == null) {
                    await ref
                        .read(managementActionProvider.notifier)
                        .addCategory(
                          CategoryModel(
                            id: '',
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            complaintsCount: 0,
                          ),
                          ref,
                        );
                  } else {
                    await ref
                        .read(managementActionProvider.notifier)
                        .updateCategory(
                          existing.copyWith(
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                          ),
                          ref,
                        );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                existing == null ? 'إضافة' : 'حفظ',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add / Edit Priority Dialog
  void _showPriorityDialog([PriorityModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final slaCtrl = TextEditingController(
      text: existing?.slaHours.toString() ?? '24',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusLG,
          ),
          title: Text(
            existing == null ? AppStrings.addNewPriority : 'تعديل الأولوية',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'اسم مستوى الأولوية',
                  controller: nameCtrl,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'زمن المعالجة المتوقع (بالساعات)',
                  controller: slaCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'الوصف والتعليمات',
                  controller: descCtrl,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  final sla = int.tryParse(slaCtrl.text) ?? 24;
                  if (existing == null) {
                    await ref
                        .read(managementActionProvider.notifier)
                        .addPriority(
                          PriorityModel(
                            id: '',
                            name: nameCtrl.text.trim(),
                            level: PriorityLevel.medium,
                            description: descCtrl.text.trim(),
                            slaHours: sla,
                          ),
                          ref,
                        );
                  } else {
                    await ref
                        .read(managementActionProvider.notifier)
                        .updatePriority(
                          existing.copyWith(
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            slaHours: sla,
                          ),
                          ref,
                        );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                existing == null ? 'إضافة' : 'حفظ',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add / Edit Status Dialog
  void _showStatusDialog([StatusModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusLG,
          ),
          title: Text(
            existing == null ? AppStrings.addNewStatus : 'تعديل حالة الشكوى',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'اسم الحالة',
                  controller: nameCtrl,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'وصف الحالة واستخدامها',
                  controller: descCtrl,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();
                  if (existing == null) {
                    await ref
                        .read(managementActionProvider.notifier)
                        .addStatus(
                          StatusModel(
                            id: '',
                            name: nameCtrl.text.trim(),
                            status: ComplaintStatus.inProgress,
                            description: descCtrl.text.trim(),
                          ),
                          ref,
                        );
                  } else {
                    await ref
                        .read(managementActionProvider.notifier)
                        .updateStatus(
                          existing.copyWith(
                            name: nameCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                          ),
                          ref,
                        );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                existing == null ? 'إضافة' : 'حفظ',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final prioritiesAsync = ref.watch(prioritiesProvider);
    final statusesAsync = ref.watch(statusesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          AppStrings.navAdminManagement,
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: AppStrings.tabCategories),
            Tab(text: AppStrings.tabPriorities),
            Tab(text: AppStrings.tabStatuses),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Categories
          _buildCategoriesTab(categoriesAsync),
          // Tab 2: Priorities
          _buildPrioritiesTab(prioritiesAsync),
          // Tab 3: Statuses
          _buildStatusesTab(statusesAsync),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(AsyncValue<List<CategoryModel>> catsAsync) {
    return catsAsync.when(
      data: (cats) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCategoryDialog(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'تصنيف جديد',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.p16),
            itemCount: cats.length,
            itemBuilder: (ctx, i) {
              final cat = cats[i];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppDimensions.borderRadiusMD,
                      ),
                      child: const Icon(
                        Icons.category_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onPressed: () => _showCategoryDialog(cat),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: AppColors.error,
                      ),
                      onPressed: () async {
                        final confirm = await AppDialog.showConfirmation(
                          context: context,
                          title: 'حذف التصنيف',
                          message: 'هل أنت متأكد من رغبتك في حذف هذا التصنيف؟',
                          isDestructive: true,
                        );
                        if (confirm == true) {
                          await ref
                              .read(managementActionProvider.notifier)
                              .deleteCategory(cat.id, ref);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('حدث خطأ أثناء تحميل التصنيفات')),
    );
  }

  Widget _buildPrioritiesTab(AsyncValue<List<PriorityModel>> priosAsync) {
    return priosAsync.when(
      data: (prios) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showPriorityDialog(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'أولوية جديدة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.p16),
            itemCount: prios.length,
            itemBuilder: (ctx, i) {
              final prio = prios[i];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: prio.level.backgroundColor,
                        borderRadius: AppDimensions.borderRadiusMD,
                      ),
                      child: Icon(
                        Icons.flag_rounded,
                        color: prio.level.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                prio.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: AppDimensions.borderRadiusSM,
                                ),
                                child: Text(
                                  '${prio.slaHours} ساعة',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prio.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onPressed: () => _showPriorityDialog(prio),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('حدث خطأ أثناء تحميل الأولويات')),
    );
  }

  Widget _buildStatusesTab(AsyncValue<List<StatusModel>> statusesAsync) {
    return statusesAsync.when(
      data: (stats) {
        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showStatusDialog(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'حالة جديدة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.p16),
            itemCount: stats.length,
            itemBuilder: (ctx, i) {
              final stat = stats[i];
              return AppCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: stat.status.backgroundColor,
                        borderRadius: AppDimensions.borderRadiusMD,
                      ),
                      child: Icon(
                        stat.status.icon,
                        color: stat.status.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: stat.status.color,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      onPressed: () => _showStatusDialog(stat),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('حدث خطأ أثناء تحميل الحالات')),
    );
  }
}
