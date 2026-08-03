class ApiEndpoints {
  const ApiEndpoints._();

  // Public content endpoints. If the website exposes another custom API,
  // update only this file and the repository layer stays unchanged.
  static const String wpPosts = '/wp-json/wp/v2/posts';
  static const String wpPages = '/wp-json/wp/v2/pages';
  static const String wpMedia = '/wp-json/wp/v2/media';

  // Existing public website routes discovered from banktaruna.com.
  static const String home = 'api/mapidashboard';
  static const String profile = '/visimisi';
  static const String information = '/informasi';
  static const String simulationCredit = '/simulasi-kredit';
  static const String onlineApplication = '/pengajuanonline';
  static const String loanApplication = '/formpengajuankredit';
  static const String savingsApplication = '/formpengajuantabungan';
  static const String depositApplication = '/formpengajuandeposito';
  static const String umkmdata = 'api/mapiumkm';
  static const String allberita = 'api/mapiberita';
  static const String detailproduk = 'api/mapiproduk/';

  // Submit endpoint: adjust this value if the production website has a
  // dedicated JSON API, for example /api/pengajuan/kredit.
  static const String loanApplicationSubmit = 'api/formpengajuankredit';
}
