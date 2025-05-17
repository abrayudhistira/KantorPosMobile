import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kantorpos/barang/barangDetailPage.dart';
import 'package:kantorpos/barang/barangFormPage.dart';
import 'package:kantorpos/model/barang.dart';
import 'package:kantorpos/service/barangService.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
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
    try {
      await barangService.deleteBarang(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil dihapus')),
      );
      _fetchBarang();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus barang')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: FutureBuilder<List<Barang>>(
        future: _barangList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat data: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Belum ada barang'),
            );
          }

          final barangList = snapshot.data!;

          return RefreshIndicator(
            color: Colors.orange,
            backgroundColor: Colors.white,
            displacement: 40,
            onRefresh: () async {
              _fetchBarang();
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: barangList.length,
              itemBuilder: (context, index) {
                final barang = barangList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    color: Colors.white,
                    elevation: 3,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: barang.foto.isNotEmpty
                                    ? Image.file(
                                        File(barang.foto),
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                      )
                                    : Container(
                                        width: 64,
                                        height: 64,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.label, size: 18, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          barang.namaBarang,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text(
                                        barang.tanggalMasuk.toLocal().toString().split(' ')[0],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
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
                                  _deleteBarang(barang.id.toString());
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')), 
                                const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                              ],
                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                            ),
                          ],
                        ),
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
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}