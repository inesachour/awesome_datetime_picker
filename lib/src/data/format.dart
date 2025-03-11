import 'package:awesome_datetime_picker/src/data/picker_type.dart';

enum AwesomeDateFormat {
  dMy([PickerType.day, PickerType.month_number, PickerType.year]),
  dMMy([PickerType.day, PickerType.month_text, PickerType.year]),
  yMd([PickerType.year, PickerType.month_number, PickerType.day]),
  yMMd([PickerType.year, PickerType.month_text, PickerType.day]);

  final List<PickerType> value;

  const AwesomeDateFormat(this.value);
}

enum AwesomeTimeFormat {
  //hm([PickerType.hour_12, PickerType.minute]),
  Hm([PickerType.hour_24, PickerType.minute]);

  final List<PickerType> value;

  const AwesomeTimeFormat(this.value);
}
