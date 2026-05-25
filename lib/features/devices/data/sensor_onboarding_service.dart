import '../../../core/network/api_client.dart';
import 'models/sensor_provisioning_request.dart';
import 'models/sensor_provisioning_response.dart';

class SensorOnboardingService {
  static final SensorOnboardingService _instance = SensorOnboardingService._internal();

  factory SensorOnboardingService([ApiClient? client]) => _instance;

  SensorOnboardingService._internal() : _client = ApiClient();

  final ApiClient _client;

  Future<SensorProvisioningResponse> registerSensor(SensorProvisioningRequest request) async {
    final response = await _client.postJsonAndDecode(
      '/api/v1/onboarding/sensor',
      request.toJson(),
    );
    return SensorProvisioningResponse.fromJson(response);
  }
}
