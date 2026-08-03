import 'dart:math' as math;

enum InstallmentType { flat, annuity }

class SimulationResult {
  const SimulationResult({
    required this.monthlyInstallment,
    required this.totalPayment,
    required this.totalInterest,
    required this.principal,
    required this.months,
    required this.annualRate,
    required this.type,
  });

  final double monthlyInstallment;
  final double totalPayment;
  final double totalInterest;
  final double principal;
  final int months;
  final double annualRate;
  final InstallmentType type;
}

class LoanCalculator {
  const LoanCalculator._();

  static SimulationResult calculate({
    required double principal,
    required int months,
    required double annualRate,
    required InstallmentType type,
  }) {
    if (principal <= 0 || months <= 0 || annualRate < 0) {
      throw ArgumentError('Input simulasi tidak valid.');
    }

    final monthlyRate = annualRate / 100 / 12;
    final monthlyInstallment = type == InstallmentType.flat
        ? _flat(principal, months, monthlyRate)
        : _annuity(principal, months, monthlyRate);

    final totalPayment = monthlyInstallment * months;
    return SimulationResult(
      monthlyInstallment: monthlyInstallment,
      totalPayment: totalPayment,
      totalInterest: totalPayment - principal,
      principal: principal,
      months: months,
      annualRate: annualRate,
      type: type,
    );
  }

  static double _flat(double principal, int months, double monthlyRate) {
    final principalPayment = principal / months;
    final interestPayment = principal * monthlyRate;
    return principalPayment + interestPayment;
  }

  static double _annuity(double principal, int months, double monthlyRate) {
    if (monthlyRate == 0) return principal / months;
    final factor = math.pow(1 + monthlyRate, months).toDouble();
    return principal * monthlyRate * factor / (factor - 1);
  }
}
