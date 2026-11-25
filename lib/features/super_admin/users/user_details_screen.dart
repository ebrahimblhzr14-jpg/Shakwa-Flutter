import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialog.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/complaint_card.dart';
import '../../complaints/domain/entities/complaint.dart';
import '../../complaints/domain/repositories/i_complaint_repository.dart';
import '../domain/entities/user_entity.dart';
import '../domain/repositories/i_super_admin_user_repository.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final ISuperAdminUserRepository? userRepository;
  final IComplaintRepository? complaintRepository;

  const UserDetailsScreen({
    super.key,
    required this.userId,
    this.userRepository,
    this.complaintRepository,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late final ISuperAdminUserRepository _userRepo;
  late final IComplaintRepository _complaintRepo;

  UserEntity? _user;
  List<Complaint> _userComplaints = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isTogglingStatus = false;

  @override
  void initState() {
    super.initState();
    _userRepo = widget.userRepository ?? sl<ISuperAdminUserRepository>();
    _complaintRepo = widget.complaintRepository ?? sl<IComplaintRepository>();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final id = int.tryParse(widget.userId);
    if (id == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'معرف المستخدم غير صالح';
      });
      return;
    }

    final userRes = await _userRepo.getUserById(id);
    final complaintsRes = await _complaintRepo.getAllComplaints();

    userRes.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        }
      },
      (user) {
        List<Complaint> complaints = [];
        complaintsRes.fold((_) {}, (all) {
          complaints = all.where((c) => c.userId == user.id).toList();
        });

        if (mounted) {
          setState(() {
            _user = user;
            _userComplaints = complaints;
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _toggleUserStatus() async {
    if (_user == null || _isTogglingStatus) return;

    final willDeactivate = _user!.isActive;
    final confirmed = await AppDialog.showConfirmation(
      context: context,
      title: willDeactivate ? 'تعطيل الحساب' : 'تفعيل الحساب',
      message: willDeactivate
          ? 'هل أنت متأكد من رغبتك في تعطيل هذا الحساب؟ لن يتمكن المستخدم من الدخول للمنظومة.'
          : 'هل ترغب في إعادة تفعيل حساب المستخدم للعمل بالمنظومة؟',
      confirmText: willDeactivate ? 'تعطيل الحساب' : 'تفعيل الحساب',
      isDestructive: willDeactivate,
    );

    if (confirmed != true) return;

    setState(() => _isTogglingStatus = true);

    final res = willDeactivate
        ? await _userRepo.deactivateUser(_user!.id)
        : await _userRepo.activateUser(_user!.id);

    if (mounted) {
      setState(() => _isTogglingStatus = false);

      res.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                failure.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (_) {
          setState(() {
            _user = UserEntity(
              id: _user!.id,
              name: _user!.name,
              email: _user!.email,
              phone: _user!.phone,
              imageUrl: _user!.imageUrl,
              roleId: _user!.roleId,
              roleName: _user!.roleName,
              isActive: !willDeactivate,
              createdAt: _user!.createdAt,
            );
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                willDeactivate
                    ? 'تم تعطيل الحساب بنجاح'
                    : 'تم تفعيل الحساب بنجاح',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.userDetails,
        subtitle: 'بيانات الحساب وتعيين الصلاحيات',
        showBack: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingIndicator(
        message: 'جاري تحميل تفاصيل المستخدم...',
      );
    }

    if (_errorMessage != null || _user == null) {
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
                _errorMessage ?? 'المستخدم غير موجود',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.p16),
              ElevatedButton.icon(
                onPressed: _loadUserDetails,
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

    final user = _user!;
    final joinDate = DateFormat('yyyy/MM/dd').format(user.createdAt);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Header Card
          AppCard(
            padding: const EdgeInsets.all(AppDimensions.p20),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primarySurface,
                      child: Text(
                        user.name.isNotEmpty ? user.name.characters.first : 'م',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.p16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: user.isActive
                                      ? AppColors.successBg
                                      : AppColors.errorBg,
                                  borderRadius: AppDimensions.borderRadiusFull,
                                ),
                                child: Text(
                                  user.isActive ? 'نشط' : 'معطل',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: user.isActive
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: AppDimensions.borderRadiusSM,
                            ),
                            child: Text(
                              user.roleName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.p16),
                const Divider(color: AppColors.divider),
                const SizedBox(height: AppDimensions.p10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('رقم الهاتف', user.phone ?? 'غير مسجل'),
                    _buildStatItem('تاريخ التسجيل', joinDate),
                    _buildStatItem(
                      'البلاغات المرتبطة',
                      '${_userComplaints.length}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.p16),

          // Management Actions
          AppButton(
            text: user.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب',
            icon: user.isActive
                ? Icons.block_rounded
                : Icons.check_circle_outline_rounded,
            variant: user.isActive
                ? AppButtonVariant.danger
                : AppButtonVariant.secondary,
            isLoading: _isTogglingStatus,
            height: 44,
            onPressed: _toggleUserStatus,
          ),
          const SizedBox(height: AppDimensions.p20),

          // Connected Complaints
          const Text(
            'شكاوى مقدمة من المستخدم',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: AppDimensions.p10),

          if (_userComplaints.isEmpty)
            const AppCard(
              padding: EdgeInsets.all(AppDimensions.p20),
              child: Center(
                child: Text(
                  'لا توجد شكاوى مرتبطة بهذا الحساب حالياً.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            )
          else
            ..._userComplaints.map((c) {
              return ComplaintCard(
                complaint: c.toLegacyModel(),
                onTap: () => context.push('/complaint/${c.id}'),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'Cairo',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
