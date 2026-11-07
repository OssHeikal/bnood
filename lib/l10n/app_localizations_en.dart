// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Bnood';

  @override
  String get navHome => 'Home';

  @override
  String get navClients => 'Clients';

  @override
  String get navDirectory => 'Directory';

  @override
  String get directoryTitle => 'Directory';

  @override
  String get navItems => 'Items';

  @override
  String get navAdd => 'New';

  @override
  String get received => 'Received';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get activeClients => 'Active clients';

  @override
  String get homeSubtitle => 'Finishing funds, simply';

  @override
  String get homeTotalsCaption =>
      'Active clients only · Since each project started';

  @override
  String get homeSupplierSpendSection => 'Supplier material spend';

  @override
  String get homeSupplierSpendMeta => 'Active clients only';

  @override
  String get homeRemainingLabel => 'Remaining in active funds';

  @override
  String get homeNoActiveClientsTitle => 'No active clients';

  @override
  String get homeNoActiveClientsDescription =>
      'Add a client from the Clients tab to start tracking.';

  @override
  String get homeLoadErrorTitle => 'Could not load home';

  @override
  String get homeNoSupplierSpendTitle => 'No material spend yet';

  @override
  String get homeNoSupplierSpendDescription =>
      'Supplier purchases for active clients will show here after you record material expenses.';

  @override
  String get retry => 'Retry';

  @override
  String get statusLoading => 'Loading';

  @override
  String get addClient => 'Add client';

  @override
  String get clientName => 'Client name';

  @override
  String get clientNameRequired => 'Enter client name';

  @override
  String get clientNameHint => 'e.g. Tower North';

  @override
  String get phoneOptional => 'Phone (optional)';

  @override
  String get clientPhoneHint => '01XXXXXXXXX';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get receive => 'Receive';

  @override
  String get spend => 'Spend';

  @override
  String get cash => 'Cash';

  @override
  String get transfer => 'Transfer';

  @override
  String get materials => 'Materials';

  @override
  String get labor => 'Labor';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get item => 'Item';

  @override
  String get supplier => 'Supplier';

  @override
  String get craftsman => 'Craftsman';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get seeAll => 'See all';

  @override
  String get movements => 'Movements';

  @override
  String get whatsappLaunchFailed => 'Couldn\'t open WhatsApp';

  @override
  String get whatsappInvalidPhone =>
      'This phone number can\'t open in WhatsApp';

  @override
  String get engineerFee => 'Profit percentage (info)';

  @override
  String get paid => 'Paid';

  @override
  String get craftsmen => 'Craftsmen';

  @override
  String get assignCraftsmen => 'Assign craftsmen';

  @override
  String get clientDetailNoCraftsmen => 'No craftsmen on this project yet';

  @override
  String get clientDetailNoItemSpend => 'No item spend recorded yet';

  @override
  String get clientDetailNoMovements => 'No movements yet';

  @override
  String get clientDetailCraftsmenEmptyDescription =>
      'Choose craftsmen from your directory to link them to this project.';

  @override
  String get engineerEstimatedProfitTitle => 'Estimated profit';

  @override
  String get engineerFeeNoRate => 'No rate set';

  @override
  String engineerFeePercentCaption(String percent) {
    return '$percent of spend';
  }

  @override
  String get engineerFeeInternalOnly => 'Internal only';

  @override
  String get engineerFeeUndefined => 'Not set';

  @override
  String get engineerFeeSheetTitle => 'Profit percentage';

  @override
  String get engineerFeePercentFieldLabel => 'Profit percentage';

  @override
  String get engineerFeePercentPlaceholder => 'Not set';

  @override
  String get engineerFeeSheetCaption =>
      'Estimated internal profit only. It is not deducted from the fund, does not create client receivables, and does not appear on the client statement or PDF. Leave blank to clear.';

  @override
  String get engineerFeePercentInvalid => 'Enter 0–100 or leave blank';

  @override
  String get clientReceiveMovementDetail => 'Payment from client';

  @override
  String get clientDetailUnspecifiedItem => 'Unspecified item';

  @override
  String get clientDetailNoDescription => 'No description';

  @override
  String get archiveClientTitle => 'Archive client?';

  @override
  String archiveClientDescription(String name) {
    return 'This moves $name\'s project to the archive. You can restore it later.';
  }

  @override
  String get craftsmanAgreedAmount => 'Agreed';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get statement => 'Statement';

  @override
  String get period => 'Period';

  @override
  String get openingBalance => 'Opening balance';

  @override
  String get closingBalance => 'Closing balance';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get createNew => 'Create new';

  @override
  String get archive => 'Archive';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get voucherAmountRequired => 'Enter an amount greater than zero';

  @override
  String get voucherSelectClient => 'Select a client';

  @override
  String get voucherSelectItem => 'Select an item';

  @override
  String get voucherSelectCraftsman => 'Select a craftsman';

  @override
  String get voucherPickerSearchHint => 'Search';

  @override
  String get voucherPickerNoResults => 'No matches';

  @override
  String get voucherPickerEmptyTitle => 'Nothing here yet';

  @override
  String get voucherReceiptPhoto => 'Receipt photo';

  @override
  String get voucherAttachCamera => 'Camera';

  @override
  String get voucherAttachGallery => 'Gallery';

  @override
  String get voucherReceiptCameraDenied =>
      'Camera access was denied. You can enable it in Settings to photograph receipts.';

  @override
  String get voucherReceiptCameraRestricted =>
      'Camera access is restricted on this device.';

  @override
  String get voucherReceiptGalleryDenied =>
      'Photo access was denied. You can enable it in Settings to attach gallery receipts.';

  @override
  String get voucherReceiptGalleryRestricted =>
      'Photo access is restricted on this device.';

  @override
  String get voucherReceiptAttachFailed =>
      'Could not attach the receipt. Try again.';

  @override
  String get voucherAssignCraftsmanFirst =>
      'Assign craftsmen to the project first';

  @override
  String get amountHint => '0.00';

  @override
  String get voucherReceiveTitle => 'Receive voucher';

  @override
  String get voucherSpendTitle => 'Spend voucher';

  @override
  String get voucherSaveReceive => 'Save receive';

  @override
  String get voucherSaveSpend => 'Save spend';

  @override
  String get expenseCategory => 'Expense category';

  @override
  String get voucherContextGeneric =>
      'General voucher · choose client and movement type';

  @override
  String voucherContextClient(String clientName) {
    return 'Voucher for $clientName · you can change the client below';
  }

  @override
  String get noteOptionalHint => 'Optional…';

  @override
  String get paymentMethod => 'Payment method';
}
