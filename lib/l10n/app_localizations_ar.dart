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
  String get received => 'وارد';

  @override
  String get spent => 'صادر';

  @override
  String get remaining => 'المتبقي';

  @override
  String get activeClients => 'عملاء نشطون';

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
    return 'هتنقل عهدة $name للأرشيف. تقدر ترجعها بعدين.';
  }

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
  String get craftsmanSetAgreedAmount => 'تعيين المبلغ المتفق عليه';

  @override
  String get craftsmanEditAgreedAmount => 'تعديل المبلغ المتفق عليه';

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
      'البنود الافتراضية — يمكنك الإضافة والتعديل والأرشفة';

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
  String get archiveItemTitle => 'أرشفة البند؟';

  @override
  String archiveItemDescription(String name) {
    return 'سيُخفى $name من القوائم. سجل المصروفات يبقى محفوظًا.';
  }

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
}
