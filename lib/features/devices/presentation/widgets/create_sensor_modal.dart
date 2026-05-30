import 'package:flutter/material.dart';

import '../../data/provisioning_repository.dart';
import '../../data/models/sensor_responses.dart';
import 'create_sensor/sensor_types_data.dart';
import 'create_sensor/threshold_section.dart';
import '../../../../core/theme/design_colors.dart';
import '../../../../core/theme/design_spacing.dart';

class CreateSensorModal extends StatefulWidget {
  final String deviceUuid;
  final String deviceName;
  final VoidCallback? onSensorCreated;

  const CreateSensorModal({
    super.key,
    required this.deviceUuid,
    required this.deviceName,
    this.onSensorCreated,
  });

  static Future<AddSensorResponse?> show(
    BuildContext context, {
    required String deviceUuid,
    required String deviceName,
    VoidCallback? onSensorCreated,
  }) {
    return showModalBottomSheet<AddSensorResponse>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateSensorModal(
        deviceUuid: deviceUuid,
        deviceName: deviceName,
        onSensorCreated: onSensorCreated,
      ),
    );
  }

  @override
  State<CreateSensorModal> createState() => _CreateSensorModalState();
}

class _CreateSensorModalState extends State<CreateSensorModal> {
  final _formKey = GlobalKey<FormState>();
  final _warningMinController = TextEditingController();
  final _warningMaxController = TextEditingController();
  final _alertMinController = TextEditingController();
  final _alertMaxController = TextEditingController();
  final _repo = ProvisioningRepository();

  String _selectedType = 'temperature';
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get _sensorTypes => sensorTypesData;

  Map<String, dynamic> get _currentType {
    return _sensorTypes.firstWhere(
      (t) => t['value'] == _selectedType,
      orElse: () => _sensorTypes.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _applyDefaults();
  }

  void _applyDefaults() {
    final type = _currentType;
    final warning = type['defaultWarning'] as List<double>;
    final alert = type['defaultAlert'] as List<double>;
    
    _warningMinController.text = warning[0].toString();
    _warningMaxController.text = warning[1].toString();
    _alertMinController.text = alert[0].toString();
    _alertMaxController.text = alert[1].toString();
  }

  @override
  void dispose() {
    _warningMinController.dispose();
    _warningMaxController.dispose();
    _alertMinController.dispose();
    _alertMaxController.dispose();
    super.dispose();
  }

  Future<void> _createSensor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final type = _currentType;
      // Nombre automático según el tipo de sensor
      final autoName = type['label'] as String;
      final result = await _repo.addSensor(
        deviceUuid: widget.deviceUuid,
        sensorType: _selectedType,
        name: autoName,
        unit: type['unit'] as String,
        warningMin: double.tryParse(_warningMinController.text),
        warningMax: double.tryParse(_warningMaxController.text),
        alertMin: double.tryParse(_alertMinController.text),
        alertMax: double.tryParse(_alertMaxController.text),
      );

      if (mounted) {
        widget.onSensorCreated?.call();
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.sensors, color: Colors.tealAccent),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Agregar Sensor',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.deviceName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: DesignColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  
                  // Tipo de sensor
                  const Text(
                    'Tipo de sensor',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sensorTypes.map((type) {
                      final isSelected = _selectedType == type['value'];
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              type['icon'] as IconData,
                              size: 16,
                              color: isSelected ? Colors.black : DesignColors.textPrimary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              type['label'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedType = type['value'] as String;
                            _applyDefaults();
                          });
                        },
                        selectedColor: Colors.tealAccent,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  
                  SizedBox(height: 8),
                  
                  ThresholdSection(
                    title: 'Umbral de Advertencia',
                    color: DesignColors.amber,
                    icon: Icons.warning_amber,
                    minController: _warningMinController,
                    maxController: _warningMaxController,
                    unit: _currentType['unit'] as String,
                  ),
                  SizedBox(height: 16),
                  ThresholdSection(
                    title: 'Umbral de Alerta',
                    color: DesignColors.red,
                    icon: Icons.error_outline,
                    minController: _alertMinController,
                    maxController: _alertMaxController,
                    unit: _currentType['unit'] as String,
                  ),
                  SizedBox(height: 24),
                  
                  if (_error != null)
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.md),
                      margin: EdgeInsets.only(bottom: DesignSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                        border: Border.all(color: DesignColors.red),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: DesignColors.red, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: DesignColors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createSensor,
                      icon: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_circle_outline),
                      label: Text(_isLoading ? 'Creando...' : 'Agregar Sensor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignRadius.md),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
