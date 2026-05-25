import 'package:flutter/material.dart';

import '../../data/models/sensor_provisioning_request.dart';
import '../../data/models/sensor_provisioning_response.dart';
import '../../data/sensor_onboarding_service.dart';
import 'onboarding/choose_method_step.dart';
import 'onboarding/registration_form_step.dart';
import 'onboarding/success_step.dart';

class SensorOnboardingFlow extends StatefulWidget {
  final String deviceUuid;
  final String deviceName;
  final VoidCallback? onSensorCreated;

  const SensorOnboardingFlow({
    super.key,
    required this.deviceUuid,
    required this.deviceName,
    this.onSensorCreated,
  });

  static Future<dynamic> show(
    BuildContext context, {
    required String deviceUuid,
    required String deviceName,
    VoidCallback? onSensorCreated,
  }) {
    return showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SensorOnboardingFlow(
        deviceUuid: deviceUuid,
        deviceName: deviceName,
        onSensorCreated: onSensorCreated,
      ),
    );
  }

  @override
  State<SensorOnboardingFlow> createState() => _SensorOnboardingFlowState();
}

class _SensorOnboardingFlowState extends State<SensorOnboardingFlow> {
  int _currentStep = 0; // 0: Choose Method, 1: Form, 2: Loading, 3: Success

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController(text: '°C');
  final _intervalController = TextEditingController(text: '2000');

  String _selectedType = 'temperature';
  int _selectedQos = 1;
  String? _error;
  SensorProvisioningResponse? _successResponse;

  final Map<String, String> _typeDefaults = {
    'temperature': '°C',
    'humidity': '%',
    'pressure': 'bar',
    'vibration': 'mm/s',
    'current': 'A',
    'voltage': 'V',
    'flow': 'L/min',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _intervalController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _currentStep = 2; // Transition to loading step
      _error = null;
    });

    try {
      final request = SensorProvisioningRequest(
        deviceUuid: widget.deviceUuid,
        sensorName: _nameController.text.trim(),
        sensorType: _selectedType,
        samplingIntervalMs: int.parse(_intervalController.text.trim()),
        unit: _unitController.text.trim(),
        qos: _selectedQos,
      );

      final response = await SensorOnboardingService().registerSensor(request);

      setState(() {
        _successResponse = response;
        _currentStep = 3; // Transition to success step
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _currentStep = 1; // Return to form step to allow correction/retry
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: _currentStep != 2, // Block back swipe/hardware back button while loading
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 16 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCurrentStep(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.sensors, color: Colors.tealAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              _currentStep == 3 ? 'Sensor Registrado' : 'Aprovisionar Sensor',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (_currentStep != 2)
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white54),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
        const Divider(color: Colors.white12, height: 20),
      ],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return ChooseMethodStep(
          onManualSelected: () => setState(() => _currentStep = 1),
        );
      case 1:
        return RegistrationFormStep(
          formKey: _formKey,
          nameController: _nameController,
          unitController: _unitController,
          intervalController: _intervalController,
          error: _error,
          selectedType: _selectedType,
          selectedQos: _selectedQos,
          onTypeChanged: (type) {
            if (type != null) {
              setState(() {
                _selectedType = type;
                _unitController.text = _typeDefaults[type] ?? '';
              });
            }
          },
          onQosChanged: (qos) {
            if (qos != null) {
              setState(() => _selectedQos = qos);
            }
          },
          onSubmit: _submitForm,
        );
      case 2:
        return _buildLoadingStep();
      case 3:
        return SuccessStep(
          response: _successResponse!,
          onDone: () {
            Navigator.of(context).pop(_successResponse);
            widget.onSensorCreated?.call();
          },
        );
      default:
        return const SizedBox(height: 100);
    }
  }

  Widget _buildLoadingStep() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent)),
          SizedBox(height: 20),
          Text(
            'Registrando sensor...',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
