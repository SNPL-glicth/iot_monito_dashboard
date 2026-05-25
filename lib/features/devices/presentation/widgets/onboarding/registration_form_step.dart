import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../define_sensor_widgets.dart';

class RegistrationFormStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController unitController;
  final TextEditingController intervalController;
  final String? error;
  final String selectedType;
  final int selectedQos;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<int?> onQosChanged;
  final VoidCallback onSubmit;

  const RegistrationFormStep({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.unitController,
    required this.intervalController,
    required this.error,
    required this.selectedType,
    required this.selectedQos,
    required this.onTypeChanged,
    required this.onQosChanged,
    required this.onSubmit,
  });

  @override
  State<RegistrationFormStep> createState() => _RegistrationFormStepState();
}

class _RegistrationFormStepState extends State<RegistrationFormStep> {
  final List<String> _sensorTypes = [
    'temperature',
    'humidity',
    'pressure',
    'vibration',
    'current',
    'voltage',
    'flow'
  ];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.error != null) ...[
            DefineSensorWidgets.errorWidget(widget.error!),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: widget.nameController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: 'Nombre del sensor',
              hint: 'Ej. Sensor de Presión de Gas',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'El nombre es obligatorio';
              if (val.length > 100) return 'Máximo 100 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: widget.selectedType,
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(label: 'Tipo de sensor'),
            items: _sensorTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type[0].toUpperCase() + type.substring(1)),
              );
            }).toList(),
            onChanged: widget.onTypeChanged,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.unitController,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              label: 'Unidad de medida',
              hint: 'Ej. °C, %, bar',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'La unidad es obligatoria';
              if (val.length > 20) return 'Máximo 20 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: widget.intervalController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration(
              label: 'Intervalo de muestreo (ms)',
              helper: 'Cada cuántos ms envía datos el sensor',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'El intervalo es obligatorio';
              final parsed = int.tryParse(val);
              if (parsed == null || parsed < 100 || parsed > 60000) {
                return 'Rango permitido: 100 - 60000 ms';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: widget.selectedQos,
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(label: 'QoS MQTT'),
            items: const [
              DropdownMenuItem<int>(value: 0, child: Text('0 - At most once')),
              DropdownMenuItem<int>(value: 1, child: Text('1 - At least once (Default)')),
              DropdownMenuItem<int>(value: 2, child: Text('2 - Exactly once')),
            ],
            onChanged: widget.onQosChanged,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.tealAccent,
              foregroundColor: const Color(0xFF1E293B),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Registrar sensor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    String? helper,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      helperText: helper,
      helperStyle: const TextStyle(color: Colors.white38),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white30),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.tealAccent),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
    );
  }
}
