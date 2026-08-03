import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/form_validators.dart';
import '../../core/utils/loan_calculator.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/section_header.dart';

class CreditSimulatorScreen extends StatefulWidget {
  const CreditSimulatorScreen({super.key});

  @override
  State<CreditSimulatorScreen> createState() => _CreditSimulatorScreenState();
}

class _CreditSimulatorScreenState extends State<CreditSimulatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController(text: '50000000');
  final _monthsController = TextEditingController(text: '24');
  final _rateController = TextEditingController(text: '12');
  InstallmentType _type = InstallmentType.flat;
  SimulationResult? _result;

  @override
  void dispose() {
    _principalController.dispose();
    _monthsController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final principal = CurrencyFormatter.parseRupiah(_principalController.text);
    final months = int.parse(_monthsController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final rate = double.parse(_rateController.text.replaceAll(',', '.'));
    setState(() {
      _result = LoanCalculator.calculate(
        principal: principal,
        months: months,
        annualRate: rate,
        type: _type,
      );
    });
  }

  void _reset() {
    _principalController.text = '50000000';
    _monthsController.text = '24';
    _rateController.text = '12';
    setState(() {
      _type = InstallmentType.flat;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ResponsiveContainer(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandHeader(subtitle: 'Simulasi kredit flat dan anuitas'),
              const SizedBox(height: 22),
              const SectionHeader(
                title: 'Simulasi Kredit',
                subtitle: 'Hitung estimasi angsuran sebelum mengajukan kredit.',
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _principalController,
                        label: 'Plafon Pembiayaan',
                        hint: 'Contoh: 50000000',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payments_rounded,
                        validator: (value) => FormValidators.money(value, label: 'Plafon pembiayaan'),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 520;
                          final children = [
                            AppTextField(
                              controller: _monthsController,
                              label: 'Lama Angsuran',
                              hint: 'Bulan',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.calendar_month_rounded,
                              validator: (value) => FormValidators.required(value, label: 'Lama angsuran'),
                            ),
                            AppTextField(
                              controller: _rateController,
                              label: 'Bunga / Tahun',
                              hint: 'Contoh: 12',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              prefixIcon: Icons.percent_rounded,
                              validator: (value) => FormValidators.required(value, label: 'Bunga'),
                            ),
                          ];

                          if (!isWide) {
                            return Column(
                              children: [children[0], const SizedBox(height: 14), children[1]],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: children[0]),
                              const SizedBox(width: 12),
                              Expanded(child: children[1]),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<InstallmentType>(
                        segments: const [
                          ButtonSegment(value: InstallmentType.flat, label: Text('Flat'), icon: Icon(Icons.align_horizontal_left_rounded)),
                          ButtonSegment(value: InstallmentType.annuity, label: Text('Anuitas'), icon: Icon(Icons.show_chart_rounded)),
                        ],
                        selected: {_type},
                        onSelectionChanged: (value) => setState(() => _type = value.first),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _reset,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _calculate,
                              icon: const Icon(Icons.calculate_rounded),
                              label: const Text('Hitung'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 16),
                _ResultCard(result: _result!),
              ],
              const SizedBox(height: 16),
              const _DisclaimerCard(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final SimulationResult result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.skyBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hasil Simulasi Pinjaman', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    Text(
                      result.type == InstallmentType.flat ? 'Metode Flat' : 'Metode Anuitas',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ResultRow(label: 'Estimasi angsuran / bulan', value: CurrencyFormatter.rupiah(result.monthlyInstallment)),
          _ResultRow(label: 'Total pembayaran', value: CurrencyFormatter.rupiah(result.totalPayment)),
          _ResultRow(label: 'Estimasi total bunga', value: CurrencyFormatter.rupiah(result.totalInterest)),
          _ResultRow(label: 'Tenor', value: '${result.months} bulan'),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Simulasi ini bersifat estimasi. Angka final mengikuti analisis, kebijakan, dan ketentuan Bank Taruna yang berlaku.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
