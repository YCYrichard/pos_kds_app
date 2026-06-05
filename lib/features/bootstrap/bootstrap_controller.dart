import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../app_role.dart';
import '../../device_persistence/device_config_store.dart';
import '../../device_persistence/device_record.dart';
import '../../device_persistence/store_bootstrap_record.dart';
import '../../device_persistence/store_bootstrap_store.dart';
import '../../network/bootstrap_service.dart';
import '../../network/host_discovery_service.dart';
import '../../network/host_server.dart';
import '../../network/local_network_info.dart';

class BootstrapController extends ChangeNotifier {
  BootstrapController({
    required this.installedRole,
    required this.deviceRecord,
    required this.deviceConfigStore,
    required this.storeBootstrapStore,
    required this.bootstrapService,
    required this.hostDiscoveryService,
    required this.localNetworkInfo,
    required this.hostServer,
    required this.onCompleted,
  });

  final AppRole installedRole;
  final DeviceRecord deviceRecord;
  final DeviceConfigStore deviceConfigStore;
  final StoreBootstrapStore storeBootstrapStore;
  final BootstrapService bootstrapService;
  final HostDiscoveryService hostDiscoveryService;
  final LocalNetworkInfo localNetworkInfo;
  final HostServer hostServer;
  final Future<void> Function() onCompleted;

  static const Uuid _uuid = Uuid();

  StoreBootstrapRecord? _bootstrapRecord;
  bool _initializing = false;
  bool _creatingStore = false;
  bool _discovering = false;
  bool _joining = false;
  String? _message;
  String? _subnetPrefix;
  List<DiscoveredHost> _discoveredHosts = const <DiscoveredHost>[];

  StoreBootstrapRecord? get bootstrapRecord => _bootstrapRecord;
  bool get initializing => _initializing;
  bool get creatingStore => _creatingStore;
  bool get discovering => _discovering;
  bool get joining => _joining;
  String? get message => _message;
  String? get subnetPrefix => _subnetPrefix;
  List<DiscoveredHost> get discoveredHosts =>
      List<DiscoveredHost>.unmodifiable(_discoveredHosts);

  bool get isConfigured => _bootstrapRecord?.isConfigured == true;

  Future<void> initialize() async {
    _initializing = true;
    _message = null;
    notifyListeners();

    try {
      _bootstrapRecord = await storeBootstrapStore.loadOrCreate(
        deviceId: deviceRecord.deviceId,
        installedRole: installedRole,
      );
      _subnetPrefix = await localNetworkInfo.getSubnetPrefix();
    } catch (e) {
      _message = 'Bootstrap initialize failed: $e';
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<void> createNewStore({
    String? storeName,
  }) async {
    _creatingStore = true;
    _message = null;
    notifyListeners();

    try {
      await hostServer.start();
      final hostUrl = await hostServer.buildHostUrl();

      final storeId = _uuid.v4();

      _bootstrapRecord = await storeBootstrapStore.configureAsNewStore(
        deviceId: deviceRecord.deviceId,
        installedRole: installedRole,
        storeId: storeId,
        storeName: storeName,
        hostUrl: hostUrl,
      );

      await deviceConfigStore.updateIdentityFields(
        deviceName: deviceRecord.deviceName,
        hostDeviceId: deviceRecord.deviceId,
      );

      _message = 'Store created successfully';
      notifyListeners();

      await onCompleted();
    } catch (e) {
      _message = 'Create store failed: $e';
      notifyListeners();
    } finally {
      _creatingStore = false;
      notifyListeners();
    }
  }

  Future<void> discoverStores() async {
    _discovering = true;
    _message = null;
    _discoveredHosts = const <DiscoveredHost>[];
    notifyListeners();

    try {
      final subnet = _subnetPrefix ?? await localNetworkInfo.getSubnetPrefix();
      _subnetPrefix = subnet;

      if (subnet == null || subnet.isEmpty) {
        _message = 'Unable to determine LAN subnet';
        return;
      }

      final hosts = await hostDiscoveryService.scanSubnet(subnet);
      _discoveredHosts = hosts;
      if (_discoveredHosts.isEmpty) {
        _message = 'No stores found on local network';
      }
    } catch (e) {
      _message = 'Discovery failed: $e';
    } finally {
      _discovering = false;
      notifyListeners();
    }
  }

  Future<void> joinDiscoveredHost(DiscoveredHost host) async {
    _joining = true;
    _message = null;
    notifyListeners();

    try {
      final joined = await bootstrapService.joinStore(
        baseUrl: host.baseUrl,
        deviceId: deviceRecord.deviceId,
        displayName: deviceRecord.deviceName,
      );

      _bootstrapRecord = await storeBootstrapStore.configureAsJoinedStore(
        deviceId: deviceRecord.deviceId,
        installedRole: installedRole,
        storeId: joined.storeId,
        storeName: joined.storeName,
        hostUrl: joined.hostUrl,
        hostDeviceId: joined.hostDeviceId,
      );

      await deviceConfigStore.updateIdentityFields(
        deviceName: deviceRecord.deviceName,
        hostDeviceId: joined.hostDeviceId,
      );

      _message = 'Joined store successfully';
      notifyListeners();

      await onCompleted();
    } catch (e) {
      _message = 'Join store failed: $e';
      notifyListeners();
    } finally {
      _joining = false;
      notifyListeners();
    }
  }
}
