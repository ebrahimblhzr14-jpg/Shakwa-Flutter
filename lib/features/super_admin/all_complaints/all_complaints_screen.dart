import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../../core/widgets/complaint_card.dart';
import '../../complaints/presentation/bloc/all_complaints_bloc.dart';
import '../../complaints/presentation/bloc/all_complaints_event.dart';
import '../../complaints/presentation/bloc/all_complaints_state.dart';

class AllComplaintsScreen extends StatefulWidget {
  final AllComplaintsBloc? bloc;

  const AllComplaintsScreen({super.key, this.bloc});

  @override
  State<AllComplaintsScreen> createState() => _AllComplaintsScreenState();
}

class _AllComplaintsScreenState extends State<AllComplaintsScreen> {
  late final AllComplaintsBloc _bloc;
  final _searchController = TextEditingController();
  int? _selectedStatusId;
  bool _onlyUnassigned = false;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? sl<AllComplaintsBloc>();
    _bloc.add(const LoadAllComplaintsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (widget.bloc == null) {
      _bloc.close();
    }
    super.dispose();
  }

  void _applyFilter({bool? onlyUnassigned, int? statusId}) {
    _bloc.add(
      FilterAllComplaintsEvent(
        onlyUnassigned: onlyUnassigned ?? _onlyUnassigned,
        statusId: statusId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.navSuperAllComplaints,
        subtitle: 'الرقابة الشاملة على كافة بلاغات المنظومة',
        showRoleSwitcher: true,
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.p16),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _bloc.add(SearchAllComplaintsEvent(val));
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'بحث برقم الشكوى، العنوان، اسم المواطن...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _bloc.add(const SearchAllComplaintsEvent(''));
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
                      FilterChip(
                        label: const Text('غير المسندة فقط'),
                        selected: _onlyUnassigned,
                        onSelected: (val) {
                          setState(() => _onlyUnassigned = val);
                          _applyFilter(
                            onlyUnassigned: val,
                            statusId: _selectedStatusId,
                          );
                        },
                        selectedColor: AppColors.warning.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.warning,
                        labelStyle: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _onlyUnassigned
                              ? AppColors.warning
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        'الكل',
                        _selectedStatusId == null && !_onlyUnassigned,
                        () {
                          setState(() {
                            _selectedStatusId = null;
                            _onlyUnassigned = false;
                          });
                          _applyFilter(onlyUnassigned: false, statusId: null);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildChip('جديدة', _selectedStatusId == 1, () {
                        setState(() => _selectedStatusId = 1);
                        _applyFilter(statusId: 1);
                      }),
                      const SizedBox(width: 8),
                      _buildChip('قيد المعالجة', _selectedStatusId == 3, () {
                        setState(() => _selectedStatusId = 3);
                        _applyFilter(statusId: 3);
                      }),
                      const SizedBox(width: 8),
                      _buildChip('تم الحل', _selectedStatusId == 4, () {
                        setState(() => _selectedStatusId = 4);
                        _applyFilter(statusId: 4);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Complaints List
          Expanded(
            child: BlocBuilder<AllComplaintsBloc, AllComplaintsState>(
              bloc: _bloc,
              builder: (context, state) {
                if (state is AllComplaintsLoadingState ||
                    state is AllComplaintsInitialState) {
                  return const AppLoadingIndicator(
                    message: 'جاري تحميل قائمة البلاغات الشاملة...',
                  );
                }

                if (state is AllComplaintsErrorState) {
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
                                const LoadAllComplaintsEvent(isRefresh: true),
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

                if (state is AllComplaintsLoadedState) {
                  final list = state.filteredComplaints;

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      _bloc.add(const LoadAllComplaintsEvent(isRefresh: true));
                    },
                    child: list.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 60),
                              child: AppEmptyState(
                                title: 'لا توجد شكاوى مطابقة',
                                description:
                                    'جرّب تعديل الفلاتر أو عبارة البحث.',
                                actionText: 'إعادة ضبط البحث',
                                onAction: () {
                                  _searchController.clear();
                                  setState(() {
                                    _selectedStatusId = null;
                                    _onlyUnassigned = false;
                                  });
                                  _applyFilter(
                                    onlyUnassigned: false,
                                    statusId: null,
                                  );
                                },
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppDimensions.p16),
                            itemCount: list.length,
                            itemBuilder: (ctx, index) {
                              final complaint = list[index];
                              final legacyModel = complaint.toLegacyModel();
                              final isPending = complaint.statusId == 1;

                              return ComplaintCard(
                                complaint: legacyModel,
                                onTap: () =>
                                    context.push('/complaint/${complaint.id}'),
                                trailingAction: isPending
                                    ? OutlinedButton.icon(
                                        onPressed: () => context.push(
                                          '/complaint/${complaint.id}/assign',
                                        ),
                                        icon: const Icon(
                                          Icons.person_add_alt_1,
                                          size: 14,
                                        ),
                                        label: const Text(
                                          'إسناد',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 11,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(
                                            color: AppColors.primary,
                                            width: 1,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 0,
                                          ),
                                          minimumSize: const Size(60, 30),
                                        ),
                                      )
                                    : null,
                              );
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
