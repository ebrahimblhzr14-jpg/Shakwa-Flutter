import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/security/jwt_claims_parser.dart';
import '../../../core/security/token_manager.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/app_priority_badge.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../../complaints/domain/entities/complaint.dart';
import '../../complaints/domain/entities/complaint_status.dart';
import '../../complaints/presentation/bloc/assigned_complaints_bloc.dart';
import '../../complaints/presentation/bloc/assigned_complaints_event.dart';
import '../../complaints/presentation/bloc/assigned_complaints_state.dart';
import '../../complaints/presentation/bloc/complaint_comments_bloc.dart';
import '../../complaints/presentation/bloc/complaint_comments_event.dart';
import '../../complaints/presentation/bloc/complaint_comments_state.dart';
import '../../complaints/presentation/bloc/complaint_details_bloc.dart';
import '../../complaints/presentation/bloc/complaint_details_event.dart';
import '../../complaints/presentation/bloc/complaint_details_state.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final String complaintId;
  final ComplaintDetailsBloc? detailsBloc;
  final ComplaintCommentsBloc? commentsBloc;
  final AssignedComplaintsBloc? assignedComplaintsBloc;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaintId,
    this.detailsBloc,
    this.commentsBloc,
    this.assignedComplaintsBloc,
  });

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  late final ComplaintDetailsBloc _detailsBloc;
  ComplaintCommentsBloc? _commentsBloc;
  AssignedComplaintsBloc? _assignedBloc;
  final _commentController = TextEditingController();

  int? get _parsedId => int.tryParse(widget.complaintId);

  bool get _isEmployee {
    if (GetIt.I.isRegistered<TokenManager>()) {
      final claims = GetIt.I<TokenManager>().claims;
      return claims != null &&
          (claims.role == UserRole.admin || claims.role == UserRole.superAdmin);
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    if (!GetIt.I.isRegistered<ComplaintDetailsBloc>()) {
      initCoreDependencies();
    }
    _detailsBloc = widget.detailsBloc ?? GetIt.I<ComplaintDetailsBloc>();

    if (widget.commentsBloc != null) {
      _commentsBloc = widget.commentsBloc;
    } else if (GetIt.I.isRegistered<ComplaintCommentsBloc>()) {
      _commentsBloc = GetIt.I<ComplaintCommentsBloc>();
    }

    if (widget.assignedComplaintsBloc != null) {
      _assignedBloc = widget.assignedComplaintsBloc;
    } else if (GetIt.I.isRegistered<AssignedComplaintsBloc>()) {
      _assignedBloc = GetIt.I<AssignedComplaintsBloc>();
    }

    if (_parsedId != null && _parsedId! > 0) {
      _detailsBloc.add(LoadComplaintDetailsEvent(_parsedId!));
      _commentsBloc?.add(LoadComplaintCommentsEvent(_parsedId!));
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showChangeStatusSheet(Complaint complaint) {
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

                  if (_assignedBloc != null) {
                    _assignedBloc!.add(
                      ChangeAssignedComplaintStatusEvent(
                        complaintId: complaint.id,
                        status: st,
                      ),
                    );
                  }
                  // Also refresh details to reflect latest status immediately
                  _detailsBloc.add(RefreshComplaintDetailsEvent(complaint.id));
                },
              );
            }).toList(),
      ),
    );
  }

  void _submitComment(int complaintId) {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى كتابة نص الملاحظة الفنية أولاً.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _commentsBloc?.add(
      AddComplaintCommentEvent(complaintId: complaintId, comment: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_parsedId == null || _parsedId! <= 0) {
      return const Scaffold(
        appBar: AppHeader(title: 'تفاصيل الشكوى', showBack: true),
        body: AppEmptyState(
          title: 'معرف الشكوى غير صالح',
          description: 'الرابط المطلوب يحتوي على معرف غير صحيح.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AssignedComplaintsBloc, AssignedComplaintsState>(
        bloc: _assignedBloc,
        listener: (context, assignedState) {
          if (assignedState is AssignedComplaintsErrorState) {
            final msg = assignedState.isForbidden
                ? 'أنت لست مسنداً لهذه الشكوى حالياً أو تم نقلها.'
                : assignedState.message;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (assignedState is AssignedComplaintsLoadedState &&
              assignedState.statusUpdateSuccessMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  assignedState.statusUpdateSuccessMessage!,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        child: BlocBuilder<ComplaintDetailsBloc, ComplaintDetailsState>(
          bloc: _detailsBloc,
          builder: (context, state) {
            if (state is ComplaintDetailsLoadingState) {
              return const Scaffold(
                appBar: AppHeader(title: 'تفاصيل الشكوى', showBack: true),
                body: AppLoadingIndicator(
                  message: 'جاري تحميل تفاصيل الشكوى...',
                ),
              );
            }

            if (state is ComplaintDetailsErrorState) {
              return Scaffold(
                appBar: const AppHeader(title: 'تفاصيل الشكوى', showBack: true),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.p24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          state.isNotFound
                              ? Icons.search_off_rounded
                              : Icons.cloud_off_rounded,
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

            if (state is ComplaintDetailsLoadedState) {
              final details = state.details;
              final complaint = details.complaint;
              final dateFormat = DateFormat('yyyy/MM/dd – hh:mm a');
              final formattedDate = dateFormat.format(complaint.createdAt);
              final isEmp = _isEmployee;
              final canCitizenEdit = !isEmp && complaint.isEditable;
              final canEmpChangeStatus = isEmp && !complaint.isClosed;

              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppHeader(
                  title: '#${complaint.id}',
                  subtitle: 'تفاصيل الشكوى ومسار المعالجة',
                  showBack: true,
                  actions: [
                    if (canCitizenEdit)
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                        ),
                        onPressed: () =>
                            context.push('/complaint/${complaint.id}/edit'),
                      ),
                    if (canEmpChangeStatus)
                      IconButton(
                        icon: const Icon(
                          Icons.sync_alt_rounded,
                          color: AppColors.primary,
                        ),
                        tooltip: 'تحديث الحالة الميدانية',
                        onPressed: () => _showChangeStatusSheet(complaint),
                      ),
                  ],
                ),
                body: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    _detailsBloc.add(
                      RefreshComplaintDetailsEvent(complaint.id),
                    );
                    _commentsBloc?.add(
                      LoadComplaintCommentsEvent(complaint.id),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        AppCard(
                          padding: const EdgeInsets.all(AppDimensions.p16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          borderRadius:
                                              AppDimensions.borderRadiusSM,
                                        ),
                                        child: Text(
                                          '#${complaint.id}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppDimensions.p8),
                                      AppPriorityBadge(
                                        priority: complaint.priority
                                            .toLegacyPriority(),
                                      ),
                                    ],
                                  ),
                                  AppStatusBadge(
                                    status: complaint.status.toLegacyStatus(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.p12),

                              // Title
                              Text(
                                complaint.title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: AppDimensions.p10),

                              // Date & Category info
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius:
                                          AppDimensions.borderRadiusSM,
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      complaint.categoryName ?? 'عام',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
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
                        const SizedBox(height: AppDimensions.p16),

                        // Employee Status Update Button
                        if (canEmpChangeStatus) ...[
                          AppButton(
                            text: 'تغيير حالة البلاغ الميداني',
                            icon: Icons.sync_alt_rounded,
                            variant: AppButtonVariant.primary,
                            height: 44,
                            onPressed: () => _showChangeStatusSheet(complaint),
                          ),
                          const SizedBox(height: AppDimensions.p16),
                        ],

                        // Description Card
                        AppCard(
                          padding: const EdgeInsets.all(AppDimensions.p16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppStrings.complaintDescription,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: AppDimensions.p8),
                              Text(
                                complaint.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              if (complaint.departmentName != null &&
                                  complaint.departmentName!.isNotEmpty) ...[
                                const SizedBox(height: AppDimensions.p12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.business_outlined,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'الجهة المختصة: ${complaint.departmentName}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p16),

                        // Primary Attachment Card
                        if (details.primaryAttachmentUrl != null &&
                            details.primaryAttachmentUrl!.isNotEmpty) ...[
                          AppCard(
                            padding: const EdgeInsets.all(AppDimensions.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'مرفقات البلاغ المعتمدة',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.p12),
                                ClipRRect(
                                  borderRadius: AppDimensions.borderRadiusMD,
                                  child: Image.network(
                                    details.primaryAttachmentUrl!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) {
                                      return Container(
                                        height: 120,
                                        color: AppColors.surface,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'تعذر تحميل صورة المرفق من الخادم',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      );
                                    },
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        height: 200,
                                        color: AppColors.surface,
                                        alignment: Alignment.center,
                                        child:
                                            const CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.p16),
                        ],

                        // History Timeline Card
                        AppCard(
                          padding: const EdgeInsets.all(AppDimensions.p16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'سجل متابعة المعالجة (التاريخ)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(height: AppDimensions.p12),
                              if (details.history.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'لا توجد إجراءات إدارية جديدة مسجلة على البلاغ حتى الآن.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: details.history.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 16,
                                    color: AppColors.divider,
                                  ),
                                  itemBuilder: (ctx, idx) {
                                    final item = details.history[idx];
                                    final timeStr = DateFormat(
                                      'yyyy/MM/dd – hh:mm a',
                                    ).format(item.createdAt);

                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.only(top: 5),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppDimensions.p12,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.action,
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              if (item.description != null &&
                                                  item.description!.isNotEmpty)
                                                Text(
                                                  item.description!,
                                                  style: const TextStyle(
                                                    fontFamily: 'Cairo',
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                              const SizedBox(height: 2),
                                              Text(
                                                timeStr,
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 10,
                                                  color: AppColors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p16),

                        // Technical Comments Section
                        if (_commentsBloc != null)
                          BlocConsumer<
                            ComplaintCommentsBloc,
                            ComplaintCommentsState
                          >(
                            bloc: _commentsBloc,
                            listener: (context, commentState) {
                              if (commentState
                                      is ComplaintCommentsLoadedState &&
                                  commentState.submissionMessage != null) {
                                _commentController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      commentState.submissionMessage!,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              } else if (commentState
                                      is ComplaintCommentsErrorState &&
                                  commentState.isSubmissionError) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      commentState.message,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            },
                            builder: (context, commentState) {
                              final comments =
                                  commentState is ComplaintCommentsLoadedState
                                  ? commentState.comments
                                  : (commentState
                                            is ComplaintCommentSubmittingState
                                        ? commentState.comments
                                        : (commentState
                                                  is ComplaintCommentsErrorState
                                              ? commentState.currentComments
                                              : const []));

                              final isSubmitting =
                                  commentState
                                      is ComplaintCommentSubmittingState;

                              return AppCard(
                                padding: const EdgeInsets.all(
                                  AppDimensions.p16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'الملاحظات والتعليقات الفنية',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceVariant,
                                            borderRadius:
                                                AppDimensions.borderRadiusSM,
                                          ),
                                          child: Text(
                                            '${comments.length}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppDimensions.p12),

                                    if (comments.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'لا توجد ملاحظات مسجلة على هذه الشكوى حتى الآن.',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: comments.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(
                                              height: 16,
                                              color: AppColors.divider,
                                            ),
                                        itemBuilder: (ctx, idx) {
                                          final c = comments[idx];
                                          final timeStr = DateFormat(
                                            'yyyy/MM/dd hh:mm a',
                                          ).format(c.createdAt);

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 12,
                                                        backgroundColor:
                                                            AppColors
                                                                .primarySurface,
                                                        child: const Icon(
                                                          Icons.person,
                                                          size: 14,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        c.userName,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .textPrimary,
                                                          fontFamily: 'Cairo',
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 1,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: AppColors
                                                              .surfaceVariant,
                                                          borderRadius:
                                                              AppDimensions
                                                                  .borderRadiusSM,
                                                        ),
                                                        child: Text(
                                                          c.userRoleText,
                                                          style: const TextStyle(
                                                            fontSize: 10,
                                                            color: AppColors
                                                                .textSecondary,
                                                            fontFamily: 'Cairo',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    timeStr,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.textMuted,
                                                      fontFamily: 'Cairo',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 32,
                                                ),
                                                child: Text(
                                                  c.comment,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                    height: 1.4,
                                                    fontFamily: 'Cairo',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),

                                    // Comment Input Bar — hidden for closed complaints
                                    if (!complaint.isClosed) ...[
                                      const SizedBox(height: AppDimensions.p16),
                                      const Divider(color: AppColors.divider),
                                      const SizedBox(height: AppDimensions.p8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _commentController,
                                              decoration: const InputDecoration(
                                                hintText:
                                                    'إضافة ملاحظة فنية أو توجيه ميداني...',
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 10,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton.filled(
                                            icon: isSubmitting
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.send_rounded,
                                                    size: 18,
                                                  ),
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: isSubmitting
                                                ? null
                                                : () => _submitComment(
                                                    complaint.id,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: AppDimensions.p16),

                        // Editing Info Banner (if closed)
                        if (complaint.isClosed)
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.p12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppDimensions.borderRadiusMD,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.lock_clock_outlined,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                                SizedBox(width: AppDimensions.p8),
                                Expanded(
                                  child: Text(
                                    'هذه الشكوى مغلقة نهائياً ولا يمكن تعديل بياناتها أو حالتها وفقاً لسياسة النظام.',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
