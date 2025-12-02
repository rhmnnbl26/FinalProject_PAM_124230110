import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bengkel.dart';
import '../models/booking_slot.dart';
import '../models/voucher.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/voucher_service.dart';
import '../widgets/voucher_card_widget.dart';

class BookingFormScreen extends StatefulWidget {
  final Bengkel bengkel;

  const BookingFormScreen({super.key, required this.bengkel});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookingService _bookingService = BookingService.instance;
  final VoucherService _voucherService = VoucherService();

  // Form controllers
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _tipeController = TextEditingController();
  final TextEditingController _tahunController = TextEditingController();
  final TextEditingController _platController = TextEditingController();
  final TextEditingController _ccController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedServiceType = 'sedang';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTimeSlot;
  Voucher? _selectedVoucher;
  bool _useVoucher = false;
  List<Voucher> _availableVouchers = [];
  List<BookingSlot> _availableSlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
    _loadAvailableSlots();
  }

  @override
  void dispose() {
    _merkController.dispose();
    _tipeController.dispose();
    _tahunController.dispose();
    _platController.dispose();
    _ccController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    final authService = AuthService();
    final userId = await authService.getCurrentUserId() ?? 1;
    final vouchers = await _voucherService.getUnusedVouchers(userId: userId);
    setState(() => _availableVouchers = vouchers);
  }

  Future<void> _loadAvailableSlots() async {
    setState(() => _isLoadingSlots = true);
    final dateStr = _selectedDate.toIso8601String().split('T')[0];
    final slots = await _bookingService.getAvailableSlots(widget.bengkel.id!, dateStr);
    setState(() {
      _availableSlots = slots;
      _isLoadingSlots = false;
      if (_availableSlots.isNotEmpty && _selectedTimeSlot == null) {
        _selectedTimeSlot = _availableSlots.first.timeSlot;
      }
    });
  }

  double _calculateTotal() {
    final price = _bookingService.getServicePrice(_selectedServiceType);
    if (_useVoucher && _selectedVoucher != null) {
      final discount = price * _selectedVoucher!.discountPercent / 100;
      return price - discount;
    }
    return price;
  }

  double _calculateDiscount() {
    if (_useVoucher && _selectedVoucher != null) {
      final price = _bookingService.getServicePrice(_selectedServiceType);
      return price * _selectedVoucher!.discountPercent / 100;
    }
    return 0;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih slot waktu terlebih dahulu')),
      );
      return;
    }

    try {
      final authService = AuthService();
      final userId = await authService.getCurrentUserId() ?? 1;
      final dateStr = _selectedDate.toIso8601String().split('T')[0];

      final booking = await _bookingService.createBooking(
        userId: userId,
        bengkelId: widget.bengkel.id!,
        motorMerk: _merkController.text,
        motorTipe: _tipeController.text,
        motorTahun: int.parse(_tahunController.text),
        motorPlat: _platController.text,
        serviceType: _selectedServiceType,
        bookingDate: dateStr,
        bookingTimeSlot: _selectedTimeSlot!,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        voucherId: _selectedVoucher?.id,
        voucherCode: _selectedVoucher?.code,
        discountPercent: _selectedVoucher?.discountPercent,
      );

      // Mark voucher as used if applicable
      if (_selectedVoucher != null && booking.id != null) {
        await _voucherService.useVoucher(_selectedVoucher!.id!, booking.id!);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Booking berhasil dikonfirmasi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final originalPrice = _bookingService.getServicePrice(_selectedServiceType);
    final discount = _calculateDiscount();
    final totalPrice = _calculateTotal();

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Servis')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '1. Informasi Motor',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _merkController,
              decoration: const InputDecoration(
                labelText: 'Merk Motor',
                hintText: 'Contoh: Ducati',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tipeController,
              decoration: const InputDecoration(
                labelText: 'Tipe Motor',
                hintText: 'Contoh: Panigale V4',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tahunController,
                    decoration: const InputDecoration(
                      labelText: 'Tahun',
                      hintText: '2023',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Wajib diisi';
                      final year = int.tryParse(v!);
                      if (year == null || year < 1900 || year > DateTime.now().year) {
                        return 'Tahun tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _ccController,
                    decoration: const InputDecoration(
                      labelText: 'CC Motor',
                      hintText: '150',
                      border: OutlineInputBorder(),
                      suffixText: 'cc',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Wajib diisi';
                      final cc = int.tryParse(v!);
                      if (cc == null || cc < 50 || cc > 3000) {
                        return 'CC tidak valid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _platController,
              decoration: const InputDecoration(
                labelText: 'Plat Nomor',
                hintText: 'AB 1234 CD',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 32),
            const Text(
              '2. Pilih Jenis Servis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildServiceTypeOption(
              'ringan',
              'Servis Ringan',
              'Rp 500.000',
              'Ganti oli premium, cek ban, cek rem',
            ),
            _buildServiceTypeOption(
              'sedang',
              'Servis Sedang',
              'Rp 1.000.000',
              'Tune-up, bersih throttle body, cek kelistrikan',
            ),
            _buildServiceTypeOption(
              'besar',
              'Servis Besar',
              'Rp 2.000.000',
              'Full tune-up, valve adjustment, ganti spare part',
            ),
            const SizedBox(height: 32),
            const Text(
              '3. Pilih Tanggal & Slot Waktu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: const Color(0xFF252525),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              leading: const Icon(Icons.calendar_today, color: Color(0xFF2196F3)),
              title: Text(
                DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().add(const Duration(days: 1)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                  _loadAvailableSlots();
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Slot Tersedia:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _isLoadingSlots
                ? const Center(child: CircularProgressIndicator())
                : _availableSlots.isEmpty
                    ? const Text(
                        'Tidak ada slot tersedia untuk tanggal ini',
                        style: TextStyle(color: Colors.white54),
                      )
                    : Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableSlots.map((slot) {
                          final isSelected = _selectedTimeSlot == slot.timeSlot;
                          return ChoiceChip(
                            label: Text(slot.displayTime),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedTimeSlot = slot.timeSlot);
                            },
                            selectedColor: const Color(0xFF2196F3),
                            backgroundColor: const Color(0xFF252525),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          );
                        }).toList(),
                      ),
            const SizedBox(height: 32),
            const Text(
              '4. Catatan Tambahan (Opsional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'Contoh: Rem depan bunyi, tolong dicek',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            const Text(
              '5. Gunakan Voucher?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _useVoucher,
              onChanged: _availableVouchers.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _useVoucher = value;
                        if (!value) _selectedVoucher = null;
                      });
                    },
              title: const Text('Gunakan Voucher', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                _availableVouchers.isEmpty
                    ? 'Tidak ada voucher tersedia'
                    : '${_availableVouchers.length} voucher tersedia',
                style: const TextStyle(color: Colors.white54),
              ),
              tileColor: const Color(0xFF252525),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            if (_useVoucher && _availableVouchers.isNotEmpty) ...[
              const SizedBox(height: 16),
              ..._availableVouchers.map((voucher) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: VoucherCardWidget(
                    voucher: voucher,
                    isSelected: _selectedVoucher?.id == voucher.id,
                    onTap: () => setState(() => _selectedVoucher = voucher),
                  ),
                );
              }),
            ],
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RINGKASAN HARGA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Harga Normal:', style: TextStyle(color: Colors.white70)),
                      Text(
                        _bookingService.formatCurrency(originalPrice),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diskon (${_selectedVoucher!.discountPercent}%):',
                          style: const TextStyle(color: Colors.green),
                        ),
                        Text(
                          '- ${_bookingService.formatCurrency(discount)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Bayar:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _bookingService.formatCurrency(totalPrice),
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.white54),
                    ),
                    child: const Text('BATALKAN'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'KONFIRMASI BOOKING ✅',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeOption(
    String value,
    String title,
    String price,
    String description,
  ) {
    final isSelected = _selectedServiceType == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedServiceType = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3).withValues(alpha: 0.2) : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedServiceType,
              onChanged: (v) => setState(() => _selectedServiceType = v!),
              activeColor: const Color(0xFF2196F3),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

