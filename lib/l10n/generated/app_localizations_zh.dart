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
  String get pickupNumber => '取餐號';

  @override
  String get orderingTitle => '點單';

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

  @override
  String get commonRefresh => '更新';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '確認';

  @override
  String get releaseTableTitle => '釋放桌號';

  @override
  String get releaseTableShort => '釋放';

  @override
  String releaseTableConfirm(Object tableNo) {
    return '確認將桌號 $tableNo 釋放為可用狀態？';
  }

  @override
  String releaseTableDone(Object tableNo) {
    return '桌號 $tableNo 已釋放';
  }

  @override
  String get noAvailableTables => '目前沒有可用桌號，請先釋放桌號或等待訂單完成。';

  @override
  String get noOccupiedTables => '目前無占用桌號';
}
