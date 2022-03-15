class Validator {
  Validator._();

  static String? validatorEmail(String? value) {
    const String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    final RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhâp email';
    } else if (!regex.hasMatch(value)) {
      return 'Vui lòng nhập một địa chỉ email hợp lệ';
    } else {
      return null;
    }
  }
}
