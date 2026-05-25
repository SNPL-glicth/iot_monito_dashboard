import 'package:flutter/material.dart';

import 'define_step_widget.dart';
import 'choose_method_step_widget.dart';
import 'scan_step_widget.dart';
import 'confirm_step_widget.dart';
import 'complete_step_widget.dart';
import 'flow_header_widget.dart';

/// Content widget for define sensor flow
class DefineSensorFlowContentWidget extends StatelessWidget {
  const DefineSensorFlowContentWidget({
    super.key,
    required this.formKey,
    required this.controller,
    required this.warningMinController,
    required this.warningMaxController,
    required this.alertMinController,
    required this.alertMaxController,
    required this.onDefineSensor,
    required this.onActivateSensorWithCode,
    required this.onPublishSensorStep,
    required this.onReserveSensorStep,
    required this.onRetryReserve,
    required this.onConfirmSensor,
    required this.onRetryConfirm,
    required this.onShowManualCodeDialog,
    required this.onOpenScanner,
    required this.onHandleScannedQR,
    required this.onFinish,
  });

  final GlobalKey<FormState> formKey;
  final dynamic controller;
  final TextEditingController warningMinController;
  final TextEditingController warningMaxController;
  final TextEditingController alertMinController;
  final TextEditingController alertMaxController;
  final VoidCallback onDefineSensor;
  final Function(String) onActivateSensorWithCode;
  final VoidCallback onPublishSensorStep;
  final VoidCallback onReserveSensorStep;
  final VoidCallback onRetryReserve;
  final VoidCallback onConfirmSensor;
  final VoidCallback onRetryConfirm;
  final VoidCallback onShowManualCodeDialog;
  final VoidCallback onOpenScanner;
  final Function(String) onHandleScannedQR;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FlowHeaderWidget(
          currentStep: controller.currentStep,
          activationMethod: controller.activationMethod,
          onClose: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildStepContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (controller.currentStep) {
      case 0:
        return DefineStepWidget(
          formKey: formKey,
          selectedType: controller.selectedType,
          warningMinController: warningMinController,
          warningMaxController: warningMaxController,
          alertMinController: alertMinController,
          alertMaxController: alertMaxController,
          onTypeSelected: (type) => controller.setSelectedType(type),
          onNext: onDefineSensor,
          isLoading: controller.isLoading,
          error: controller.error,
        );
      case 1:
        return ChooseMethodStepWidget(
          selectedType: controller.selectedType,
          publishDone: controller.publishDone,
          reserveDone: controller.reserveDone,
          onQRSelected: () {
            controller.setActivationMethod('qr');
            controller.setStep(2);
          },
          onPublishSelected: onPublishSensorStep,
          onReserveSelected: onReserveSensorStep,
          onRetryReserve: onRetryReserve,
          isLoading: controller.isLoading,
          error: controller.error,
        );
      case 2:
        return controller.activationMethod == 'qr'
            ? ScanStepWidget(
                selectedType: controller.selectedType,
                onOpenScanner: onOpenScanner,
                onManualCode: onShowManualCodeDialog,
                isLoading: controller.isLoading,
                error: controller.error,
              )
            : ConfirmStepWidget(
                reserveData: controller.reserveData,
                onConfirm: onConfirmSensor,
                onRetry: onRetryConfirm,
                isLoading: controller.isLoading,
                error: controller.error,
              );
      case 3:
        return CompleteStepWidget(
          confirmResult: controller.confirmResult,
          onFinish: onFinish,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
