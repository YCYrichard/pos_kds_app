// lib/data/models/store_config.dart

class StoreConfig {
  final int? id;
  final String storeId;
  final String? storeName;
  final String createdAt;
  final String updatedAt;

  const StoreConfig({
    this.id,
    required this.storeId,
    this.storeName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'store_name': storeName,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory StoreConfig.fromMap(Map<String, Object?> map) {
    return StoreConfig(
      id: map['id'] as int?,
      storeId: map['store_id'] as String,
      storeName: map['store_name'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }
}
