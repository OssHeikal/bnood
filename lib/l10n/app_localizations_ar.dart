// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بنود';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navClients => 'العملاء';

  @override
  String get navDirectory => 'الدليل';

  @override
  String get directoryTitle => 'الموردين والصنايعية';

  @override
  String get navItems => 'البنود';

  @override
  String get navAdd => 'جديد';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsThemeSection => 'المظهر';

  @override
  String get settingsLanguageSection => 'اللغة';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsPersistenceUnavailable =>
      'تعذر حفظ الإعدادات على الجهاز — ستعود القيم الافتراضية بعد إعادة التشغيل.';

  @override
  String get received => 'وارد';

  @override
  String get spent => 'صادر';

  @override
  String get remaining => 'المتبقي';

  @override
  String get activeClients => 'عملاء نشطون';

  @override
  String get homeAppName => 'بنود';

  @override
  String get homeSubtitle => 'حسابات التشطيب ببساطة';

  @override
  String get homeTotalsCaption => 'للعملاء الناشطين فقط · منذ بداية كل مشروع';

  @override
  String get homeSupplierSpendSection => 'مصروفات الخامات للموردين';

  @override
  String get homeSupplierSpendMeta => 'للعملاء الناشطين فقط';

  @override
  String get homeRemainingLabel => 'المتبقي في العهد الناشطة';

  @override
  String get homeNoActiveClientsTitle => 'مفيش عملاء نشطين';

  @override
  String get homeNoActiveClientsDescription =>
      'أضف عميل من تبويب العملاء عشان تبدأ المتابعة.';

  @override
  String get homeLoadErrorTitle => 'تعذر تحميل الرئيسية';

  @override
  String get homeNoSupplierSpendTitle => 'مفيش مصروف خامات لسه';

  @override
  String get homeNoSupplierSpendDescription =>
      'مصروفات الخامات من الموردين للعملاء الناشطين هتظهر هنا بعد ما تسجّل صرف خامات.';

  @override
  String get homeCraftsmenSection => 'صنايعية بآخر أعمال';

  @override
  String get homeNoCraftsmenTitle => 'مفيش مدفوعات عمالة حديثة';

  @override
  String get homeNoCraftsmenDescription =>
      'مدفوعات العمالة للعملاء الناشطين هتظهر هنا بعد تسجيل صرف عمالة.';

  @override
  String get deleteMovementTitle => 'حذف الحركة دي؟';

  @override
  String get deleteMovementBody => 'لا يمكن التراجع. الأرصدة والكشوف هتتحدّث.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get statusLoading => 'جاري التحميل';

  @override
  String get addClient => 'إضافة عميل';

  @override
  String get clientName => 'اسم العميل';

  @override
  String get clientNameRequired => 'أدخل اسم العميل';

  @override
  String get clientNameHint => 'مثال: برج الشمال';

  @override
  String get pickFromContacts => 'اختيار من جهات الاتصال';

  @override
  String get contactPickFailed =>
      'تعذّر فتح جهات الاتصال. يمكنك الإدخال يدوياً.';

  @override
  String get contactPickChoosePhone => 'اختر رقم التليفون';

  @override
  String get phoneOptional => 'التليفون (اختياري)';

  @override
  String get clientPhoneHint => '01XXXXXXXXX';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get receive => 'استلام';

  @override
  String get spend => 'صرف';

  @override
  String get cash => 'كاش';

  @override
  String get transfer => 'تحويل';

  @override
  String get materials => 'خامات';

  @override
  String get labor => 'مصنعية';

  @override
  String get amount => 'المبلغ';

  @override
  String get date => 'التاريخ';

  @override
  String get descriptionOptional => 'وصف (اختياري)';

  @override
  String get item => 'البند';

  @override
  String get supplier => 'مورد';

  @override
  String get craftsman => 'صنايعي';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get movements => 'الحركات';

  @override
  String get whatsappLaunchFailed => 'تعذّر فتح واتساب';

  @override
  String get whatsappInvalidPhone => 'رقم الهاتف ده مش صالح لفتح واتساب';

  @override
  String get engineerFee => 'نسبة الربح (معلومات)';

  @override
  String get paid => 'مدفوع';

  @override
  String get craftsmen => 'صنايعية';

  @override
  String get assignCraftsmen => 'تحديد الصنايعية';

  @override
  String get clientDetailNoCraftsmen => 'مفيش صنايعية على المشروع ده لسه';

  @override
  String get clientDetailNoItemSpend => 'مفيش صرف بنود مسجّل لسه';

  @override
  String get clientDetailNoMovements => 'مفيش حركات لسه';

  @override
  String get clientDetailCraftsmenEmptyDescription =>
      'اختار الصنايعية من دليلك العام لربطهم بهذا المشروع.';

  @override
  String get engineerEstimatedProfitTitle => 'ربح تقديري';

  @override
  String get engineerFeeNoRate => 'بدون نسبة';

  @override
  String engineerFeePercentCaption(String percent) {
    return '$percent من المصروف';
  }

  @override
  String get engineerFeeInternalOnly => 'داخلي فقط';

  @override
  String get engineerFeeUndefined => 'غير محدد';

  @override
  String get engineerFeeSheetTitle => 'نسبة الربح';

  @override
  String get engineerFeePercentFieldLabel => 'نسبة الربح';

  @override
  String get engineerFeePercentPlaceholder => 'غير محددة';

  @override
  String get engineerFeeSheetCaption =>
      'ربح تقديري داخلي فقط؛ لا يُخصم من العهدة ولا ينشئ مستحقات على العميل، ولا يظهر في كشف حسابه أو ملف PDF. اترك النسبة فارغة لإلغاء الاحتساب.';

  @override
  String get engineerFeePercentInvalid =>
      'أدخل نسبة من 0 إلى 100 أو اتركها فارغة';

  @override
  String get clientReceiveMovementDetail => 'دفعة من العميل';

  @override
  String get clientDetailUnspecifiedItem => 'بند غير محدد';

  @override
  String get clientDetailNoDescription => 'بدون وصف';

  @override
  String get archiveClientTitle => 'أرشفة العميل؟';

  @override
  String archiveClientDescription(String name) {
    return 'أرشفة $name؟ العملية نهائية — العميل المؤرشف للقراءة فقط.';
  }

  @override
  String get clientsSearchHint => 'ابحث بالاسم أو الهاتف';

  @override
  String get amountUnavailable => '—';

  @override
  String get clientDuplicateNameTitle => 'اسم عميل مكرر';

  @override
  String get clientDuplicateNameDescription => 'يوجد عميل بنفس الاسم. متابعة؟';

  @override
  String get clientDuplicateNameConfirm => 'متابعة';

  @override
  String get clientDuplicatePhoneError => 'رقم الهاتف مستخدم لعميل آخر.';

  @override
  String get clientDeleteTitle => 'حذف العميل؟';

  @override
  String clientDeleteDescription(String name) {
    return 'حذف $name؟ سيُحذف العميل والمشروع.';
  }

  @override
  String get clientDeleteHasActivityTitle => 'العميل عليه حركات';

  @override
  String get clientDeleteHasActivityDescription =>
      'هذا العميل مرتبط بمعاملات أو روابط. أرشفه للاحتفاظ بالسجل.';

  @override
  String get clientDeleteArchiveInstead => 'أرشفة بدلًا من ذلك';

  @override
  String get clientArchivedBadge => 'مؤرشف';

  @override
  String get clientLedgerNotOnlineTitle => 'العهدة غير متصلة بعد';

  @override
  String get clientLedgerNotOnlineDescription =>
      'الحركات والأرصدة ستظهر هنا عند تفعيل العهدة أونلاين.';

  @override
  String get craftsmanAgreedAmount => 'المتفق عليه';

  @override
  String get suppliers => 'موردين';

  @override
  String get statement => 'كشف حساب';

  @override
  String get period => 'الفترة';

  @override
  String get openingBalance => 'رصيد أول المدة';

  @override
  String get closingBalance => 'رصيد آخر المدة';

  @override
  String get sharePdf => 'مشاركة PDF';

  @override
  String get createNew => 'إنشاء جديد';

  @override
  String get archive => 'أرشفة';

  @override
  String get unarchive => 'إلغاء الأرشفة';

  @override
  String get clientsFilterAll => 'الكل';

  @override
  String get clientsFilterActive => 'نشط';

  @override
  String get clientsFilterArchived => 'مؤرشف';

  @override
  String get clientsNoArchivedTitle => 'لا يوجد عملاء مؤرشفون';

  @override
  String get clientsNoArchivedDescription =>
      'العملاء المؤرشفون يظهرون هنا بعد أرشفة العهدة.';

  @override
  String get clientsNoClientsTitle => 'لا يوجد عملاء بعد';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get voucherAmountRequired => 'أدخل مبلغًا أكبر من صفر';

  @override
  String get voucherSelectClient => 'اختر العميل';

  @override
  String get voucherSelectItem => 'اختر البند';

  @override
  String get voucherSelectCraftsman => 'اختر الصنايعي';

  @override
  String get voucherPickerSearchHint => 'بحث';

  @override
  String get voucherPickerNoResults => 'لا توجد نتائج';

  @override
  String get voucherPickerEmptyTitle => 'لا يوجد شيء بعد';

  @override
  String get voucherReceiptPhoto => 'صورة إيصال';

  @override
  String get voucherAttachCamera => 'الكاميرا';

  @override
  String get voucherAttachGallery => 'المعرض';

  @override
  String get voucherReceiptCameraDenied =>
      'تم رفض الوصول إلى الكاميرا. يمكنك تفعيله من الإعدادات لتصوير الإيصالات.';

  @override
  String get voucherReceiptCameraRestricted =>
      'الوصول إلى الكاميرا مقيّد على هذا الجهاز.';

  @override
  String get voucherReceiptGalleryDenied =>
      'تم رفض الوصول إلى الصور. يمكنك تفعيله من الإعدادات لإرفاق إيصالات من المعرض.';

  @override
  String get voucherReceiptGalleryRestricted =>
      'الوصول إلى الصور مقيّد على هذا الجهاز.';

  @override
  String get voucherReceiptAttachFailed =>
      'تعذّر إرفاق الإيصال. حاول مرة أخرى.';

  @override
  String get voucherReceiptUploadRetry =>
      'تم حفظ السند. اضغط حفظ مرة أخرى لإعادة رفع صور الإيصال.';

  @override
  String get voucherReceiptDeleteRetry =>
      'تم حفظ السند لكن تعذّر حذف إيصال. اضغط حفظ للمحاولة مرة أخرى.';

  @override
  String get voucherReceiptTooLarge =>
      'صورة الإيصال كبيرة جدًا. جرّب صورة أصغر أو احفظ مرة أخرى بعد الضغط.';

  @override
  String get voucherReceiptCompressFailed =>
      'تعذّر تجهيز صورة الإيصال للرفع. جرّب صورة أخرى أو احفظ مجددًا.';

  @override
  String get voucherReceiptInvalidMime =>
      'نوع الملف غير مقبول. استخدم JPEG أو PNG أو WebP.';

  @override
  String get voucherAssignCraftsmanFirst => 'عيّن صنايعية للمشروع أولًا';

  @override
  String get amountHint => '0.00';

  @override
  String get voucherReceiveTitle => 'سند قبض';

  @override
  String get voucherSpendTitle => 'سند صرف';

  @override
  String get voucherSaveReceive => 'حفظ القبض';

  @override
  String get voucherSaveSpend => 'حفظ الصرف';

  @override
  String get expenseCategory => 'تصنيف المصروف';

  @override
  String get voucherContextGeneric => 'سند عام · اختار العميل ونوع الحركة';

  @override
  String voucherContextClient(String clientName) {
    return 'سند للعميل: $clientName · يمكنك تغيير العميل أدناه';
  }

  @override
  String get noteOptionalHint => 'اختياري…';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get directorySuppliersHint =>
      'موردو الخامات · بيانات وحركات مدفوعة فقط، دون مستحقات أو مديونيات.';

  @override
  String get directoryCraftsmenHint =>
      'دليلك العام للصنايعية · يمكن ربط الصنايعي بأكثر من عميل.';

  @override
  String get directorySupplierKindMeta => 'مورد خامات';

  @override
  String get directoryEmptySuppliersTitle => 'لا يوجد موردون بعد';

  @override
  String get directoryEmptySuppliersDescription =>
      'أضف موردًا للدليل، ثم اربطه عند تسجيل صرف خامات.';

  @override
  String get directoryEmptyCraftsmenTitle => 'لا يوجد صنايعية بعد';

  @override
  String get directoryEmptyCraftsmenDescription =>
      'أضف صنايعيًا للدليل، ثم عيّنه من صفحة العميل.';

  @override
  String get directoryAddSupplier => 'إضافة مورد';

  @override
  String get directoryAddCraftsman => 'إضافة صنايعي';

  @override
  String directoryCraftsmanProjectsCount(int count) {
    return '$count مشروعات';
  }

  @override
  String get directoryViewDetails => 'عرض التفاصيل';

  @override
  String get archiveSupplierTitle => 'أرشفة المورد؟';

  @override
  String archiveSupplierDescription(String name) {
    return 'سيُخفى $name من القوائم. سجل المدفوعات يبقى محفوظًا.';
  }

  @override
  String get archiveCraftsmanTitle => 'أرشفة الصنايعي؟';

  @override
  String archiveCraftsmanDescription(String name) {
    return 'سيُخفى $name من القوائم. سجل المصنعية يبقى محفوظًا.';
  }

  @override
  String get supplierNameRequired => 'أدخل اسم المورد';

  @override
  String get craftsmanNameRequired => 'أدخل اسم الصنايعي';

  @override
  String get craftsmanPhoneLabel => 'التليفون';

  @override
  String get craftsmanPhoneRequired => 'أدخل رقم التليفون';

  @override
  String get directorySupplierNameHint => 'مثال: مورد خامات';

  @override
  String get directoryCraftsmanNameHint => 'مثال: سبّاك';

  @override
  String get supplierTotalPaidLabel => 'إجمالي المدفوع للمورد';

  @override
  String get supplierSpendRecordedCaption => 'حركات مدفوعة مسجلة فقط';

  @override
  String get supplierDetailTransactionsSection => 'سجل التعاملات';

  @override
  String get supplierDetailNoTransactions => 'لا توجد تعاملات مسجلة';

  @override
  String get supplierDetailNotFoundTitle => 'المورد غير موجود';

  @override
  String get supplierProfilePhoneLabel => 'التليفون';

  @override
  String get supplierProfileNotesLabel => 'ملاحظات';

  @override
  String get directoryCraftsmanKindMeta => 'صنايعي';

  @override
  String get craftsmanTotalLaborPaidLabel => 'إجمالي المصنعية المدفوعة';

  @override
  String craftsmanLaborStatCaption(int count) {
    return 'عبر $count مشروعات · يُحسب من حركات المصنعية فقط';
  }

  @override
  String get craftsmanDetailJobsSection => 'العمل حسب العميل';

  @override
  String get craftsmanDetailEditAgreement => 'تعديل الاتفاق';

  @override
  String get craftsmanDetailNoAgreedAmount => 'بدون مبلغ متفق عليه';

  @override
  String get craftsmanDetailNoJobs => 'لا مشروعات عملاء مرتبطة';

  @override
  String get craftsmanDetailLaborHistorySection => 'سجل مدفوعات المصنعية';

  @override
  String get craftsmanDetailNoLaborHistory => 'لا مدفوعات مصنعية مسجلة';

  @override
  String get craftsmanDetailNotFoundTitle => 'الصنايعي غير موجود';

  @override
  String get craftsmanProfileTradeLabel => 'التخصص';

  @override
  String get craftsmanProfileNotesLabel => 'ملاحظات';

  @override
  String get crewAssignmentsIntro =>
      'اختَر من الدليل. المبلغ المتفق عليه اختياري لهذا المشروع.';

  @override
  String crewAssignmentsProjectContext(String name) {
    return 'مشروع $name';
  }

  @override
  String get craftsmanSetAgreedAmount => 'تعيين المبلغ';

  @override
  String get craftsmanEditAgreedAmount => 'تعديل المبلغ';

  @override
  String get craftsmanAgreedAmountSheetTitle => 'المبلغ المتفق عليه';

  @override
  String get craftsmanAgreedForClientLabel =>
      'المتفق عليه لهذا العميل (اختياري)';

  @override
  String get craftsmanAgreementAmountPlaceholder => 'غير محدد';

  @override
  String get craftsmanAgreementAmountCaption =>
      'اتركه فارغًا إن لم يكن هناك اتفاق. أدخل 0 إذا كان المتفق عليه صفرًا.';

  @override
  String get craftsmanAgreementAmountInvalid =>
      'أدخل مبلغًا غير سالب أو اتركه فارغًا';

  @override
  String get craftsmanAgreementHasPayments => 'له مدفوعات مسجلة';

  @override
  String get directoryAddCraftsmanToRoster => 'إضافة صنايعي للدليل';

  @override
  String get crewAssignmentsSaved => 'حُفظت اختيارات الصنايعية لهذا العميل';

  @override
  String get itemsCatalogCaption =>
      'البنود الافتراضية للقراءة فقط — يمكنك إضافة بنودك';

  @override
  String get addItem => 'إضافة بند';

  @override
  String get itemCreateSheetTitle => 'بند جديد';

  @override
  String get itemEditSheetTitle => 'تعديل البند';

  @override
  String get itemNameLabel => 'اسم البند';

  @override
  String get itemNameRequired => 'اكتب اسم البند';

  @override
  String get itemNameHint => 'مثال: عزل';

  @override
  String get itemsEmptyTitle => 'لا توجد بنود بعد';

  @override
  String get itemsEmptyDescription => 'أضف بندًا لتصنيف مصروفات المشروع.';

  @override
  String get deleteItemTitle => 'حذف البند؟';

  @override
  String deleteItemDescription(String name) {
    return 'سيُحذف $name. المصروفات المرتبطة تبقى في السجل.';
  }

  @override
  String get itemInUseError => 'البند مرتبط بمعاملات ولا يمكن حذفه أو تعديله.';

  @override
  String get itemDuplicateNameError => 'يوجد بند بنفس الاسم.';

  @override
  String get providersSearchHint => 'بحث بالاسم أو الهاتف';

  @override
  String get providersFilterAll => 'الكل';

  @override
  String get providersOnlineCaption =>
      'الموردون والصنايعية في دليلك — المدفوعات والاتفاقيات تبقى في المعاملات.';

  @override
  String get providersEmptyAllTitle => 'لا موردين أو صنايعية بعد';

  @override
  String get providersEmptySuppliersTitle => 'لا موردين بعد';

  @override
  String get providersEmptyCraftsmenTitle => 'لا صنايعية بعد';

  @override
  String get providersEmptyDescription =>
      'أضف مورّدًا أو صنايعيًا لربطه ببنود الصرف ومشاريع العملاء.';

  @override
  String get directoryAddProvider => 'إضافة للدليل';

  @override
  String get providerCreateSheetTitle => 'إضافة للدليل';

  @override
  String get providerTypeLabel => 'النوع';

  @override
  String get providerNameLabel => 'الاسم';

  @override
  String get providerNameHint => 'مثال: مورد مواد';

  @override
  String get providerNameRequired => 'أدخل الاسم';

  @override
  String get providerDuplicateNameError => 'هذا الاسم موجود في دليلك.';

  @override
  String get providerDuplicatePhoneError =>
      'رقم الهاتف مستخدم لجهة أخرى في الدليل.';

  @override
  String get providerDetailNotFoundTitle => 'الجهة غير موجودة في الدليل';

  @override
  String get providerDetailLinkedClientsTitle => 'العملاء المرتبطون';

  @override
  String get providerDetailNoLinkedClients => 'لا يوجد عملاء مرتبطون بعد';

  @override
  String get agreementUnlinkTitle => 'إلغاء ربط الصنايعي؟';

  @override
  String agreementUnlinkDescription(String name) {
    return 'سيُزال $name من العميل. يمكنك ربطه مرة أخرى لاحقاً.';
  }

  @override
  String get unlink => 'إلغاء الربط';

  @override
  String get deleteProviderTitle => 'حذف من الدليل؟';

  @override
  String deleteProviderDescription(String name) {
    return 'سيُزال $name من قائمة الدليل.';
  }

  @override
  String get itemDefaultBadge => 'افتراضي';

  @override
  String get itemPickIconLabel => 'الأيقونة';

  @override
  String get itemPickColorLabel => 'اللون';

  @override
  String get statementClientHeading => 'عهدة / كشف حساب العميل';

  @override
  String get statementPeriodToday => 'اليوم';

  @override
  String get statementPeriodMonth => 'هذا الشهر';

  @override
  String get statementPeriodAll => 'كل الفترة';

  @override
  String get statementTotalReceived => 'إجمالي المقبوض';

  @override
  String get statementTotalSpent => 'إجمالي المصروف';

  @override
  String get statementClosingLabel => 'المتبقي';

  @override
  String get statementClosingEndOfPeriod => 'المتبقي بنهاية الفترة';

  @override
  String statementMaterialsLaborSummary(String materials, String labor) {
    return 'إجمالي مونة (خامات): $materials | إجمالي مصنعية: $labor';
  }

  @override
  String statementOpeningPeriodNet(String opening, String net) {
    return 'رصيد أول الفترة: $opening · صافي حركة الفترة: $net';
  }

  @override
  String get statementReceiptsSectionTitle => 'المقبوضات من العميل';

  @override
  String get statementReceiptsSectionCaption =>
      'تُعرض الدفعات هنا فقط، ولا تُكرر داخل بنود المصروفات.';

  @override
  String get statementEmptyReceipts => 'لا توجد مقبوضات في الفترة المحددة.';

  @override
  String statementItemSectionTitle(String name) {
    return 'بند: $name';
  }

  @override
  String statementItemSectionTotal(String total) {
    return 'الإجمالي: $total';
  }

  @override
  String statementItemMaterialsLabor(String materials, String labor) {
    return 'إجمالي مونة (خامات): $materials | إجمالي مصنعية: $labor';
  }

  @override
  String statementReconcileSpend(String materials, String labor, String spent) {
    return 'مراجعة المصروفات: $materials خامات + $labor مصنعية = $spent';
  }

  @override
  String statementReconcileBalance(
    String openingPrefix,
    String received,
    String spent,
    String closing,
  ) {
    return '$openingPrefix$received مقبوض − $spent مصروف = $closing متبقي';
  }

  @override
  String statementIssuedOn(String date) {
    return 'تاريخ الكشف: $date';
  }

  @override
  String statementPeriodDisplay(String label) {
    return 'الفترة: $label';
  }

  @override
  String get statementCurrencyNote => 'العملة: الجنيه المصري (EGP)';

  @override
  String get statementTableSerial => 'م';

  @override
  String get statementTableAmount => 'مبلغ';

  @override
  String get statementTableDetail => 'بيان';

  @override
  String get statementPdfExporting => 'جاري إعداد الملف…';

  @override
  String get statementSupplierHeading => 'كشف حساب مورد';

  @override
  String statementPageFooter(String page, String pages) {
    return 'صفحة $page من $pages';
  }

  @override
  String get statementPeriodCustomize => 'تخصيص الفترة';

  @override
  String get statementPeriodSinceLastExport => 'من آخر تصدير';

  @override
  String get statementSinceLastExportUnavailable =>
      'لا يوجد تصدير سابق بعد — اختر فترة أخرى.';

  @override
  String get statementPeriodDatesHint =>
      'التواريخ باليوم المحلي، شاملة لأول وآخر يوم.';

  @override
  String get statementReconcileSectionTitle => 'مراجعة الرصيد';

  @override
  String statementLastExportAt(String date) {
    return 'آخر تصدير PDF ناجح: $date';
  }

  @override
  String get statementExportFailed => 'تعذّر إعداد ملف PDF';

  @override
  String get statementExportShareFailed =>
      'تم إعداد الملف ولكن تعذّرت المشاركة. أعد المحاولة.';

  @override
  String get statementPeriodFrom => 'من';

  @override
  String get statementPeriodTo => 'إلى';

  @override
  String get statementSupplierPaymentsTitle => 'مدفوعات الفترة';

  @override
  String get statementSupplierPaymentsCaption =>
      'حركات صرف خامات مرتبطة بالمورد فقط.';

  @override
  String get statementEmptyPayments => 'لا توجد مدفوعات في الفترة المحددة.';

  @override
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get authLoginSubtitle =>
      'تابع أموال العملاء والبنود ومشاريع التشطيب من حسابك.';

  @override
  String get authRegisterTitle => 'إنشاء حساب';

  @override
  String get authRegisterSubtitle =>
      'أنشئ حساباً لحفظ مساحة عملك وفتحها من أي موبايل.';

  @override
  String get authPhone => 'رقم الموبايل';

  @override
  String get authPhoneInvalid => 'أدخل رقم موبايل من 11 رقماً يبدأ بـ 01.';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authPasswordConfirm => 'تأكيد كلمة المرور';

  @override
  String get authCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get authNewPassword => 'كلمة المرور الجديدة';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authForgotPasswordTitle => 'استرداد كلمة المرور';

  @override
  String get authForgotPasswordSubtitle =>
      'أدخل رقم الموبايل المسجّل. سنرسل رمز تأكيد.';

  @override
  String get authVerificationTitle => 'رمز التحقق';

  @override
  String get authVerificationSubtitle => 'أدخل رمز التحقق الذي استلمته.';

  @override
  String authVerificationDeliverySubtitle(String phone) {
    return 'أدخل الرمز الذي وصل إلى $phone.';
  }

  @override
  String get authRecoveryVerifySubtitle => 'أدخل رمز الاسترداد الذي استلمته.';

  @override
  String authRecoveryDeliverySubtitle(String phone) {
    return 'أدخل رمز استرجاع كلمة المرور الذي وصل إلى $phone.';
  }

  @override
  String get authCompleteProfileTitle => 'اسمك';

  @override
  String get authCompleteProfileSubtitle =>
      'اكتب اسمك كما يظهر في العمل، ثم اضغط متابعة.';

  @override
  String get authDisplayName => 'الاسم الكامل';

  @override
  String get authDisplayNameHint => 'مثال: أحمد حسن';

  @override
  String get authVerificationCode => 'الرمز';

  @override
  String get authResendCode => 'إعادة إرسال الرمز';

  @override
  String authResendWait(int seconds) {
    return 'انتظر $seconds ث ثم أعد الإرسال.';
  }

  @override
  String get authCreateAccount => 'إنشاء حساب';

  @override
  String get authLoginAction => 'تسجيل الدخول';

  @override
  String get authVerifyAction => 'تحقق';

  @override
  String get authContinue => 'متابعة';

  @override
  String get authRegisterLink => 'مستخدم جديد؟ أنشئ حساباً';

  @override
  String get authLoginLink => 'لديك حساب؟ سجّل الدخول';

  @override
  String get authResetPasswordTitle => 'كلمة مرور جديدة';

  @override
  String get authResetPasswordAction => 'تحديث كلمة المرور';

  @override
  String get authChangePassword => 'تغيير كلمة المرور';

  @override
  String get authSignOut => 'تسجيل الخروج';

  @override
  String get authSignIn => 'تسجيل الدخول للحساب السحابي';

  @override
  String get authAccountSection => 'الحساب';

  @override
  String get authRemoteWorkspaceTitle => 'الحساب';

  @override
  String get authRemoteWorkspaceBody =>
      'تم تسجيل الدخول. بيانات المشاريع على السحابة غير متاحة الآن.';

  @override
  String get shellTabNotOnlineTitle => 'غير متاح على الإنترنت بعد';

  @override
  String get shellTabNotOnlineDescription =>
      'هذا التبويب غير جاهز للاستخدام أونلاين بعد. استخدم «العملاء» لما هو متاح الآن.';

  @override
  String get authSignedInAs => 'مسجّل الدخول كـ';

  @override
  String get authBootstrapRetry => 'إعادة المحاولة';

  @override
  String get authNetworkError =>
      'تعذر الاتصال. تحقق من الشبكة، ثم أعد المحاولة.';

  @override
  String get authInvalidCredentials =>
      'رقم الموبايل أو كلمة المرور غير صحيحة. راجعها ثم حاول مرة أخرى.';

  @override
  String get authChallengeInvalid =>
      'الرمز غير صحيح أو انتهت صلاحيته. اطلب رمزاً جديداً ثم أدخله.';

  @override
  String get authThrottled => 'محاولات كثيرة. انتظر قليلاً، ثم أعد المحاولة.';

  @override
  String get authSessionExpired =>
      'انتهت الجلسة. سجّل الدخول من جديد للمتابعة.';

  @override
  String get authFieldRequired => 'املأ هذا الحقل للمتابعة.';

  @override
  String get authPasswordMinLength =>
      'كلمة المرور قصيرة. استخدم 8 أحرف على الأقل.';

  @override
  String get authPasswordMismatch =>
      'كلمتا المرور مختلفتان. اكتبهما بالنص نفسه.';

  @override
  String get authCodeLengthHint => 'أدخل الرمز المكوّن من 6 أرقام.';

  @override
  String get authAccountExistsTitle => 'الرقم مربوط بحساب';

  @override
  String get authAccountExistsMessage =>
      'هذا الرقم مربوط بحساب بالفعل. سجّل الدخول به أو استخدم رقمًا آخر.';

  @override
  String get authAccountExistsLoginAction => 'تسجيل الدخول';

  @override
  String get authAccountExistsAnotherPhoneAction => 'إدخال رقم آخر';

  @override
  String get authFlowExpired => 'انتهت هذه الخطوة. ابدأ من جديد.';

  @override
  String get authPasswordResetSuccess =>
      'تم تحديث كلمة المرور. سجّل الدخول بالكلمة الجديدة.';

  @override
  String get authPasswordChangedSuccess =>
      'تم تغيير كلمة المرور. استخدم الكلمة الجديدة في المرة القادمة.';
}
