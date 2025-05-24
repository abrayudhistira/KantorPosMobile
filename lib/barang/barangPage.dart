import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantorpos/barang/barangDetailPage.dart';
import 'package:kantorpos/barang/barangFormPage.dart';
import 'package:kantorpos/dashboard/dashboard.dart';
import 'package:kantorpos/model/barang.dart';
import 'package:kantorpos/service/barangService.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFDD9F52);
  static const Color secondaryColor = Color(0xFFDCC894);
  static const Color accentColor = Color(0xFF2C586E);
  static const Color lightAccentColor = Color(0xFF8DA1AF);
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color white = Colors.white;
}

class BarangPage extends StatefulWidget {
  final String username;
  const BarangPage({super.key, required this.username});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

String formatTanggalIndo(DateTime date) {
  return DateFormat('d MMMM yyyy', 'id_ID').format(date);
}

class _BarangPageState extends State<BarangPage> {
  final BarangService barangService = BarangService();
  late Future<List<Barang>> _barangList;

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  void _fetchBarang() {
    setState(() {
      _barangList = barangService.fetchAll();
    });
  }

  Future<void> _deleteBarang(String id) async {
    print('[DEBUG] Akan hapus barang dengan id: $id');
    try {
      await barangService.deleteBarang(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Barang berhasil dihapus'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      _fetchBarang();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal menghapus barang'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightAccentColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard(username: widget.username)),
            );
          },
        ),
        title: const Text(
          'Daftar Barang',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppTheme.accentColor,
      ),
      body: FutureBuilder<List<Barang>>(
        future: _barangList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal memuat data: ${snapshot.error}',
                style: const TextStyle(color: AppTheme.textSecondaryColor),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logokantorpos.png', height: 200),
                  const Text(
                    'Belum ada barang',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + untuk menambahkan barang baru',
                    style: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                ],
              ),
            );
          }

          final barangList = snapshot.data!;

          return RefreshIndicator(
            color: AppTheme.accentColor,
            backgroundColor: AppTheme.white,
            displacement: 40,
            onRefresh: () async {
              _fetchBarang();
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: barangList.length,
              itemBuilder: (context, index) {
                final barang = barangList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: AppTheme.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BarangDetailPage(barang: barang),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: 'barang_${barang.id}',
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: barang.foto.isNotEmpty
                                    ? Image.network(
                                        'https://8f60-2405-5fc0-7-1-3c0d-e012-e09c-8c2a.ngrok-free.app/${barang.foto}',
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: AppTheme.lightAccentColor,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.image,
                                        size: 40,
                                        color: AppTheme.lightAccentColor,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  barang.namaBarang,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  barang.jenisBarang,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatTanggalIndo(barang.tanggalMasuk),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.lightAccentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BarangFormPage(
                                      barangService: barangService,
                                      barang: barang,
                                    ),
                                  ),
                                ).then((_) => _fetchBarang());
                              } else if (value == 'delete') {
                                _showDeleteDialog(barang.id.toString());
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.edit,
                                    color: AppTheme.accentColor,
                                  ),
                                  title: Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    'Hapus',
                                    style: TextStyle(
                                      color: AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            icon: const Icon(
                              Icons.more_vert,
                              color: AppTheme.lightAccentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BarangFormPage(barangService: barangService),
            ),
          ).then((_) => _fetchBarang());
        },
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        title: const Text(
          'Hapus Barang',
          style: TextStyle(color: AppTheme.textPrimaryColor),
        ),
        content: const Text(
          'Apakah anda yakin ingin menghapus barang ini?',
          style: TextStyle(color: AppTheme.textSecondaryColor),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppTheme.lightAccentColor),
            ),
          ),
          TextButton(
            onPressed: () {
              _deleteBarang(id);
              Navigator.pop(context);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}