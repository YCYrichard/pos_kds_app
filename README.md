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
