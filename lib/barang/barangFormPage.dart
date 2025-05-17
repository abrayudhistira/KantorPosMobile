import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kantorpos/model/barang.dart';
import 'package:kantorpos/service/barangService.dart';
import 'package:image_picker/image_picker.dart';

class BarangFormPage extends StatefulWidget {
  final BarangService barangService;
  final Barang? barang;

  const BarangFormPage({
    super.key,
    required this.barangService,
    this.barang,
  });

  @override
  State<BarangFormPage> createState() => _BarangFormPageState();
}

class _BarangFormPageState extends State<BarangFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaBarangController;
  late TextEditingController _jenisBarangController;
  late TextEditingController _asalBarangController;
  late TextEditingController _namaAsalBarangController;
  late TextEditingController _fotoController;
  DateTime? _tanggalMasuk;
  File? _fotoFile;

  @override
  void initState() {
    super.initState();
    final barang = widget.barang;
    _namaBarangController = TextEditingController(text: barang?.namaBarang ?? '');
    _jenisBarangController = TextEditingController(text: barang?.jenisBarang ?? '');
    _asalBarangController = TextEditingController(text: barang?.asalbarang ?? '');
    _namaAsalBarangController = TextEditingController(text: barang?.namaasalbarang ?? '');
    _fotoController = TextEditingController(text: barang?.foto ?? '');
    _tanggalMasuk = barang?.tanggalMasuk;
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _jenisBarangController.dispose();
    _asalBarangController.dispose();
    _namaAsalBarangController.dispose();
    _fotoController.dispose();
    super.dispose();
  }

  Future<void> _saveBarang() async {
    if (!_formKey.currentState!.validate()) return;

    final barang = Barang(
      id: widget.barang?.id ?? 0,
      namaBarang: _namaBarangController.text.trim(),
      jenisBarang: _jenisBarangController.text.trim(),
      asalbarang: _asalBarangController.text.trim(),
      namaasalbarang: _namaAsalBarangController.text.trim(),
      foto: _fotoController.text.trim(),
      tanggalMasuk: _tanggalMasuk ?? DateTime.now(),
    );

    try {
      if (widget.barang == null) {
        await widget.barangService.createBarang(barang);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil ditambahkan')),
        );
      } else {
        await widget.barangService.updateBarang(barang);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barang berhasil diperbarui')),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan barang')),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _fotoFile = File(pickedFile.path);
        _fotoController.text = pickedFile.path; // Simpan path lokal
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barang == null ? 'Tambah Barang' : 'Edit Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _namaBarangController,
                  decoration: const InputDecoration(labelText: 'Nama Barang'),
                  validator: (value) => value == null || value.isEmpty ? 'Nama barang harus diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jenisBarangController,
                  decoration: const InputDecoration(labelText: 'Jenis Barang'),
                  validator: (value) => value == null || value.isEmpty ? 'Jenis barang harus diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _asalBarangController,
                  decoration: const InputDecoration(labelText: 'Asal Barang'),
                  validator: (value) => value == null || value.isEmpty ? 'Asal barang harus diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaAsalBarangController,
                  decoration: const InputDecoration(labelText: 'Nama Asal Barang'),
                  validator: (value) => value == null || value.isEmpty ? 'Nama asal barang harus diisi' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fotoController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Foto Barang (Path)'),
                        validator: (value) => value == null || value.isEmpty ? 'Foto barang harus diisi' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.photo_camera),
                      onPressed: () => _pickImage(ImageSource.camera),
                      tooltip: 'Ambil dari Kamera',
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: () => _pickImage(ImageSource.gallery),
                      tooltip: 'Pilih dari Galeri',
                    ),
                  ],
                ),
                if (_fotoFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(_fotoFile!, height: 100),
                  ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _tanggalMasuk ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (selectedDate != null) {
                      setState(() => _tanggalMasuk = selectedDate);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Tanggal Masuk'),
                    child: Text(
                      _tanggalMasuk != null
                          ? _tanggalMasuk!.toLocal().toString().split(' ')[0]
                          : 'Pilih Tanggal Masuk',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveBarang,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}