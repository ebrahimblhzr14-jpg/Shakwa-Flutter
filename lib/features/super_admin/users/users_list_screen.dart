import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../domain/entities/user_entity.dart';
import '../presentation/bloc/users_bloc.dart';
import '../presentation/bloc/users_event.dart';
import '../presentation/bloc/users_state.dart';

class UsersListScreen extends StatefulWidget {
  final UsersBloc? bloc;

  const UsersListScreen({super.key, this.bloc});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late final UsersBloc _bloc;
  final _searchController = TextEditingController();
  int? _selectedRoleId;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? sl<UsersBloc>();
    _bloc.add(const LoadUsersEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.bloc == null) {
      _bloc.close();
    }
    super.dispose();
  }

  void _onRoleFilterSelected(int? roleId) {
    setState(() => _selectedRoleId = roleId);
    _bloc.add(FilterUsersByRoleEvent(roleId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.usersList,
        subtitle: 'إدارة حسابات المواطنين والموظفين والمشرفين',
        showRoleSwitcher: true,
      ),
      body: Column(
        children: [
          // Filter & Search
          Container(
            padding: const EdgeInsets.all(AppDimensions.p16),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _bloc.add(SearchUsersEvent(val));
                  },
                  decoration: InputDecoration(
                    hintText: 'بحث بالاسم، البريد، أو الدور...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _bloc.add(const SearchUsersEvent(''));
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.p12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleFilterChip(
                        label: 'الكل',
                        isSelected: _selectedRoleId == null,
                        onSelected: () => _onRoleFilterSelected(null),
                      ),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip(
                        label: 'المواطنين',
                        isSelected: _selectedRoleId == 1,
                        onSelected: () => _onRoleFilterSelected(1),
                      ),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip(
                        label: 'المشرفين',
                        isSelected: _selectedRoleId == 2,
                        onSelected: () => _onRoleFilterSelected(2),
                      ),
                      const SizedBox(width: 8),
                      _buildRoleFilterChip(
                        label: 'المسؤولين',
                        isSelected: _selectedRoleId == 3,
                        onSelected: () => _onRoleFilterSelected(3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: BlocConsumer<UsersBloc, UsersState>(
              bloc: _bloc,
              listener: (context, state) {
                if (state is UsersLoadedState &&
                    state.actionFeedbackMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.actionFeedbackMessage!,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is UsersLoadingState || state is UsersInitialState) {
                  return const AppLoadingIndicator(
                    message: 'جاري تحميل قائمة المستخدمين...',
                  );
                }

                if (state is UsersErrorState) {
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
                              _bloc.add(const LoadUsersEvent(isRefresh: true));
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

                if (state is UsersLoadedState) {
                  final users = state.filteredUsers;

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      _bloc.add(const LoadUsersEvent(isRefresh: true));
                    },
                    child: users.isEmpty
                        ? const SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.only(top: 60),
                              child: AppEmptyState(
                                title: 'لا يوجد مستخدمين مطابقين',
                                description:
                                    'لم يتم العثور على أي حسابات بالمعايير المدخلة.',
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppDimensions.p16),
                            itemCount: users.length,
                            itemBuilder: (ctx, index) {
                              final u = users[index];
                              return _buildUserCard(u);
                            },
                          ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserEntity u) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.push('/users/${u.id}'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              u.name.isNotEmpty ? u.name.characters.first : 'م',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        u.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: u.isActive
                            ? AppColors.successBg
                            : AppColors.errorBg,
                        borderRadius: AppDimensions.borderRadiusSM,
                      ),
                      child: Text(
                        u.isActive ? 'نشط' : 'معطل',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: u.isActive
                              ? AppColors.success
                              : AppColors.error,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  u.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppDimensions.borderRadiusSM,
                  ),
                  child: Text(
                    u.roleName,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
            onPressed: () => context.push('/users/${u.id}'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip({
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
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusFull,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}
