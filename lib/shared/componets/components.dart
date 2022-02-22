import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget defaultTextField({
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  required String label,
  required IconData prefixIcon,
  required FormFieldValidator validate,
}) =>
    TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validate,
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon),
          border: const OutlineInputBorder()),
    );
