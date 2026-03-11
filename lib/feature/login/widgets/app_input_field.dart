import 'package:flutter/material.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/core/theme/app_dimens.dart';
import 'package:unilib/core/theme/app_text_styles.dart';

class AppInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AppInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  bool _obscure = true;
  bool _focused = false;
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()
      ..addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Field label
        Text(widget.label.toUpperCase(), style: AppTextStyles.fieldLabel),

        const SizedBox(height: AppDimens.spXS),

        // Input box
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.navyInput,
            borderRadius: AppDimens.inputRadius,
            border: Border.all(
              color: _focused ? AppColors.blue : AppColors.navyBorder,
              width: _focused ? 1.5 : 1.0,
            ),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.blue.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            obscureText: widget.isPassword && _obscure,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            style: AppTextStyles.inputText,
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.spMD,
                vertical: AppDimens.spMD,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  widget.prefixIcon,
                  color: _focused ? AppColors.blue : AppColors.textMuted,
                  size: AppDimens.inputIconSize,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 48),
              // Eye toggle for password fields
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: AppDimens.inputIconSize,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
