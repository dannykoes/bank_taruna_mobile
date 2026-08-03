import 'package:bank_taruna_mobile/core/constants/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/form_validators.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand_header.dart';
import '../../core/widgets/responsive_container.dart';
import '../../core/widgets/section_header.dart';
import '../../shared/models/product_item.dart';
import '../home/home_data.dart';
import 'loan_application.dart';
import 'loan_application_repository.dart';

/// Provider untuk mengambil daftar jenis kredit berdasarkan produk utama.
///
/// Contoh alur:
/// 1. User memilih produk dari [bankProducts], misalnya "Kredit".
/// 2. Provider memanggil endpoint: {baseUrl}/api/detailproduk/{namaProduk}.
/// 3. Response API diparse menjadi [_LoanTypeOption].
/// 4. Dropdown menampilkan [title], tetapi value yang disimpan/dikirim adalah [id].
final loanTypeOptionsProvider =
    FutureProvider.family<List<_LoanTypeOption>, String>(
  (ref, productName) async {
    return fetchLoanTypeOptionsByProductName(productName);
  },
);

/// Model kecil khusus dropdown jenis kredit.
///
/// [id] adalah nilai yang dikirim ke API submit.
/// [title] adalah teks yang ditampilkan ke user di dropdown.
class _LoanTypeOption {
  const _LoanTypeOption({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;
}

/// Mengambil data jenis kredit dari API berdasarkan nama produk utama.
///
/// Endpoint mengikuti request:
/// ${baseUrl}api/detailproduk/nama produk
Future<List<_LoanTypeOption>> fetchLoanTypeOptionsByProductName(
  String productName,
) async {
  final endpoint = _detailProdukByNameUrl(productName);
  final response = await ApiClient.createDio().get(endpoint);

  final statusCode = response.statusCode ?? 0;
  if (statusCode < 200 || statusCode >= 300) {
    throw Exception('Gagal memuat jenis kredit. Status code: $statusCode');
  }

  final rawItems = _extractLoanTypeList(response.data);
  final options = <_LoanTypeOption>[];
  final usedIds = <String>{};

  for (final item in rawItems) {
    final option = _loanTypeOptionFromApi(item);

    // Hanya tampilkan item valid, lalu hilangkan duplikasi berdasarkan id.
    if (option == null || usedIds.contains(option.id)) continue;

    usedIds.add(option.id);
    options.add(option);
  }

  return List<_LoanTypeOption>.unmodifiable(options);
}

/// Membuat URL detail produk berdasarkan nama produk.
///
/// Nama produk di-encode agar spasi dan karakter seperti "/" aman dipakai di URL.
String _detailProdukByNameUrl(String productName) {
  final cleanBaseUrl = AppConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
  final encodedProductName =
      Uri.encodeComponent(productName.trim().toLowerCase());
  return '$cleanBaseUrl/${ApiEndpoints.detailproduk}$encodedProductName';
}

/// Mengubah berbagai kemungkinan response API menjadi list data.
///
/// Mendukung response:
/// - [ {...}, {...} ]
/// - { data: [ {...}, {...} ] }
/// - { data: { items: [ {...}, {...} ] } }
List<dynamic> _extractLoanTypeList(dynamic raw) {
  if (raw == null) return <dynamic>[];
  if (raw is List) return raw;

  if (raw is Map) {
    final json = raw.map((key, value) => MapEntry(key.toString(), value));

    for (final key in const [
      'data',
      'produk',
      'products',
      'items',
      'result',
      'results',
      'list',
    ]) {
      final value = json[key];
      if (value is List) return value;
      if (value is Map) {
        final nested = _extractLoanTypeList(value);
        if (nested.isNotEmpty) return nested;
      }
    }
  }

  return <dynamic>[];
}

/// Mengambil id dan title dari satu item API.
///
/// Field id dipakai sebagai value dropdown dan dikirim saat submit.
/// Field title dipakai sebagai label yang user lihat.
_LoanTypeOption? _loanTypeOptionFromApi(dynamic item) {
  if (item == null) return null;

  if (item is String || item is num || item is bool) {
    final value = item.toString().trim();
    if (value.isEmpty) return null;

    // Fallback untuk response primitif. Idealnya API mengirim object {id, title}.
    return _LoanTypeOption(id: value, title: value);
  }

  if (item is! Map) return null;

  final json = item.map((key, value) => MapEntry(key.toString(), value));

  final id = _firstNonEmptyValue(json, const [
    'id',
    'product_id',
    'productId',
    'produk_id',
    'produkId',
    'kode_produk',
    'kodeProduk',
    'jenis_id',
    'jenisId',
    'id_jenis',
    'idJenis',
    'value',
    'slug',
  ]);

  final title = _firstNonEmptyValue(json, const [
    'title',
    'nama',
    'nama_produk',
    'namaProduk',
    'name',
    'jenis',
    'jenis_kredit',
    'jenisKredit',
    'kategori',
    'label',
  ]);

  if (id == null || id.isEmpty) return null;

  return _LoanTypeOption(
    id: id,
    title: title == null || title.isEmpty ? id : title,
  );
}

/// Mengambil value pertama yang tidak kosong dari beberapa kemungkinan key API.
String? _firstNonEmptyValue(Map<dynamic, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;

    final parsed = value.toString().trim();
    if (parsed.isNotEmpty && parsed.toLowerCase() != 'null') {
      return parsed;
    }
  }

  return null;
}

/// Mengambil nama produk dari ProductItem yang berasal dari home_data.dart.
String _productNameOf(ProductItem product) => product.title.trim();

class LoanApplicationScreen extends ConsumerStatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  ConsumerState<LoanApplicationScreen> createState() =>
      _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends ConsumerState<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _identityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _jobController = TextEditingController();
  final _incomeController = TextEditingController();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _additionalNoteController = TextEditingController();
  final _disbursementAccountController = TextEditingController();
  final _sourceOfFundsController = TextEditingController();
  final _setoranAwal = TextEditingController();

  // Produk utama diambil dari home_data.dart -> bankProducts().
  // Nilai ini menjadi dropdown pertama sebelum memilih jenis kredit.
  String? _selectedProductName =
      bankProducts().isEmpty ? null : _productNameOf(bankProducts().first);

  // Jenis kredit diambil dari API setelah produk utama dipilih.
  // Yang disimpan adalah ID jenis kredit, sedangkan dropdown menampilkan title.
  String? _selectedLoanTypeId;

  String _tenor = _tenors.first;
  bool _isSubmitting = false;

  static const _tenors = ['6', '12', '24', '36'];

  bool get _isDepositoSelected =>
      _selectedProductName?.toLowerCase().contains('deposito') ?? false;

  bool get _isTabunganSelected =>
      _selectedProductName?.toLowerCase().contains('tabungan') ?? false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _identityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _jobController.dispose();
    _incomeController.dispose();
    _addressController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    _additionalNoteController.dispose();
    _disbursementAccountController.dispose();
    _sourceOfFundsController.dispose();
    _setoranAwal.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final application = LoanApplication(
      fullName: _fullNameController.text.trim(),
      identityNumber: _identityController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      job: _jobController.text.trim(),
      monthlyIncome: CurrencyFormatter.parseRupiah(_incomeController.text),
      address: _addressController.text.trim(),
      // loanType berisi ID jenis kredit dari dropdown API, bukan title.
      loanProduk: _selectedProductName ?? 'kredit',
      loanType: _selectedLoanTypeId ?? '',
      loanAmount: CurrencyFormatter.parseRupiah(_amountController.text),
      tenor: _tenor,
      purpose: _purposeController.text.trim(),
      additionalNote: _additionalNoteController.text.trim(),
      disbursementAccount:
          _isDepositoSelected ? _disbursementAccountController.text.trim() : '',
      sourceOfFunds:
          _isTabunganSelected ? _sourceOfFundsController.text.trim() : '',
      setoranAwal: _isTabunganSelected ? _setoranAwal.text.trim() : '',
    );

    try {
      await ref.read(loanApplicationRepositoryProvider).submit(application);
      if (!mounted) return;
      _showSuccess();
      _clearForm();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(
        'Pengajuan belum terkirim. Pastikan inputan terisi semua, lalu coba lagi.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    _fullNameController.clear();
    _identityController.clear();
    _phoneController.clear();
    _emailController.clear();
    _jobController.clear();
    _incomeController.clear();
    _addressController.clear();
    _amountController.clear();
    _purposeController.clear();
    _additionalNoteController.clear();
    _disbursementAccountController.clear();
    _sourceOfFundsController.clear();
    _setoranAwal.clear();
    setState(() {
      _selectedProductName =
          bankProducts().isEmpty ? null : _productNameOf(bankProducts().first);
      _selectedLoanTypeId = null;
      _tenor = _tenors.first;
    });
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 44),
        title: const Text('Pengajuan Terkirim'),
        content: const Text(
            'Data pengajuan Anda berhasil dikirim. Tim Bank Taruna akan menindaklanjuti sesuai prosedur.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup')),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.primaryRed : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedProductName = _selectedProductName;
    final isDepositoSelected = _isDepositoSelected;
    final isTabunganSelected = _isTabunganSelected;
    final loanTypeOptionsAsync = selectedProductName == null
        ? const AsyncValue<List<_LoanTypeOption>>.data(<_LoanTypeOption>[])
        : ref.watch(loanTypeOptionsProvider(selectedProductName));
    return ListView(
      children: [
        ResponsiveContainer(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandHeader(subtitle: 'Pengajuan kredit online'),
              const SizedBox(height: 22),
              const SectionHeader(
                title: 'Form Pengajuan Kredit',
                subtitle:
                    'Isi data sesuai form pengajuan kredit pada website Bank Taruna.',
              ),
              const SizedBox(height: 14),
              AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormGroupTitle(
                          icon: Icons.person_rounded, title: 'Data Pemohon'),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _fullNameController,
                        label: 'Nama Lengkap',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (value) => FormValidators.required(value,
                            label: 'Nama lengkap'),
                      ),
                      const SizedBox(height: 14),
                      _ResponsiveFields(
                        children: [
                          AppTextField(
                            controller: _identityController,
                            label: 'No. KTP',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.badge_outlined,
                            validator: FormValidators.ktp,
                          ),
                          AppTextField(
                            controller: _phoneController,
                            label: 'No. Handphone',
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_outlined,
                            validator: FormValidators.phone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: 14),
                      _ResponsiveFields(
                        children: [
                          AppTextField(
                            controller: _jobController,
                            label: 'Pekerjaan',
                            prefixIcon: Icons.work_outline_rounded,
                            validator: (value) => FormValidators.required(value,
                                label: 'Pekerjaan'),
                          ),
                          AppTextField(
                            controller: _incomeController,
                            label: 'Penghasilan / Bulan',
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.payments_outlined,
                            validator: (value) => FormValidators.money(value,
                                label: 'Penghasilan'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _addressController,
                        label: 'Alamat Lengkap',
                        prefixIcon: Icons.location_on_outlined,
                        maxLines: 3,
                        validator: (value) => FormValidators.required(value,
                            label: 'Alamat lengkap'),
                      ),
                      const SizedBox(height: 24),
                      _FormGroupTitle(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Data Pengajuan Kredit'),
                      const SizedBox(height: 14),
                      // Dropdown produk utama dari home_data.dart -> bankProducts().
                      // Contoh isi: Kredit, Tabungan, Deposito, dan produk lain yang ada di data beranda.
                      DropdownButtonFormField<String>(
                        value: _selectedProductName,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Produk',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                        items: bankProducts()
                            .map((product) => _productNameOf(product))
                            .where((name) => name.isNotEmpty)
                            .toSet()
                            .map(
                              (name) => DropdownMenuItem(
                                value: name,
                                child: Text(name),
                              ),
                            )
                            .toList(),
                        validator: (value) => FormValidators.required(
                          value,
                          label: 'Produk',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedProductName = value;
                            // Reset pilihan jenis kredit karena data jenis kredit bergantung pada produk yang dipilih.
                            _selectedLoanTypeId = null;
                            _disbursementAccountController.clear();
                            _sourceOfFundsController.clear();
                            _setoranAwal.clear();
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _LoanTypeDropdown(
                        selectedProductName: selectedProductName,
                        selectedLoanTypeId: _selectedLoanTypeId,
                        loanTypeOptionsAsync: loanTypeOptionsAsync,
                        onRetry: selectedProductName == null
                            ? null
                            : () => ref.invalidate(
                                  loanTypeOptionsProvider(selectedProductName),
                                ),
                        onChanged: (value) {
                          setState(() => _selectedLoanTypeId = value);
                        },
                      ),
                      if (!isTabunganSelected && !isDepositoSelected) ...[
                        const SizedBox(height: 14),
                        _ResponsiveFields(
                          children: [
                            AppTextField(
                              controller: _amountController,
                              label: 'Jumlah Kredit ( Rupiah )',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.price_change_outlined,
                              validator: (value) => FormValidators.money(value,
                                  label: 'Jumlah kredit'),
                            ),
                            DropdownButtonFormField<String>(
                              value: _tenor,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                  labelText: 'Jangka Waktu ( bulan )',
                                  prefixIcon:
                                      Icon(Icons.calendar_today_outlined)),
                              items: _tenors
                                  .map((item) => DropdownMenuItem(
                                      value: item, child: Text(item)))
                                  .toList(),
                              onChanged: (value) => setState(
                                  () => _tenor = value ?? _tenors.first),
                            ),
                          ],
                        ),
                      ],

                      if (isDepositoSelected) ...[
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _disbursementAccountController,
                          label: 'Rekening Pencairan',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.account_balance_wallet_outlined,
                          validator: (value) => FormValidators.required(
                            value,
                            label: 'Rekening pencairan',
                          ),
                        ),
                      ],
                      if (isTabunganSelected) ...[
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _setoranAwal,
                          label: 'Setoran Awal',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.account_balance_wallet_outlined,
                          validator: (value) => FormValidators.required(
                            value,
                            label: 'Setoran Awal',
                          ),
                        ),
                      ],
                      if (isTabunganSelected || isDepositoSelected) ...[
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _sourceOfFundsController,
                          label: 'Sumber Dana',
                          prefixIcon: Icons.wallet,
                          validator: (value) => FormValidators.required(
                            value,
                            label: 'Sumber dana',
                          ),
                        ),
                      ],

                      if (!isDepositoSelected) ...[
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _purposeController,
                          label: 'Tujuan Pengajuan',
                          prefixIcon: Icons.flag_outlined,
                          maxLines: 3,
                          validator: (value) => FormValidators.required(value,
                              label: 'Tujuan Pengajuan'),
                        ),
                      ],
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _additionalNoteController,
                        label: 'Catatan Tambahan',
                        prefixIcon: Icons.notes_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send_rounded),
                        label: Text(
                            _isSubmitting ? 'Mengirim...' : 'Kirim Pengajuan'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // const AppCard(
              //   color: AppColors.softRed,
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Icon(Icons.security_rounded, color: AppColors.primaryRed),
              //       SizedBox(width: 12),
              //       Expanded(
              //         child: Text(
              //           'Pastikan inputan sudah sesuai, No KTP 16 digit, No HP minimal 10 digit, Email sesuai format. Apabila terjadi kesalahan aplikasi harap hubungi ${AppConstants.phone} untuk tindak lanjut layanan.',
              //           style: TextStyle(color: AppColors.ink, height: 1.35),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Dropdown jenis kredit yang datanya berasal dari API.
///
/// Widget ini sengaja dipisah supaya build utama tetap bersih dan mudah dirawat.
/// Dropdown menampilkan title, tetapi value yang tersimpan adalah id.
class _LoanTypeDropdown extends StatelessWidget {
  const _LoanTypeDropdown({
    required this.selectedProductName,
    required this.selectedLoanTypeId,
    required this.loanTypeOptionsAsync,
    required this.onChanged,
    required this.onRetry,
  });

  final String? selectedProductName;
  final String? selectedLoanTypeId;
  final AsyncValue<List<_LoanTypeOption>> loanTypeOptionsAsync;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    if (selectedProductName == null || selectedProductName!.trim().isEmpty) {
      return DropdownButtonFormField<String>(
        value: null,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Jenis Kredit',
          prefixIcon: Icon(Icons.category_outlined),
        ),
        hint: const Text('Pilih produk terlebih dahulu'),
        items: const [],
        onChanged: null,
        validator: (_) => 'Pilih produk terlebih dahulu',
      );
    }

    return loanTypeOptionsAsync.when(
      loading: () => DropdownButtonFormField<String>(
        value: null,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Jenis Kredit',
          prefixIcon: Icon(Icons.sync_rounded),
        ),
        hint: Text('Memuat jenis kredit $selectedProductName...'),
        items: const [],
        onChanged: null,
        validator: (_) => 'Jenis kredit sedang dimuat',
      ),
      error: (error, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Jenis Kredit',
              prefixIcon: Icon(Icons.error_outline_rounded),
            ),
            hint: const Text('Gagal memuat jenis kredit'),
            items: const [],
            onChanged: null,
            validator: (_) => 'Jenis kredit belum berhasil dimuat',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'API belum dapat memuat jenis kredit. $error',
                  style: const TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ],
      ),
      data: (loanTypes) {
        final validLoanTypes = loanTypes
            .where((item) => item.id.trim().isNotEmpty)
            .toList(growable: false);

        final effectiveValue =
            validLoanTypes.any((item) => item.id == selectedLoanTypeId)
                ? selectedLoanTypeId
                : null;

        return DropdownButtonFormField<String>(
          // value adalah id. Inilah nilai yang masuk ke _selectedLoanTypeId
          // dan dikirim saat submit.
          value: effectiveValue,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Jenis Kredit',
            prefixIcon: Icon(Icons.category_outlined),
          ),
          hint: Text(
            validLoanTypes.isEmpty
                ? 'Jenis kredit belum tersedia'
                : 'Pilih jenis kredit',
          ),
          items: validLoanTypes
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.id,
                  // User tetap melihat title/nama produk, bukan id.
                  child: Text(item.title),
                ),
              )
              .toList(growable: false),
          onChanged: validLoanTypes.isEmpty ? null : onChanged,
          validator: (value) => FormValidators.required(
            value,
            label: 'Jenis kredit',
          ),
        );
      },
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  const _ResponsiveFields({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              children[0],
              const SizedBox(height: 14),
              children[1],
            ],
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
    );
  }
}

class _FormGroupTitle extends StatelessWidget {
  const _FormGroupTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: AppColors.skyBlue,
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }
}
