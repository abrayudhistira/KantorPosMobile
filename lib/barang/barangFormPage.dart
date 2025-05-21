import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kantorpos/model/barang.dart';
import 'package:kantorpos/service/barangService.dart';
import 'package:image_picker/image_picker.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFDD9F52);
  static const Color secondaryColor = Color(0xFFDCC894);
  static const Color accentColor = Color(0xFF2C586E);
  static const Color lightAccentColor = Color(0xFF8DA1AF);
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color white = Colors.white;
}

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
    _tanggalMasuk = b?.tanggalMasuk ?? DateTime.now();
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
        _showSnackbar('Barang berhasil ditambahkan');
      } else {
        await widget.barangService.updateBarang(barang);
        _showSnackbar('Barang berhasil diperbarui');
      }
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackbar('Gagal menyimpan barang: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.barang != null;
    return Scaffold(
      backgroundColor: AppTheme.lightAccentColor,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Barang' : 'Tambah Barang',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.white),
        ),
        backgroundColor: AppTheme.accentColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: AppTheme.white,
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
                          backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                          backgroundImage: _fotoFile != null ? FileImage(_fotoFile!) : null,
                          child: _fotoFile == null 
                              ? const Icon(Icons.photo, size: 40, color: AppTheme.lightAccentColor) 
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => _pickImage(ImageSource.camera),
                                borderRadius: BorderRadius.circular(24),
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.accentColor,
                                  child: Icon(Icons.photo_camera, size: 16, color: AppTheme.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _pickImage(ImageSource.gallery),
                                borderRadius: BorderRadius.circular(24),
                                child: const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.accentColor,
                                  child: Icon(Icons.photo_library, size: 16, color: AppTheme.white),
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
                  _buildInputField(
                    controller: _namaBarangController,
                    label: 'Nama Barang',
                    icon: Icons.label,
                    validator: (v) => v == null || v.isEmpty ? 'Nama barang harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  // Jenis Barang
                  _buildInputField(
                    controller: _jenisBarangController,
                    label: 'Jenis Barang',
                    icon: Icons.category,
                    validator: (v) => v == null || v.isEmpty ? 'Jenis barang harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  // Asal Barang
                  _buildInputField(
                    controller: _asalBarangController,
                    label: 'Asal Barang',
                    icon: Icons.location_on,
                    validator: (v) => v == null || v.isEmpty ? 'Asal barang harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  // Nama Asal Barang
                  _buildInputField(
                    controller: _namaAsalBarangController,
                    label: 'Nama Asal Barang',
                    icon: Icons.person,
                    validator: (v) => v == null || v.isEmpty ? 'Nama asal barang harus diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  // Tanggal Masuk
                  _buildDatePicker(context),
                  const SizedBox(height: 32),
                  // Tombol Simpan
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _saveBarang,
                      icon: const Icon(Icons.save),
                      label: Text(
                        isEditing ? 'SIMPAN PERUBAHAN' : 'TAMBAH BARANG',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimaryColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
        prefixIcon: Icon(icon, color: AppTheme.accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.textSecondaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.textSecondaryColor.withOpacity(0.5)),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _tanggalMasuk ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.accentColor,
                onPrimary: AppTheme.white,
                surface: AppTheme.white,
                onSurface: AppTheme.textPrimaryColor,
              ),
              dialogBackgroundColor: AppTheme.white,
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          setState(() => _tanggalMasuk = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal Masuk',
          labelStyle: const TextStyle(color: AppTheme.textSecondaryColor),
          prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.accentColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.textSecondaryColor.withOpacity(0.5)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tanggalMasuk != null
                  ? _tanggalMasuk!.toLocal().toString().split(' ')[0]
                  : 'Pilih tanggal',
              style: TextStyle(
                color: _tanggalMasuk == null 
                    ? AppTheme.textSecondaryColor 
                    : AppTheme.textPrimaryColor,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppTheme.lightAccentColor),
          ],
        ),
      ),
    );
  }
}