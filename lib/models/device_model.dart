class DeviceModel {
  final String id;
  final String name;
  final String icon;
  final double baseUsage;
  double currentUsage;
  bool isOn;
  final bool alwaysOn;
  final String mode; // 'home' or 'industry'

  DeviceModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.baseUsage,
    required this.currentUsage,
    required this.isOn,
    this.alwaysOn = false,
    required this.mode,
  });

  DeviceModel copyWith({
    String? id,
    String? name,
    String? icon,
    double? baseUsage,
    double? currentUsage,
    bool? isOn,
    bool? alwaysOn,
    String? mode,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      baseUsage: baseUsage ?? this.baseUsage,
      currentUsage: currentUsage ?? this.currentUsage,
      isOn: isOn ?? this.isOn,
      alwaysOn: alwaysOn ?? this.alwaysOn,
      mode: mode ?? this.mode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'baseUsage': baseUsage,
        'currentUsage': currentUsage,
        'isOn': isOn,
        'alwaysOn': alwaysOn,
        'mode': mode,
      };

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        icon: json['icon'] ?? 'zap',
        baseUsage: (json['baseUsage'] ?? 0).toDouble(),
        currentUsage: (json['currentUsage'] ?? 0).toDouble(),
        isOn: json['isOn'] ?? false,
        alwaysOn: json['alwaysOn'] ?? false,
        mode: json['mode'] ?? 'home',
      );
}
