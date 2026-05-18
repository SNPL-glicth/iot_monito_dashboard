import 'sensor_activation_service.dart';

/// Controller for define sensor flow state management
class DefineSensorFlowController {
  DefineSensorFlowController({
    required this.onStateChanged,
  });

  final Function() onStateChanged;

  final _service = SensorActivationService();

  // Estado del flujo
  int _currentStep = 0;
  String _selectedType = 'temperature';
  bool _isLoading = false;
  String? _error;

  // Datos del sensor definido
  dynamic _definedSensor;
  String? scannedCode;
  
  // Reserve/Confirm (flujo definitivo)
  dynamic _reserveData;
  dynamic _confirmResult;
  String _activationMethod = '';

  int get currentStep => _currentStep;
  String get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String? get error => _error;
  dynamic get definedSensor => _definedSensor;
  dynamic get reserveData => _reserveData;
  dynamic get confirmResult => _confirmResult;
  String get activationMethod => _activationMethod;

  void setSelectedType(String type) {
    _selectedType = type;
    onStateChanged();
  }

  void setStep(int step) {
    _currentStep = step;
    onStateChanged();
  }

  void setActivationMethod(String method) {
    _activationMethod = method;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }

  void setError(String? error) {
    _error = error;
    onStateChanged();
  }

  Future<void> defineSensor({
    required String deviceUuid,
    required String unit,
    required double? warningMin,
    required double? warningMax,
    required double? alertMin,
    required double? alertMax,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final result = await _service.defineSensor(
        deviceUuid: deviceUuid,
        sensorType: _selectedType,
        unit: unit,
        warningMin: warningMin,
        warningMax: warningMax,
        alertMin: alertMin,
        alertMax: alertMax,
      );

      _definedSensor = result;
      setStep(1);
      setLoading(false);
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      setLoading(false);
    }
  }

  Future<void> activateSensorWithCode(String scannedCode) async {
    if (_definedSensor == null) return;

    this.scannedCode = scannedCode;
    setLoading(true);
    setError(null);

    try {
      final result = await _service.activateSensorWithCode(
        sensorUuid: _definedSensor!.sensorUuid,
      );

      _confirmResult = result;
      setStep(2);
      setLoading(false);
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      setLoading(false);
    }
  }

  Future<void> publishAndReserveSensor() async {
    if (_definedSensor == null) return;

    setLoading(true);
    setError(null);

    try {
      await _service.publishSensor(sensorUuid: _definedSensor!.sensorUuid);
      
      final result = await _service.reserveSensor(
        sensorUuid: _definedSensor!.sensorUuid,
      );

      _reserveData = result;
      _activationMethod = 'reserve';
      setStep(2);
      setLoading(false);
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      setLoading(false);
    }
  }

  Future<void> confirmSensor() async {
    if (_reserveData == null) return;

    setLoading(true);
    setError(null);

    try {
      final result = await _service.confirmSensor(
        claimToken: _reserveData!.claimToken,
      );

      _confirmResult = result;
      setStep(3);
      setLoading(false);
    } catch (e) {
      setError(e.toString().replaceAll('Exception: ', ''));
      setLoading(false);
    }
  }

  String parseQRCode(String qrData) {
    return _service.parseQRCode(qrData);
  }
}
