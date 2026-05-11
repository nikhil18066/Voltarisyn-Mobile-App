import 'package:flutter/foundation.dart';
import '../models/device_model.dart';

class DeviceProvider extends ChangeNotifier {
  List<DeviceModel> _homeDevices = [
    DeviceModel(id: 'ac', name: 'Air Conditioner', icon: 'wind', baseUsage: 2.4, currentUsage: 2.4, isOn: true, alwaysOn: false, mode: 'home'),
    DeviceModel(id: 'fridge', name: 'Refrigerator', icon: 'thermometer', baseUsage: 0.8, currentUsage: 0.8, isOn: true, alwaysOn: true, mode: 'home'),
    DeviceModel(id: 'washer', name: 'Washing Machine', icon: 'rotate-cw', baseUsage: 1.2, currentUsage: 1.2, isOn: false, alwaysOn: false, mode: 'home'),
    DeviceModel(id: 'lights', name: 'LED Lights (×6)', icon: 'lightbulb', baseUsage: 0.3, currentUsage: 0.3, isOn: true, alwaysOn: false, mode: 'home'),
    DeviceModel(id: 'heater', name: 'Water Heater', icon: 'flame', baseUsage: 1.5, currentUsage: 1.5, isOn: true, alwaysOn: false, mode: 'home'),
    DeviceModel(id: 'ev', name: 'EV Charger', icon: 'zap', baseUsage: 3.2, currentUsage: 3.2, isOn: false, alwaysOn: false, mode: 'home'),
  ];

  List<DeviceModel> _industryDevices = [
    DeviceModel(id: 'cnc', name: 'CNC Machine', icon: 'settings', baseUsage: 8.5, currentUsage: 8.5, isOn: true, alwaysOn: false, mode: 'industry'),
    DeviceModel(id: 'motor', name: 'Industrial Motor A', icon: 'cpu', baseUsage: 12.3, currentUsage: 12.3, isOn: true, alwaysOn: false, mode: 'industry'),
    DeviceModel(id: 'conveyor', name: 'Conveyor Belt', icon: 'move-right', baseUsage: 4.7, currentUsage: 4.7, isOn: true, alwaysOn: false, mode: 'industry'),
    DeviceModel(id: 'hvac', name: 'HVAC System', icon: 'wind', baseUsage: 6.2, currentUsage: 6.2, isOn: true, alwaysOn: false, mode: 'industry'),
    DeviceModel(id: 'compressor', name: 'Compressor Unit', icon: 'gauge', baseUsage: 9.1, currentUsage: 9.1, isOn: false, alwaysOn: false, mode: 'industry'),
    DeviceModel(id: 'lighting', name: 'Lighting Array', icon: 'lightbulb', baseUsage: 2.1, currentUsage: 2.1, isOn: true, alwaysOn: false, mode: 'industry'),
  ];

  String _mode = 'home';

  String get mode => _mode;
  List<DeviceModel> get devices => _mode == 'home' ? _homeDevices : _industryDevices;
  List<DeviceModel> get activeDevices => devices.where((d) => d.isOn).toList();
  int get activeCount => activeDevices.length;

  double get totalActiveLoad {
    return devices
        .where((d) => d.isOn)
        .fold(0.0, (sum, d) => sum + d.currentUsage);
  }

  double get threshold => _mode == 'home' ? 8.0 : 35.0;

  void setMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  void toggleDevice(String id) {
    final deviceList = _mode == 'home' ? _homeDevices : _industryDevices;
    final index = deviceList.indexWhere((d) => d.id == id);
    if (index != -1 && !deviceList[index].alwaysOn) {
      deviceList[index] = deviceList[index].copyWith(
        isOn: !deviceList[index].isOn,
      );
      notifyListeners();
    }
  }

  void turnOffAll() {
    final deviceList = _mode == 'home' ? _homeDevices : _industryDevices;
    for (int i = 0; i < deviceList.length; i++) {
      if (!deviceList[i].alwaysOn) {
        deviceList[i] = deviceList[i].copyWith(isOn: false);
      }
    }
    notifyListeners();
  }

  void addDevice(DeviceModel device) {
    if (_mode == 'home') {
      _homeDevices.add(device);
    } else {
      _industryDevices.add(device);
    }
    notifyListeners();
  }

  void removeDevice(String id) {
    if (_mode == 'home') {
      _homeDevices.removeWhere((d) => d.id == id);
    } else {
      _industryDevices.removeWhere((d) => d.id == id);
    }
    notifyListeners();
  }
}
