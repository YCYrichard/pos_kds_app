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
  late final TextEditingController _tableController;
  late final TextEditingController _pickupController;

  @override
  void initState() {
    super.initState();
    _tableController = TextEditingController();
    _pickupController = TextEditingController();
  }

  @override
  void dispose() {
    _tableController.dispose();
    _pickupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FrontdeskController>(
      builder: (context, controller, _) {
        _syncControllerTexts(controller);

        return Scaffold(
          appBar: AppBar(title: const Text('前台點單')),
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
                  TextField(
                    controller: _tableController,
                    decoration: const InputDecoration(
                      labelText: '桌號',
                      hintText: '例如 A1',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: controller.setTableNo,
                  )
                else
                  TextField(
                    controller: _pickupController,
                    decoration: const InputDecoration(
                      labelText: '取餐號',
                      hintText: '例如 101',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: controller.setPickupNo,
                  ),
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
                    onPressed: controller.isSubmitting
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
                      child: Text(controller.isSubmitting ? '送單中...' : '送出訂單'),
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

  void _syncControllerTexts(FrontdeskController controller) {
    if (_tableController.text != controller.tableNo) {
      _tableController.value = _tableController.value.copyWith(
        text: controller.tableNo,
        selection: TextSelection.collapsed(offset: controller.tableNo.length),
      );
    }
    if (_pickupController.text != controller.pickupNo) {
      _pickupController.value = _pickupController.value.copyWith(
        text: controller.pickupNo,
        selection: TextSelection.collapsed(offset: controller.pickupNo.length),
      );
    }
  }
}
