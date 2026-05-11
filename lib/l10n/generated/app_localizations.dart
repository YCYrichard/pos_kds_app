import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'POS KDS App'**
  String get appTitle;

  /// No description provided for @tabFrontdesk.
  ///
  /// In en, this message translates to:
  /// **'Frontdesk'**
  String get tabFrontdesk;

  /// No description provided for @tabKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get tabKitchen;

  /// No description provided for @tabBackoffice.
  ///
  /// In en, this message translates to:
  /// **'Backoffice'**
  String get tabBackoffice;

  /// No description provided for @frontdeskTitle.
  ///
  /// In en, this message translates to:
  /// **'Frontdesk'**
  String get frontdeskTitle;

  /// No description provided for @orderTypeDineIn.
  ///
  /// In en, this message translates to:
  /// **'Dine in'**
  String get orderTypeDineIn;

  /// No description provided for @orderTypeTakeaway.
  ///
  /// In en, this message translates to:
  /// **'Takeaway'**
  String get orderTypeTakeaway;

  /// No description provided for @tableNumber.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get tableNumber;

  /// No description provided for @pickupNumber.
  ///
  /// In en, this message translates to:
  /// **'Pickup no.'**
  String get pickupNumber;

  /// No description provided for @orderingTitle.
  ///
  /// In en, this message translates to:
  /// **'Ordering'**
  String get orderingTitle;

  /// No description provided for @pleaseEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter number'**
  String get pleaseEnterNumber;

  /// No description provided for @noSpicyLevel.
  ///
  /// In en, this message translates to:
  /// **'No spicy level'**
  String get noSpicyLevel;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// No description provided for @currentOrder.
  ///
  /// In en, this message translates to:
  /// **'Current order'**
  String get currentOrder;

  /// No description provided for @orderSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Order submitted successfully'**
  String get orderSubmitted;

  /// No description provided for @submitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// No description provided for @submitOrder.
  ///
  /// In en, this message translates to:
  /// **'Submit order'**
  String get submitOrder;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @releaseTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Release table'**
  String get releaseTableTitle;

  /// No description provided for @releaseTableShort.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get releaseTableShort;

  /// No description provided for @releaseTableConfirm.
  ///
  /// In en, this message translates to:
  /// **'Release table {tableNo}?'**
  String releaseTableConfirm(Object tableNo);

  /// No description provided for @releaseTableDone.
  ///
  /// In en, this message translates to:
  /// **'Table {tableNo} released'**
  String releaseTableDone(Object tableNo);

  /// No description provided for @noAvailableTables.
  ///
  /// In en, this message translates to:
  /// **'No available tables. Release a table or wait for an order to finish.'**
  String get noAvailableTables;

  /// No description provided for @noOccupiedTables.
  ///
  /// In en, this message translates to:
  /// **'No occupied tables'**
  String get noOccupiedTables;

  /// No description provided for @kitchenTitle.
  ///
  /// In en, this message translates to:
  /// **'Kitchen KDS'**
  String get kitchenTitle;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldestFirst;

  /// No description provided for @sortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewestFirst;

  /// No description provided for @noPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'No pending orders'**
  String get noPendingOrders;

  /// No description provided for @itemCompleted.
  ///
  /// In en, this message translates to:
  /// **'Item completed'**
  String get itemCompleted;

  /// No description provided for @backofficeTitle.
  ///
  /// In en, this message translates to:
  /// **'Backoffice summary'**
  String get backofficeTitle;

  /// No description provided for @orderListTitle.
  ///
  /// In en, this message translates to:
  /// **'Order list'**
  String get orderListTitle;

  /// No description provided for @noOrderRecords.
  ///
  /// In en, this message translates to:
  /// **'No order records'**
  String get noOrderRecords;

  /// No description provided for @todayOrders.
  ///
  /// In en, this message translates to:
  /// **'Today\'s orders'**
  String get todayOrders;

  /// No description provided for @pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingOrders;

  /// No description provided for @todayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s revenue'**
  String get todayRevenue;

  /// No description provided for @dineInWithTable.
  ///
  /// In en, this message translates to:
  /// **'Dine in | Table {tableNo}'**
  String dineInWithTable(Object tableNo);

  /// No description provided for @takeawayWithPickup.
  ///
  /// In en, this message translates to:
  /// **'Takeaway | Pickup no. {pickupNo}'**
  String takeawayWithPickup(Object pickupNo);

  /// No description provided for @createdTime.
  ///
  /// In en, this message translates to:
  /// **'Created time'**
  String get createdTime;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total items'**
  String get totalItems;

  /// No description provided for @orderDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailTitle;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order no.'**
  String get orderNumber;

  /// No description provided for @orderTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get orderTypeLabel;

  /// No description provided for @tableLabel.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get tableLabel;

  /// No description provided for @pickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup no.'**
  String get pickupLabel;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @completedTime.
  ///
  /// In en, this message translates to:
  /// **'Completed time'**
  String get completedTime;

  /// No description provided for @itemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsTitle;

  /// No description provided for @statusCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get statusCreated;

  /// No description provided for @statusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @noSpicyConfigured.
  ///
  /// In en, this message translates to:
  /// **'No spicy level'**
  String get noSpicyConfigured;

  /// No description provided for @spicyLevelValue.
  ///
  /// In en, this message translates to:
  /// **'Spicy level {level}'**
  String spicyLevelValue(Object level);

  /// No description provided for @quantityWithSpicy.
  ///
  /// In en, this message translates to:
  /// **'Qty {qty} | {spicy}'**
  String quantityWithSpicy(Object qty, Object spicy);

  /// No description provided for @currentOrderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get currentOrderEmpty;

  /// No description provided for @spicyNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Spicy: not selected'**
  String get spicyNotSelected;

  /// No description provided for @spicyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Spicy: {level}'**
  String spicyPrefix(Object level);

  /// No description provided for @orderPrefix.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNo}'**
  String orderPrefix(Object orderNo);

  /// No description provided for @typePrefix.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String typePrefix(Object type);

  /// No description provided for @tablePrefix.
  ///
  /// In en, this message translates to:
  /// **'Table: {tableNo}'**
  String tablePrefix(Object tableNo);

  /// No description provided for @pickupPrefix.
  ///
  /// In en, this message translates to:
  /// **'Pickup no.: {pickupNo}'**
  String pickupPrefix(Object pickupNo);

  /// No description provided for @completeAction.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeAction;

  /// No description provided for @orderDetailPageStub.
  ///
  /// In en, this message translates to:
  /// **'Order detail page skeleton created'**
  String get orderDetailPageStub;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
