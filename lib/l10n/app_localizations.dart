import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'بنود'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// No description provided for @navDirectory.
  ///
  /// In en, this message translates to:
  /// **'Directory'**
  String get navDirectory;

  /// No description provided for @directoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Directory'**
  String get directoryTitle;

  /// No description provided for @navItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get navItems;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get navAdd;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsThemeSection.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeSection;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageSection;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get settingsLanguageArabic;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsPersistenceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings on this device — choices reset after restart.'**
  String get settingsPersistenceUnavailable;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @activeClients.
  ///
  /// In en, this message translates to:
  /// **'Active clients'**
  String get activeClients;

  /// No description provided for @homeAppName.
  ///
  /// In en, this message translates to:
  /// **'Bnood'**
  String get homeAppName;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finishing funds, simply'**
  String get homeSubtitle;

  /// No description provided for @homeTotalsCaption.
  ///
  /// In en, this message translates to:
  /// **'Active clients only · Since each project started'**
  String get homeTotalsCaption;

  /// No description provided for @homeSupplierSpendSection.
  ///
  /// In en, this message translates to:
  /// **'Supplier material spend'**
  String get homeSupplierSpendSection;

  /// No description provided for @homeSupplierSpendMeta.
  ///
  /// In en, this message translates to:
  /// **'Active clients only'**
  String get homeSupplierSpendMeta;

  /// No description provided for @homeRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining in active funds'**
  String get homeRemainingLabel;

  /// No description provided for @homeNoActiveClientsTitle.
  ///
  /// In en, this message translates to:
  /// **'No active clients'**
  String get homeNoActiveClientsTitle;

  /// No description provided for @homeNoActiveClientsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a client from the Clients tab to start tracking.'**
  String get homeNoActiveClientsDescription;

  /// No description provided for @homeLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load home'**
  String get homeLoadErrorTitle;

  /// No description provided for @homeNoSupplierSpendTitle.
  ///
  /// In en, this message translates to:
  /// **'No material spend yet'**
  String get homeNoSupplierSpendTitle;

  /// No description provided for @homeNoSupplierSpendDescription.
  ///
  /// In en, this message translates to:
  /// **'Supplier purchases for active clients will show here after you record material expenses.'**
  String get homeNoSupplierSpendDescription;

  /// No description provided for @homeCraftsmenSection.
  ///
  /// In en, this message translates to:
  /// **'Craftsmen with recent labor'**
  String get homeCraftsmenSection;

  /// No description provided for @homeNoCraftsmenTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent labor payments'**
  String get homeNoCraftsmenTitle;

  /// No description provided for @homeNoCraftsmenDescription.
  ///
  /// In en, this message translates to:
  /// **'Labor spend for active clients will show here after you record craftsman payments.'**
  String get homeNoCraftsmenDescription;

  /// No description provided for @deleteMovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get deleteMovementTitle;

  /// No description provided for @deleteMovementBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. Balances and statements will update.'**
  String get deleteMovementBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @statusLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get statusLoading;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add client'**
  String get addClient;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client name'**
  String get clientName;

  /// No description provided for @clientNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter client name'**
  String get clientNameRequired;

  /// No description provided for @clientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Tower North'**
  String get clientNameHint;

  /// No description provided for @pickFromContacts.
  ///
  /// In en, this message translates to:
  /// **'Choose from contacts'**
  String get pickFromContacts;

  /// No description provided for @contactPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open contacts. You can still enter details manually.'**
  String get contactPickFailed;

  /// No description provided for @contactPickChoosePhone.
  ///
  /// In en, this message translates to:
  /// **'Choose a phone number'**
  String get contactPickChoosePhone;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @clientPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'01XXXXXXXXX'**
  String get clientPhoneHint;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @spend.
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get spend;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @labor.
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get labor;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @craftsman.
  ///
  /// In en, this message translates to:
  /// **'Craftsman'**
  String get craftsman;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @movements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get movements;

  /// No description provided for @whatsappLaunchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open WhatsApp'**
  String get whatsappLaunchFailed;

  /// No description provided for @whatsappInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone number can\'t open in WhatsApp'**
  String get whatsappInvalidPhone;

  /// No description provided for @engineerFee.
  ///
  /// In en, this message translates to:
  /// **'Profit percentage (info)'**
  String get engineerFee;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @craftsmen.
  ///
  /// In en, this message translates to:
  /// **'Craftsmen'**
  String get craftsmen;

  /// No description provided for @assignCraftsmen.
  ///
  /// In en, this message translates to:
  /// **'Assign craftsmen'**
  String get assignCraftsmen;

  /// No description provided for @clientDetailNoCraftsmen.
  ///
  /// In en, this message translates to:
  /// **'No craftsmen on this project yet'**
  String get clientDetailNoCraftsmen;

  /// No description provided for @clientDetailNoItemSpend.
  ///
  /// In en, this message translates to:
  /// **'No item spend recorded yet'**
  String get clientDetailNoItemSpend;

  /// No description provided for @clientDetailNoMovements.
  ///
  /// In en, this message translates to:
  /// **'No movements yet'**
  String get clientDetailNoMovements;

  /// No description provided for @clientDetailCraftsmenEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose craftsmen from your directory to link them to this project.'**
  String get clientDetailCraftsmenEmptyDescription;

  /// No description provided for @engineerEstimatedProfitTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated profit'**
  String get engineerEstimatedProfitTitle;

  /// No description provided for @engineerFeeNoRate.
  ///
  /// In en, this message translates to:
  /// **'No rate set'**
  String get engineerFeeNoRate;

  /// No description provided for @engineerFeePercentCaption.
  ///
  /// In en, this message translates to:
  /// **'{percent} of spend'**
  String engineerFeePercentCaption(String percent);

  /// No description provided for @engineerFeeInternalOnly.
  ///
  /// In en, this message translates to:
  /// **'Internal only'**
  String get engineerFeeInternalOnly;

  /// No description provided for @engineerFeeUndefined.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get engineerFeeUndefined;

  /// No description provided for @engineerFeeSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Profit percentage'**
  String get engineerFeeSheetTitle;

  /// No description provided for @engineerFeePercentFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Profit percentage'**
  String get engineerFeePercentFieldLabel;

  /// No description provided for @engineerFeePercentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get engineerFeePercentPlaceholder;

  /// No description provided for @engineerFeeSheetCaption.
  ///
  /// In en, this message translates to:
  /// **'Estimated internal profit only. It is not deducted from the fund, does not create client receivables, and does not appear on the client statement or PDF. Leave blank to clear.'**
  String get engineerFeeSheetCaption;

  /// No description provided for @engineerFeePercentInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 0–100 or leave blank'**
  String get engineerFeePercentInvalid;

  /// No description provided for @clientReceiveMovementDetail.
  ///
  /// In en, this message translates to:
  /// **'Payment from client'**
  String get clientReceiveMovementDetail;

  /// No description provided for @clientDetailUnspecifiedItem.
  ///
  /// In en, this message translates to:
  /// **'Unspecified item'**
  String get clientDetailUnspecifiedItem;

  /// No description provided for @clientDetailNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get clientDetailNoDescription;

  /// No description provided for @archiveClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive client?'**
  String get archiveClientTitle;

  /// No description provided for @archiveClientDescription.
  ///
  /// In en, this message translates to:
  /// **'This moves {name}\'s project to the archive. You can restore it later.'**
  String archiveClientDescription(String name);

  /// No description provided for @craftsmanAgreedAmount.
  ///
  /// In en, this message translates to:
  /// **'Agreed'**
  String get craftsmanAgreedAmount;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @statement.
  ///
  /// In en, this message translates to:
  /// **'Statement'**
  String get statement;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @openingBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening balance'**
  String get openingBalance;

  /// No description provided for @closingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing balance'**
  String get closingBalance;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create new'**
  String get createNew;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @clientsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get clientsFilterAll;

  /// No description provided for @clientsFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get clientsFilterActive;

  /// No description provided for @clientsFilterArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get clientsFilterArchived;

  /// No description provided for @clientsNoArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'No archived clients'**
  String get clientsNoArchivedTitle;

  /// No description provided for @clientsNoArchivedDescription.
  ///
  /// In en, this message translates to:
  /// **'Archived clients appear here after you archive a project.'**
  String get clientsNoArchivedDescription;

  /// No description provided for @clientsNoClientsTitle.
  ///
  /// In en, this message translates to:
  /// **'No clients yet'**
  String get clientsNoClientsTitle;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @voucherAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get voucherAmountRequired;

  /// No description provided for @voucherSelectClient.
  ///
  /// In en, this message translates to:
  /// **'Select a client'**
  String get voucherSelectClient;

  /// No description provided for @voucherSelectItem.
  ///
  /// In en, this message translates to:
  /// **'Select an item'**
  String get voucherSelectItem;

  /// No description provided for @voucherSelectCraftsman.
  ///
  /// In en, this message translates to:
  /// **'Select a craftsman'**
  String get voucherSelectCraftsman;

  /// No description provided for @voucherPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get voucherPickerSearchHint;

  /// No description provided for @voucherPickerNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get voucherPickerNoResults;

  /// No description provided for @voucherPickerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get voucherPickerEmptyTitle;

  /// No description provided for @voucherReceiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get voucherReceiptPhoto;

  /// No description provided for @voucherAttachCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get voucherAttachCamera;

  /// No description provided for @voucherAttachGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get voucherAttachGallery;

  /// No description provided for @voucherReceiptCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access was denied. You can enable it in Settings to photograph receipts.'**
  String get voucherReceiptCameraDenied;

  /// No description provided for @voucherReceiptCameraRestricted.
  ///
  /// In en, this message translates to:
  /// **'Camera access is restricted on this device.'**
  String get voucherReceiptCameraRestricted;

  /// No description provided for @voucherReceiptGalleryDenied.
  ///
  /// In en, this message translates to:
  /// **'Photo access was denied. You can enable it in Settings to attach gallery receipts.'**
  String get voucherReceiptGalleryDenied;

  /// No description provided for @voucherReceiptGalleryRestricted.
  ///
  /// In en, this message translates to:
  /// **'Photo access is restricted on this device.'**
  String get voucherReceiptGalleryRestricted;

  /// No description provided for @voucherReceiptAttachFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not attach the receipt. Try again.'**
  String get voucherReceiptAttachFailed;

  /// No description provided for @voucherAssignCraftsmanFirst.
  ///
  /// In en, this message translates to:
  /// **'Assign craftsmen to the project first'**
  String get voucherAssignCraftsmanFirst;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// No description provided for @voucherReceiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive voucher'**
  String get voucherReceiveTitle;

  /// No description provided for @voucherSpendTitle.
  ///
  /// In en, this message translates to:
  /// **'Spend voucher'**
  String get voucherSpendTitle;

  /// No description provided for @voucherSaveReceive.
  ///
  /// In en, this message translates to:
  /// **'Save receive'**
  String get voucherSaveReceive;

  /// No description provided for @voucherSaveSpend.
  ///
  /// In en, this message translates to:
  /// **'Save spend'**
  String get voucherSaveSpend;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense category'**
  String get expenseCategory;

  /// No description provided for @voucherContextGeneric.
  ///
  /// In en, this message translates to:
  /// **'General voucher · choose client and movement type'**
  String get voucherContextGeneric;

  /// No description provided for @voucherContextClient.
  ///
  /// In en, this message translates to:
  /// **'Voucher for {clientName} · you can change the client below'**
  String voucherContextClient(String clientName);

  /// No description provided for @noteOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Optional…'**
  String get noteOptionalHint;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @directorySuppliersHint.
  ///
  /// In en, this message translates to:
  /// **'Material suppliers · recorded payments only, no payables or credit balances.'**
  String get directorySuppliersHint;

  /// No description provided for @directoryCraftsmenHint.
  ///
  /// In en, this message translates to:
  /// **'Your general craftsman roster · a craftsman can be linked to more than one client.'**
  String get directoryCraftsmenHint;

  /// No description provided for @directorySupplierKindMeta.
  ///
  /// In en, this message translates to:
  /// **'Materials supplier'**
  String get directorySupplierKindMeta;

  /// No description provided for @directoryEmptySuppliersTitle.
  ///
  /// In en, this message translates to:
  /// **'No suppliers yet'**
  String get directoryEmptySuppliersTitle;

  /// No description provided for @directoryEmptySuppliersDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a supplier to your directory, then link them on material spend vouchers.'**
  String get directoryEmptySuppliersDescription;

  /// No description provided for @directoryEmptyCraftsmenTitle.
  ///
  /// In en, this message translates to:
  /// **'No craftsmen yet'**
  String get directoryEmptyCraftsmenTitle;

  /// No description provided for @directoryEmptyCraftsmenDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a craftsman to your directory, then assign them from a client project.'**
  String get directoryEmptyCraftsmenDescription;

  /// No description provided for @directoryAddSupplier.
  ///
  /// In en, this message translates to:
  /// **'Add supplier'**
  String get directoryAddSupplier;

  /// No description provided for @directoryAddCraftsman.
  ///
  /// In en, this message translates to:
  /// **'Add craftsman'**
  String get directoryAddCraftsman;

  /// No description provided for @directoryCraftsmanProjectsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} projects'**
  String directoryCraftsmanProjectsCount(int count);

  /// No description provided for @directoryViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get directoryViewDetails;

  /// No description provided for @archiveSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive supplier?'**
  String get archiveSupplierTitle;

  /// No description provided for @archiveSupplierDescription.
  ///
  /// In en, this message translates to:
  /// **'{name} will be hidden from pickers. Payment history is kept.'**
  String archiveSupplierDescription(String name);

  /// No description provided for @archiveCraftsmanTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive craftsman?'**
  String get archiveCraftsmanTitle;

  /// No description provided for @archiveCraftsmanDescription.
  ///
  /// In en, this message translates to:
  /// **'{name} will be hidden from pickers. Labor history is kept.'**
  String archiveCraftsmanDescription(String name);

  /// No description provided for @supplierNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter supplier name'**
  String get supplierNameRequired;

  /// No description provided for @craftsmanNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter craftsman name'**
  String get craftsmanNameRequired;

  /// No description provided for @craftsmanPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get craftsmanPhoneLabel;

  /// No description provided for @craftsmanPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a phone number'**
  String get craftsmanPhoneRequired;

  /// No description provided for @directorySupplierNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Materials supplier'**
  String get directorySupplierNameHint;

  /// No description provided for @directoryCraftsmanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Plumber'**
  String get directoryCraftsmanNameHint;

  /// No description provided for @supplierTotalPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total paid to supplier'**
  String get supplierTotalPaidLabel;

  /// No description provided for @supplierSpendRecordedCaption.
  ///
  /// In en, this message translates to:
  /// **'Recorded payment transactions only'**
  String get supplierSpendRecordedCaption;

  /// No description provided for @supplierDetailTransactionsSection.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get supplierDetailTransactionsSection;

  /// No description provided for @supplierDetailNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions recorded'**
  String get supplierDetailNoTransactions;

  /// No description provided for @supplierDetailNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Supplier not found'**
  String get supplierDetailNotFoundTitle;

  /// No description provided for @supplierProfilePhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get supplierProfilePhoneLabel;

  /// No description provided for @supplierProfileNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get supplierProfileNotesLabel;

  /// No description provided for @directoryCraftsmanKindMeta.
  ///
  /// In en, this message translates to:
  /// **'Craftsman'**
  String get directoryCraftsmanKindMeta;

  /// No description provided for @craftsmanTotalLaborPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Total labor paid'**
  String get craftsmanTotalLaborPaidLabel;

  /// No description provided for @craftsmanLaborStatCaption.
  ///
  /// In en, this message translates to:
  /// **'Across {count} projects · labor payments only'**
  String craftsmanLaborStatCaption(int count);

  /// No description provided for @craftsmanDetailJobsSection.
  ///
  /// In en, this message translates to:
  /// **'Work by client'**
  String get craftsmanDetailJobsSection;

  /// No description provided for @craftsmanDetailEditAgreement.
  ///
  /// In en, this message translates to:
  /// **'Edit agreement'**
  String get craftsmanDetailEditAgreement;

  /// No description provided for @craftsmanDetailNoAgreedAmount.
  ///
  /// In en, this message translates to:
  /// **'No agreed amount'**
  String get craftsmanDetailNoAgreedAmount;

  /// No description provided for @craftsmanDetailNoJobs.
  ///
  /// In en, this message translates to:
  /// **'No linked client projects'**
  String get craftsmanDetailNoJobs;

  /// No description provided for @craftsmanDetailLaborHistorySection.
  ///
  /// In en, this message translates to:
  /// **'Labor payment history'**
  String get craftsmanDetailLaborHistorySection;

  /// No description provided for @craftsmanDetailNoLaborHistory.
  ///
  /// In en, this message translates to:
  /// **'No labor payments recorded'**
  String get craftsmanDetailNoLaborHistory;

  /// No description provided for @craftsmanDetailNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Craftsman not found'**
  String get craftsmanDetailNotFoundTitle;

  /// No description provided for @craftsmanProfileTradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get craftsmanProfileTradeLabel;

  /// No description provided for @craftsmanProfileNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get craftsmanProfileNotesLabel;

  /// No description provided for @crewAssignmentsIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick from your directory. Agreed amount is optional for this project.'**
  String get crewAssignmentsIntro;

  /// No description provided for @crewAssignmentsProjectContext.
  ///
  /// In en, this message translates to:
  /// **'Project {name}'**
  String crewAssignmentsProjectContext(String name);

  /// No description provided for @craftsmanSetAgreedAmount.
  ///
  /// In en, this message translates to:
  /// **'Set agreed amount'**
  String get craftsmanSetAgreedAmount;

  /// No description provided for @craftsmanEditAgreedAmount.
  ///
  /// In en, this message translates to:
  /// **'Edit agreed amount'**
  String get craftsmanEditAgreedAmount;

  /// No description provided for @craftsmanAgreedAmountSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Agreed amount'**
  String get craftsmanAgreedAmountSheetTitle;

  /// No description provided for @craftsmanAgreedForClientLabel.
  ///
  /// In en, this message translates to:
  /// **'Agreed for this client (optional)'**
  String get craftsmanAgreedForClientLabel;

  /// No description provided for @craftsmanAgreementAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get craftsmanAgreementAmountPlaceholder;

  /// No description provided for @craftsmanAgreementAmountCaption.
  ///
  /// In en, this message translates to:
  /// **'Leave empty if nothing was agreed. Enter 0 when the agreed amount is zero.'**
  String get craftsmanAgreementAmountCaption;

  /// No description provided for @craftsmanAgreementAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative amount or leave blank'**
  String get craftsmanAgreementAmountInvalid;

  /// No description provided for @craftsmanAgreementHasPayments.
  ///
  /// In en, this message translates to:
  /// **'Has recorded payments'**
  String get craftsmanAgreementHasPayments;

  /// No description provided for @directoryAddCraftsmanToRoster.
  ///
  /// In en, this message translates to:
  /// **'Add craftsman to directory'**
  String get directoryAddCraftsmanToRoster;

  /// No description provided for @crewAssignmentsSaved.
  ///
  /// In en, this message translates to:
  /// **'Craftsman choices saved for this client'**
  String get crewAssignmentsSaved;

  /// No description provided for @itemsCatalogCaption.
  ///
  /// In en, this message translates to:
  /// **'Default items — you can add, edit, and archive'**
  String get itemsCatalogCaption;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @itemCreateSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get itemCreateSheetTitle;

  /// No description provided for @itemEditSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get itemEditSheetTitle;

  /// No description provided for @itemNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemNameLabel;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter item name'**
  String get itemNameRequired;

  /// No description provided for @itemNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Insulation'**
  String get itemNameHint;

  /// No description provided for @itemsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get itemsEmptyTitle;

  /// No description provided for @itemsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add an item to categorize project spend.'**
  String get itemsEmptyDescription;

  /// No description provided for @archiveItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive item?'**
  String get archiveItemTitle;

  /// No description provided for @archiveItemDescription.
  ///
  /// In en, this message translates to:
  /// **'{name} will be hidden from lists. Expense history is kept.'**
  String archiveItemDescription(String name);

  /// No description provided for @statementClientHeading.
  ///
  /// In en, this message translates to:
  /// **'Fund / client statement'**
  String get statementClientHeading;

  /// No description provided for @statementPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statementPeriodToday;

  /// No description provided for @statementPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get statementPeriodMonth;

  /// No description provided for @statementPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get statementPeriodAll;

  /// No description provided for @statementTotalReceived.
  ///
  /// In en, this message translates to:
  /// **'Total received'**
  String get statementTotalReceived;

  /// No description provided for @statementTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get statementTotalSpent;

  /// No description provided for @statementClosingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get statementClosingLabel;

  /// No description provided for @statementClosingEndOfPeriod.
  ///
  /// In en, this message translates to:
  /// **'Remaining at period end'**
  String get statementClosingEndOfPeriod;

  /// No description provided for @statementMaterialsLaborSummary.
  ///
  /// In en, this message translates to:
  /// **'Materials total: {materials} | Labor total: {labor}'**
  String statementMaterialsLaborSummary(String materials, String labor);

  /// No description provided for @statementOpeningPeriodNet.
  ///
  /// In en, this message translates to:
  /// **'Opening balance: {opening} · Net movement: {net}'**
  String statementOpeningPeriodNet(String opening, String net);

  /// No description provided for @statementReceiptsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipts from client'**
  String get statementReceiptsSectionTitle;

  /// No description provided for @statementReceiptsSectionCaption.
  ///
  /// In en, this message translates to:
  /// **'Payments appear here only and are not repeated under expense items.'**
  String get statementReceiptsSectionCaption;

  /// No description provided for @statementEmptyReceipts.
  ///
  /// In en, this message translates to:
  /// **'No receipts in the selected period.'**
  String get statementEmptyReceipts;

  /// No description provided for @statementItemSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Item: {name}'**
  String statementItemSectionTitle(String name);

  /// No description provided for @statementItemSectionTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}'**
  String statementItemSectionTotal(String total);

  /// No description provided for @statementItemMaterialsLabor.
  ///
  /// In en, this message translates to:
  /// **'Materials: {materials} | Labor: {labor}'**
  String statementItemMaterialsLabor(String materials, String labor);

  /// No description provided for @statementReconcileSpend.
  ///
  /// In en, this message translates to:
  /// **'Expense check: {materials} materials + {labor} labor = {spent}'**
  String statementReconcileSpend(String materials, String labor, String spent);

  /// No description provided for @statementReconcileBalance.
  ///
  /// In en, this message translates to:
  /// **'{openingPrefix}{received} received − {spent} spent = {closing} remaining'**
  String statementReconcileBalance(
    String openingPrefix,
    String received,
    String spent,
    String closing,
  );

  /// No description provided for @statementIssuedOn.
  ///
  /// In en, this message translates to:
  /// **'Issued: {date}'**
  String statementIssuedOn(String date);

  /// No description provided for @statementPeriodDisplay.
  ///
  /// In en, this message translates to:
  /// **'Period: {label}'**
  String statementPeriodDisplay(String label);

  /// No description provided for @statementCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'Currency: Egyptian pound (EGP)'**
  String get statementCurrencyNote;

  /// No description provided for @statementTableSerial.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get statementTableSerial;

  /// No description provided for @statementTableAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get statementTableAmount;

  /// No description provided for @statementTableDetail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get statementTableDetail;

  /// No description provided for @statementPdfExporting.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF…'**
  String get statementPdfExporting;

  /// No description provided for @statementSupplierHeading.
  ///
  /// In en, this message translates to:
  /// **'Supplier statement'**
  String get statementSupplierHeading;

  /// No description provided for @statementPageFooter.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {pages}'**
  String statementPageFooter(String page, String pages);

  /// No description provided for @statementPeriodCustomize.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get statementPeriodCustomize;

  /// No description provided for @statementPeriodSinceLastExport.
  ///
  /// In en, this message translates to:
  /// **'Since last export'**
  String get statementPeriodSinceLastExport;

  /// No description provided for @statementSinceLastExportUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No prior export yet — choose another range.'**
  String get statementSinceLastExportUnavailable;

  /// No description provided for @statementPeriodDatesHint.
  ///
  /// In en, this message translates to:
  /// **'Dates use inclusive local calendar days.'**
  String get statementPeriodDatesHint;

  /// No description provided for @statementReconcileSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance review'**
  String get statementReconcileSectionTitle;

  /// No description provided for @statementLastExportAt.
  ///
  /// In en, this message translates to:
  /// **'Last successful PDF: {date}'**
  String statementLastExportAt(String date);

  /// No description provided for @statementExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare PDF'**
  String get statementExportFailed;

  /// No description provided for @statementExportShareFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF ready but sharing failed. Try again.'**
  String get statementExportShareFailed;

  /// No description provided for @statementPeriodFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get statementPeriodFrom;

  /// No description provided for @statementPeriodTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get statementPeriodTo;

  /// No description provided for @statementSupplierPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments in period'**
  String get statementSupplierPaymentsTitle;

  /// No description provided for @statementSupplierPaymentsCaption.
  ///
  /// In en, this message translates to:
  /// **'Material spend rows linked to this supplier only.'**
  String get statementSupplierPaymentsCaption;

  /// No description provided for @statementEmptyPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments in the selected period.'**
  String get statementEmptyPayments;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Egypt mobile number only. Your number cannot be changed later.'**
  String get authRegisterSubtitle;

  /// No description provided for @authPhone.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get authPhone;

  /// No description provided for @authPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid Egypt mobile (01XXXXXXXXX)'**
  String get authPhoneInvalid;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authPasswordConfirm;

  /// No description provided for @authCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get authCurrentPassword;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password recovery'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered mobile number.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get authVerificationTitle;

  /// No description provided for @authVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code you received.'**
  String get authVerificationSubtitle;

  /// No description provided for @authRecoveryVerifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the recovery code you received.'**
  String get authRecoveryVerifySubtitle;

  /// No description provided for @authVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get authVerificationCode;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authResendWait.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String authResendWait(int seconds);

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authLoginAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginAction;

  /// No description provided for @authVerifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerifyAction;

  /// No description provided for @authContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authContinue;

  /// No description provided for @authRegisterLink.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authRegisterLink;

  /// No description provided for @authLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authLoginLink;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordAction.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get authResetPasswordAction;

  /// No description provided for @authChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get authChangePassword;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to cloud account'**
  String get authSignIn;

  /// No description provided for @authAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get authAccountSection;

  /// No description provided for @authRemoteWorkspaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get authRemoteWorkspaceTitle;

  /// No description provided for @authRemoteWorkspaceBody.
  ///
  /// In en, this message translates to:
  /// **'You are signed in. Cloud project data is not available in this phase yet.'**
  String get authRemoteWorkspaceBody;

  /// No description provided for @authSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get authSignedInAs;

  /// No description provided for @authBootstrapRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get authBootstrapRetry;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Check the network and try again.'**
  String get authNetworkError;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Phone or password is incorrect.'**
  String get authInvalidCredentials;

  /// No description provided for @authChallengeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Code is invalid or expired.'**
  String get authChallengeInvalid;

  /// No description provided for @authThrottled.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get authThrottled;

  /// No description provided for @authSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again.'**
  String get authSessionExpired;

  /// No description provided for @authFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get authFieldRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get authPasswordMinLength;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordMismatch;

  /// No description provided for @authCodeLengthHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 4–8 characters'**
  String get authCodeLengthHint;

  /// No description provided for @authFlowExpired.
  ///
  /// In en, this message translates to:
  /// **'This step expired. Start again.'**
  String get authFlowExpired;

  /// No description provided for @authPasswordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Sign in with your new password.'**
  String get authPasswordResetSuccess;

  /// No description provided for @authPasswordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get authPasswordChangedSuccess;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
