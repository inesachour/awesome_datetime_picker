library awesome_datetime_picker;

import 'package:awesome_datetime_picker/src/widgets/custom_number_picker_widget.dart';
import 'package:awesome_datetime_picker/src/widgets/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AwesomeDateTimePicker extends StatefulWidget {
  const AwesomeDateTimePicker({super.key});

  @override
  State<AwesomeDateTimePicker> createState() => _AwesomeDateTimePickerState();
}

class _AwesomeDateTimePickerState extends State<AwesomeDateTimePicker> {
  @override
  Widget build(BuildContext context) {
    return DatePicker();
  }
}
