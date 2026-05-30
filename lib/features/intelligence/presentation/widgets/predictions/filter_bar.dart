import 'package:flutter/material.dart';

import '../../../../../core/theme/zenin_colors.dart';

/// Barra de filtros tipo pill para predicciones.
///
/// Notifica cambios via [onFilterChanged].
class FilterBarWidget extends StatefulWidget {
  const FilterBarWidget({
    super.key,
    required this.onFilterChanged,
  });

  final ValueChanged<String> onFilterChanged;

  @override
  State<FilterBarWidget> createState() => _FilterBarWidgetState();
}

class _FilterBarWidgetState extends State<FilterBarWidget> {
  String _active = 'all';

  void _onTap(String filter) {
    if (_active == filter) return;
    setState(() => _active = filter);
    widget.onFilterChanged(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterPill(
          label: 'Todos',
          active: _active == 'all',
          onTap: () => _onTap('all'),
        ),
        const SizedBox(width: 8),
        _FilterPill(
          label: 'Alertas',
          active: _active == 'alerts',
          onTap: () => _onTap('alerts'),
        ),
        const SizedBox(width: 8),
        _FilterPill(
          label: 'Normal',
          active: _active == 'normal',
          onTap: () => _onTap('normal'),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? ZeninColors.green.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: active ? ZeninColors.green : ZeninColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? ZeninColors.green : ZeninColors.textDim,
          ),
        ),
      ),
    );
  }
}
