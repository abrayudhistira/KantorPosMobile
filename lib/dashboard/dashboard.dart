import 'package:flutter/material.dart';
import 'package:kantorpos/barang/barangPage.dart';
import 'package:kantorpos/model/saldo.dart';
import 'package:kantorpos/service/saldoService.dart';
import 'package:kantorpos/service/uangKeluarService.dart';
import 'package:kantorpos/service/uangMasukService.dart';
import 'package:kantorpos/uangkeluar/uangKeluarPage.dart';
import 'package:kantorpos/uangmasuk/uangMaskPage.dart';
import 'package:intl/intl.dart';

// Define theme colors
class KantorPosTheme {
  static const Color primaryColor = Color(0xFFDD9F52);    // Warna utama (appbar)
  static const Color secondaryColor = Color(0xFFDCC894);  // Warna background
  static const Color accentColor = Color(0xFF2C586E);     // Button primary
  static const Color lightAccentColor = Color(0xFF8DA1AF); // Button secondary
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color white = Colors.white;
}

class Dashboard extends StatefulWidget {
  final String username;
  const Dashboard({super.key, required this.username});

  @override
  State<Dashboard> createState() => _DashboardState();
}

String formatRupiah(dynamic nominal) {
  if (nominal == null) return '-';
  final number = int.tryParse(nominal.toString()) ?? 0;
  return 'Rp. ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}

class _DashboardState extends State<Dashboard> {
  final SaldoService _saldoService = SaldoService();
  final UangMasukService _uangMasukService = UangMasukService();
  final UangKeluarService _uangKeluarService = UangKeluarService();
  late Future<List<Saldo>> _saldoList;
  Future<List<dynamic>> _activityList = Future.value([]);
  int _selectedIndex = 2; // <-- Set index awal ke Home

  @override
  void initState() {
    super.initState();
    _loadSaldo();
    _loadActivities();
  }

  void _loadSaldo() {
    setState(() {
      _saldoList = _saldoService.fetchAll();
    });
  }

  void _loadActivities() {
    setState(() {
      _activityList = _fetchCombinedActivities();
    });
  }

  Future<List<dynamic>> _fetchCombinedActivities() async {
    try {
      final uangMasukList = await _uangMasukService.fetchAll();
      final uangKeluarList = await _uangKeluarService.fetchAll();

      List<Map<String, dynamic>> combined = [];

      for (var item in uangMasukList) {
        combined.add({
          'type': 'masuk',
          'data': item,
          'date': item.tanggal is DateTime ? item.tanggal : DateTime.parse(item.tanggal.toString()),
        });
      }

      for (var item in uangKeluarList) {
        combined.add({
          'type': 'keluar',
          'data': item,
          'date': item.tanggalkeluar is DateTime ? item.tanggalkeluar : DateTime.parse(item.tanggalkeluar.toString()),
        });
      }

      combined.sort((a, b) => b['date'].compareTo(a['date']));
      return combined.take(5).toList();
    } catch (e) {
      print('Error fetching activities: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
      if (index == 2) return; // Sudah di Dashboard (Home)
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UangKeluarScreen(username: widget.username)),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UangMasukScreen(username: widget.username)),
        );
      } else if (index == 3) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BarangPage(username: widget.username)),
        );
      }
    }

    return Scaffold(
      backgroundColor: KantorPosTheme.lightAccentColor, // Lighter background
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logokantorpos.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KANTOR POS',
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    color: KantorPosTheme.white,
                  ),
                ),
                Text(
                  'Halo, ${widget.username}',
                  style: TextStyle(
                    fontSize: 14,
                    color: KantorPosTheme.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: KantorPosTheme.accentColor,
        elevation: 2,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.notifications_outlined, color: KantorPosTheme.white),
        //     onPressed: () {
        //       // Handle notification press
        //     },
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        color: KantorPosTheme.accentColor,
        backgroundColor: KantorPosTheme.white,
        displacement: 40,
        onRefresh: () async {
          _loadSaldo();
          _loadActivities();
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Saldo
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  color: KantorPosTheme.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<List<Saldo>>(
                      future: _saldoList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Row(
                            children: [
                              CircularProgressIndicator(color: KantorPosTheme.primaryColor),
                              const SizedBox(width: 12),
                              Text('Memuat saldo...', style: TextStyle(color: KantorPosTheme.textSecondaryColor)),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Saldo Kosong');
                        }
                        final latest = snapshot.data!.last;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo Saat Ini', 
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                                color: KantorPosTheme.textPrimaryColor
                              )
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [KantorPosTheme.primaryColor, KantorPosTheme.primaryColor.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Balance',
                                        style: TextStyle(
                                          color: KantorPosTheme.textPrimaryColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatRupiah(latest.nominalakhir),
                                        style: TextStyle(
                                          color: KantorPosTheme.textPrimaryColor,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: KantorPosTheme.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: KantorPosTheme.textPrimaryColor,
                                      size: 28,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  'Layanan Utama',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: KantorPosTheme.textPrimaryColor,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Services Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Uang Masuk Card
                    _buildServiceCard(
                      context,
                      title: 'Uang Masuk',
                      icon: Icons.trending_up,
                      color: KantorPosTheme.accentColor,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => UangMasukScreen(username: widget.username)),
                        );
                      },
                    ),
                    
                    // Uang Keluar Card
                    _buildServiceCard(
                      context,
                      title: 'Uang Keluar',
                      icon: Icons.trending_down,
                      color: KantorPosTheme.lightAccentColor,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => UangKeluarScreen(username: widget.username)),
                        );
                      },
                    ),
                    
                    // Barang Card
                    _buildServiceCard(
                      context,
                      title: 'Kelola Barang',
                      icon: Icons.inventory_2_outlined,
                      color: KantorPosTheme.accentColor,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => BarangPage(username: widget.username)),
                        );
                      },
                    ),
                    
                    // Reports Card
                    // _buildServiceCard(
                    //   context,
                    //   title: 'Laporan',
                    //   icon: Icons.bar_chart,
                    //   color: KantorPosTheme.lightAccentColor,
                    //   onTap: () {
                    //     // Navigate to Reports when implemented
                    //   },
                    // ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Quick Actions
                Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: KantorPosTheme.textPrimaryColor,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Activity List
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  color: KantorPosTheme.white,
                  child: FutureBuilder<List<dynamic>>(
                    future: _activityList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('Belum ada aktivitas', style: TextStyle(color: Colors.grey)),
                        );
                      }
                      return Column(
                        children: List.generate(snapshot.data!.length, (index) {
                          final activity = snapshot.data![index];
                          final isIncome = activity['type'] == 'masuk';
                          final data = activity['data'];

                          // Format tanggal dengan pengecekan tipe
                          DateTime? date;
                          if (isIncome) {
                            if (data.tanggal is DateTime) {
                              date = data.tanggal;
                            } else if (data.tanggal is String) {
                              date = DateTime.tryParse(data.tanggal);
                            }
                          } else {
                            if (data.tanggalkeluar is DateTime) {
                              date = data.tanggalkeluar;
                            } else if (data.tanggalkeluar is String) {
                              date = DateTime.tryParse(data.tanggalkeluar);
                            }
                          }
                          String formattedDate = date != null
                              ? DateFormat('d MMMM yyyy', 'id_ID').format(date)
                              : 'Tanggal tidak valid';

                          return Column(
                            children: [
                              _buildActivityItem(
                                icon: isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                title: isIncome
                                    ? (data.keterangan ?? 'Uang Masuk')
                                    : 'Uang Keluar',
                                subtitle: data.keterangan ?? '-',
                                amount: isIncome
                                    ? '+ ${formatRupiah(data.nominal)}'
                                    : '- ${formatRupiah(data.nominalkeluar)}',
                                date: formattedDate,
                                isIncome: isIncome,
                              ),
                              if (index < snapshot.data!.length - 1)
                                Divider(color: KantorPosTheme.secondaryColor.withOpacity(0.3)),
                            ],
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        backgroundColor: KantorPosTheme.white,
        selectedItemColor: KantorPosTheme.primaryColor,
        unselectedItemColor: KantorPosTheme.textSecondaryColor,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: 'Uang Keluar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Uang Masuk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Barang',
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Show quick actions menu
      //     showModalBottomSheet(
      //       context: context,
      //       builder: (context) => _buildQuickActionsSheet(context),
      //       shape: const RoundedRectangleBorder(
      //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      //       ),
      //     );
      //   },
      //   backgroundColor: KantorPosTheme.accentColor,
      //   child: const Icon(Icons.add, color: KantorPosTheme.white),
      // ),
    );
  }
  
  Widget _buildServiceCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: KantorPosTheme.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: KantorPosTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String date,
    required bool isIncome,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isIncome ? KantorPosTheme.accentColor.withOpacity(0.1) : KantorPosTheme.lightAccentColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isIncome ? KantorPosTheme.accentColor : KantorPosTheme.lightAccentColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: KantorPosTheme.textPrimaryColor,
        ),
      ),
      subtitle: Text(
        '$subtitle • $date',
        style: TextStyle(
          fontSize: 12,
          color: KantorPosTheme.textSecondaryColor,
        ),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isIncome ? KantorPosTheme.accentColor : Colors.redAccent,
        ),
      ),
    );
  }
  
  Widget _buildQuickActionsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tambah Transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: KantorPosTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickActionButton(
                context,
                icon: Icons.trending_up,
                label: 'Uang Masuk',
                color: KantorPosTheme.accentColor,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  UangMasukScreen(username: widget.username)),
                  );
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.trending_down,
                label: 'Uang Keluar',
                color: KantorPosTheme.lightAccentColor,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => UangKeluarScreen(username: widget.username)),
                  );
                },
              ),
              _buildQuickActionButton(
                context,
                icon: Icons.inventory_2_outlined,
                label: 'Barang',
                color: KantorPosTheme.primaryColor,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BarangPage(username: widget.username)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: KantorPosTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}