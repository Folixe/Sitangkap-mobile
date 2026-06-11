import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/socket_service.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<dynamic> _catches = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  StreamSubscription? _socketSub;

  @override
  void initState() {
    super.initState();
    _fetchCatches();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (mounted) await _fetchCatches();
    });
    _startSocket();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _socketSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchCatches() async {
    final data = await ApiService.getCatches();
    if (data != null && data['status'] == 'success') {
      setState(() {
        _catches = data['catches'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _startSocket() async {
    try {
      await SocketService().connect();
      _socketSub = SocketService().stream.listen((event) async {
        try {
          if (event is Map && (event['type'] == 'catch_created' || event['type'] == 'catches_updated')) {
            if (mounted) await _fetchCatches();
          }
        } catch (_) {
          if (mounted) await _fetchCatches();
        }
      }, onError: (_) {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Riwayat.',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1.5),
                          ),
                          const SizedBox(height: 4),
                          Text('Mutasi data tangkapan Anda', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                  _catches.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(
                            child: Text('Belum ada riwayat tangkapan.', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = _catches[index];
                                final detail = (item['details'] as List<dynamic>?)?.first;
                                final jenisIkan = detail?['jenis_ikan']?['nama_lokal'] ?? 'Ikan Campuran';
                                final berat = detail?['berat_kg'] ?? '0.0';
                                final dateStr = item['tanggal_penangkapan'] as String;
                                final formattedDate = DateFormat('dd MMMM yyyy').format(DateTime.parse(dateStr));
                                final status = item['status'] as String? ?? 'pending';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  color: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                                          child: const Icon(Icons.set_meal, color: Color(0xFF475569), size: 24),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(jenisIkan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(height: 4),
                                              Text(formattedDate, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: status == 'verified' ? Colors.green.shade50 : Colors.orange.shade50,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  status == 'verified' ? 'TERVERIFIKASI' : 'MENUNGGU VERIFIKASI',
                                                  style: TextStyle(
                                                    color: status == 'verified' ? Colors.green.shade700 : Colors.orange.shade700,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children: [
                                                const Text('+', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                                Text(
                                                  '$berat',
                                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                                ),
                                              ],
                                            ),
                                            const Text('Kg', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: _catches.length,
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
