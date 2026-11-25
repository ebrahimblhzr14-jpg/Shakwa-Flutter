import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../complaints/domain/entities/complaint.dart';
import '../../complaints/domain/entities/complaint_category.dart';
import '../../complaints/domain/entities/complaint_status.dart';
import '../../complaints/presentation/bloc/complaint_details_bloc.dart';
import '../../complaints/presentation/bloc/complaint_details_event.dart';
import '../../complaints/presentation/bloc/complaint_details_state.dart';
import '../../complaints/presentation/bloc/complaint_submission_bloc.dart';
import '../../complaints/presentation/bloc/complaint_submission_event.dart';
import '../../complaints/presentation/bloc/complaint_submission_state.dart';

class EditComplaintScreen extends StatefulWidget {
  final String complaintId;
  final ComplaintDetailsBloc? detailsBloc;
  final ComplaintSubmissionBloc? submissionBloc;

  const EditComplaintScreen({
    super.key,
    required this.complaintId,
    this.detailsBloc,
    this.submissionBloc,
  });

  @override
  State<EditComplaintScreen> createState() => _EditComplaintScreenState();
}

class _EditComplaintScreenState extends State<EditComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ComplaintDetailsBloc _detailsBloc;
  late final ComplaintSubmissionBloc _submissionBloc;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  int? _selectedCategoryId;
  ComplaintPriority _selectedPriority = ComplaintPriority.medium;
  bool _initialized = false;

  int? get _parsedId => int.tryParse(widget.complaintId);

  @override
  void initState() {
    super.initState();
    if (!GetIt.I.isRegistered<ComplaintDetailsBloc>() ||
        !GetIt.I.isRegistered<ComplaintSubmissionBloc>()) {
      initCoreDependencies();
    }
    _detailsBloc = widget.detailsBloc ?? GetIt.I<ComplaintDetailsBloc>();
    _submissionBloc =
        widget.submissionBloc ?? GetIt.I<ComplaintSubmissionBloc>();

    if (_parsedId != null && _parsedId! > 0) {
      _detailsBloc.add(LoadComplaintDetailsEvent(_parsedId!));
      _submissionBloc.add(const LoadSubmissionCategoriesEvent());
    }
  }

  void _initFields(Complaint complaint) {
    if (_initialized) return;
    _titleController = TextEditingController(text: complaint.title);
    _descriptionController = TextEditingController(text: complaint.description);
    _selectedCategoryId = complaint.categoryId;
    _selectedPriority = complaint.priority;
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _titleController.dispose();
      _descriptionController.dispose();
    }
    super.dispose();
  }

  void _handleSave(int id) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedCategoryId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء اختيار تصنيف الشكوى',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _submissionBloc.add(
      UpdateComplaintEvent(
        id: id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
        priorityId: _selectedPriority.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_parsedId == null || _parsedId! <= 0) {
      return const Scaffold(
        appBar: AppHeader(title: 'تعديل الشكوى', showBack: true),
        body: AppEmptyState(
          title: 'معرف غير صالح',
          description: 'رقم الشكوى غير صحيح.',
        ),
      );
    }

    return BlocListener<ComplaintSubmissionBloc, ComplaintSubmissionState>(
      bloc: _submissionBloc,
      listener: (context, state) async {
        if (state is ComplaintSubmissionSuccessState) {
          await AppDialog.showSuccess(
            context: context,
            title: AppStrings.successTitle,
            message: state.message,
            buttonText: 'حسناً',
            onDismiss: () {
              _detailsBloc.add(RefreshComplaintDetailsEvent(_parsedId!));
              if (context.mounted) {
                context.pop();
              }
            },
          );
        }

        if (state is ComplaintSubmissionFailureState && context.mounted) {
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
      child: BlocBuilder<ComplaintDetailsBloc, ComplaintDetailsState>(
        bloc: _detailsBloc,
        builder: (context, detailsState) {
          if (detailsState is ComplaintDetailsLoadingState) {
            return const Scaffold(
              appBar: AppHeader(title: 'تعديل الشكوى', showBack: true),
              body: AppLoadingIndicator(message: 'جاري تحميل بيانات الشكوى...'),
            );
          }

          if (detailsState is ComplaintDetailsErrorState) {
            return Scaffold(
              appBar: const AppHeader(title: 'تعديل الشكوى', showBack: true),
              body: Center(
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
                        detailsState.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p16),
                      AppButton(
                        text: 'إعادة المحاولة',
                        onPressed: () => _detailsBloc.add(
                          LoadComplaintDetailsEvent(_parsedId!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (detailsState is ComplaintDetailsLoadedState) {
            final complaint = detailsState.details.complaint;
            _initFields(complaint);

            // Backend rule: Closed complaints cannot be modified (HTTP 409)
            if (!complaint.isEditable) {
              return Scaffold(
                appBar: AppHeader(
                  title: 'تعديل #${complaint.id}',
                  showBack: true,
                ),
                body: Padding(
                  padding: const EdgeInsets.all(AppDimensions.p24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        size: 64,
                        color: AppColors.warning,
                      ),
                      const SizedBox(height: AppDimensions.p16),
                      const Text(
                        'لا يمكن تعديل هذه الشكوى',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p8),
                      Text(
                        complaint.isClosed
                            ? 'هذه الشكوى في حالة مغلقة نهائياً وفق قواعد الخادم ولا يمكن فتحها للتعديل.'
                            : 'الشكوى قيد المراجعة أو المعالجة الميدانية حالياً، ويقتصر التعديل على الشكاوى الجديدة فقط.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.p24),
                      AppButton(
                        text: 'العودة للتفاصيل',
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppHeader(
                title: 'تعديل #${complaint.id}',
                subtitle: 'تحديث بيانات الشكوى المسجلة',
                showBack: true,
              ),
              body:
                  BlocBuilder<
                    ComplaintSubmissionBloc,
                    ComplaintSubmissionState
                  >(
                    bloc: _submissionBloc,
                    builder: (context, subState) {
                      final isSaving = subState is ComplaintSubmittingState;
                      final categories =
                          subState is ComplaintSubmissionInitialState
                          ? subState.categories
                          : <ComplaintCategory>[];

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Read-only Complaint Number
                              AppTextField(
                                label: AppStrings.complaintNumber,
                                initialValue: '#${complaint.id}',
                                readOnly: true,
                                prefixIcon: Icons.confirmation_number_outlined,
                              ),
                              const SizedBox(height: AppDimensions.p16),

                              // Title
                              AppTextField(
                                label: AppStrings.complaintTitle,
                                controller: _titleController,
                                prefixIcon: Icons.title_rounded,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty)
                                    return AppStrings.requiredField;
                                  if (val.trim().length < 5)
                                    return 'يجب أن لا يقل العنوان عن 5 أحرف';
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.p16),

                              // Category Dropdown
                              AppDropdown<int>(
                                label: AppStrings.complaintCategory,
                                value: _selectedCategoryId,
                                prefixIcon: Icons.category_outlined,
                                items: categories.map((c) {
                                  return DropdownMenuItem<int>(
                                    value: c.id,
                                    child: Text(
                                      c.name,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) =>
                                    setState(() => _selectedCategoryId = val),
                              ),
                              const SizedBox(height: AppDimensions.p16),

                              // Priority
                              AppDropdown<ComplaintPriority>(
                                label: AppStrings.complaintPriority,
                                value: _selectedPriority,
                                prefixIcon: Icons.flag_outlined,
                                items:
                                    [
                                      ComplaintPriority.low,
                                      ComplaintPriority.medium,
                                      ComplaintPriority.high,
                                      ComplaintPriority.urgent,
                                    ].map((p) {
                                      return DropdownMenuItem<
                                        ComplaintPriority
                                      >(
                                        value: p,
                                        child: Text(
                                          p.displayNameArabic,
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedPriority = val);
                                },
                              ),
                              const SizedBox(height: AppDimensions.p16),

                              // Description
                              AppTextField(
                                label: AppStrings.complaintDescription,
                                controller: _descriptionController,
                                maxLines: 4,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty)
                                    return AppStrings.requiredField;
                                  if (val.trim().length < 10)
                                    return 'يجب أن لا يقل الوصف عن 10 أحرف';
                                  return null;
                                },
                              ),
                              const SizedBox(height: AppDimensions.p32),

                              // Action Buttons: Save & Cancel
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      text: AppStrings.cancel,
                                      variant: AppButtonVariant.outline,
                                      onPressed: isSaving
                                          ? null
                                          : () => context.pop(),
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.p12),
                                  Expanded(
                                    child: AppButton(
                                      text: AppStrings.save,
                                      isLoading: isSaving,
                                      onPressed: isSaving
                                          ? null
                                          : () => _handleSave(complaint.id),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
