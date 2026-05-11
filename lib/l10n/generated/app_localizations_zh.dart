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

  @override
  String get kitchenTitle => '後廚 KDS';

  @override
  String get sortLabel => '排序';

  @override
  String get sortOldestFirst => '最早優先';

  @override
  String get sortNewestFirst => '最新優先';

  @override
  String get noPendingOrders => '目前沒有待處理訂單';

  @override
  String get itemCompleted => '品項已完成';

  @override
  String get backofficeTitle => '後台摘要';

  @override
  String get orderListTitle => '訂單列表';

  @override
  String get noOrderRecords => '目前沒有訂單紀錄';

  @override
  String get todayOrders => '今日訂單';

  @override
  String get pendingOrders => '待完成';

  @override
  String get todayRevenue => '今日營收';

  @override
  String dineInWithTable(Object tableNo) {
    return '內用｜桌號 $tableNo';
  }

  @override
  String takeawayWithPickup(Object pickupNo) {
    return '外帶｜取餐號 $pickupNo';
  }

  @override
  String get createdTime => '建立時間';

  @override
  String get totalItems => '總品項數';

  @override
  String get orderDetailTitle => '訂單明細';

  @override
  String get orderNumber => '訂單編號';

  @override
  String get orderTypeLabel => '訂單類型';

  @override
  String get tableLabel => '桌號';

  @override
  String get pickupLabel => '取餐號';

  @override
  String get statusLabel => '狀態';

  @override
  String get completedTime => '完成時間';

  @override
  String get itemsTitle => '品項';

  @override
  String get statusCreated => '已建立';

  @override
  String get statusPreparing => '製作中';

  @override
  String get statusCompleted => '已完成';

  @override
  String get noSpicyConfigured => '不辣度設定';

  @override
  String spicyLevelValue(Object level) {
    return '辣度 $level';
  }

  @override
  String quantityWithSpicy(Object qty, Object spicy) {
    return '數量 $qty｜$spicy';
  }

  @override
  String get currentOrderEmpty => '目前尚未加入品項';

  @override
  String get spicyNotSelected => '辣度：未選';

  @override
  String spicyPrefix(Object level) {
    return '辣度：$level';
  }

  @override
  String orderPrefix(Object orderNo) {
    return '訂單 $orderNo';
  }

  @override
  String typePrefix(Object type) {
    return '類型：$type';
  }

  @override
  String tablePrefix(Object tableNo) {
    return '桌號：$tableNo';
  }

  @override
  String pickupPrefix(Object pickupNo) {
    return '取餐號：$pickupNo';
  }

  @override
  String get completeAction => '完成';

  @override
  String get orderDetailPageStub => '訂單明細頁骨架已建立';
}
