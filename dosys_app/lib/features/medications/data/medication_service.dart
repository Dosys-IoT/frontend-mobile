import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'medication_models.dart';

class MedicationService {
  static Future<List<DeviceModel>> getDevices() async {
    final res = await ApiClient.get('/api/v1/medication/devices');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => DeviceModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<List<ContainerModel>> getContainers(int deviceId) async {
    final res = await ApiClient.get('/api/v1/medication/devices/$deviceId/containers');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => ContainerModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<List<ScheduleModel>> getSchedules(int deviceId) async {
    final res = await ApiClient.get('/api/v1/medication/devices/$deviceId/schedules');
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => ScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  static Future<bool> updateContainer(
    int deviceId,
    int containerNumber,
    String medicationName,
    String dosageLabel,
    int remainingPills,
    bool isEnabled,
  ) async {
    final res = await ApiClient.put(
      '/api/v1/medication/devices/$deviceId/containers/$containerNumber',
      {
        'medicationName': medicationName,
        'dosageLabel': dosageLabel,
        'remainingPills': remainingPills,
        'isEnabled': isEnabled,
      },
    );
    return res.statusCode == 200;
  }

  static Future<bool> updateSchedule(
    int deviceId,
    int scheduleId,
    Map<String, dynamic> body,
  ) async {
    final res = await ApiClient.put(
      '/api/v1/medication/devices/$deviceId/schedules/$scheduleId',
      body,
    );
    return res.statusCode == 200;
  }

  static Future<bool> deleteSchedule(int deviceId, int scheduleId) async {
    final res = await ApiClient.delete(
      '/api/v1/medication/devices/$deviceId/schedules/$scheduleId',
    );
    return res.statusCode == 204;
  }

  static Future<Map<String, dynamic>?> getLatestEnvironment(int deviceId) async {
    final res = await ApiClient.get('/api/v1/medication/devices/$deviceId/environment/latest');
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    return null;
  }
}
