import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'input_catch_screen.dart';
import 'history_tab.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Map<String, dynamic>? _profile;
  List<dynamic> _catches = [];
  bool _isLoading = true;
  double _monthlyWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final profileData = await ApiService.getProfile();
    final catchesData = await ApiService.getCatches();

    if (profileData != null && profileData['status'] == 'success') {
      _profile = profileData['nelayan'];
    }

    if (catchesData != null && catchesData['status'] == 'success') {
      _catches = catchesData['catches'] ?? [];
      _calculateMonthlyWeight();
    }

    setState(() => _isLoading = false);
  }

  void _calculateMonthlyWeight() {
    double total = 0.0;
    final now = DateTime.now();
    for (var c in _catches) {
      final dateStr = c['tanggal_penangkapan'] as String?;
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null && date.year == now.year && date.month == now.month) {
          final details = c['details'] as List<dynamic>? ?? [];
          for (var detail in details) {
            total += double.tryParse(detail['berat_kg'].toString()) ?? 0.0;
          }
        }
      }
    }
    setState(() {
      _monthlyWeight = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0F172A))));
    }

    final name = _profile?['nama_lengkap'] ?? 'Nelayan';
    final kelompok = _profile?['profil']?['kelompok_nelayan']?['nama_kelompok'] ?? 'Kelompok Mandiri';

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(color: Colors.blue.shade50.withOpacity(0.4), shape: BoxShape.circle),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.blue.shade100,
                            backgroundImage: NetworkImage(
                              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0ea5e9&color=fff',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              Text(kelompok, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade200),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'TANGKAPAN BULAN INI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _monthlyWeight.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -2),
                      ),
                      const SizedBox(width: 8),
                      const Text('Kg', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InputCatchScreen()),
                      ).then((_) => _fetchData());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                                child: const Icon(Icons.add, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Input Tangkapan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                  SizedBox(height: 2),
                                  Text('Catat hasil melaut hari ini', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Aktivitas Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryTab())), child: const Text('Lihat Semua', style: TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _catches.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: const Center(
                            child: Text('Belum ada laporan tangkapan hari ini.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _catches.length > 2 ? 2 : _catches.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = _catches[index];
                            final detail = (item['details'] as List<dynamic>?)?.first;
                            final jenisIkan = detail?['jenis_ikan']?['nama_lokal'] ?? 'Ikan Campuran';
                            final berat = detail?['berat_kg'] ?? '0.0';
                            final dateStr = item['tanggal_penangkapan'] as String;
                            final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(dateStr));
                            final status = item['status'] as String? ?? 'pending';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                                    child: const Icon(Icons.set_meal, color: Color(0xFF64748B), size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(jenisIkan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: status == 'verified' ? Colors.green.shade50 : Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                status == 'verified' ? 'TERVERIFIKASI' : 'PENDING',
                                                style: TextStyle(
                                                  color: status == 'verified' ? Colors.green.shade700 : Colors.orange.shade700,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '$berat Kg',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
