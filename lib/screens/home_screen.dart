import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/kompen_card.dart';
import '../widgets/primary_button.dart';
import 'kompen_form_screen.dart';
import 'kompen_list_screen.dart';
import 'profile_screen.dart';
import 'pengajuan_screen.dart';
import '../widgets/app_header.dart';
import '../widgets/app_bottom_nav.dart';
import 'tracking_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> _historyData = [
    {
      'tanggal': '22 April 2024',
      'matkul': 'Matkul Database',
      'dosen': 'Tudaa',
      'status': 'Approved',
      'tanggalAjukan': '22 april 2024',
    },
    {
      'tanggal': '20 April 2024',
      'matkul': 'Matkul Kalkulus',
      'dosen': 'Sabru',
      'status': 'Pending',
      'tanggalAjukan': '20 april 2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      body: IndexedStack(
        index: _currentIndex,
        children: [
<<<<<<< HEAD
          _buildHomeContent(),
          const KompenListScreen(),
          const Center(child: Text('Mahasiswa')),
          const Center(child: Text('Profil')),
=======
          const AppHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: _backgroundCream,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  _buildGreetingCard(),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusKompen(),
                          const SizedBox(height: 16),
                          _buildRekapitulasiSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppBottomNav(
            activeTab: NavTab.home,
            onTabSelected: (tab) {
              switch (tab) {
                case NavTab.profil:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  break;
                case NavTab.pengajuan:
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const PengajuanKompenScreen()), 
                  );
                break;
                case NavTab.tracking:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrackingListScreen()),
                  );
                  break;
                case NavTab.home:
                  break;
              }
            },
          ),
>>>>>>> cbb7972acdd313439f983345e7adc6d203e1b8ea
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 80,
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.primaryRed,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Jenis',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 26),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Halo, Seli!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Butuh bantuan\npengajuan kompen?',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.lightRed.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          size: 40,
                          color: AppTheme.primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats + Button Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pengajuan Kamu Bulan Ini',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: '4 ',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w800,
                                fontSize: 32,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                            TextSpan(
                              text: 'Pengajuan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Ajukan Kompen',
                        icon: Icons.add,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KompenFormScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'History Kompen Terbaru',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                      child: const Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                ..._historyData.map(
                  (item) => KompenCard(
                    tanggal: item['tanggal']!,
                    matkul: item['matkul']!,
                    dosen: item['dosen']!,
                    status: item['status']!,
                    tanggalAjukan: item['tanggalAjukan']!,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryRed,
        unselectedItemColor: AppTheme.textGrey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_alt), label: 'Pengajuan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mahasiswa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profil'),
        ],
      ),
    );
  }
}