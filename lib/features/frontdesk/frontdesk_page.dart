import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/enums/order_type.dart';
import '../../domain/enums/spicy_level.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('釋放桌號'),
          content: Text('確認將桌號 $tableNo 釋放為可用狀態？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('確認釋放'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await controller.releaseTable(tableNo);
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('桌號 $tableNo 已釋放')));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FrontdeskController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('前台點單'),
            actions: [
              IconButton(
                onPressed: controller.isLoadingOptions
                    ? null
                    : controller.loadServiceOptions,
                icon: const Icon(Icons.refresh),
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
                    segments: const [
                      ButtonSegment(value: OrderType.dineIn, label: Text('內用')),
                      ButtonSegment(
                        value: OrderType.takeaway,
                        label: Text('外帶'),
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
                            '點單',
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
                                  ? '請輸入號碼'
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
                                label: const Text('不選辣度'),
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
                              icon: const Icon(
                                Icons.add_shopping_cart_outlined,
                              ),
                              label: const Text('加入品項'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '目前訂單',
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
                  if (controller.message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        controller.message!,
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
                                const SnackBar(content: Text('訂單已成功送出')),
                              );
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        controller.isSubmitting
                            ? '送單中...'
                            : controller.isLoadingOptions
                            ? '資料更新中...'
                            : '送出訂單',
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
  const _CompactTableSelector({required this.controller});

  final FrontdeskController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingOptions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.availableTables.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '目前沒有可用桌號，請先釋放桌號或等待訂單完成。',
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
                  '桌號',
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
                  '釋放',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            Expanded(
              child: controller.occupiedTables.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '目前無占用桌號',
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
  const _CompactTakeawaySerialCard({required this.controller});

  final FrontdeskController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final serialText = controller.isLoadingOptions
        ? '...'
        : controller.pickupNo;

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
                    '取餐號',
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
            ),
          ],
        ),
      ),
    );
  }
}
