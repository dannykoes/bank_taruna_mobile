import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/simulation/credit_simulator_screen.dart';
import 'features/transactions/transaction_screen.dart';
import 'features/umkm/umkm_screen.dart';

class BankTarunaApp extends StatelessWidget {
  const BankTarunaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.light(),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  DateTime? lastBackPressed;

  late final List<Widget> _pages = [
    HomeScreen(onNavigate: _selectTab),
    const UmkmPage(),
    const TransactionScreen(),
    const CreditSimulatorScreen(),
    // const LoanApplicationScreen(),
    // const NewsScreen(),
    const ProfileScreen(),
  ];

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          final now = DateTime.now();

          if (lastBackPressed == null ||
              now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
            lastBackPressed = now;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tekan sekali lagi untuk keluar'),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          Navigator.pop(context);
        },
        child: Scaffold(
          body: SafeArea(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectTab,
            destinations: const [
              NavigationDestination(
                  // 192 x 192 px
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Beranda'),
              NavigationDestination(
                  icon: Icon(Icons.store_outlined),
                  selectedIcon: Icon(Icons.store_rounded),
                  label: 'UMKM'),
              NavigationDestination(
                  icon: _TransactionNavIcon(selected: false),
                  selectedIcon: _TransactionNavIcon(selected: true),
                  label: 'Transaksi'),
              NavigationDestination(
                  icon: Icon(Icons.calculate_outlined),
                  selectedIcon: Icon(Icons.calculate_rounded),
                  label: 'Simulasi'),
              // NavigationDestination(
              //     icon: Icon(Icons.assignment_outlined),
              //     selectedIcon: Icon(Icons.assignment_rounded),
              //     label: 'Pengajuan'),
              // NavigationDestination(
              //     icon: Icon(Icons.newspaper_outlined),
              //     selectedIcon: Icon(Icons.newspaper_rounded),
              //     label: 'Berita'),
              NavigationDestination(
                  icon: Icon(Icons.account_balance_outlined),
                  selectedIcon: Icon(Icons.account_balance_rounded),
                  label: 'Profil'),
            ],
          ),
        ));
  }
}

class _TransactionNavIcon extends StatelessWidget {
  const _TransactionNavIcon({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, selected ? -6 : -4),
      child: Container(
          width: selected ? 50 : 44,
          height: selected ? 50 : 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color.fromARGB(255, 255, 255, 255)
              ],
              // colors: [AppColors.primaryRed, AppColors.primaryBlue],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue
                    .withValues(alpha: selected ? 0.32 : 0.2),
                blurRadius: selected ? 20 : 14,
                offset: Offset(0, selected ? 10 : 7),
              ),
            ],
          ),
          child: Image.asset(
            'assets/icons/ic_launcher.png',
            width: 26,
            height: 26,
          )
          // const Icon(
          //   Icons.receipt_long_rounded,
          //   color: Colors.white,
          //   size: 24,
          // ),
          ),
    );
  }
}
