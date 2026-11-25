import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/network/attachment_upload_service.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_dropdown.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../complaints/domain/entities/complaint_category.dart';
import '../../complaints/domain/entities/complaint_status.dart';
import '../../complaints/presentation/bloc/complaint_submission_bloc.dart';
import '../../complaints/presentation/bloc/complaint_submission_event.dart';
import '../../complaints/presentation/bloc/complaint_submission_state.dart';

class CreateComplaintScreen extends StatefulWidget {
  final ComplaintSubmissionBloc? submissionBloc;

  const CreateComplaintScreen({super.key, this.submissionBloc});

  @override
  State<CreateComplaintScreen> createState() => _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends State<CreateComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  int? _selectedCategoryId;
  ComplaintPriority _selectedPriority = ComplaintPriority.medium;
  final List<AttachmentUploadItem> _attachments = [];

  late final ComplaintSubmissionBloc _submissionBloc;

  @override
  void initState() {
    super.initState();
    if (!GetIt.I.isRegistered<ComplaintSubmissionBloc>()) {
      initCoreDependencies();
    }
    _submissionBloc =
        widget.submissionBloc ?? GetIt.I<ComplaintSubmissionBloc>();
    _submissionBloc.add(const LoadSubmissionCategoriesEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _addMockPhotoAttachment() {
    // Generate an in-memory sample image for attachment pipeline
    final sampleBytes = Uint8List.fromList([
      0xFF,
      0xD8,
      0xFF,
      0xE0,
      0x00,
      0x10,
      0x4A,
      0x46,
      0x49,
      0x46,
      0x00,
      0x01,
      0x01,
      0x01,
      0x00,
      0x60,
      0x00,
      0x60,
      0x00,
      0x00,
      0xFF,
      0xDB,
      0x00,
      0x43,
      ...List.generate(200, (i) => (i * 7) % 256),
      0xFF,
      0xD9,
    ]);

    if (sampleBytes.length > AppConfig.maxFileSizeBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حجم الصورة يتجاوز الحد المسموح به (5 ميجابايت)',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final item = AttachmentUploadItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: 'photo_${_attachments.length + 1}.jpg',
      fileBytes: sampleBytes,
      contentType: 'image/jpeg',
    );

    setState(() {
      _attachments.add(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم إرفاق الصورة بنجاح',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _submitComplaint() async {
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

    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: 'تأكيد إرسال الشكوى',
      message: 'هل ترغب في اعتماد وإرسال البلاغ إلى الفريق المختص؟',
      confirmText: 'نعم، إرسال الآن',
      cancelText: 'مراجعة البلاغ',
    );

    if (confirmed != true) return;

    final fullDescription = _locationController.text.trim().isNotEmpty
        ? '${_descriptionController.text.trim()}\n\nالموقع: ${_locationController.text.trim()}'
        : _descriptionController.text.trim();

    _submissionBloc.add(
      SubmitComplaintEvent(
        title: _titleController.text.trim(),
        description: fullDescription,
        categoryId: _selectedCategoryId!,
        priorityId: _selectedPriority.id,
        attachments: _attachments.isNotEmpty ? List.from(_attachments) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintSubmissionBloc, ComplaintSubmissionState>(
      bloc: _submissionBloc,
      listener: (context, state) async {
        if (state is ComplaintSubmissionSuccessState) {
          if (state.hasPartialAttachmentFailures) {
            final retry = await AppDialog.showConfirmation(
              context: context,
              title: 'تنبيه بشأن المرفقات',
              message:
                  '${state.message}\nهل ترغب في إعادة محاولة رفع المرفقات المتبقية الآن؟',
              confirmText: 'إعادة المحاولة',
              cancelText: 'الانتقال للشكوى',
            );

            if (retry == true && mounted) {
              final failed = state.attachments
                  .where((a) => a.isFailed)
                  .toList();
              _submissionBloc.add(
                RetryFailedAttachmentsEvent(
                  complaintId: state.complaint.id,
                  failedAttachments: failed,
                ),
              );
              return;
            }
          } else {
            await AppDialog.showSuccess(
              context: context,
              title: AppStrings.successTitle,
              message: state.message,
              buttonText: 'الانتقال إلى شكاواي',
              onDismiss: () {
                if (context.mounted) {
                  context.go('/my-complaints');
                }
              },
            );
          }
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
      builder: (context, state) {
        final isSubmitting = state is ComplaintSubmittingState;
        final categories = state is ComplaintSubmissionInitialState
            ? state.categories
            : <ComplaintCategory>[];
        final isLoadingCategories =
            state is ComplaintSubmissionInitialState &&
            state.isLoadingCategories;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const AppHeader(
            title: AppStrings.navNewComplaint,
            subtitle: 'تسجيل بلاغ جديد ومتابعته',
            showRoleSwitcher: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.p16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notice Card
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.p14),
                    decoration: BoxDecoration(
                      color: AppColors.secondarySurface,
                      borderRadius: AppDimensions.borderRadiusMD,
                      border: Border.all(
                        color: AppColors.secondaryLight.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.secondaryDark,
                          size: 22,
                        ),
                        const SizedBox(width: AppDimensions.p10),
                        const Expanded(
                          child: Text(
                            'يرجى تزويدنا بكافة التفاصيل الدقيقة وموقع المشكلة لتمكين الفرق الميدانية من معالجة البلاغ في أسرع وقت.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              height: 1.4,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p20),

                  // Title
                  AppTextField(
                    label: AppStrings.complaintTitle,
                    hintText: AppStrings.enterTitleHint,
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
                  if (isLoadingCategories)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    )
                  else
                    AppDropdown<int>(
                      label: AppStrings.complaintCategory,
                      hintText: AppStrings.selectCategory,
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
                      validator: (val) =>
                          val == null ? AppStrings.requiredField : null,
                    ),
                  const SizedBox(height: AppDimensions.p16),

                  // Priority Dropdown
                  AppDropdown<ComplaintPriority>(
                    label: AppStrings.complaintPriority,
                    hintText: AppStrings.selectPriority,
                    value: _selectedPriority,
                    prefixIcon: Icons.flag_outlined,
                    items:
                        [
                          ComplaintPriority.low,
                          ComplaintPriority.medium,
                          ComplaintPriority.high,
                          ComplaintPriority.urgent,
                        ].map((p) {
                          return DropdownMenuItem<ComplaintPriority>(
                            value: p,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: p.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  p.displayNameArabic,
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedPriority = val);
                    },
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Location (Required)
                  AppTextField(
                    label: AppStrings.complaintLocation,
                    hintText: AppStrings.enterLocationHint,
                    controller: _locationController,
                    prefixIcon: Icons.location_on_outlined,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty)
                        return AppStrings.requiredField;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.p16),

                  // Description
                  AppTextField(
                    label: AppStrings.complaintDescription,
                    hintText: AppStrings.enterDescHint,
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
                  const SizedBox(height: AppDimensions.p20),

                  // Attachments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.attachments,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : _addMockPhotoAttachment,
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 18,
                        ),
                        label: const Text(
                          'إرفاق صورة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p8),

                  if (_attachments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.p20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppDimensions.borderRadiusMD,
                        border: Border.all(
                          color: AppColors.border,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 36,
                            color: AppColors.textMuted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'يمكنك إرفاق صور للمشكلة (JPG, PNG بحد أقصى 5 ميجابايت)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _attachments.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final item = entry.value;
                        return Chip(
                          avatar: const Icon(
                            Icons.image,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          label: Text(
                            item.fileName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: isSubmitting
                              ? null
                              : () => _removeAttachment(idx),
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.border),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: AppDimensions.p32),

                  // Submit Button
                  AppButton(
                    text: isSubmitting
                        ? state.progressMessage
                        : AppStrings.submit,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submitComplaint,
                  ),
                  const SizedBox(height: AppDimensions.p24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
