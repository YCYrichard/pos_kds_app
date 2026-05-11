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
  String get orderTypeDineIn => 'Dine in';

  @override
  String get orderTypeTakeaway => 'Takeaway';

  @override
  String get tableNumber => 'Table';

  @override
  String get pickupNumber => 'Pickup no.';

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
}
