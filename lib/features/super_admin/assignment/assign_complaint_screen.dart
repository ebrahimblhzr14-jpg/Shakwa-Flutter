import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../complaints/domain/entities/complaint.dart';
import '../../complaints/presentation/bloc/assign_complaint_bloc.dart';
import '../../complaints/presentation/bloc/assign_complaint_event.dart';
import '../../complaints/presentation/bloc/assign_complaint_state.dart';
import '../domain/entities/user_entity.dart';

class AssignComplaintScreen extends StatefulWidget {
  final String? complaintId;
  final AssignComplaintBloc? bloc;

  const AssignComplaintScreen({super.key, this.complaintId, this.bloc});

  @override
  State<AssignComplaintScreen> createState() => _AssignComplaintScreenState();
}

class _AssignComplaintScreenState extends State<AssignComplaintScreen> {
  late final AssignComplaintBloc _bloc;
  int? _selectedEmployeeId;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? sl<AssignComplaintBloc>();
    final parsedId = int.tryParse(widget.complaintId ?? '') ?? 0;
    _bloc.add(LoadAssignmentDataEvent(parsedId));
  }

  @override
  void dispose() {
    _notesController.dispose();
    if (widget.bloc == null) {
      _bloc.close();
    }
    super.dispose();
  }

  Future<void> _handleAssign(
    Complaint complaint,
    List<UserEntity> employees,
  ) async {
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء اختيار الموظف أو المشرف المسؤول',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }

    final emp = employees.firstWhere((e) => e.id == _selectedEmployeeId);

    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'تأكيد إسناد البلاغ',
      message:
          'هل ترغب في توجيه وإسناد البلاغ "#${complaint.id}" إلى المهندس/المشرف ${emp.name}؟',
      confirmText: 'نعم، إسناد',
      cancelText: 'تراجع',
    );

    if (confirmed != true) return;

    _bloc.add(
      SubmitAssignmentEvent(
        complaintId: complaint.id,
        assignedToUserId: emp.id,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.assignToEmployee,
        subtitle: 'توجيه البلاغ للقسم والموظف الميداني المختص',
        showBack: true,
      ),
      body: BlocConsumer<AssignComplaintBloc, AssignComplaintState>(
        bloc: _bloc,
        listener: (context, state) async {
          if (state is AssignComplaintSuccessState) {
            await AppDialog.showSuccess(
              context: context,
              title: AppStrings.successTitle,
              message: state.message,
              buttonText: 'حسناً',
              onDismiss: () => context.pop(),
            );
          } else if (state is AssignComplaintErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AssignComplaintLoadingState ||
              state is AssignComplaintInitialState) {
            return const AppLoadingIndicator(
              message: 'جاري تحميل بيانات البلاغ والمشرفين...',
            );
          }

          if (state is AssignComplaintErrorState) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppDimensions.p12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p16),
                    ElevatedButton(
                      onPressed: () {
                        final parsedId =
                            int.tryParse(widget.complaintId ?? '') ?? 0;
                        _bloc.add(LoadAssignmentDataEvent(parsedId));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(
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

          if (state is AssignComplaintLoadedState) {
            final complaint = state.complaint;
            final employees = state.eligibleEmployees.cast<UserEntity>();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Context Card
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: AppDimensions.borderRadiusSM,
                              ),
                              child: Text(
                                '#${complaint.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            Text(
                              complaint.categoryName ?? 'عام',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          complaint.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                complaint.departmentName ?? 'البلدية العامة',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p20),

                  // Employee Dropdown
                  AppDropdown<int>(
                    label: AppStrings.selectEmployee,
                    hintText: 'اختر المشرف / الموظف المسؤول',
                    value: _selectedEmployeeId,
                    prefixIcon: Icons.engineering_outlined,
                    items: employees.map((emp) {
                      return DropdownMenuItem<int>(
                        value: emp.id,
                        child: Text(
                          '${emp.name} (${emp.roleName})',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedEmployeeId = val),
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Notes / Directives
                  AppTextField(
                    label: 'ملاحظات وتوجيهات الإسناد (اختياري)',
                    hintText:
                        'مثال: يرجى الوقوف على الموقع بشكل عاجل وإفادتنا بالتقرير الفني...',
                    controller: _notesController,
                    maxLines: 4,
                    prefixIcon: Icons.note_alt_outlined,
                  ),
                  const SizedBox(height: AppDimensions.p32),

                  // Confirm Assignment Button
                  AppButton(
                    text: 'اعتماد إسناد الشكوى',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: state.isSubmitting,
                    onPressed: () => _handleAssign(complaint, employees),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
