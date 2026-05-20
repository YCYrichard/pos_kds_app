// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'POS KDS App';

  @override
  String get tabFrontdesk => 'Frontdesk';

  @override
  String get tabKitchen => 'Kitchen';

  @override
  String get tabBackoffice => 'Backoffice';

  @override
  String get frontdeskTitle => 'Frontdesk';

  @override
  String get kitchenTitle => 'Kitchen KDS';

  @override
  String get backofficeTitle => 'Backoffice summary';

  @override
  String get orderTypeDineIn => 'Dine in';

  @override
  String get orderTypeTakeaway => 'Takeaway';

  @override
  String get orderTypeLabel => 'Order type';

  @override
  String get tableNumber => 'Table';

  @override
  String get tableLabel => 'Table';

  @override
  String get pickupNumber => 'Pickup no.';

  @override
  String get pickupLabel => 'Pickup no.';

  @override
  String get orderingTitle => 'Ordering';

  @override
  String get pleaseEnterNumber => 'Please enter number';

  @override
  String get noSpicyLevel => 'No spicy level';

  @override
  String get addItem => 'Add item';

  @override
  String get currentOrder => 'Current order';

  @override
  String get currentOrderEmpty => 'No items added yet';

  @override
  String get orderSubmitted => 'Order submitted successfully';

  @override
  String get submitting => 'Submitting...';

  @override
  String get submitOrder => 'Submit order';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get releaseTableTitle => 'Release table';

  @override
  String get releaseTableShort => 'Release';

  @override
  String releaseTableConfirm(Object tableNo) {
    return 'Release table $tableNo?';
  }

  @override
  String releaseTableDone(Object tableNo) {
    return 'Table $tableNo released';
  }

  @override
  String get noAvailableTables =>
      'No available tables. Release a table or wait for an order to finish.';

  @override
  String get noOccupiedTables => 'No occupied tables';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortOldestFirst => 'Oldest first';

  @override
  String get sortNewestFirst => 'Newest first';

  @override
  String get noPendingOrders => 'No pending orders';

  @override
  String get itemCompleted => 'Item completed';

  @override
  String get orderListTitle => 'Order list';

  @override
  String get noOrderRecords => 'No order records';

  @override
  String get backofficeLoadFailed => 'Failed to load backoffice data';

  @override
  String get todayOrders => 'Today\'s orders';

  @override
  String get pendingOrders => 'Pending';

  @override
  String get todayRevenue => 'Today\'s revenue';

  @override
  String dineInWithTable(Object tableNo) {
    return 'Dine in | Table $tableNo';
  }

  @override
  String takeawayWithPickup(Object pickupNo) {
    return 'Takeaway | Pickup no. $pickupNo';
  }

  @override
  String get createdTime => 'Created time';

  @override
  String get completedTime => 'Completed time';

  @override
  String get totalItems => 'Total items';

  @override
  String get orderDetailTitle => 'Order details';

  @override
  String get orderNumber => 'Order no.';

  @override
  String get statusLabel => 'Status';

  @override
  String get itemsTitle => 'Items';

  @override
  String get statusCreated => 'Created';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get noSpicyConfigured => 'No spicy setting';

  @override
  String spicyLevelValue(Object level) {
    return 'Spicy level $level';
  }

  @override
  String quantityWithSpicy(Object qty, Object spicy) {
    return 'Qty $qty | $spicy';
  }

  @override
  String get spicyNotSelected => 'Spicy: not selected';

  @override
  String spicyPrefix(Object value) {
    return 'Spicy: $value';
  }

  @override
  String orderPrefix(Object orderNo) {
    return 'Order $orderNo';
  }

  @override
  String typePrefix(Object value) {
    return 'Type: $value';
  }

  @override
  String tablePrefix(Object value) {
    return 'Table: $value';
  }

  @override
  String pickupPrefix(Object value) {
    return 'Pickup no.: $value';
  }

  @override
  String get completeAction => 'Complete';

  @override
  String get orderDetailPageStub => 'Order detail page scaffold created';

  @override
  String get enterItemCodeFirst => 'Please enter item code first';

  @override
  String itemCodeNotFound(Object itemCode) {
    return 'Item code $itemCode not found';
  }

  @override
  String itemAdded(Object itemName) {
    return 'Added $itemName';
  }

  @override
  String itemRemoved(Object itemName) {
    return 'Removed $itemName';
  }

  @override
  String get orderNeedsAtLeastOneItem =>
      'An order must contain at least one item';

  @override
  String get dineInSelectTable => 'Please select a table for dine-in';

  @override
  String get takeawaySerialNotReady =>
      'Takeaway serial number is not ready yet';

  @override
  String get spicyMild => 'Mild';

  @override
  String get spicyMedium => 'Medium';

  @override
  String get spicyHot => 'Hot';
}
