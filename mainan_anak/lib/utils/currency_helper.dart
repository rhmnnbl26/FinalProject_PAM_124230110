import 'package:intl/intl.dart';

class CurrencyHelper {
  static final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final usdFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$ ',
    decimalDigits: 2,
  );

  static final eurFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '€ ',
    decimalDigits: 2,
  );

  static final jpyFormat = NumberFormat.currency(
    locale: 'ja_JP',
    symbol: '¥ ',
    decimalDigits: 0,
  );

  static String formatIDR(double amount) {
    return currencyFormat.format(amount);
  }

  static String formatUSD(double amount) {
    return usdFormat.format(amount);
  }

  static String formatEUR(double amount) {
    return eurFormat.format(amount);
  }

  static String formatJPY(double amount) {
    return jpyFormat.format(amount);
  }

  static String formatCurrency(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return formatUSD(amount);
      case 'EUR':
        return formatEUR(amount);
      case 'JPY':
        return formatJPY(amount);
      default:
        return formatIDR(amount);
    }
  }
}
