import 'package:flutter/material.dart';
import 'package:kantorpos/barang/barangPage.dart';
import 'package:kantorpos/model/saldo.dart';
import 'package:kantorpos/service/saldoService.dart';

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
  late Future<List<Saldo>> _saldoList;

  @override
  void initState() {
    super.initState();
    _loadSaldo();
  }

  void _loadSaldo() {
    setState(() {
      _saldoList = _saldoService.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Halo, ${widget.username}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: RefreshIndicator(
        color: Colors.orange,
        backgroundColor: Colors.white,
        displacement: 40,
        onRefresh: () async {
          _loadSaldo();
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
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<List<Saldo>>(
                      future: _saldoList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Row(
                            children: const [
                              CircularProgressIndicator(),
                              SizedBox(width: 12),
                              Text('Memuat saldo...'),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('Saldo Kosong');
                        }
                        final latest = snapshot.data!.last;
                        const SizedBox(height: 8);
                        return ListTile(
                          leading: const Icon(Icons.account_balance_wallet, size: 32, color: Colors.orange),
                          title: const Text('Saldo Saat Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            formatRupiah(latest.nominalakhir),
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => _loadSaldo(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Card Barang
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.inventory, color: Colors.blueAccent),
                    title: const Text('Barang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Lihat dan kelola data barang'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BarangPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
