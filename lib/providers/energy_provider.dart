import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/energy_data_model.dart';
import '../models/device_model.dart';
import '../services/energy_simulator_service.dart';

class EnergyProvider extends ChangeNotifier {
  final EnergySimulatorService _simulator = EnergySimulatorService();
  Timer? _timer;

  // ₹8.5 per kWh (Indian electricity rate)
  static const double _ratePerKwh = 8.5;

  List<EnergyDataPoint> _energyData = [];
  double _totalEnergyToday = 47.3;
  int _efficiencyScore = 87;
  String _systemStatus = 'normal'; // 'normal', 'warning', 'critical'
  bool _autoPowerCut = true;
  List<PowerEvent> _powerEvents = [];
  List<AlertModel> _alerts = [];
  bool _notificationsEnabled = true;

  // Track overload state to prevent duplicate triggers
  bool _overloadHandled = false;

  List<EnergyDataPoint> get energyData => _energyData;
  double get totalEnergyToday => _totalEnergyToday;
  double get estimatedCost =>
      double.parse((_totalEnergyToday * _ratePerKwh).toStringAsFixed(0));
  int get efficiencyScore => _efficiencyScore;
  String get systemStatus => _systemStatus;
  bool get autoPowerCut => _autoPowerCut;
  List<PowerEvent> get powerEvents => _powerEvents;
  List<AlertModel> get alerts => _alerts;
  bool get notificationsEnabled => _notificationsEnabled;

  EnergyProvider() {
    _energyData = _simulator.generateInitialData();
    _initAlerts();
    _initPowerEvents();
  }

  void _initAlerts() {
    _alerts = [
      AlertModel(
        id: 'a1',
        severity: 'warning',
        title: 'High Usage Detected',
        description:
            'Energy consumption is 23% above your daily average. Consider turning off idle devices.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      AlertModel(
        id: 'a2',
        severity: 'info',
        title: 'Efficiency Score Updated',
        description:
            'Your efficiency score improved to 87/100 after scheduling the water heater.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      AlertModel(
        id: 'a3',
        severity: 'info',
        title: 'Off-Peak Hours Starting',
        description:
            'Off-peak electricity rates begin at 11:00 PM. Consider scheduling high-load tasks.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  void _initPowerEvents() {
    _powerEvents = [
      PowerEvent(
        id: 'pe1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 108)),
        message: 'System returned to normal after load reduction',
        type: 'restore',
      ),
      PowerEvent(
        id: 'pe2',
        timestamp: DateTime.now().subtract(const Duration(minutes: 111)),
        message: 'High usage warning issued — load at 87% threshold',
        type: 'warning',
      ),
      PowerEvent(
        id: 'pe3',
        timestamp: DateTime.now().subtract(const Duration(minutes: 195)),
        message: 'Auto power cut triggered: EV Charger disabled (overload)',
        type: 'cut',
      ),
    ];
  }

  void startSimulation(double Function() getActiveLoad, String Function() getMode,
      List<DeviceModel> Function() getDevices, Function(String) toggleDevice) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      final activeLoad = getActiveLoad();
      final dataPoint = _simulator.generateDataPoint(activeLoad);
      _energyData = [..._energyData.skip(_energyData.length > 19 ? 1 : 0), dataPoint];
      _totalEnergyToday = double.parse(
          (_totalEnergyToday + dataPoint.usage / 1200).toStringAsFixed(2));

      final r = Random();
      if (r.nextDouble() > 0.7) {
        _efficiencyScore = min(100, max(60, _efficiencyScore + (r.nextBool() ? 1 : -1)));
      }

      // Run overload check inside the simulation timer (NOT in build)
      _checkOverloadInternal(activeLoad, getMode(), getDevices(), toggleDevice);

      notifyListeners();
    });
  }

  void _checkOverloadInternal(double totalActiveLoad, String mode,
      List<DeviceModel> devices, Function(String) toggleDevice) {
    final threshold = mode == 'home' ? 8.0 : 35.0;

    if (totalActiveLoad >= threshold) {
      _systemStatus = 'critical';

      if (!_overloadHandled) {
        _overloadHandled = true;
        _addAlert(
          'critical',
          'Overload Detected',
          'Total load exceeded ${threshold.toStringAsFixed(1)} kWh threshold. Immediate action required.',
        );
        _addPowerEvent(
          'Overload detected — total load: ${totalActiveLoad.toStringAsFixed(1)} kWh',
          'warning',
        );

        if (_autoPowerCut) {
          // Keep cutting devices until under threshold
          final toggleable = devices.where((d) => d.isOn && !d.alwaysOn).toList();
          toggleable.sort((a, b) => b.currentUsage.compareTo(a.currentUsage));

          for (final device in toggleable) {
            toggleDevice(device.id);
            _addPowerEvent(
              'Auto power cut: ${device.name} disabled (${device.currentUsage.toStringAsFixed(1)} kWh)',
              'cut',
            );
            _addAlert(
              'critical',
              'Auto Power Cut — ${device.name}',
              '${device.name} was automatically disabled to prevent overload.',
            );
            // Recalculate after toggling
            final newLoad = devices
                .where((d) => d.isOn && d.id != device.id)
                .fold(0.0, (sum, d) => sum + d.currentUsage);
            if (newLoad < threshold) break;
          }
        }
      }
    } else if (totalActiveLoad >= threshold * 0.8) {
      _overloadHandled = false;
      if (_systemStatus == 'normal') {
        _systemStatus = 'warning';
        _addAlert(
          'warning',
          'High Usage Warning',
          'Load at ${((totalActiveLoad / threshold) * 100).round()}% of threshold. Monitor closely.',
        );
      }
    } else {
      if (_systemStatus != 'normal') {
        _addPowerEvent(
          'System returned to normal — load within safe limits',
          'restore',
        );
      }
      _systemStatus = 'normal';
      _overloadHandled = false;
    }
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
  }

  void _addAlert(String severity, String title, String description) {
    _alerts.insert(
      0,
      AlertModel(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        severity: severity,
        title: title,
        description: description,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _addPowerEvent(String message, String type) {
    _powerEvents.insert(
      0,
      PowerEvent(
        id: 'pe-${DateTime.now().millisecondsSinceEpoch}',
        timestamp: DateTime.now(),
        message: message,
        type: type,
      ),
    );
  }

  void dismissAlert(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index].dismissed = true;
      notifyListeners();
    }
  }

  void clearPowerEvents() {
    _powerEvents.clear();
    notifyListeners();
  }

  void setAutoPowerCut(bool value) {
    _autoPowerCut = value;
    notifyListeners();
  }

  void setNotificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setSystemStatus(String status) {
    _systemStatus = status;
    notifyListeners();
  }

  void addManualPowerCutEvent() {
    _systemStatus = 'critical';
    _addPowerEvent('Manual power cut triggered by user', 'manual');
    _addAlert(
      'critical',
      'Manual Power Cut Triggered',
      'User manually triggered a power cut. All non-essential devices disabled.',
    );
    notifyListeners();
  }

  void addTurnOffAllEvent() {
    _addPowerEvent('Manual turn-off: all non-essential devices disabled', 'manual');
    _addAlert(
      'info',
      'All Devices Turned Off',
      'All non-essential devices have been turned off manually.',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
