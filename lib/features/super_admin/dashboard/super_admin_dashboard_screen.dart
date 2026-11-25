import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/security/token_manager.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/complaint_card.dart';
import '../../complaints/domain/entities/complaint_status.dart';
import '../../complaints/presentation/bloc/super_admin_dashboard_bloc.dart';
import '../../complaints/presentation/bloc/super_admin_dashboard_event.dart';
import '../../complaints/presentation/bloc/super_admin_dashboard_state.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  final SuperAdminDashboardBloc? bloc;

  const SuperAdminDashboardScreen({super.key, this.bloc});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> {
  late final SuperAdminDashboardBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? sl<SuperAdminDashboardBloc>();
    _bloc.add(const LoadSuperAdminDashboardEvent());
  }

  @override
  void dispose() {
    if (widget.bloc == null) {
      _bloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String userName = 'المسؤول العام';
    if (sl.isRegistered<TokenManager>()) {
      final tokenManager = sl<TokenManager>();
      userName = tokenManager.claims?.fullName ?? 'المسؤول العام';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: AppStrings.superAdminDashboard,
        subtitle: '$userName — الرقابة والتحكم المركزي',
        showRoleSwitcher: true,
      ),
      body: BlocBuilder<SuperAdminDashboardBloc, SuperAdminDashboardState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is SuperAdminDashboardLoadingState ||
              state is SuperAdminDashboardInitialState) {
            return const AppLoadingIndicator(
              message: 'جاري تحميل مؤشرات المنصة المركزية...',
            );
          }

          if (state is SuperAdminDashboardErrorState) {
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
                    ElevatedButton.icon(
                      onPressed: () {
                        _bloc.add(
                          const LoadSuperAdminDashboardEvent(isRefresh: true),
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        'إعادة المحاولة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SuperAdminDashboardLoadedState) {
            final resolutionRate = state.resolutionRate;
            final activeComplaints =
                state.totalComplaints - state.resolvedComplaints;
            final totalUsers = state.totalUsersCount;

            final unassignedComplaints = state.recentComplaints
                .where((c) => c.status == ComplaintStatus.pending)
                .toList();

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                _bloc.add(const LoadSuperAdminDashboardEvent(isRefresh: true));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Executive Banner
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), AppColors.primary],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        borderRadius: AppDimensions.borderRadiusLG,
                        boxShadow: AppDimensions.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الإدارة العامة للبلاغات',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'متابعة مستوى الإنجاز والتوزيع اللوجستي للأقسام',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shield_rounded,
                                  color: AppColors.secondary,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.p16),
                          Row(
                            children: [
                              _buildBannerStatItem(
                                'نسبة الحل العام',
                                '$resolutionRate%',
                              ),
                              Container(
                                width: 1,
                                height: 28,
                                color: Colors.white24,
                              ),
                              _buildBannerStatItem(
                                'البلاغات النشطة',
                                '$activeComplaints',
                              ),
                              Container(
                                width: 1,
                                height: 28,
                                color: Colors.white24,
                              ),
                              _buildBannerStatItem(
                                'مستخدمي المنصة',
                                '$totalUsers',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p20),

                    // Key Performance Indicators (KPIs)
                    const Text(
                      'المؤشرات العامة للنظام',
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
                          child: _buildKpiCard(
                            title: 'إجمالي البلاغات',
                            count: state.totalComplaints,
                            color: AppColors.primary,
                            icon: Icons.all_inbox_rounded,
                            onTap: () => context.go('/all-complaints'),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.p12),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'تتطلب إسناد فوري',
                            count: state.unassignedCount,
                            color: AppColors.warning,
                            icon: Icons.assignment_late_rounded,
                            onTap: () => context.go('/all-complaints'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            title: 'قيد المعالجة الميدانية',
                            count: state.inProgressComplaints,
                            color: AppColors.statusInProgress,
                            icon: Icons.build_circle_rounded,
                            onTap: () => context.go('/all-complaints'),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.p12),
                        Expanded(
                          child: _buildKpiCard(
                            title: 'تم إنجازها بنجاح',
                            count: state.resolvedComplaints,
                            color: AppColors.statusResolved,
                            icon: Icons.check_circle_rounded,
                            onTap: () => context.go('/all-complaints'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p20),

                    // Quick Management Actions
                    const Text(
                      'إدارة الأقسام والعمليات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: AppDimensions.p10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            title: 'المستخدمين',
                            subtitle: 'إدارة وتفعيل الحسابات',
                            icon: Icons.people_alt_rounded,
                            color: AppColors.primary,
                            route: '/users',
                          ),
                        ),
                        const SizedBox(width: AppDimensions.p12),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            title: 'سجل النشاطات',
                            subtitle: 'تدقيق وتاريخ العمليات',
                            icon: Icons.manage_history_rounded,
                            color: AppColors.secondary,
                            route: '/history',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.p20),

                    // Needs Attention Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'بلاغات بحاجة إلى إسناد عاجل',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/all-complaints'),
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

                    if (unassignedComplaints.isEmpty)
                      const AppCard(
                        padding: EdgeInsets.all(AppDimensions.p16),
                        child: Center(
                          child: Text(
                            'لا توجد بلاغات معلقة بحاجة إلى إسناد حالياً.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      )
                    else
                      ...unassignedComplaints.take(3).map((complaint) {
                        return ComplaintCard(
                          complaint: complaint.toLegacyModel(),
                          onTap: () =>
                              context.push('/complaint/${complaint.id}'),
                          trailingAction: TextButton.icon(
                            onPressed: () => context.push(
                              '/complaint/${complaint.id}/assign',
                            ),
                            icon: const Icon(Icons.person_add_alt, size: 16),
                            label: const Text(
                              'إسناد',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBannerStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.p16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppDimensions.borderRadiusMD,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppDimensions.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return AppCard(
      onTap: () => context.go(route),
      padding: const EdgeInsets.all(AppDimensions.p14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.p10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
