// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'بنود';

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
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeSection => 'Theme';

  @override
  String get settingsLanguageSection => 'Language';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageArabic => 'العربية';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsPersistenceUnavailable =>
      'Could not save settings on this device — choices reset after restart.';

  @override
  String get received => 'Received';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get activeClients => 'Active clients';

  @override
  String get homeAppName => 'Bnood';

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
  String get clientMovementsLoadErrorTitle => 'Could not load movements';

  @override
  String get homeNoSupplierSpendTitle => 'No material spend yet';

  @override
  String get homeNoSupplierSpendDescription =>
      'Supplier purchases for active clients will show here after you record material expenses.';

  @override
  String get homeCraftsmenSection => 'Craftsmen with recent labor';

  @override
  String get homeNoCraftsmenTitle => 'No recent labor payments';

  @override
  String get homeNoCraftsmenDescription =>
      'Labor spend for active clients will show here after you record craftsman payments.';

  @override
  String get deleteMovementTitle => 'Delete this transaction?';

  @override
  String get deleteMovementBody =>
      'This cannot be undone. Balances and statements will update.';

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
  String get pickFromContacts => 'Choose from contacts';

  @override
  String get contactPickFailed =>
      'Could not open contacts. You can still enter details manually.';

  @override
  String get contactPickChoosePhone => 'Choose a phone number';

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
    return 'Archive $name? This is one-way — archived clients stay read-only.';
  }

  @override
  String get clientsSearchHint => 'Search by name or phone';

  @override
  String get amountUnavailable => '—';

  @override
  String get clientDuplicateNameTitle => 'Same client name';

  @override
  String get clientDuplicateNameDescription =>
      'A client with this name already exists. Continue anyway?';

  @override
  String get clientDuplicateNameConfirm => 'Continue';

  @override
  String get clientDuplicatePhoneError =>
      'This phone number is already used for another client.';

  @override
  String get clientDeleteTitle => 'Delete client?';

  @override
  String clientDeleteDescription(String name) {
    return 'Delete $name? This removes the client and project.';
  }

  @override
  String get clientDeleteHasActivityTitle => 'Client has activity';

  @override
  String get clientDeleteHasActivityDescription =>
      'This client has transactions or links. Archive instead to keep history.';

  @override
  String get clientDeleteArchiveInstead => 'Archive instead';

  @override
  String get clientArchivedBadge => 'Archived';

  @override
  String get clientLedgerNotOnlineTitle => 'Ledger not online yet';

  @override
  String get clientLedgerNotOnlineDescription =>
      'Movements and balances will appear here after the online ledger ships.';

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
  String get unarchive => 'Unarchive';

  @override
  String get clientsFilterAll => 'All';

  @override
  String get clientsFilterActive => 'Active';

  @override
  String get clientsFilterArchived => 'Archived';

  @override
  String get clientsNoArchivedTitle => 'No archived clients';

  @override
  String get clientsNoArchivedDescription =>
      'Archived clients appear here after you archive a project.';

  @override
  String get clientsNoClientsTitle => 'No clients yet';

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
  String get voucherReceiptUploadRetry =>
      'Voucher saved. Tap Save again to retry uploading receipt photos.';

  @override
  String get voucherReceiptDeleteRetry =>
      'Voucher saved but a receipt could not be removed. Tap Save to try again.';

  @override
  String get voucherReceiptTooLarge =>
      'This receipt image is too large. Try a smaller photo or save again after compression.';

  @override
  String get voucherReceiptCompressFailed =>
      'Could not prepare the receipt image for upload. Try another photo or save again.';

  @override
  String get voucherReceiptInvalidMime =>
      'This file type is not accepted. Use JPEG, PNG, or WebP.';

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

  @override
  String get directorySuppliersHint =>
      'Material suppliers · recorded payments only, no payables or credit balances.';

  @override
  String get directoryCraftsmenHint =>
      'Your general craftsman roster · a craftsman can be linked to more than one client.';

  @override
  String get directorySupplierKindMeta => 'Materials supplier';

  @override
  String get directoryEmptySuppliersTitle => 'No suppliers yet';

  @override
  String get directoryEmptySuppliersDescription =>
      'Add a supplier to your directory, then link them on material spend vouchers.';

  @override
  String get directoryEmptyCraftsmenTitle => 'No craftsmen yet';

  @override
  String get directoryEmptyCraftsmenDescription =>
      'Add a craftsman to your directory, then assign them from a client project.';

  @override
  String get directoryAddSupplier => 'Add supplier';

  @override
  String get directoryAddCraftsman => 'Add craftsman';

  @override
  String directoryCraftsmanProjectsCount(int count) {
    return '$count projects';
  }

  @override
  String get directoryViewDetails => 'View details';

  @override
  String get archiveSupplierTitle => 'Archive supplier?';

  @override
  String archiveSupplierDescription(String name) {
    return '$name will be hidden from pickers. Payment history is kept.';
  }

  @override
  String get archiveCraftsmanTitle => 'Archive craftsman?';

  @override
  String archiveCraftsmanDescription(String name) {
    return '$name will be hidden from pickers. Labor history is kept.';
  }

  @override
  String get supplierNameRequired => 'Enter supplier name';

  @override
  String get craftsmanNameRequired => 'Enter craftsman name';

  @override
  String get craftsmanPhoneLabel => 'Phone';

  @override
  String get craftsmanPhoneRequired => 'Enter a phone number';

  @override
  String get directorySupplierNameHint => 'e.g. Materials supplier';

  @override
  String get directoryCraftsmanNameHint => 'e.g. Plumber';

  @override
  String get supplierTotalPaidLabel => 'Total paid to supplier';

  @override
  String get supplierSpendRecordedCaption =>
      'Recorded payment transactions only';

  @override
  String get supplierDetailTransactionsSection => 'Transaction history';

  @override
  String get supplierDetailNoTransactions => 'No transactions recorded';

  @override
  String get supplierDetailNotFoundTitle => 'Supplier not found';

  @override
  String get supplierProfilePhoneLabel => 'Phone';

  @override
  String get supplierProfileNotesLabel => 'Notes';

  @override
  String get directoryCraftsmanKindMeta => 'Craftsman';

  @override
  String get craftsmanTotalLaborPaidLabel => 'Total labor paid';

  @override
  String craftsmanLaborStatCaption(int count) {
    return 'Across $count projects · labor payments only';
  }

  @override
  String get craftsmanDetailJobsSection => 'Work by client';

  @override
  String get craftsmanDetailEditAgreement => 'Edit agreement';

  @override
  String get craftsmanDetailNoAgreedAmount => 'No agreed amount';

  @override
  String get craftsmanDetailNoJobs => 'No linked client projects';

  @override
  String get craftsmanDetailLaborHistorySection => 'Labor payment history';

  @override
  String get craftsmanDetailNoLaborHistory => 'No labor payments recorded';

  @override
  String get craftsmanDetailNotFoundTitle => 'Craftsman not found';

  @override
  String get craftsmanProfileTradeLabel => 'Trade';

  @override
  String get craftsmanProfileNotesLabel => 'Notes';

  @override
  String get crewAssignmentsIntro =>
      'Pick from your directory. Agreed amount is optional for this project.';

  @override
  String crewAssignmentsProjectContext(String name) {
    return 'Project $name';
  }

  @override
  String get craftsmanSetAgreedAmount => 'Set amount';

  @override
  String get craftsmanEditAgreedAmount => 'Edit amount';

  @override
  String get craftsmanAgreedAmountSheetTitle => 'Agreed amount';

  @override
  String get craftsmanAgreedForClientLabel =>
      'Agreed for this client (optional)';

  @override
  String get craftsmanAgreementAmountPlaceholder => 'Not set';

  @override
  String get craftsmanAgreementAmountCaption =>
      'Leave empty if nothing was agreed. Enter 0 when the agreed amount is zero.';

  @override
  String get craftsmanAgreementAmountInvalid =>
      'Enter a non-negative amount or leave blank';

  @override
  String get craftsmanAgreementHasPayments => 'Has recorded payments';

  @override
  String get directoryAddCraftsmanToRoster => 'Add craftsman to directory';

  @override
  String get crewAssignmentsSaved => 'Craftsman choices saved for this client';

  @override
  String get itemsCatalogCaption =>
      'Default items are read-only — add your own items below';

  @override
  String get addItem => 'Add item';

  @override
  String get itemCreateSheetTitle => 'New item';

  @override
  String get itemEditSheetTitle => 'Edit item';

  @override
  String get itemNameLabel => 'Item name';

  @override
  String get itemNameRequired => 'Enter item name';

  @override
  String get itemNameHint => 'e.g. Insulation';

  @override
  String get itemsEmptyTitle => 'No items yet';

  @override
  String get itemsEmptyDescription =>
      'Add an item to categorize project spend.';

  @override
  String get deleteItemTitle => 'Delete item?';

  @override
  String deleteItemDescription(String name) {
    return '$name will be removed. Linked expenses keep their history.';
  }

  @override
  String get itemInUseError =>
      'This item is linked to transactions and cannot be deleted or changed.';

  @override
  String get itemDuplicateNameError => 'An item with this name already exists.';

  @override
  String get providersSearchHint => 'Search by name or phone';

  @override
  String get providersFilterAll => 'All';

  @override
  String get providersOnlineCaption =>
      'Suppliers and craftsmen in your directory — payments and agreements stay on transactions.';

  @override
  String get providersEmptyAllTitle => 'No suppliers or craftsmen yet';

  @override
  String get providersEmptySuppliersTitle => 'No suppliers yet';

  @override
  String get providersEmptyCraftsmenTitle => 'No craftsmen yet';

  @override
  String get providersEmptyDescription =>
      'Add a supplier or craftsman to link them on spend vouchers and client projects.';

  @override
  String get directoryAddProvider => 'Add to directory';

  @override
  String get providerCreateSheetTitle => 'New directory entry';

  @override
  String get providerTypeLabel => 'Type';

  @override
  String get providerNameLabel => 'Name';

  @override
  String get providerNameHint => 'e.g. Materials supplier';

  @override
  String get providerNameRequired => 'Enter a name';

  @override
  String get providerDuplicateNameError =>
      'This name is already in your directory.';

  @override
  String get providerDuplicatePhoneError =>
      'This phone number is already used for another directory entry.';

  @override
  String get providerDetailNotFoundTitle => 'Directory entry not found';

  @override
  String get providerDetailLinkedClientsTitle => 'Linked clients';

  @override
  String get providerDetailNoLinkedClients => 'No linked clients yet';

  @override
  String get agreementUnlinkTitle => 'Unlink craftsman?';

  @override
  String agreementUnlinkDescription(String name) {
    return 'This removes $name from the client. You can link them again later.';
  }

  @override
  String get unlink => 'Unlink';

  @override
  String get deleteProviderTitle => 'Delete from directory?';

  @override
  String deleteProviderDescription(String name) {
    return '$name will be removed from your directory list.';
  }

  @override
  String get itemDefaultBadge => 'Default';

  @override
  String get itemPickIconLabel => 'Icon';

  @override
  String get itemPickColorLabel => 'Color';

  @override
  String get statementClientHeading => 'Fund / client statement';

  @override
  String get statementPeriodToday => 'Today';

  @override
  String get statementPeriodMonth => 'This month';

  @override
  String get statementPeriodAll => 'All time';

  @override
  String get statementTotalReceived => 'Total received';

  @override
  String get statementTotalSpent => 'Total spent';

  @override
  String get statementClosingLabel => 'Remaining';

  @override
  String get statementClosingEndOfPeriod => 'Remaining at period end';

  @override
  String statementMaterialsLaborSummary(String materials, String labor) {
    return 'Materials total: $materials | Labor total: $labor';
  }

  @override
  String statementOpeningPeriodNet(String opening, String net) {
    return 'Opening balance: $opening · Net movement: $net';
  }

  @override
  String get statementReceiptsSectionTitle => 'Receipts from client';

  @override
  String get statementReceiptsSectionCaption =>
      'Payments appear here only and are not repeated under expense items.';

  @override
  String get statementEmptyReceipts => 'No receipts in the selected period.';

  @override
  String statementItemSectionTitle(String name) {
    return 'Item: $name';
  }

  @override
  String statementItemSectionTotal(String total) {
    return 'Total: $total';
  }

  @override
  String statementItemMaterialsLabor(String materials, String labor) {
    return 'Materials: $materials | Labor: $labor';
  }

  @override
  String statementReconcileSpend(String materials, String labor, String spent) {
    return 'Expense check: $materials materials + $labor labor = $spent';
  }

  @override
  String statementReconcileBalance(
    String openingPrefix,
    String received,
    String spent,
    String closing,
  ) {
    return '$openingPrefix$received received − $spent spent = $closing remaining';
  }

  @override
  String statementIssuedOn(String date) {
    return 'Issued: $date';
  }

  @override
  String statementPeriodDisplay(String label) {
    return 'Period: $label';
  }

  @override
  String get statementCurrencyNote => 'Currency: Egyptian pound (EGP)';

  @override
  String get statementTableSerial => '#';

  @override
  String get statementTableAmount => 'Amount';

  @override
  String get statementTableDetail => 'Detail';

  @override
  String get statementPdfExporting => 'Preparing PDF…';

  @override
  String get statementSupplierHeading => 'Supplier statement';

  @override
  String statementPageFooter(String page, String pages) {
    return 'Page $page of $pages';
  }

  @override
  String get statementPeriodCustomize => 'Custom range';

  @override
  String get statementPeriodSinceLastExport => 'Since last export';

  @override
  String get statementSinceLastExportUnavailable =>
      'No prior export yet — choose another range.';

  @override
  String get statementPeriodDatesHint =>
      'Dates use inclusive local calendar days.';

  @override
  String get statementReconcileSectionTitle => 'Balance review';

  @override
  String statementLastExportAt(String date) {
    return 'Last successful PDF: $date';
  }

  @override
  String get statementExportFailed => 'Could not prepare PDF';

  @override
  String get statementExportShareFailed =>
      'PDF ready but sharing failed. Try again.';

  @override
  String get statementPeriodFrom => 'From';

  @override
  String get statementPeriodTo => 'To';

  @override
  String get statementSupplierPaymentsTitle => 'Payments in period';

  @override
  String get statementSupplierPaymentsCaption =>
      'Material spend rows linked to this supplier only.';

  @override
  String get statementEmptyPayments => 'No payments in the selected period.';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authLoginSubtitle =>
      'Track client funds, vouchers, and finishing projects from your account.';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get authRegisterSubtitle =>
      'Create an account to keep your workspace and sign in on another phone.';

  @override
  String get authPhone => 'Mobile number';

  @override
  String get authPhoneInvalid =>
      'Enter an 11-digit mobile number that starts with 01.';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordConfirm => 'Confirm password';

  @override
  String get authCurrentPassword => 'Current password';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authForgotPasswordTitle => 'Password recovery';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter the mobile number on your account. We will send a confirmation code.';

  @override
  String get authVerificationTitle => 'Verification code';

  @override
  String get authVerificationSubtitle =>
      'Enter the verification code you received.';

  @override
  String authVerificationDeliverySubtitle(String phone) {
    return 'Enter the code sent to $phone.';
  }

  @override
  String get authRecoveryVerifySubtitle =>
      'Enter the recovery code you received.';

  @override
  String authRecoveryDeliverySubtitle(String phone) {
    return 'Enter the password recovery code sent to $phone.';
  }

  @override
  String get authCompleteProfileTitle => 'Your name';

  @override
  String get authCompleteProfileSubtitle =>
      'Enter the name you use at work, then tap Continue.';

  @override
  String get authDisplayName => 'Full name';

  @override
  String get authDisplayNameHint => 'e.g. Ahmed Hassan';

  @override
  String get authVerificationCode => 'Code';

  @override
  String get authResendCode => 'Resend code';

  @override
  String authResendWait(int seconds) {
    return 'Wait ${seconds}s, then send again.';
  }

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authLoginAction => 'Sign in';

  @override
  String get authVerifyAction => 'Verify';

  @override
  String get authContinue => 'Continue';

  @override
  String get authRegisterLink => 'New here? Create an account';

  @override
  String get authLoginLink => 'Already have an account? Sign in';

  @override
  String get authResetPasswordTitle => 'New password';

  @override
  String get authResetPasswordAction => 'Update password';

  @override
  String get authChangePassword => 'Change password';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authSignIn => 'Sign in to cloud account';

  @override
  String get authAccountSection => 'Account';

  @override
  String get authRemoteWorkspaceTitle => 'Account';

  @override
  String get authRemoteWorkspaceBody =>
      'You are signed in. Cloud project data is not available yet.';

  @override
  String get shellTabNotOnlineTitle => 'Not available online yet';

  @override
  String get shellTabNotOnlineDescription =>
      'This tab is not ready for online use yet. Use Clients for what is available today.';

  @override
  String get authSignedInAs => 'Signed in as';

  @override
  String get authBootstrapRetry => 'Retry';

  @override
  String get authNetworkError =>
      'Could not connect. Check the network, then try again.';

  @override
  String get authInvalidCredentials =>
      'Mobile number or password is wrong. Check them, then try again.';

  @override
  String get authChallengeInvalid =>
      'That code is wrong or expired. Request a new one, then enter it.';

  @override
  String get authThrottled =>
      'Too many attempts. Wait a moment, then try again.';

  @override
  String get authSessionExpired =>
      'Your session ended. Sign in again to continue.';

  @override
  String get authFieldRequired => 'Fill in this field to continue.';

  @override
  String get authPasswordMinLength =>
      'Password is too short. Use at least 8 characters.';

  @override
  String get authPasswordMismatch =>
      'Those passwords differ. Type the same password in both fields.';

  @override
  String get authCodeLengthHint => 'Enter the 6-digit code.';

  @override
  String get authAccountExistsTitle => 'Phone already linked';

  @override
  String get authAccountExistsMessage =>
      'This phone is already linked to an account. Sign in with that number or use a different phone.';

  @override
  String get authAccountExistsLoginAction => 'Sign in';

  @override
  String get authAccountExistsAnotherPhoneAction => 'Enter another phone';

  @override
  String get authFlowExpired => 'This step expired. Start again.';

  @override
  String get authPasswordResetSuccess =>
      'Password updated. Sign in with the new one.';

  @override
  String get authPasswordChangedSuccess =>
      'Password changed. Use the new one next time.';
}
