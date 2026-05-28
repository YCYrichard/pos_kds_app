class DataAccessProfile {
  const DataAccessProfile({
    required this.canReadMenu,
    required this.canWriteMenu,
    required this.canReadOrders,
    required this.canWriteOrders,
    required this.canCompleteKitchenItems,
    required this.canViewBackofficeSummary,
  });

  final bool canReadMenu;
  final bool canWriteMenu;
  final bool canReadOrders;
  final bool canWriteOrders;
  final bool canCompleteKitchenItems;
  final bool canViewBackofficeSummary;

  bool get isReadOnly =>
      !canWriteMenu && !canWriteOrders && !canCompleteKitchenItems;
}
