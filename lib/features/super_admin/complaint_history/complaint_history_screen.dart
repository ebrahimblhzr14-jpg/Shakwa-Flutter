import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_loading_indicator.dart';
import '../../complaints/domain/entities/complaint_history_item.dart';
import '../../complaints/domain/repositories/i_complaint_repository.dart';

class ComplaintHistoryScreen extends StatefulWidget {
  final IComplaintRepository? complaintRepository;

  const ComplaintHistoryScreen({super.key, this.complaintRepository});

  @override
  State<ComplaintHistoryScreen> createState() => _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState extends State<ComplaintHistoryScreen> {
  late final IComplaintRepository _repo;
  final _searchController = TextEditingController();
  List<ComplaintHistoryItem> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repo = widget.complaintRepository ?? sl<IComplaintRepository>();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _repo.getGlobalComplaintHistory();

    if (mounted) {
      res.fold(
        (failure) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (items) {
          setState(() {
            _history = items;
            _isLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(
        title: AppStrings.complaintHistory,
        subtitle: 'سجل التتبع والتدقيق الزمني للبلاغات',
        showRoleSwitcher: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.p16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'بحث برقم الشكوى، اسم الموظف، أو نوع الإجراء...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
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
          ),

          // History Audit Log Timeline
          Expanded(child: _buildTimelineContent()),
        ],
      ),
    );
  }

  Widget _buildTimelineContent() {
    if (_isLoading) {
      return const AppLoadingIndicator(
        message: 'جاري تحميل سجل النشاطات والأحداث...',
      );
    }

    if (_errorMessage != null) {
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.p16),
              ElevatedButton.icon(
                onPressed: _loadHistory,
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

    var filtered = List<ComplaintHistoryItem>.from(_history);
    final query = _searchController.text.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (h) =>
                h.complaintId.toString().contains(query) ||
                h.action.toLowerCase().contains(query) ||
                (h.description?.toLowerCase().contains(query) ?? false) ||
                (h.userName?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    if (filtered.isEmpty) {
      return const AppEmptyState(
        title: 'لا توجد سجلات نشاط مطابقة',
        description: 'لم يتم العثور على أي أحداث أو حركات تطابق معايير البحث.',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.p16),
        itemCount: filtered.length,
        itemBuilder: (ctx, index) {
          final h = filtered[index];
          final timeStr = DateFormat(
            'yyyy/MM/dd – hh:mm a',
          ).format(h.createdAt);

          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: () => context.push('/complaint/${h.complaintId}'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history_toggle_off_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.p12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                              '#${h.complaintId}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        h.action,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      if (h.description != null &&
                          h.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          h.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Cairo',
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_pin_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'بواسطة: ${h.userName ?? "النظام"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
