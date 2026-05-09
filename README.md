# POS KDS Flutter 檔案包

這是一份依照已確認需求整理的 Flutter 專案檔案包，適用於 Windows + VS Code workspace 開發流程。

## 已依照先前確認內容

- 餐飲小店 POS
- 手機優先
- 前台用號碼輸入點單
- 先選內用 / 外帶
- 內用有桌號（區域 + 數字）
- 外帶有取餐號碼
- 後廚單欄 KDS
- 每個品項可逐一完成
- 品項備註目前只做辣度，且可不填
- 狀態先不做完成後回退
- 第一版為單機 offline-first，共用本機 SQLite

## 建議使用方式

1. 在本機執行 `flutter create pos_kds_app`
2. 用本檔案包覆蓋對應檔案
3. 在專案根目錄執行 `flutter pub get`
4. 先跑 `flutter test`
5. 再跑 `flutter test integration_test`
6. 最後用模擬器執行 `flutter run`


## 本地路徑基準（修正版）

- Workspace 根目錄：`C:\\dev\\workspace`
- Flutter 專案建議位置：`C:\\dev\\workspace\\pos_kds_app`
- VS Code workspace 檔建議位置：`C:\\dev\\workspace\\pos_kds_app.code-workspace`

建議先在本機執行：

```powershell
cd C:\\dev\\workspace
flutter create pos_kds_app
cd C:\\dev\\workspace\\pos_kds_app
code .
```


## Frontdesk MVP（新增）

已新增第一階段可操作版前台點單功能：
- 內用 / 外帶切換
- 桌號 / 取餐號輸入
- 數字 keypad 輸入品項號碼
- 辣度選擇
- 加入目前訂單
- 送單寫入 SQLite

新增檔案：
- `lib/features/frontdesk/frontdesk_controller.dart`
- `lib/shared/widgets/numeric_keypad.dart`
- `lib/shared/widgets/current_order_panel.dart`
- 更新 `lib/features/frontdesk/frontdesk_page.dart`


## Kitchen MVP（新增）

此版本以上一個 Frontdesk package 為 base，新增：
- App shell 三頁切換（Frontdesk / Kitchen / Backoffice placeholder）
- Kitchen 單欄列表
- 讀取 active orders + order items
- 後廚單品完成按鈕
- 完成後刷新 order status 與 active queue

Git 建議：
- branch: `feature/kitchen-mvp`
- commit 1: `feat(app): add basic shell navigation`
- commit 2: `feat(kitchen): add single-column kitchen order list`
- commit 3: `feat(kitchen): add item completion and active order refresh`
