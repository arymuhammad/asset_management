import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CsTextField extends StatelessWidget {
  final String label;
  final Widget? icon;
  final int? maxLines;
  final TextEditingController? controller;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final String? initialValue;
  final Function(String)? onFieldSubmitted;
  const CsTextField({
    super.key,
    required this.label,
    this.icon,
    this.maxLines,
    this.controller,
    this.enabled,
    this.inputFormatters,
    this.onChanged,
    this.initialValue,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      // readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        suffixIcon: icon,
        contentPadding: const EdgeInsets.all(8),
        fillColor: Colors.white,
        filled: true,
      ),
      onChanged: onChanged,
      initialValue: initialValue,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,

      // validator: (value) {
      //   if (value == null || value.isEmpty) {
      //     return 'Harap isi kolom $label';
      //   }
      //   return null;
      // },
    );
  }
}
