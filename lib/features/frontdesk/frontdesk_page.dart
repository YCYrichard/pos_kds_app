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
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<OrderType>(
                  segments: const [
                    ButtonSegment(value: OrderType.dineIn, label: Text('內用')),
                    ButtonSegment(value: OrderType.takeaway, label: Text('外帶')),
                  ],
                  selected: {controller.orderType},
                  onSelectionChanged: (value) =>
                      controller.setOrderType(value.first),
                ),
                const SizedBox(height: 16),
                if (controller.orderType == OrderType.dineIn)
                  _TableSelector(controller: controller)
                else
                  _TakeawaySerialField(controller: controller),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '品項號碼輸入',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            controller.itemCodeInput.isEmpty
                                ? '請輸入號碼'
                                : controller.itemCodeInput,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: const Text('不選辣度'),
                              selected: controller.selectedSpicyLevel == null,
                              onSelected: (_) => controller.setSpicyLevel(null),
                            ),
                            for (final level in SpicyLevel.values)
                              FilterChip(
                                label: Text(level.name),
                                selected:
                                    controller.selectedSpicyLevel == level,
                                onSelected: (_) =>
                                    controller.setSpicyLevel(level),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NumericKeypad(
                          onDigitTap: controller.appendItemCodeDigit,
                          onBackspaceTap: controller.backspaceItemCode,
                          onClearTap: controller.clearItemCode,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: controller.addCurrentItem,
                            icon: const Icon(Icons.add_shopping_cart_outlined),
                            label: const Text('加入品項'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('目前訂單', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                CurrentOrderPanel(
                  items: controller.items,
                  onRemove: controller.removeItemAt,
                ),
                const SizedBox(height: 12),
                if (controller.message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      controller.message!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        controller.isSubmitting
                            ? '送單中...'
                            : controller.isLoadingOptions
                            ? '資料更新中...'
                            : '送出訂單',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TableSelector extends StatelessWidget {
  const _TableSelector({required this.controller});

  final FrontdeskController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingOptions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.availableTables.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '目前沒有可用桌號，請等待未完成訂單結單後再使用。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final selectedValue =
        controller.availableTables.contains(controller.tableNo)
        ? controller.tableNo
        : controller.availableTables.first;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: const InputDecoration(
        labelText: '桌號',
        border: OutlineInputBorder(),
      ),
      items: controller.availableTables
          .map(
            (table) =>
                DropdownMenuItem<String>(value: table, child: Text(table)),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        controller.setTableNo(value);
      },
    );
  }
}

class _TakeawaySerialField extends StatelessWidget {
  const _TakeawaySerialField({required this.controller});

  final FrontdeskController controller;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: '取餐流水號',
        border: OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              controller.isLoadingOptions ? '載入中...' : controller.pickupNo,
              style: Theme.of(context).textTheme.titleMedium,
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
    );
  }
}
