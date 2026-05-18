import 'package:flutter/material.dart';

import '../../data/provisioning_repository.dart';
import '../../data/models/device_responses.dart';
import '../widgets/add_device/device_form_view.dart';
import '../widgets/add_device/device_success_view.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _repo = ProvisioningRepository();

  bool _isLoading = false;
  String? _error;
  ProvisionDeviceResponse? _result;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _repo.createDevice(
        name: _nameController.text.trim(),
      );

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_result != null ? 'Dispositivo Creado' : 'Agregar Dispositivo'),
      ),
      body: _result != null
          ? DeviceSuccessView(
              deviceName: _nameController.text,
              deviceUuid: _result?.deviceUuid ?? '-',
              deviceId: _result?.deviceId ?? '',
            )
          : DeviceFormView(
              formKey: _formKey,
              nameController: _nameController,
              isLoading: _isLoading,
              error: _error,
              onSubmit: _createDevice,
            ),
    );
  }

}
