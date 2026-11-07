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
}
