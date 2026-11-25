/// Centralized Arabic Strings for Shakwa (شكوى)
class AppStrings {
  AppStrings._();

  // App Identity
  static const String appName = 'شكوى';
  static const String appEnglishName = 'Shakwa';
  static const String appTagline = 'نظام إدارة ومتابعة الشكاوى الذكي';

  // Roles
  static const String roleUser = 'مواطن / مستخدم';
  static const String roleAdmin = 'مشرف معالجة (Admin)';
  static const String roleSuperAdmin = 'مسؤول عام (SuperAdmin)';

  // Authentication
  static const String loginTitle = 'تسجيل الدخول';
  static const String loginSubtitle =
      'أهلاً بك، الرجاء تسجيل الدخول لمتابعة حسابك';
  static const String emailOrUsername = 'البريد الإلكتروني أو اسم المستخدم';
  static const String email = 'البريد الإلكتروني';
  static const String fullName = 'الاسم الكامل';
  static const String password = 'كلمة المرور';
  static const String confirmPassword = 'تأكيد كلمة المرور';
  static const String loginButton = 'دخول';
  static const String registerButton = 'إنشاء حساب جديد';
  static const String registerTitle = 'إنشاء حساب جديد';
  static const String registerSubtitle = 'أدخل بياناتك للانضمام إلى منصة شكوى';
  static const String noAccount = 'ليس لديك حساب؟';
  static const String haveAccount = 'لديك حساب بالفعل؟';
  static const String forgotPassword = 'نسيت كلمة المرور؟';
  static const String quickMockLogin = 'تسجيل دخول تجريبي سريع:';

  // Navigation
  static const String navHome = 'الرئيسية';
  static const String navComplaints = 'شكاواي';
  static const String navNewComplaint = 'تقديم شكوى';
  static const String navProfile = 'حسابي';
  static const String navAdminAssigned = 'الشكاوى المسندة';
  static const String navAdminManagement = 'إدارة النظام';
  static const String navSuperAllComplaints = 'كل الشكاوى';
  static const String navSuperUsers = 'المستخدمين';
  static const String navSuperHistory = 'سجل الشكاوى';

  // User Dashboard
  static const String welcomeBack = 'مرحباً بك مجدداً';
  static const String dashboardStats = 'نظرة عامة على الشكاوى';
  static const String totalComplaints = 'إجمالي الشكاوى';
  static const String pendingComplaints = 'قيد الانتظار';
  static const String inProgressComplaints = 'قيد المعالجة';
  static const String resolvedComplaints = 'تم الحل';
  static const String rejectedComplaints = 'مرفوضة';
  static const String recentComplaints = 'أحدث الشكاوى المسجلة';
  static const String viewAll = 'عرض الكل';
  static const String quickActions = 'إجراءات سريعة';
  static const String addNewComplaintAction = 'تقديم بلاغ جديد';

  // Complaint Management
  static const String complaintNumber = 'رقم الشكوى';
  static const String complaintTitle = 'عنوان الشكوى';
  static const String complaintDescription = 'تفاصيل الشكوى';
  static const String complaintCategory = 'التصنيف';
  static const String complaintPriority = 'الأولوية';
  static const String complaintLocation = 'موقع المشكلة / العنوان';
  static const String complaintStatus = 'حالة الشكوى';
  static const String complaintDate = 'تاريخ التقديم';
  static const String attachments = 'المرفقات والوثائق';
  static const String addAttachment = 'إضافة مرفق';
  static const String selectCategory = 'اختر التصنيف المناسب';
  static const String selectPriority = 'اختر مستوى الأولوية';
  static const String enterTitleHint = 'مثال: انقطاع إنارة الشارع الرئيسي';
  static const String enterDescHint =
      'اشرح المشكلة بالتفصيل ومكانها وما ترغب بحله...';
  static const String enterLocationHint =
      'مثال: حي النور، شارع السلام، مبنى رقم 14';

  // Status Labels
  static const String statusPendingLabel = 'جديدة';
  static const String statusUnderReviewLabel = 'قيد المراجعة';
  static const String statusInProgressLabel = 'قيد المعالجة';
  static const String statusResolvedLabel = 'تم الحل';
  static const String statusClosedLabel = 'مغلقة';
  static const String statusRejectedLabel = 'مرفوضة';

  // Priorities
  static const String priorityLowLabel = 'منخفضة';
  static const String priorityMediumLabel = 'متوسطة';
  static const String priorityHighLabel = 'عالية';
  static const String priorityUrgentLabel = 'حرجة / طارئة';

  // Actions & Buttons
  static const String submit = 'إرسال';
  static const String save = 'حفظ التعديلات';
  static const String cancel = 'إلغاء';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String assign = 'إسناد';
  static const String searchHint = 'بحث برقم الشكوى، العنوان، أو التصنيف...';
  static const String filterAll = 'الكل';
  static const String comments = 'التعليقات والمتابعات';
  static const String addComment = 'إضافة تعليق';
  static const String commentHint = 'اكتب تعليقك أو استفسارك هنا...';
  static const String ratingTitle = 'تقييم جودة الخدمة';
  static const String ratingSubtitle = 'كيف كانت تجربتك في حل هذه الشكوى؟';
  static const String submitRating = 'إرسال التقييم';
  static const String logout = 'تسجيل الخروج';
  static const String logoutConfirmMsg =
      'هل أنت متأكد من رغبتك في تسجيل الخروج من التطبيق؟';

  // Confirmation & Feedback
  static const String confirmTitle = 'تأكيد العملية';
  static const String successTitle = 'تمت العملية بنجاح';
  static const String complaintCreatedSuccess =
      'تم تقديم شكواك بنجاح وجاري مراجعتها من قبل الفريق المختص.';
  static const String complaintUpdatedSuccess = 'تم حفظ تعديلات الشكوى بنجاح.';
  static const String deleteConfirmMsg =
      'هل أنت متأكد من رغبتك في الحذف؟ لا يمكن التراجع عن هذا الإجراء.';
  static const String assignSuccessMsg =
      'تم إسناد الشكوى إلى الموظف المسؤول بنجاح.';
  static const String statusUpdatedSuccess = 'تم تحديث حالة الشكوى بنجاح.';

  // Validation
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'الرجاء إدخال بريد إلكتروني صحيح';
  static const String shortPassword = 'كلمة المرور يجب أن لا تقل عن 6 خانات';
  static const String passwordMismatch = 'كلمتا المرور غير متطابقتين';

  // Management Screen
  static const String tabCategories = 'التصنيفات';
  static const String tabPriorities = 'مستويات الأولوية';
  static const String tabStatuses = 'حالات الشكاوى';
  static const String addNewCategory = 'إضافة تصنيف جديد';
  static const String addNewPriority = 'إضافة أولوية جديدة';
  static const String addNewStatus = 'إضافة حالة جديدة';

  // SuperAdmin
  static const String superAdminDashboard = 'لوحة التحكم المركزية';
  static const String assignToEmployee = 'إسناد الشكوى إلى موظف';
  static const String selectEmployee = 'اختر الموظف المختص';
  static const String selectDepartment = 'اختر القسم';
  static const String usersList = 'قائمة مستخدمي النظام';
  static const String userDetails = 'تفاصيل حساب المستخدم';
  static const String complaintHistory = 'سجل النشاطات والأحداث';
  static const String filterByRole = 'تصفية حسب الدور';
}
