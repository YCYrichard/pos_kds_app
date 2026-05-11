// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'POS KDS App';

  @override
  String get tabFrontdesk => '前台';

  @override
  String get tabKitchen => '後廚';

  @override
  String get tabBackoffice => '後台';

  @override
  String get frontdeskTitle => '前台點單';

  @override
  String get orderTypeDineIn => '內用';

  @override
  String get orderTypeTakeaway => '外帶';

  @override
  String get tableNumber => '桌號';

  @override
  String get tableExample => '例如 A1';

  @override
  String get pickupNumber => '取餐號';

  @override
  String get pickupExample => '例如 101';

  @override
  String get itemCodeInput => '品項號碼輸入';

  @override
  String get pleaseEnterNumber => '請輸入號碼';

  @override
  String get noSpicyLevel => '不選辣度';

  @override
  String get addItem => '加入品項';

  @override
  String get currentOrder => '目前訂單';

  @override
  String get orderSubmitted => '訂單已成功送出';

  @override
  String get submitting => '送單中...';

  @override
  String get submitOrder => '送出訂單';
}
