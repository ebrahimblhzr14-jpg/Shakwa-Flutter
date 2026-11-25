import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/complaint_card.dart';
import '../../complaints/domain/entities/complaint.dart';
import '../../complaints/domain/entities/complaint_status.dart';
import '../../complaints/presentation/bloc/assigned_complaints_bloc.dart';
import '../../complaints/presentation/bloc/assigned_complaints_event.dart';
import '../../complaints/presentation/bloc/assigned_complaints_state.dart';

class AssignedComplaintsScreen extends StatefulWidget {
  final AssignedComplaintsBloc? assignedComplaintsBloc;

  const AssignedComplaintsScreen({super.key, this.assignedComplaintsBloc});

  @override
  State<AssignedComplaintsScreen> createState() =>
      _AssignedComplaintsScreenState();
}

class _AssignedComplaintsScreenState extends State<AssignedComplaintsScreen> {
  final _searchController = TextEditingController();
  late final AssignedComplaintsBloc _assignedBloc;

  @override
  void initState() {
    super.initState();
    if (!GetIt.I.isRegistered<AssignedComplaintsBloc>()) {
      initCoreDependencies();
    }
    _assignedBloc =
        widget.assignedComplaintsBloc ?? GetIt.I<AssignedComplaintsBloc>();
    _assignedBloc.add(const LoadAssignedComplaintsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showQuickStatusUpdateSheet(Complaint complaint) {
    if (complaint.isClosed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'هذه الشكوى في حالة مغلقة نهائياً ولا يمكن تعديل حالتها وفقاً لسياسة النظام.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    AppBottomSheet.show(
      context: context,
      title: 'تحديث حالة الشكوى',
      subtitle: '#${complaint.id} — ${complaint.title}',
      child: Column(
        children:
            [
              ComplaintStatus.pending,
              ComplaintStatus.underReview,
              ComplaintStatus.inProgress,
              ComplaintStatus.resolved,
              ComplaintStatus.closed,
            ].map((st) {
              final isCurrent = complaint.status == st;
              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: st.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(st.icon, size: 16, color: st.color),
                ),
                title: Text(
                  st.displayNameArabic,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent ? st.color : AppColors.textPrimary,
                  ),
                ),
                trailing: isCurrent
                    ? Icon(Icons.check_rounded, color: st.color)
                    : null,
                onTap: () {
                  Navigator.of(context).pop();
                  if (isCurrent) return;

                  _assignedBloc.add(
                    ChangeAssignedComplaintStatusEvent(
                      complaintId: complaint.id,
                      status: st,
                    ),
                  );
                },
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssignedComplaintsBloc, AssignedComplaintsState>(
      bloc: _assignedBloc,
      listener: (context, state) {
        if (state is AssignedComplaintsLoadedState &&
            state.statusUpdateSuccessMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.statusUpdateSuccessMessage!,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }

        if (state is AssignedComplaintsErrorState) {
          final msg = state.isForbidden
              ? 'أنت لست مسنداً لهذه الشكوى حالياً أو تم نقلها.'
              : state.message;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final selectedStatus = state is AssignedComplaintsLoadedState
            ? state.selectedStatus
            : null;
        final list = state is AssignedComplaintsLoadedState
            ? state.filteredComplaints
            : <Complaint>[];

        final isLoading = state is AssignedComplaintsLoadingState;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppHeader(
            title: AppStrings.navAdminAssigned,
            subtitle: 'قائمة الشكاوى المسندة لمتابعتك الميدانية',
            showRoleSwitcher: true,
          ),
          body: Column(
            children: [
              // Search & Filter Header
              Container(
                padding: const EdgeInsets.all(AppDimensions.p16),
                color: AppColors.surface,
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (q) =>
                          _assignedBloc.add(SearchAssignedComplaintsEvent(q)),
                      decoration: InputDecoration(
                        hintText: 'بحث في الشكاوى المسندة...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textMuted,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _assignedBloc.add(
                                    const SearchAssignedComplaintsEvent(''),
                                  );
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip('الكل', selectedStatus == null, () {
                            _assignedBloc.add(
                              const FilterAssignedComplaintsByStatusEvent(null),
                            );
                          }),
                          const SizedBox(width: 8),
                          _buildChip(
                            'قيد المراجعة',
                            selectedStatus == ComplaintStatus.underReview,
                            () {
                              _assignedBloc.add(
                                const FilterAssignedComplaintsByStatusEvent(
                                  ComplaintStatus.underReview,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChip(
                            'قيد المعالجة',
                            selectedStatus == ComplaintStatus.inProgress,
                            () {
                              _assignedBloc.add(
                                const FilterAssignedComplaintsByStatusEvent(
                                  ComplaintStatus.inProgress,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChip(
                            'تم الحل',
                            selectedStatus == ComplaintStatus.resolved,
                            () {
                              _assignedBloc.add(
                                const FilterAssignedComplaintsByStatusEvent(
                                  ComplaintStatus.resolved,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildChip(
                            'مغلقة',
                            selectedStatus == ComplaintStatus.closed,
                            () {
                              _assignedBloc.add(
                                const FilterAssignedComplaintsByStatusEvent(
                                  ComplaintStatus.closed,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // List of Complaints
              Expanded(
                child: isLoading
                    ? const AppLoadingIndicator(
                        message: 'جاري تحميل الشكاوى المسندة...',
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          _assignedBloc.add(
                            const LoadAssignedComplaintsEvent(isRefresh: true),
                          );
                        },
                        child: list.isEmpty
                            ? SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 60),
                                  child:
                                      _searchController.text.isNotEmpty ||
                                          selectedStatus != null
                                      ? AppEmptyState(
                                          title: 'لا توجد شكاوى مطابقة',
                                          description:
                                              'جرّب البحث بكلمات أخرى أو اختر فلتر حالة مختلف.',
                                          actionText: 'عرض كل الشكاوى المسندة',
                                          onAction: () {
                                            _searchController.clear();
                                            _assignedBloc.add(
                                              const SearchAssignedComplaintsEvent(
                                                '',
                                              ),
                                            );
                                            _assignedBloc.add(
                                              const FilterAssignedComplaintsByStatusEvent(
                                                null,
                                              ),
                                            );
                                          },
                                        )
                                      : const AppEmptyState(
                                          title: 'لا توجد شكاوى مسندة لك',
                                          description:
                                              'لم يتم إسناد أي بلاغات جديدة لك في هذا الوقت.',
                                        ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(
                                  AppDimensions.p16,
                                ),
                                itemCount: list.length,
                                itemBuilder: (ctx, index) {
                                  final complaint = list[index];
                                  return ComplaintCard(
                                    complaint: complaint.toLegacyModel(),
                                    onTap: () => context.push(
                                      '/complaint/${complaint.id}',
                                    ),
                                    trailingAction: IconButton(
                                      icon: const Icon(
                                        Icons.sync_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      tooltip: 'تغيير الحالة سريعاً',
                                      onPressed: () =>
                                          _showQuickStatusUpdateSheet(
                                            complaint,
                                          ),
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onSelected) {
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
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusFull,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}
