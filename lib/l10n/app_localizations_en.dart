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
  String get tableExample => 'e.g. A1';

  @override
  String get pickupNumber => 'Pickup no.';

  @override
  String get pickupExample => 'e.g. 101';

  @override
  String get itemCodeInput => 'Item code input';

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
}
