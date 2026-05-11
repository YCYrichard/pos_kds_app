import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/enums/order_type.dart';
import '../../domain/enums/spicy_level.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/current_order_panel.dart';
import '../../shared/widgets/numeric_keypad.dart';
import 'frontdesk_controller.dart';

class FrontdeskPage extends StatelessWidget {
  const FrontdeskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _FrontdeskView();
  }
}

class _FrontdeskView extends StatefulWidget {
  const _FrontdeskView();

  @override
  State<_FrontdeskView> createState() => _FrontdeskViewState();
}

class _FrontdeskViewState extends State<_FrontdeskView> {
  Future<void> _confirmReleaseTable(
    BuildContext context,
    FrontdeskController controller,
    String tableNo,
  ) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.releaseTableTitle),
          content: Text(l10n.releaseTableConfirm(tableNo)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.commonConfirm),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await controller.releaseTable(tableNo);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.releaseTableDone(tableNo))),
    );
  }

  String? _resolveFrontdeskMessage(
    BuildContext context,
    FrontdeskController controller,
  ) {
    final l10n = context.l10n;
    final key = controller.messageKey;
    final args = controller.messageArgs;

    switch (key) {
      case FrontdeskMessage.releaseTableDone:
        return l10n.releaseTableDone(args['tableNo'] ?? '');
      case FrontdeskMessage.enterItemCodeFirst:
        return l10n.enterItemCodeFirst;
      case FrontdeskMessage.itemCodeNotFound:
        return l10n.itemCodeNotFound(args['itemCode'] ?? '');
      case FrontdeskMessage.itemAdded:
        return l10n.itemAdded(args['itemName'] ?? '');
      case FrontdeskMessage.itemRemoved:
        return l10n.itemRemoved(args['itemName'] ?? '');
      case FrontdeskMessage.orderNeedsAtLeastOneItem:
        return l10n.orderNeedsAtLeastOneItem;
      case FrontdeskMessage.dineInSelectTable:
        return l10n.dineInSelectTable;
      case FrontdeskMessage.takeawaySerialNotReady:
        return l10n.takeawaySerialNotReady;
      case FrontdeskMessage.orderSubmitted:
        return l10n.orderSubmitted;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer<FrontdeskController>(
      builder: (context, controller, _) {
        final messageText = _resolveFrontdeskMessage(context, controller);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.frontdeskTitle),
            actions: [
              IconButton(
                onPressed: controller.isLoadingOptions
                    ? null
                    : controller.loadServiceOptions,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.commonRefresh,
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<OrderType>(
                    segments: [
                      ButtonSegment(
                        value: OrderType.dineIn,
                        label: Text(l10n.orderTypeDineIn),
                      ),
                      ButtonSegment(
                        value: OrderType.takeaway,
                        label: Text(l10n.orderTypeTakeaway),
                      ),
                    ],
                    selected: {controller.orderType},
                    onSelectionChanged: (value) =>
                        controller.setOrderType(value.first),
                  ),
                  const SizedBox(height: 12),
                  if (controller.orderType == OrderType.dineIn) ...[
                    _CompactTableSelector(controller: controller),
                    const SizedBox(height: 8),
                    _CompactReleaseTableRow(
                      controller: controller,
                      onReleaseTable: (tableNo) =>
                          _confirmReleaseTable(context, controller, tableNo),
                    ),
                  ] else ...[
                    _CompactTakeawaySerialCard(controller: controller),
                  ],
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.orderingTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              controller.itemCodeInput.isEmpty
                                  ? l10n.pleaseEnterNumber
                                  : controller.itemCodeInput,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              FilterChip(
                                label: Text(l10n.noSpicyLevel),
                                selected: controller.selectedSpicyLevel == null,
                                onSelected: (_) =>
                                    controller.setSpicyLevel(null),
                                visualDensity: VisualDensity.compact,
                              ),
                              for (final level in SpicyLevel.values)
                                FilterChip(
                                  label: Text(level.name),
                                  selected:
                                      controller.selectedSpicyLevel == level,
                                  onSelected: (_) =>
                                      controller.setSpicyLevel(level),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          NumericKeypad(
                            onDigitTap: controller.appendItemCodeDigit,
                            onBackspaceTap: controller.backspaceItemCode,
                            onClearTap: controller.clearItemCode,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: controller.addCurrentItem,
                              icon:
                                  const Icon(Icons.add_shopping_cart_outlined),
                              label: Text(l10n.addItem),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.currentOrder,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          CurrentOrderPanel(
                            items: controller.items,
                            onRemove: controller.removeItemAt,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (messageText != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        messageText,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed:
                        controller.isSubmitting || controller.isLoadingOptions
                            ? null
                            : () async {
                                final ok = await controller.submitOrder();
                                if (!context.mounted) return;
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.orderSubmitted),
                                    ),
                                  );
                                }
                              },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        controller.isSubmitting
                            ? l10n.submitting
                            : l10n.submitOrder,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompactTableSelector extends StatelessWidget {
  const _CompactTableSelector({
    required this.controller,
  });

  final FrontdeskController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (controller.isLoadingOptions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.availableTables.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            l10n.noAvailableTables,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final selectedTable =
        controller.availableTables.contains(controller.tableNo)
            ? controller.tableNo
            : controller.availableTables.first;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.tableNumber,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: controller.availableTables.map((table) {
                  return ChoiceChip(
                    label: Text(table),
                    selected: selectedTable == table,
                    onSelected: (_) => controller.setTableNo(table),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactReleaseTableRow extends StatelessWidget {
  const _CompactReleaseTableRow({
    required this.controller,
    required this.onReleaseTable,
  });

  final FrontdeskController controller;
  final ValueChanged<String> onReleaseTable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.releaseTableShort,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            Expanded(
              child: controller.occupiedTables.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        l10n.noOccupiedTables,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: controller.occupiedTables.map((table) {
                        return ActionChip(
                          label: Text(table),
                          onPressed: controller.isReleasingTable
                              ? null
                              : () => onReleaseTable(table),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactTakeawaySerialCard extends StatelessWidget {
  const _CompactTakeawaySerialCard({
    required this.controller,
  });

  final FrontdeskController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final serialText =
        controller.isLoadingOptions ? '...' : controller.pickupNo;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Text(
                    l10n.pickupNumber,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    serialText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: controller.isLoadingOptions
                  ? null
                  : controller.loadServiceOptions,
              icon: const Icon(Icons.refresh),
              tooltip: l10n.commonRefresh,
            ),
          ],
        ),
      ),
    );
  }
}
