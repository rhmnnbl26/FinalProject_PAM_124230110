import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/timezone_helper.dart';

class WaktuScreen extends StatefulWidget {
  const WaktuScreen({super.key});

  @override
  State<WaktuScreen> createState() => _WaktuScreenState();
}

class _WaktuScreenState extends State<WaktuScreen> {
  Timer? _timer;
  Map<String, String> _timezones = {};

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _timezones = TimezoneHelper.getAllTimezones();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Waktu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Waktu Saat Ini',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TimezoneHelper.formatTime(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildTimezoneCard(
                    'WIB',
                    'Waktu Indonesia Barat',
                    _timezones['WIB'] ?? '--:--:--',
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildTimezoneCard(
                    'WITA',
                    'Waktu Indonesia Tengah',
                    _timezones['WITA'] ?? '--:--:--',
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildTimezoneCard(
                    'WIT',
                    'Waktu Indonesia Timur',
                    _timezones['WIT'] ?? '--:--:--',
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _buildTimezoneCard(
                    'London',
                    'Greenwich Mean Time',
                    _timezones['London'] ?? '--:--:--',
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimezoneCard(
    String code,
    String name,
    String time,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  code,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
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
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
