import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kantorpos/model/barang.dart';

class BarangDetailPage extends StatefulWidget {
  final Barang barang;
  final Future<Barang> Function()? onRefresh;

  const BarangDetailPage({Key? key, required this.barang, this.onRefresh}) : super(key: key);

  @override
  State<BarangDetailPage> createState() => _BarangDetailPageState();
}

class _BarangDetailPageState extends State<BarangDetailPage> {
  late Barang barang;

  @override
  void initState() {
    super.initState();
    barang = widget.barang;
  }

  Future<void> _refresh() async {
    if (widget.onRefresh != null) {
      final updated = await widget.onRefresh!();
      setState(() {
        barang = updated;
      });
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Barang'),
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: Colors.white,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: barang.id.toString(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: barang.foto.isNotEmpty
                          ? Image.network(
                              'https://8f60-2405-5fc0-7-1-3c0d-e012-e09c-8c2a.ngrok-free.app/${barang.foto}',
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => 
                                  const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                            )
                          : Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 80, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(Icons.label, 'Nama Barang', barang.namaBarang),
                  _buildInfoRow(Icons.category, 'Jenis Barang', barang.jenisBarang),
                  _buildInfoRow(Icons.location_on, 'Asal Barang', barang.asalbarang),
                  _buildInfoRow(Icons.person, 'Nama Asal Barang', barang.namaasalbarang),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Tanggal Masuk',
                    barang.tanggalMasuk.toLocal().toString().split(' ')[0],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
