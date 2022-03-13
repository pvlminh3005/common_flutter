import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class InputFormatters {
  static MaskTextInputFormatter maskFormatters({
    String? mask,
    Map<String, RegExp>? filter,
    MaskAutoCompletionType type = MaskAutoCompletionType.eager,
  }) {
    return MaskTextInputFormatter(
      mask: mask,
      filter: filter,
      type: type,
    );
  }
}
