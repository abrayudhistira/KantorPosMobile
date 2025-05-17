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
  DateTime? _tanggalMasuk;
  File? _fotoFile;

  @override
  void initState() {
    super.initState();
    final b = widget.barang;
    _namaBarangController = TextEditingController(text: b?.namaBarang ?? '');
    _jenisBarangController = TextEditingController(text: b?.jenisBarang ?? '');
    _asalBarangController = TextEditingController(text: b?.asalbarang ?? '');
    _namaAsalBarangController = TextEditingController(text: b?.namaasalbarang ?? '');
    _tanggalMasuk = b?.tanggalMasuk;
    if (b?.foto != null && b!.foto.isNotEmpty) {
      _fotoFile = File(b.foto);
    }
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _jenisBarangController.dispose();
    _asalBarangController.dispose();
    _namaAsalBarangController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _fotoFile = File(picked.path);
      });
    }
  }

  Future<void> _saveBarang() async {
    if (!_formKey.currentState!.validate()) return;
    final barang = Barang(
      id: widget.barang?.id ?? 0,
      namaBarang: _namaBarangController.text.trim(),
      jenisBarang: _jenisBarangController.text.trim(),
      asalbarang: _asalBarangController.text.trim(),
      namaasalbarang: _namaAsalBarangController.text.trim(),
      foto: _fotoFile?.path ?? '',
      tanggalMasuk: _tanggalMasuk ?? DateTime.now(),
    );
    try {
      if (widget.barang == null) {
        await widget.barangService.createBarang(barang);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barang berhasil ditambahkan'),
            backgroundColor: Colors.green[600],
          ),
        );
      } else {
        await widget.barangService.updateBarang(barang);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Barang berhasil diperbarui'),
            backgroundColor: Colors.blue[600],
          ),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan barang: \$e'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.barang != null;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Barang' : 'Tambah Barang'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Foto Preview with camera/gallery pick
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _fotoFile != null ? FileImage(_fotoFile!) : null,
                          child: _fotoFile == null ? Icon(Icons.photo, size: 40, color: Colors.grey[600]) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => _pickImage(ImageSource.camera),
                                borderRadius: BorderRadius.circular(24),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.orange,
                                  child: Icon(Icons.photo_camera, size: 16, color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _pickImage(ImageSource.gallery),
                                borderRadius: BorderRadius.circular(24),
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.orange,
                                  child: Icon(Icons.photo_library, size: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nama Barang
                  TextFormField(
                    controller: _namaBarangController,
                    decoration: InputDecoration(
                      labelText: 'Nama Barang',
                      prefixIcon: Icon(Icons.label, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Nama barang harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  // Jenis Barang
                  TextFormField(
                    controller: _jenisBarangController,
                    decoration: InputDecoration(
                      labelText: 'Jenis Barang',
                      prefixIcon: Icon(Icons.category, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Jenis barang harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  // Asal Barang
                  TextFormField(
                    controller: _asalBarangController,
                    decoration: InputDecoration(
                      labelText: 'Asal Barang',
                      prefixIcon: Icon(Icons.location_on, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Asal barang harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  // Nama Asal Barang
                  TextFormField(
                    controller: _namaAsalBarangController,
                    decoration: InputDecoration(
                      labelText: 'Nama Asal Barang',
                      prefixIcon: Icon(Icons.person, color: Colors.orange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Nama asal barang harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  // Tanggal Masuk
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _tanggalMasuk ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _tanggalMasuk = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Tanggal Masuk',
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.orange),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        _tanggalMasuk != null
                            ? _tanggalMasuk!.toLocal().toString().split(' ')[0]
                            : 'Pilih tanggal',
                        style: TextStyle(fontSize: 16, color: _tanggalMasuk == null ? Colors.grey[600] : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Tombol Simpan
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveBarang,
                      icon: Icon(Icons.save),
                      label: Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}