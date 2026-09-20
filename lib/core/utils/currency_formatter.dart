import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final NumberFormat _numberFormatter = NumberFormat.decimalPattern('id_ID');

  static String format(num amount) {
    return _formatter.format(amount);
  }
  static String formatNumber(num amount) {
    return _numberFormatter.format(amount);
  }


  static String formatCompact(num amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final String formatted;
    if (absAmount >= 1000000) {
      final juta = (absAmount / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      formatted = 'Rp ${juta}jt';
    } else if (absAmount >= 1000) {
      final ribu = (absAmount / 1000).toStringAsFixed(0);
      formatted = 'Rp ${ribu}rb';
    } else {
      formatted = 'Rp $absAmount';
    }
    return isNegative ? '-$formatted' : formatted;
  }

  static int parse(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }
}

/// Automatically formats numeric inputs with thousands separator dot (.) in real-time.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Handle Backspace when cursor is positioned right after a separator dot (.)
    if (oldValue.text.length > newValue.text.length &&
        oldValue.selection.isCollapsed &&
        oldValue.selection.end > 0 &&
        oldValue.selection.end <= oldValue.text.length &&
        oldValue.text[oldValue.selection.end - 1] == '.') {
      final indexToRemove = oldValue.selection.end - 2;
      if (indexToRemove >= 0) {
        final textWithoutDigit = oldValue.text.substring(0, indexToRemove) +
            oldValue.text.substring(oldValue.selection.end);
        final digitsClean = textWithoutDigit.replaceAll(RegExp(r'[^0-9]'), '');
        if (digitsClean.isEmpty) {
          return const TextEditingValue();
        }
        final number = int.tryParse(digitsClean) ?? 0;
        final formatted = CurrencyFormatter.formatNumber(number);

        final digitsBeforeCursor = textWithoutDigit
            .substring(0, indexToRemove)
            .replaceAll(RegExp(r'[^0-9]'), '')
            .length;

        int newCursorPos = 0;
        int digitCount = 0;
        for (int i = 0; i < formatted.length; i++) {
          if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
            digitCount++;
          }
          if (digitCount == digitsBeforeCursor) {
            newCursorPos = i + 1;
            break;
          }
        }
        if (digitsBeforeCursor == 0) {
          newCursorPos = 0;
        } else if (newCursorPos == 0) {
          newCursorPos = formatted.length;
        }

        return TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(
            offset: newCursorPos.clamp(0, formatted.length),
          ),
        );
      }
    }

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue();
    }

    // Count how many digits existed before the cursor in newValue
    final cursorIndex = newValue.selection.end;
    final textBeforeCursor = newValue.text.substring(0, cursorIndex.clamp(0, newValue.text.length));
    final digitsBeforeCursor = textBeforeCursor.replaceAll(RegExp(r'[^0-9]'), '').length;

    final number = int.tryParse(digits) ?? 0;
    final formatted = CurrencyFormatter.formatNumber(number);

    // Calculate new cursor position based on digitsBeforeCursor
    int newCursorPos = 0;
    int digitCount = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
        digitCount++;
      }
      if (digitCount == digitsBeforeCursor) {
        newCursorPos = i + 1;
        break;
      }
    }
    if (digitsBeforeCursor == 0) {
      newCursorPos = 0;
    } else if (newCursorPos == 0) {
      newCursorPos = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: newCursorPos.clamp(0, formatted.length),
      ),
    );
  }
}

