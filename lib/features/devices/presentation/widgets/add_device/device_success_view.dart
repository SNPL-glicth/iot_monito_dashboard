import 'package:flutter/material.dart';
import '../../../../../../core/theme/design_colors.dart';
import '../../../../../../core/theme/design_spacing.dart';
import '../../../../../../core/theme/design_text_styles.dart';


/// Vista de éxito después de crear un dispositivo.
class DeviceSuccessView extends StatelessWidget {
  const DeviceSuccessView({
    super.key,
    required this.deviceName,
    required this.deviceUuid,
    required this.deviceId,
  });

  final String deviceName;
  final String deviceUuid;
  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignSpacing.xl),
      child: Column(
        children: [
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(DesignSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [DesignColors.green, DesignColors.green.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(DesignRadius.xl),
              boxShadow: [
                BoxShadow(
                  color: DesignColors.green.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(Icons.check_rounded, size: 48, color: DesignColors.textPrimary),
          ),
          SizedBox(height: DesignSpacing.xl),
          Text(
            'Dispositivo Creado!',
            style: DesignTextStyles.screenTitle,
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            'Ahora puedes agregar sensores a este dispositivo',
            textAlign: TextAlign.center,
            style: DesignTextStyles.bodyText,
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(color: DesignColors.surface, border: Border.all(color: DesignColors.border, width: 0.5), borderRadius: BorderRadius.circular(DesignRadius.lg)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.sm),
                      decoration: BoxDecoration(
                        color: DesignColors.cyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Icon(Icons.info_outline_rounded, color: DesignColors.cyan, size: 18),
                    ),
                    SizedBox(width: DesignSpacing.md),
                    Text('Detalles', style: DesignTextStyles.cardTitle),
                  ],
                ),
                SizedBox(height: DesignSpacing.lg),
                _infoRow('Nombre', deviceName),
                _infoRow('UUID', deviceUuid),
                _infoRow('Estado', 'Esperando activación'),
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.lg),
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              color: DesignColors.surface2,
              border: Border.all(color: DesignColors.border, width: 0.5),
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.sm),
                      decoration: BoxDecoration(
                        color: DesignColors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(DesignRadius.sm),
                      ),
                      child: Icon(Icons.lightbulb_outline_rounded, color: DesignColors.amber, size: 18),
                    ),
                    SizedBox(width: DesignSpacing.md),
                    Text('Próximos pasos', style: DesignTextStyles.cardTitle),
                  ],
                ),
                SizedBox(height: DesignSpacing.lg),
                _stepItem('1', 'Agregar sensores al dispositivo'),
                _stepItem('2', 'Escanear QR del hardware físico'),
                _stepItem('3', 'El dispositivo se activará automáticamente'),
              ],
            ),
          ),
          SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.textPrimary,
                    side: BorderSide(color: DesignColors.border),
                    padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 18),
                      SizedBox(width: DesignSpacing.sm),
                      Text('Volver'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/device/$deviceId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.cyan,
                    foregroundColor: DesignColors.textPrimary,
                    padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignRadius.md)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sensors_rounded, size: 18),
                      SizedBox(width: DesignSpacing.sm),
                      Text('Agregar Sensores'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: DesignTextStyles.bodyText),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: DesignColors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.sm),
            ),
            child: Center(
              child: Text(number, style: TextStyle(color: DesignColors.cyan, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Text(text, style: DesignTextStyles.bodyText),
          ),
        ],
      ),
    );
  }
}
