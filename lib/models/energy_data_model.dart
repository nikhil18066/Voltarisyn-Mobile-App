class EnergyDataPoint {
  final String time;
  final double usage;
  final double cost;

  EnergyDataPoint({
    required this.time,
    required this.usage,
    required this.cost,
  });
}

class PowerEvent {
  final String id;
  final DateTime timestamp;
  final String message;
  final String type; // 'cut', 'restore', 'warning', 'manual'

  PowerEvent({
    required this.id,
    required this.timestamp,
    required this.message,
    required this.type,
  });
}

class AlertModel {
  final String id;
  final String severity; // 'critical', 'warning', 'info'
  final String title;
  final String description;
  final DateTime timestamp;
  bool dismissed;

  AlertModel({
    required this.id,
    required this.severity,
    required this.title,
    required this.description,
    required this.timestamp,
    this.dismissed = false,
  });
}
