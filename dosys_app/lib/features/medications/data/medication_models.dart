class ContainerModel {
  final int id;
  final int containerNumber;
  final String? medicationName;
  final String? dosageLabel;
  final int remainingPills;
  final bool isEnabled;

  const ContainerModel({
    required this.id,
    required this.containerNumber,
    this.medicationName,
    this.dosageLabel,
    required this.remainingPills,
    required this.isEnabled,
  });

  factory ContainerModel.fromJson(Map<String, dynamic> json) => ContainerModel(
        id: json['id'] as int,
        containerNumber: json['containerNumber'] as int,
        medicationName: json['medicationName'] as String?,
        dosageLabel: json['dosageLabel'] as String?,
        remainingPills: json['remainingPills'] as int,
        isEnabled: json['isEnabled'] as bool,
      );
}

class ScheduleModel {
  final int id;
  final int containerNumber;
  final Map<String, int> time;
  final List<String> daysOfWeek;
  final bool isActive;

  const ScheduleModel({
    required this.id,
    required this.containerNumber,
    required this.time,
    required this.daysOfWeek,
    required this.isActive,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'] as int,
        containerNumber: json['containerNumber'] as int,
        time: Map<String, int>.from(json['time'] as Map),
        daysOfWeek: List<String>.from(json['daysOfWeek'] as List),
        isActive: json['isActive'] as bool,
      );

  String get timeLabel {
    final h = time['hour'] ?? 0;
    final m = time['minute'] ?? 0;
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }
}

class DeviceModel {
  final int id;
  final String? name;
  final double? humidityThreshold;
  final double? temperatureThreshold;
  final DateTime? lastSeenAt;

  const DeviceModel({
    required this.id,
    this.name,
    this.humidityThreshold,
    this.temperatureThreshold,
    this.lastSeenAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
        id: json['id'] as int,
        name: json['name'] as String?,
        humidityThreshold: (json['humidityThreshold'] as num?)?.toDouble(),
        temperatureThreshold: (json['temperatureThreshold'] as num?)?.toDouble(),
        lastSeenAt: json['lastSeenAt'] != null
            ? DateTime.tryParse(json['lastSeenAt'] as String)
            : null,
      );

  bool get isConnected {
    if (lastSeenAt == null) return false;
    return DateTime.now().difference(lastSeenAt!).inMinutes < 10;
  }
}
