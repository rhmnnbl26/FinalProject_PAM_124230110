class ExchangeRate {
  final double usd;
  final double eur;
  final double jpy;

  ExchangeRate({required this.usd, required this.eur, required this.jpy});

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    final rates = json['rates'] as Map<String, dynamic>;
    return ExchangeRate(
      usd: (rates['USD'] as num?)?.toDouble() ?? 1.0,
      eur: (rates['EUR'] as num?)?.toDouble() ?? 1.0,
      jpy: (rates['JPY'] as num?)?.toDouble() ?? 1.0,
    );
  }

  double convertFromIdr(double idrAmount, String targetCurrency) {
    // Frankfurter API gives rates from base currency
    // We need to convert IDR to target currency
    switch (targetCurrency.toUpperCase()) {
      case 'USD':
        return idrAmount * usd;
      case 'EUR':
        return idrAmount * eur;
      case 'JPY':
        return idrAmount * jpy;
      default:
        return idrAmount;
    }
  }
}
