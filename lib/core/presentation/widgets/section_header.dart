import 'package:flutter/material.dart';
import '../../theme/design_colors.dart';
import '../../theme/design_spacing.dart';
import '../../theme/design_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: DesignSpacing.sm),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: DesignColors.border, width: 0.5),
                ),
              ),
              child: Text(
                title.toUpperCase(),
                style: DesignTextStyles.sectionTitle,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
