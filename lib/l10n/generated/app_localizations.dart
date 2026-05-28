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

  /// Application title.
  ///
  /// In en, this message translates to:
  /// **'POS KDS App'**
  String get appTitle;

  /// Frontdesk tab label.
  ///
  /// In en, this message translates to:
  /// **'Frontdesk'**
  String get tabFrontdesk;

  /// Kitchen tab label.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get tabKitchen;

  /// Backoffice tab label.
  ///
  /// In en, this message translates to:
  /// **'Backoffice'**
  String get tabBackoffice;

  /// Frontdesk page title.
  ///
  /// In en, this message translates to:
  /// **'Frontdesk'**
  String get frontdeskTitle;

  /// Kitchen page title.
  ///
  /// In en, this message translates to:
  /// **'Kitchen KDS'**
  String get kitchenTitle;

  /// Backoffice summary page title.
  ///
  /// In en, this message translates to:
  /// **'Backoffice summary'**
  String get backofficeTitle;

  /// Label for dine-in order type.
  ///
  /// In en, this message translates to:
  /// **'Dine in'**
  String get orderTypeDineIn;

  /// Label for takeaway order type.
  ///
  /// In en, this message translates to:
  /// **'Takeaway'**
  String get orderTypeTakeaway;

  /// Generic label for order type.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get orderTypeLabel;

  /// Short table number label.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get tableNumber;

  /// Generic label for table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get tableLabel;

  /// Short pickup number label.
  ///
  /// In en, this message translates to:
  /// **'Pickup no.'**
  String get pickupNumber;

  /// Generic label for pickup number.
  ///
  /// In en, this message translates to:
  /// **'Pickup no.'**
  String get pickupLabel;

  /// Ordering section title.
  ///
  /// In en, this message translates to:
  /// **'Ordering'**
  String get orderingTitle;

  /// Prompt asking the user to enter a number.
  ///
  /// In en, this message translates to:
  /// **'Please enter number'**
  String get pleaseEnterNumber;

  /// Option meaning no spicy level selected.
  ///
  /// In en, this message translates to:
  /// **'No spicy level'**
  String get noSpicyLevel;

  /// Button label to add an item.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get addItem;

  /// Current order section title.
  ///
  /// In en, this message translates to:
  /// **'Current order'**
  String get currentOrder;

  /// Shown when the current order is empty.
  ///
  /// In en, this message translates to:
  /// **'No items added yet'**
  String get currentOrderEmpty;

  /// Message shown after an order is submitted successfully.
  ///
  /// In en, this message translates to:
  /// **'Order submitted successfully'**
  String get orderSubmitted;

  /// Loading text shown while submitting an order.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting;

  /// Button label to submit the order.
  ///
  /// In en, this message translates to:
  /// **'Submit order'**
  String get submitOrder;

  /// Common refresh action label.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// Common cancel action label.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Common confirm action label.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// Dialog title for releasing a table.
  ///
  /// In en, this message translates to:
  /// **'Release table'**
  String get releaseTableTitle;

  /// Short action label for releasing a table.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get releaseTableShort;

  /// Confirmation message for releasing a table.
  ///
  /// In en, this message translates to:
  /// **'Release table {tableNo}?'**
  String releaseTableConfirm(Object tableNo);

  /// Message shown after a table is released.
  ///
  /// In en, this message translates to:
  /// **'Table {tableNo} released'**
  String releaseTableDone(Object tableNo);

  /// Message shown when there are no available tables.
  ///
  /// In en, this message translates to:
  /// **'No available tables. Release a table or wait for an order to finish.'**
  String get noAvailableTables;

  /// Message shown when there are no occupied tables.
  ///
  /// In en, this message translates to:
  /// **'No occupied tables'**
  String get noOccupiedTables;

  /// Generic sort label.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// Sorting option for oldest orders first.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldestFirst;

  /// Sorting option for newest orders first.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewestFirst;

  /// Message shown when there are no pending kitchen orders.
  ///
  /// In en, this message translates to:
  /// **'No pending orders'**
  String get noPendingOrders;

  /// Message shown when an order item is completed.
  ///
  /// In en, this message translates to:
  /// **'Item completed'**
  String get itemCompleted;

  /// Order list section title.
  ///
  /// In en, this message translates to:
  /// **'Order list'**
  String get orderListTitle;

  /// Message shown when there are no order records.
  ///
  /// In en, this message translates to:
  /// **'No order records'**
  String get noOrderRecords;

  /// Message shown when backoffice data fails to load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load backoffice data'**
  String get backofficeLoadFailed;

  /// Dashboard label for today's order count.
  ///
  /// In en, this message translates to:
  /// **'Today\'s orders'**
  String get todayOrders;

  /// Dashboard label for pending orders.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingOrders;

  /// Dashboard label for today's revenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s revenue'**
  String get todayRevenue;

  /// Order summary text for dine-in orders with table number.
  ///
  /// In en, this message translates to:
  /// **'Dine in | Table {tableNo}'**
  String dineInWithTable(Object tableNo);

  /// Order summary text for takeaway orders with pickup number.
  ///
  /// In en, this message translates to:
  /// **'Takeaway | Pickup no. {pickupNo}'**
  String takeawayWithPickup(Object pickupNo);

  /// Label for order created time.
  ///
  /// In en, this message translates to:
  /// **'Created time'**
  String get createdTime;

  /// Label for order completed time.
  ///
  /// In en, this message translates to:
  /// **'Completed time'**
  String get completedTime;

  /// Label for total item count in an order.
  ///
  /// In en, this message translates to:
  /// **'Total items'**
  String get totalItems;

  /// Order detail page or sheet title.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetailTitle;

  /// Label for order number.
  ///
  /// In en, this message translates to:
  /// **'Order no.'**
  String get orderNumber;

  /// Generic status label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// Items section title.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get itemsTitle;

  /// Order status label for created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get statusCreated;

  /// Order status label for preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get statusPreparing;

  /// Order status label for completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// Message shown when no spicy setting is configured.
  ///
  /// In en, this message translates to:
  /// **'No spicy setting'**
  String get noSpicyConfigured;

  /// Message displaying a spicy level value.
  ///
  /// In en, this message translates to:
  /// **'Spicy level {level}'**
  String spicyLevelValue(Object level);

  /// Message displaying quantity and spicy level together.
  ///
  /// In en, this message translates to:
  /// **'Qty {qty} | {spicy}'**
  String quantityWithSpicy(Object qty, Object spicy);

  /// Message shown when spicy level is not selected.
  ///
  /// In en, this message translates to:
  /// **'Spicy: not selected'**
  String get spicyNotSelected;

  /// Prefix label for spicy level value.
  ///
  /// In en, this message translates to:
  /// **'Spicy: {value}'**
  String spicyPrefix(Object value);

  /// Prefix label for order number.
  ///
  /// In en, this message translates to:
  /// **'Order {orderNo}'**
  String orderPrefix(Object orderNo);

  /// Prefix label for order type value.
  ///
  /// In en, this message translates to:
  /// **'Type: {value}'**
  String typePrefix(Object value);

  /// Prefix label for table value.
  ///
  /// In en, this message translates to:
  /// **'Table: {value}'**
  String tablePrefix(Object value);

  /// Prefix label for pickup number value.
  ///
  /// In en, this message translates to:
  /// **'Pickup no.: {value}'**
  String pickupPrefix(Object value);

  /// Action label to complete an item or order.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeAction;

  /// Temporary stub text for order detail page.
  ///
  /// In en, this message translates to:
  /// **'Order detail page scaffold created'**
  String get orderDetailPageStub;

  /// Validation message asking the user to enter an item code first.
  ///
  /// In en, this message translates to:
  /// **'Please enter item code first'**
  String get enterItemCodeFirst;

  /// Message shown when an entered item code is not found.
  ///
  /// In en, this message translates to:
  /// **'Item code {itemCode} not found'**
  String itemCodeNotFound(Object itemCode);

  /// Message shown after an item is added to the order.
  ///
  /// In en, this message translates to:
  /// **'Added {itemName}'**
  String itemAdded(Object itemName);

  /// Message shown after an item is removed from the order.
  ///
  /// In en, this message translates to:
  /// **'Removed {itemName}'**
  String itemRemoved(Object itemName);

  /// Validation message shown when trying to submit an empty order.
  ///
  /// In en, this message translates to:
  /// **'An order must contain at least one item'**
  String get orderNeedsAtLeastOneItem;

  /// Validation message shown when a dine-in order has no table selected.
  ///
  /// In en, this message translates to:
  /// **'Please select a table for dine-in'**
  String get dineInSelectTable;

  /// Message shown when takeaway serial number is not ready.
  ///
  /// In en, this message translates to:
  /// **'Takeaway serial number is not ready yet'**
  String get takeawaySerialNotReady;

  /// Spicy level label for mild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get spicyMild;

  /// Spicy level label for medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get spicyMedium;

  /// Spicy level label for hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get spicyHot;
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
