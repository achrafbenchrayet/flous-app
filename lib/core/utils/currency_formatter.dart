import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();
  static final NumberFormat _formatter = NumberFormat("#,##0.000", "fr_FR");

  static String formatMillimes(int millimes, {bool includeSymbol = true}) {
    final double dinars = millimes / 1000.0;
    final formatted = _formatter.format(dinars).replaceAll('\u00A0', ' ');
    return includeSymbol ? '$formatted DT' : formatted;
  }

  static int parseToMillimes(String input) {
    if (input.trim().isEmpty) return 0;
    final sanitized = input.replaceAll(' ', '').replaceAll(',', '.');
    final double? dinars = double.tryParse(sanitized);
    if (dinars == null) return 0;
    return (dinars * 1000).round();
  }
}
