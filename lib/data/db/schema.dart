// lib/data/db/schema.dart

const String createMenuItemsTable = '''
CREATE TABLE menu_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  item_code TEXT NOT NULL UNIQUE,
  item_name TEXT NOT NULL,
  price INTEGER NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1
);
''';

const String createStoresTable = '''
CREATE TABLE stores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  store_id TEXT NOT NULL UNIQUE,
  store_name TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
''';

const String createDeviceConfigTable = '''
CREATE TABLE device_config (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  device_id TEXT NOT NULL UNIQUE,
  store_id TEXT,
  role TEXT NOT NULL,
  host_url TEXT,
  display_name TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
''';

const String createOrdersTable = '''
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_no TEXT NOT NULL UNIQUE,
  order_type TEXT NOT NULL,
  table_no TEXT,
  pickup_no TEXT,
  status TEXT NOT NULL,
  total_items INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  completed_at TEXT,
  released_at TEXT,
  store_id TEXT,
  device_id TEXT,
  updated_at TEXT,
  sync_status TEXT
);
''';

const String createOrderItemsTable = '''
CREATE TABLE order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  item_code TEXT NOT NULL,
  item_name TEXT NOT NULL,
  qty INTEGER NOT NULL,
  spicy_level TEXT,
  status TEXT NOT NULL,
  completed_at TEXT,
  unit_price INTEGER,
  store_id TEXT,
  device_id TEXT,
  updated_at TEXT,
  sync_status TEXT,
  FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE
);
''';

const String createSyncEventsTable = '''
CREATE TABLE sync_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_id TEXT NOT NULL UNIQUE,
  device_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  action TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  hlc TEXT NOT NULL,
  created_at TEXT NOT NULL
);
''';
