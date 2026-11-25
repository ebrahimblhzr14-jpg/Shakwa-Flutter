import '../models/user_model.dart';
import '../models/category_model.dart';
import '../models/priority_model.dart';
import '../models/status_model.dart';
import '../models/complaint_model.dart';
import '../models/comment_model.dart';
import '../models/history_model.dart';

class MockDatabase {
  MockDatabase._();

  static final MockDatabase instance = MockDatabase._();

  // Current logged in user
  UserModel? currentUser;

  // In-memory data collections
  late List<UserModel> users;
  late List<CategoryModel> categories;
  late List<PriorityModel> priorities;
  late List<StatusModel> statuses;
  late List<ComplaintModel> complaints;
  late List<HistoryModel> history;

  void initialize() {
    _initUsers();
    _initCategories();
    _initPriorities();
    _initStatuses();
    _initComplaints();
    _initHistory();

    // Default current user to standard User for initial app load
    currentUser = users[0];
  }

  void _initUsers() {
    users = [
      UserModel(
        id: 'usr-1',
        fullName: 'أحمد محمد الشمري',
        email: 'user@shakwa.sa',
        phone: '0551234567',
        role: UserRole.user,
        department: 'مستفيد خارجي',
        isActive: true,
        createdAt: DateTime(2025, 1, 10),
      ),
      UserModel(
        id: 'usr-2',
        fullName: 'م. سارة خالد العتيبي',
        email: 'admin@shakwa.sa',
        phone: '0559876543',
        role: UserRole.admin,
        department: 'قسم الإنارة والكهرباء',
        isActive: true,
        createdAt: DateTime(2024, 6, 15),
      ),
      UserModel(
        id: 'usr-3',
        fullName: 'د. فيصل عبدالعزيز المقرن',
        email: 'super@shakwa.sa',
        phone: '0501122334',
        role: UserRole.superAdmin,
        department: 'الإدارة العامة للمتابعة والبلاغات',
        isActive: true,
        createdAt: DateTime(2023, 12, 1),
      ),
      UserModel(
        id: 'usr-4',
        fullName: 'م. خالد إبراهيم المنصور',
        email: 'khaled@shakwa.sa',
        phone: '0543322114',
        role: UserRole.admin,
        department: 'قسم الطرق والجسور والأرصفة',
        isActive: true,
        createdAt: DateTime(2024, 7, 20),
      ),
      UserModel(
        id: 'usr-5',
        fullName: 'أ. فاطمة ناصر الدوسري',
        email: 'fatima@shakwa.sa',
        phone: '0567788990',
        role: UserRole.admin,
        department: 'قسم الإصحاح البيئي والنظافة',
        isActive: true,
        createdAt: DateTime(2024, 8, 5),
      ),
      UserModel(
        id: 'usr-6',
        fullName: 'م. عمر سليمان الحربي',
        email: 'omar@shakwa.sa',
        phone: '0534455667',
        role: UserRole.admin,
        department: 'قسم شبكات المياه والصرف',
        isActive: true,
        createdAt: DateTime(2024, 9, 1),
      ),
      UserModel(
        id: 'usr-7',
        fullName: 'نورة عبدالله القحطاني',
        email: 'noura@shakwa.sa',
        phone: '0598877665',
        role: UserRole.user,
        department: 'مستفيدة',
        isActive: true,
        createdAt: DateTime(2025, 2, 12),
      ),
    ];
  }

  void _initCategories() {
    categories = [
      const CategoryModel(
        id: 'cat-1',
        name: 'إنارة الطرق والشوارع',
        description:
            'بلاغات أعمدة الإنارة المطفأة، الأسلاك المكشوفة، ومشاكل التغذية الكهربائية',
        iconCode: 'lightbulb',
        isActive: true,
        complaintsCount: 14,
      ),
      const CategoryModel(
        id: 'cat-2',
        name: 'هبوط وحفر الأسفلت',
        description:
            'تشققات الطرق، حفر الإسفلت، المطبات غير النظامية، والأرصفة المتهالكة',
        iconCode: 'road',
        isActive: true,
        complaintsCount: 22,
      ),
      const CategoryModel(
        id: 'cat-3',
        name: 'النظافة وتراكم النفايات',
        description:
            'تكدس الحاويات، مخلفات البناء، الهدم العشوائي ونظافة الأماكن العامة',
        iconCode: 'cleaning',
        isActive: true,
        complaintsCount: 35,
      ),
      const CategoryModel(
        id: 'cat-4',
        name: 'تسربات المياه والصرف',
        description:
            'كسور أنابيب المياه، طفح مياه الصرف الصحي، وانسداد فتحات التصريف',
        iconCode: 'water',
        isActive: true,
        complaintsCount: 18,
      ),
      const CategoryModel(
        id: 'cat-5',
        name: 'الحدائق والمرافق العامة',
        description:
            'صيانة المسطحات الخضراء، ألعاب الأطفال، المقاعد، ودورات المياه العامة',
        iconCode: 'park',
        isActive: true,
        complaintsCount: 9,
      ),
      const CategoryModel(
        id: 'cat-6',
        name: 'المخالفات التجارية والبلدية',
        description:
            'التعديات على الأرصفة، إشغال الطرق، وعدم الالتزام بالاشتراطات البلدية',
        iconCode: 'store',
        isActive: true,
        complaintsCount: 11,
      ),
    ];
  }

  void _initPriorities() {
    priorities = [
      const PriorityModel(
        id: 'prio-1',
        name: 'منخفضة',
        level: PriorityLevel.low,
        description: 'بلاغات تحسينية غير طارئة لا تؤثر على السلامة العامة',
        slaHours: 72,
      ),
      const PriorityModel(
        id: 'prio-2',
        name: 'متوسطة',
        level: PriorityLevel.medium,
        description: 'مشكلات دورية تتطلب متابعة خلال المدة النظامية المعتادة',
        slaHours: 48,
      ),
      const PriorityModel(
        id: 'prio-3',
        name: 'عالية',
        level: PriorityLevel.high,
        description:
            'مشكلات تسبب تعطيل لحركة السير أو إزعاجاً متكرراً للمواطنين',
        slaHours: 24,
      ),
      const PriorityModel(
        id: 'prio-4',
        name: 'حرجة / طارئة',
        level: PriorityLevel.urgent,
        description:
            'مخاطر فورية على الأرواح أو السلامة العامة مثل التماسات أو هبوط أرضي مفاجئ',
        slaHours: 6,
      ),
    ];
  }

  void _initStatuses() {
    statuses = [
      const StatusModel(
        id: 'stat-1',
        name: 'جديدة',
        status: ComplaintStatus.pending,
        description: 'تم تقديم البلاغ بنجاح وينتظر التدقيق والتوجيه',
        isDefault: true,
        order: 1,
      ),
      const StatusModel(
        id: 'stat-2',
        name: 'قيد المراجعة',
        status: ComplaintStatus.underReview,
        description: 'البلاغ يخضع للفحص الفني والفرز وتحديد القسم المختص',
        isDefault: false,
        order: 2,
      ),
      const StatusModel(
        id: 'stat-3',
        name: 'قيد المعالجة',
        status: ComplaintStatus.inProgress,
        description: 'تم تسليم البلاغ للفرقة الميدانية وبدء أعمال الإصلاح',
        isDefault: false,
        order: 3,
      ),
      const StatusModel(
        id: 'stat-4',
        name: 'تم الحل',
        status: ComplaintStatus.resolved,
        description: 'تم إنجاز العمل الميداني وإصلاح المشكلة بنجاح',
        isDefault: false,
        order: 4,
      ),
      const StatusModel(
        id: 'stat-5',
        name: 'مغلقة',
        status: ComplaintStatus.closed,
        description: 'أغلقت الشكوى بعد تأكيد المستفيد ورضاه عن الخدمة',
        isDefault: false,
        order: 5,
      ),
      const StatusModel(
        id: 'stat-6',
        name: 'مرفوضة',
        status: ComplaintStatus.rejected,
        description: 'البلاغ مكرر أو خارج النطاق الجغرافي والاختصاص البلدي',
        isDefault: false,
        order: 6,
      ),
    ];
  }

  void _initComplaints() {
    complaints = [
      ComplaintModel(
        id: 'c-101',
        complaintNumber: 'SHK-2026-101',
        title: 'عطل كامل في أعمدة إنارة الشارع التجاري',
        description:
            'توقفت 6 أعمدة إنارة رئيسية عن العمل مما أدى إلى ظلام دامس في التقاطع وخطورة على المارة والسيارات خلال ساعات الليل.',
        category: 'إنارة الطرق والشوارع',
        priority: PriorityLevel.high,
        status: ComplaintStatus.inProgress,
        location: 'حي الياسمين، تقاطع طريق أنس بن مالك مع شارع القادسية',
        attachments: ['assets/images/logo.png'],
        submittedByUserId: 'usr-1',
        submittedByName: 'أحمد محمد الشمري',
        assignedToUserId: 'usr-2',
        assignedToName: 'م. سارة خالد العتيبي',
        department: 'قسم الإنارة والكهرباء',
        createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
        comments: [
          CommentModel(
            id: 'cm-1',
            complaintId: 'c-101',
            userId: 'usr-1',
            userName: 'أحمد محمد الشمري',
            userRoleText: 'مقدم الشكوى',
            message:
                'نرجو الإسراع في الحل للأهمية القصوى لأن الشارع حيوي ومظلم جداً.',
            createdAt: DateTime.now().subtract(
              const Duration(days: 1, hours: 10),
            ),
          ),
          CommentModel(
            id: 'cm-2',
            complaintId: 'c-101',
            userId: 'usr-2',
            userName: 'م. سارة خالد العتيبي',
            userRoleText: 'مشرف معالجة',
            message:
                'تم استلام البلاغ وتم تحريك فرقة الصيانة الميدانية لفحص القاطع الرئيسي وعلبة التغذية.',
            createdAt: DateTime.now().subtract(const Duration(hours: 4)),
          ),
        ],
      ),
      ComplaintModel(
        id: 'c-102',
        complaintNumber: 'SHK-2026-102',
        title: 'هبوط أسفلتي عميق يهدد المركبات',
        description:
            'يوجد هبوط في طبقة الأسفلت بعمق 15 سم أمام مدخل الحي، تسبب في أضرار لعدة سيارات أثناء الدخول.',
        category: 'هبوط وحفر الأسفلت',
        priority: PriorityLevel.urgent,
        status: ComplaintStatus.pending,
        location: 'حي النرجس، شارع رقم 42 بجوار مدرسة الأمل',
        attachments: [],
        submittedByUserId: 'usr-1',
        submittedByName: 'أحمد محمد الشمري',
        assignedToUserId: null,
        assignedToName: null,
        department: 'قسم الطرق والجسور والأرصفة',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
        comments: [],
      ),
      ComplaintModel(
        id: 'c-103',
        complaintNumber: 'SHK-2026-103',
        title: 'تراكم نفايات بناء تعيق الرصيف',
        description:
            'قام مقاول بناء بإلقاء مخلفات حفر وبناء على الرصيف العام مما أجبر المشاة على النزول لحرم الشارع.',
        category: 'النظافة وتراكم النفايات',
        priority: PriorityLevel.medium,
        status: ComplaintStatus.resolved,
        location: 'حي العارض، شارع وادي الساحل، أمام عمارة 89',
        attachments: ['assets/images/logo.png'],
        submittedByUserId: 'usr-1',
        submittedByName: 'أحمد محمد الشمري',
        assignedToUserId: 'usr-5',
        assignedToName: 'أ. فاطمة ناصر الدوسري',
        department: 'قسم الإصحاح البيئي والنظافة',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        rating: 5,
        feedbackText:
            'تمت إزالة المخلفات بالكامل وتنظيف الموقع بشكل ممتاز وسريع، شكراً لكم.',
        comments: [
          CommentModel(
            id: 'cm-3',
            complaintId: 'c-103',
            userId: 'usr-5',
            userName: 'أ. فاطمة ناصر الدوسري',
            userRoleText: 'مشرف معالجة',
            message:
                'تم إلزام المقاول برفع المخلفات وتطبيق الغرامة البلدية وتنظيف الموقع.',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      ComplaintModel(
        id: 'c-104',
        complaintNumber: 'SHK-2026-104',
        title: 'كسر في أنبوب مياه رئيسي بالحديقة',
        description:
            'تدفق كميات كبيرة من المياه الصالحة للشرب في الحديقة العامة نتيجة كسر ماسورة الري.',
        category: 'تسربات المياه والصرف',
        priority: PriorityLevel.high,
        status: ComplaintStatus.underReview,
        location: 'حي الصحافة، حديقة اليمامة، مخرج 5',
        attachments: [],
        submittedByUserId: 'usr-7',
        submittedByName: 'نورة عبدالله القحطاني',
        assignedToUserId: 'usr-6',
        assignedToName: 'م. عمر سليمان الحربي',
        department: 'قسم شبكات المياه والصرف',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        comments: [],
      ),
      ComplaintModel(
        id: 'c-105',
        complaintNumber: 'SHK-2026-105',
        title: 'طلب صيانة ألعاب الأطفال المكسورة',
        description:
            'أرجوحة وزحليقة حديدية مكسورة في حديقة الحي وتسبب خطراً على سلامة الأطفال.',
        category: 'الحدائق والمرافق العامة',
        priority: PriorityLevel.low,
        status: ComplaintStatus.inProgress,
        location: 'حي الملقا، شارع الأمير محمد بن سعد',
        attachments: [],
        submittedByUserId: 'usr-7',
        submittedByName: 'نورة عبدالله القحطاني',
        assignedToUserId: 'usr-2',
        assignedToName: 'م. سارة خالد العتيبي',
        department: 'قسم الحدائق والتشجير',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        comments: [],
      ),
      ComplaintModel(
        id: 'c-106',
        complaintNumber: 'SHK-2026-106',
        title: 'إشغال رصيف مشاة من قبل معرض سيارات',
        description:
            'وقوف سيارات المعرض فوق كامل رصيف المشاة مما يعطل كبار السن وعربات الأطفال.',
        category: 'المخالفات التجارية والبلدية',
        priority: PriorityLevel.medium,
        status: ComplaintStatus.rejected,
        location: 'حي الشفا، طريق ديراب',
        attachments: [],
        submittedByUserId: 'usr-1',
        submittedByName: 'أحمد محمد الشمري',
        assignedToUserId: null,
        assignedToName: null,
        department: 'قسم الرقابة الشاملة',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
        comments: [
          CommentModel(
            id: 'cm-4',
            complaintId: 'c-106',
            userId: 'usr-3',
            userName: 'د. فيصل عبدالعزيز المقرن',
            userRoleText: 'مسؤول عام',
            message:
                'تم رفض البلاغ لعدم وضوح المعالم وسبق التعامل مع الموقع بمحضر ضبط منفصل.',
            createdAt: DateTime.now().subtract(const Duration(days: 9)),
          ),
        ],
      ),
    ];
  }

  void _initHistory() {
    history = [
      HistoryModel(
        id: 'h-1',
        complaintId: 'c-101',
        complaintNumber: 'SHK-2026-101',
        actionTitle: 'تغيير حالة الشكوى',
        actionDescription:
            'تم تغيير الحالة من قيد المراجعة إلى قيد المعالجة الميدانية',
        performedByUserId: 'usr-2',
        performedByName: 'م. سارة خالد العتيبي',
        performedByRole: 'مشرف معالجة',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        previousStatus: ComplaintStatus.underReview,
        newStatus: ComplaintStatus.inProgress,
      ),
      HistoryModel(
        id: 'h-2',
        complaintId: 'c-101',
        complaintNumber: 'SHK-2026-101',
        actionTitle: 'إسناد الشكوى لموظف',
        actionDescription:
            'تم إسناد الشكوى إلى المهندسة سارة العتيبي - قسم الإنارة',
        performedByUserId: 'usr-3',
        performedByName: 'د. فيصل عبدالعزيز المقرن',
        performedByRole: 'مسؤول عام',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      HistoryModel(
        id: 'h-3',
        complaintId: 'c-101',
        complaintNumber: 'SHK-2026-101',
        actionTitle: 'تسجيل بلاغ جديد',
        actionDescription: 'قام المواطن بتقديم الشكوى عبر التطبيق المتنقل',
        performedByUserId: 'usr-1',
        performedByName: 'أحمد محمد الشمري',
        performedByRole: 'مواطن',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 3)),
        newStatus: ComplaintStatus.pending,
      ),
      HistoryModel(
        id: 'h-4',
        complaintId: 'c-103',
        complaintNumber: 'SHK-2026-103',
        actionTitle: 'إغلاق وحل الشكوى',
        actionDescription:
            'تم تنظيف الموقع وإلزام المخالف ووضع الشكوى كـ تم الحل',
        performedByUserId: 'usr-5',
        performedByName: 'أ. فاطمة ناصر الدوسري',
        performedByRole: 'مشرف معالجة',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        previousStatus: ComplaintStatus.inProgress,
        newStatus: ComplaintStatus.resolved,
      ),
    ];
  }
}
