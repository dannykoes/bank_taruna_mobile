class FormValidators {
  const FormValidators._();

  static String? required(String? value, {String label = 'Data'}) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Format email belum valid';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor handphone wajib diisi';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 10) return 'Nomor handphone minimal 10 digit';
    return null;
  }

  static String? ktp(String? value) {
    if (value == null || value.trim().isEmpty) return 'No. KTP wajib diisi';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 16) return 'No. KTP harus 16 digit';
    return null;
  }

  static String? money(String? value, {String label = 'Nominal'}) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty || double.parse(digits) <= 0) return '$label belum valid';
    return null;
  }
}
