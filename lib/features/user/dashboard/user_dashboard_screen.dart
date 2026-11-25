import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/security/token_manager.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/complaint_card.dart';
import '../../complaints/domain/entities/complaint.dart';
import '../../complaints/presentation/bloc/complaints_bloc.dart';
import '../../complaints/presentation/bloc/complaints_event.dart';
import '../../complaints/presentation/bloc/complaints_state.dart';

class UserDashboardScreen extends StatefulWidget {
  final ComplaintsBloc? complaintsBloc;

  const UserDashboardScreen({super.key, this.complaintsBloc});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
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

  String _getUserFullName() {
    if (GetIt.I.isRegistered<TokenManager>()) {
      final claims = GetIt.I<TokenManager>().claims;
      if (claims != null && claims.fullName.isNotEmpty) {
        return claims.fullName;
      }
    }
    return 'عزيزي المواطن';
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserFullName();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: 'الرئيسية',
        subtitle: 'أهلاً، $userName',
        showRoleSwitcher: true,
      ),
      body: BlocBuilder<ComplaintsBloc, ComplaintsState>(
        bloc: _complaintsBloc,
        builder: (context, state) {
          if (state is ComplaintsLoadingState) {
            return const AppLoadingIndicator(
              message: 'جاري تحديث لوحة البيانات...',
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
                      onPressed: () =>
                          _complaintsBloc.add(const LoadMyComplaintsEvent()),
                    ),
                  ],
                ),
              ),
            );
          }

          int totalCount = 0;
          int pendingCount = 0;
          int inProgressCount = 0;
          int resolvedCount = 0;
          List<Complaint> recentComplaints = [];

          if (state is ComplaintsLoadedState) {
            totalCount = state.totalCount;
            pendingCount = state.pendingCount;
            inProgressCount = state.inProgressCount;
            resolvedCount = state.resolvedCount;
            recentComplaints = state.complaints.take(3).toList();
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              _complaintsBloc.add(const LoadMyComplaintsEvent(isRefresh: true));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome & Quick Action Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.p20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'مرحباً بك، $userName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'صوتك مسموع، يسعدنا استقبال بلاغاتك ومتابعتها حتى اكتمال الحل.',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.4,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.campaign_rounded,
                                color: AppColors.secondary,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.p16),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/create-complaint'),
                          icon: const Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          label: const Text(
                            AppStrings.addNewComplaintAction,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.borderRadiusMD,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p20),

                  // Statistics Section Header
                  const Text(
                    AppStrings.dashboardStats,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: AppDimensions.p12),

                  // Grid of 4 Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: AppStrings.totalComplaints,
                          count: totalCount,
                          color: AppColors.primary,
                          icon: Icons.folder_open_rounded,
                          onTap: () => context.go('/my-complaints'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p12),
                      Expanded(
                        child: _buildStatCard(
                          title: AppStrings.pendingComplaints,
                          count: pendingCount,
                          color: AppColors.statusPending,
                          icon: Icons.hourglass_top_rounded,
                          onTap: () => context.go('/my-complaints'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: AppStrings.inProgressComplaints,
                          count: inProgressCount,
                          color: AppColors.statusInProgress,
                          icon: Icons.build_rounded,
                          onTap: () => context.go('/my-complaints'),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p12),
                      Expanded(
                        child: _buildStatCard(
                          title: AppStrings.resolvedComplaints,
                          count: resolvedCount,
                          color: AppColors.statusResolved,
                          icon: Icons.check_circle_rounded,
                          onTap: () => context.go('/my-complaints'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p24),

                  // Recent Complaints Header with View All
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        AppStrings.recentComplaints,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/my-complaints'),
                        child: const Text(
                          AppStrings.viewAll,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p8),

                  // Recent Complaints List or Empty State
                  if (recentComplaints.isEmpty)
                    AppCard(
                      padding: const EdgeInsets.all(AppDimensions.p24),
                      child: AppEmptyState(
                        title: 'لا توجد شكاوى مسجلة حتى الآن',
                        description:
                            'يمكنك البدء بتقديم بلاغ جديد ليتم توجيهه ومعالجته فوراً من قبل البلدية.',
                        actionText: 'تقديم أول شكوى',
                        onAction: () => context.go('/create-complaint'),
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

  Widget _buildStatCard({
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
          const SizedBox(height: AppDimensions.p12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
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
