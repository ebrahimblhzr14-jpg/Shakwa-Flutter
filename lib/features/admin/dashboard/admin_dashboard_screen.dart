import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/security/token_manager.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/complaint_card.dart';
import '../../complaints/domain/entities/complaint.dart';
import '../../complaints/presentation/bloc/assigned_complaints_bloc.dart';
import '../../complaints/presentation/bloc/assigned_complaints_event.dart';
import '../../complaints/presentation/bloc/assigned_complaints_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AssignedComplaintsBloc? assignedComplaintsBloc;

  const AdminDashboardScreen({super.key, this.assignedComplaintsBloc});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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

  String _getUserFullName() {
    if (GetIt.I.isRegistered<TokenManager>()) {
      final claims = GetIt.I<TokenManager>().claims;
      if (claims != null && claims.fullName.isNotEmpty) {
        return claims.fullName;
      }
    }
    return 'المشرف الميداني';
  }

  @override
  Widget build(BuildContext context) {
    final employeeName = _getUserFullName();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'لوحة تحكم المشرف',
        subtitle: '$employeeName — إدارة المعالجة الميدانية',
        showRoleSwitcher: true,
      ),
      body: BlocBuilder<AssignedComplaintsBloc, AssignedComplaintsState>(
        bloc: _assignedBloc,
        builder: (context, state) {
          if (state is AssignedComplaintsLoadingState) {
            return const AppLoadingIndicator(
              message: 'جاري تحميل لوحة المشرف...',
            );
          }

          if (state is AssignedComplaintsErrorState &&
              state.complaintsList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    ElevatedButton.icon(
                      onPressed: () => _assignedBloc.add(
                        const LoadAssignedComplaintsEvent(),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final complaints = state is AssignedComplaintsLoadedState
              ? state.complaints
              : <Complaint>[];

          final totalAssigned = state is AssignedComplaintsLoadedState
              ? state.totalAssigned
              : 0;
          final pending = state is AssignedComplaintsLoadedState
              ? state.pendingCount
              : 0;
          final inProgress = state is AssignedComplaintsLoadedState
              ? state.inProgressCount
              : 0;
          final resolved = state is AssignedComplaintsLoadedState
              ? state.resolvedCount
              : 0;

          final recentComplaints = complaints.take(3).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              _assignedBloc.add(
                const LoadAssignedComplaintsEvent(isRefresh: true),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Banner
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: AppDimensions.borderRadiusLG,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: AppColors.secondary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.p14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'مركز معالجة البلاغات الميدانية',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'متابعة وإنجاز البلاغات والشكاوى المسندة',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p20),

                  // Metrics Grid
                  const Text(
                    'مؤشرات الأداء والمعالجة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'الشكاوى المسندة إليك',
                          count: totalAssigned,
                          color: AppColors.primary,
                          icon: Icons.assignment_ind_rounded,
                          onTap: () => context.go('/assigned-complaints'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'قيد المراجعة والتدقيق',
                          count: pending,
                          color: AppColors.statusPending,
                          icon: Icons.pending_actions_rounded,
                          onTap: () => context.go('/assigned-complaints'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'أعمال جارية ميدانياً',
                          count: inProgress,
                          color: AppColors.statusInProgress,
                          icon: Icons.engineering_rounded,
                          onTap: () => context.go('/assigned-complaints'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p12),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'تم إنجازها وحلها',
                          count: resolved,
                          color: AppColors.statusResolved,
                          icon: Icons.task_alt_rounded,
                          onTap: () => context.go('/assigned-complaints'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p20),

                  // Quick Management Navigation
                  AppCard(
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الإدارة والإعدادات السريعة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: AppDimensions.p12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.go('/management'),
                                icon: const Icon(
                                  Icons.category_rounded,
                                  size: 18,
                                ),
                                label: const Text(
                                  'التصنيفات',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppDimensions.borderRadiusMD,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.go('/management'),
                                icon: const Icon(Icons.tune_rounded, size: 18),
                                label: const Text(
                                  'الحالات والأولويات',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppDimensions.borderRadiusMD,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p20),

                  // Assigned Complaints Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'أحدث الشكاوى المسندة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/assigned-complaints'),
                        child: const Text(
                          'عرض الكل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p8),

                  if (recentComplaints.isEmpty)
                    AppCard(
                      padding: const EdgeInsets.all(AppDimensions.p24),
                      child: const AppEmptyState(
                        title: 'لا توجد شكاوى مسندة لك حالياً',
                        description:
                            'ستظهر هنا الشكاوى التي يتم توجيهها إلى حسابك من قبل الإدارة المركزية.',
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentComplaints.length,
                      itemBuilder: (ctx, index) {
                        final complaint = recentComplaints[index];
                        return ComplaintCard(
                          complaint: complaint.toLegacyModel(),
                          onTap: () =>
                              context.push('/complaint/${complaint.id}'),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppDimensions.borderRadiusSM,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.p10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}

extension on AssignedComplaintsState {
  List<Complaint> get complaintsList {
    if (this is AssignedComplaintsLoadedState) {
      return (this as AssignedComplaintsLoadedState).complaints;
    }
    return const [];
  }
}
