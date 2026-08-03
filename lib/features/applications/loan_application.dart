class LoanApplication {
  const LoanApplication({
    required this.fullName,
    required this.identityNumber,
    required this.phone,
    required this.email,
    required this.job,
    required this.monthlyIncome,
    required this.address,
    required this.loanType,
    required this.loanProduk,
    required this.loanAmount,
    required this.tenor,
    required this.purpose,
    required this.additionalNote,
    required this.disbursementAccount,
    required this.sourceOfFunds,
    required this.setoranAwal,
  });

  final String fullName;
  final String identityNumber;
  final String phone;
  final String email;
  final String job;
  final double monthlyIncome;
  final String address;
  final String loanType;
  final String loanProduk;
  final double loanAmount;
  final String tenor;
  final String purpose;
  final String additionalNote;
  final String disbursementAccount;
  final String sourceOfFunds;
  final String setoranAwal;

  Map<String, dynamic> toFormData() {
    return {
      'nama_lengkap': fullName,
      'no_ktp': identityNumber,
      'no_handphone': phone,
      'email': email,
      'pekerjaan': job,
      'penghasilan_bulan': monthlyIncome.round().toString(),
      'alamat_lengkap': address,
      'jenis_produk': loanProduk,
      'jenis_kredit': loanType,
      'jumlah_kredit': loanAmount.round().toString(),
      'jangka_waktu': tenor,
      'tujuan_kredit': purpose,
      'cat_tmbhn': additionalNote,
      'rek_pencairan': disbursementAccount,
      'sumber_dn': sourceOfFunds,
      'setoran_awal': setoranAwal,
      'source': 'mobile_app',
    };
  }
}
