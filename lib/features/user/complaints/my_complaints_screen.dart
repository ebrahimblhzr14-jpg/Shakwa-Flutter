import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/complaint_card.dart';
import '../../complaints/domain/entities/complaint.dart';
import '../../complaints/domain/entities/complaint_status.dart';
import '../../complaints/presentation/bloc/complaints_bloc.dart';
import '../../complaints/presentation/bloc/complaints_event.dart';
import '../../complaints/presentation/bloc/complaints_state.dart';

class MyComplaintsScreen extends StatefulWidget {
  final ComplaintsBloc? complaintsBloc;

  const MyComplaintsScreen({super.key, this.complaintsBloc});

  @override
  State<MyComplaintsScreen> createState() => _MyComplaintsScreenState();
}

class _MyComplaintsScreenState extends State<MyComplaintsScreen> {
  final _searchController = TextEditingController();
  ComplaintStatus? _selectedStatus;
  late final ComplaintsBloc _complaintsBloc;

  @override
  void initState() {
    super.initState();
    if (!GetIt.I.isRegistered<ComplaintsBloc>()) {
      initCoreDependencies();
    }
    _complaintsBloc = widget.complaintsBloc ?? GetIt.I<ComplaintsBloc>();
    _complaintsBloc.add(const LoadMyComplaintsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _complaintsBloc.add(SearchComplaintsEvent(query));
  }

  void _onStatusSelected(ComplaintStatus? status) {
    setState(() => _selectedStatus = status);
    _complaintsBloc.add(FilterComplaintsByStatusEvent(status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.navComplaints,
        subtitle: 'متابعة وتفاصيل بلاغاتي المقدمة',
        showRoleSwitcher: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/create-complaint'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'بلاغ جديد',
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
          Container(
            padding: const EdgeInsets.all(AppDimensions.p16),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchHint,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMD,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppDimensions.borderRadiusMD,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.p12),

                // Filter Chips List
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: AppStrings.filterAll,
                        isSelected: _selectedStatus == null,
                        onSelected: () => _onStatusSelected(null),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'جديدة',
                        isSelected: _selectedStatus == ComplaintStatus.pending,
                        onSelected: () =>
                            _onStatusSelected(ComplaintStatus.pending),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'قيد المعالجة',
                        isSelected:
                            _selectedStatus == ComplaintStatus.inProgress,
                        onSelected: () =>
                            _onStatusSelected(ComplaintStatus.inProgress),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'تم الحل',
                        isSelected: _selectedStatus == ComplaintStatus.resolved,
                        onSelected: () =>
                            _onStatusSelected(ComplaintStatus.resolved),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'مغلقة',
                        isSelected: _selectedStatus == ComplaintStatus.closed,
                        onSelected: () =>
                            _onStatusSelected(ComplaintStatus.closed),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Complaints List or Empty/Error States
          Expanded(
            child: BlocBuilder<ComplaintsBloc, ComplaintsState>(
              bloc: _complaintsBloc,
              builder: (context, state) {
                if (state is ComplaintsLoadingState) {
                  return const AppLoadingIndicator(
                    message: 'جاري تحميل الشكاوى...',
                  );
                }

                if (state is ComplaintsErrorState) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.p24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            size: 56,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppDimensions.p16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.p16),
                          AppButton(
                            text: 'إعادة المحاولة',
                            onPressed: () => _complaintsBloc.add(
                              const LoadMyComplaintsEvent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                List<Complaint> list = [];
                if (state is ComplaintsLoadedState) {
                  list = state.filteredComplaints;
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    _complaintsBloc.add(
                      const LoadMyComplaintsEvent(isRefresh: true),
                    );
                  },
                  child: list.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child:
                                _searchController.text.isNotEmpty ||
                                    _selectedStatus != null
                                ? AppEmptyState(
                                    title: 'لا توجد نتائج مطابقة',
                                    description:
                                        'لم نتمكن من العثور على أي شكاوى تطابق خيارات البحث الحالية.',
                                    actionText: 'إعادة ضبط الفلاتر',
                                    onAction: () {
                                      _searchController.clear();
                                      _onStatusSelected(null);
                                    },
                                  )
                                : AppEmptyState(
                                    title: 'سجل الشكاوى فارغ',
                                    description:
                                        'لم تقم بتقديم أي بلاغات حتى الآن. يمكنك تسجيل شكواك الأولى الآن.',
                                    actionText: 'تقديم شكوى الآن',
                                    onAction: () =>
                                        context.go('/create-complaint'),
                                  ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppDimensions.p16),
                          itemCount: list.length,
                          itemBuilder: (ctx, index) {
                            final complaint = list[index];
                            return ComplaintCard(
                              complaint: complaint.toLegacyModel(),
                              onTap: () =>
                                  context.push('/complaint/${complaint.id}'),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontFamily: 'Cairo',
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusFull,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}
