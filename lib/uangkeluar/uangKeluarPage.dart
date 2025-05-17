import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kantorpos/model/uangkeluar.dart';
import 'package:kantorpos/service/uangKeluarService.dart';

class UangKeluarScreen extends StatefulWidget {
  const UangKeluarScreen({super.key});

  @override
  State<UangKeluarScreen> createState() => _UangKeluarScreenState();
}

class _UangKeluarScreenState extends State<UangKeluarScreen> {
  final UangKeluarService _service = UangKeluarService();
  List<UangKeluar> _uangKeluarList = [];
  bool _isLoading = true;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Controllers
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  UangKeluar? _selectedUangKeluar;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final data = await _service.fetchAll();
      setState(() {
        _uangKeluarList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Gagal memuat data: $e');
    }
  }

  void _showForm({UangKeluar? uangKeluar}) {
    bool isEdit = uangKeluar != null;
    
    if (isEdit) {
      _nominalController.text = uangKeluar.nominalkeluar;
      _tujuanController.text = uangKeluar.tujuan;
      _keteranganController.text = uangKeluar.keterangan;
      _selectedDate = uangKeluar.tanggalkeluar;
      _selectedUangKeluar = uangKeluar;
    } else {
      _nominalController.clear();
      _tujuanController.clear();
      _keteranganController.clear();
      _selectedDate = DateTime.now();
      _selectedUangKeluar = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isEdit ? 'Edit Transaksi' : 'Transaksi Baru',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green),
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _nominalController,
              label: 'Nominal',
              prefix: 'Rp',
              keyboardType: TextInputType.number,
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 16),
            _buildDatePicker(context),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _tujuanController,
              label: 'Tujuan',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _keteranganController,
              label: 'Keterangan',
              icon: Icons.description,
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _handleSubmit,
                child: Text(
                  isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH TRANSAKSI',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    IconData? icon,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        prefixIcon: icon != null ? Icon(icon, color: Colors.green) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green)),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.green,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null && picked != _selectedDate) {
          setState(() => _selectedDate = picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal',
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_nominalController.text.isEmpty || 
        _tujuanController.text.isEmpty || 
        _keteranganController.text.isEmpty) {
      _showSnackbar('Harap isi semua field yang wajib diisi');
      return;
    }

    final uangKeluar = UangKeluar(
      id: _selectedUangKeluar?.id ?? 0,
      nominalkeluar: _nominalController.text,
      tanggalkeluar: _selectedDate,
      tujuan: _tujuanController.text,
      keterangan: _keteranganController.text,
    );

    try {
      if (_selectedUangKeluar != null) {
        await _service.updateUangKeluar(uangKeluar);
      } else {
        await _service.createUangKeluar(uangKeluar);
      }
      _fetchData();
      Navigator.pop(context);
      _showSnackbar(
        _selectedUangKeluar != null 
          ? 'Transaksi berhasil diperbarui' 
          : 'Transaksi baru ditambahkan',
      );
    } catch (e) {
      _showSnackbar('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Uang Keluar',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: Colors.green,
        backgroundColor: Colors.white,
        onRefresh: _fetchData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _uangKeluarList.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      //_buildTotalHeader(),
                      Expanded(child: _buildTransactionList()),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/empty.png', height: 200),
          const Text('Belum ada transaksi',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Tap + untuk menambahkan transaksi baru',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Widget _buildTotalHeader() {
  //   final total = _uangKeluarList.fold(
  //     0.0, (sum, item) => sum + double.parse(item.nominalkeluar));
    
  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.green,
  //       borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
  //     ),
  //     child: Column(
  //       children: [
  //         const Text('Total Uang Keluar',
  //             style: TextStyle(color: Colors.white, fontSize: 16)),
  //         const SizedBox(height: 8),
  //         Text(_currencyFormat.format(total),
  //             style: const TextStyle(
  //               color: Colors.white,
  //               fontSize: 28,
  //               fontWeight: FontWeight.bold)),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildTransactionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _uangKeluarList.length,
      itemBuilder: (context, index) {
        final transaction = _uangKeluarList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.arrow_upward, 
                color: Colors.green)),
            title: Text(_currencyFormat.format(double.parse(transaction.nominalkeluar))),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(transaction.tujuan,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(transaction.keterangan,
                    style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd MMM yyyy').format(transaction.tanggalkeluar),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12)),
              ],
            ),
            trailing: PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit, color: Colors.green),
                    title: Text('Edit')),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Hapus')),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showForm(uangKeluar: transaction);
                } else if (value == 'delete') {
                  _showDeleteDialog(transaction.id);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              try {
                await _service.deleteUangKeluar(id);
                _fetchData();
                Navigator.pop(context);
                _showSnackbar('Transaksi berhasil dihapus');
              } catch (e) {
                _showSnackbar('Gagal menghapus: $e');
              }
            },
            child: const Text('Hapus', 
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.green,
      ),
    );
  }
}