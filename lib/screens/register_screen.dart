import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _rtController = TextEditingController(text: '001');
  final _rwController = TextEditingController(text: '001');
  final _namaKapalController = TextEditingController();
  final _noRegistrasiKapalController = TextEditingController();

  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 30));
  bool _isLoadingReference = true;
  bool _isSubmitting = false;

  List<dynamic> _kecamatanList = [];
  List<dynamic> _desaList = [];
  List<dynamic> _kelompokList = [];
  List<dynamic> _filteredDesaList = [];

  String? _selectedKecamatanId;
  String? _selectedDesaId;
  String? _selectedKelompokId;
  String _selectedJenisKapal = 'Jukung';
  String _selectedJenisTangkapan = 'Pelagis';

  final List<String> _kapalList = ['Compreng', 'Jukung', 'Kolek', 'Perahu Motor'];
  final List<String> _tangkapanList = ['Pelagis', 'Demersal', 'Udang / Krustasea', 'Campuran'];

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    final data = await ApiService.getReferenceData();
    if (data != null && data['status'] == 'success') {
      setState(() {
        _kecamatanList = data['kecamatan'] ?? [];
        _desaList = data['desa'] ?? [];
        _kelompokList = data['kelompok_nelayan'] ?? [];
        
        if (_kecamatanList.isNotEmpty) {
          _selectedKecamatanId = _kecamatanList.first['id'].toString();
          _filterDesa(_selectedKecamatanId!);
        }
        if (_kelompokList.isNotEmpty) {
          _selectedKelompokId = _kelompokList.first['id'].toString();
        }
        _isLoadingReference = false;
      });
    } else {
      setState(() {
        _kecamatanList = [
          {'id': 'kec1', 'nama': 'Cilacap Selatan'},
          {'id': 'kec2', 'nama': 'Adipala'},
          {'id': 'kec3', 'nama': 'Kesugihan'}
        ];
        _desaList = [
          {'id': 'desa1', 'kecamatan_id': 'kec1', 'nama': 'Tegalkamulyan'},
          {'id': 'desa2', 'kecamatan_id': 'kec1', 'nama': 'Cilacap'},
          {'id': 'desa3', 'kecamatan_id': 'kec2', 'nama': 'Adipala'},
          {'id': 'desa4', 'kecamatan_id': 'kec3', 'nama': 'Kesugihan'}
        ];
        _kelompokList = [
          {'id': 'kel1', 'nama_kelompok': 'Mina Makmur'},
          {'id': 'kel2', 'nama_kelompok': 'Samudra Jaya'},
          {'id': 'kel3', 'nama_kelompok': 'Bakti Laut'}
        ];
        _selectedKecamatanId = 'kec1';
        _selectedKelompokId = 'kel1';
        _filterDesa('kec1');
        _isLoadingReference = false;
      });
    }
  }

  void _filterDesa(String kecamatanId) {
    setState(() {
      _filteredDesaList = _desaList.where((d) => d['kecamatan_id'].toString() == kecamatanId).toList();
      if (_filteredDesaList.isNotEmpty) {
        _selectedDesaId = _filteredDesaList.first['id'].toString();
      } else {
        _selectedDesaId = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _tempatLahirController.text.isEmpty ||
        _selectedDesaId == null ||
        _selectedKelompokId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'nama_lengkap': _namaController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'no_telepon': _noTelpController.text.trim(),
      'tempat_lahir': _tempatLahirController.text.trim(),
      'tanggal_lahir': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'kelompok_id': _selectedKelompokId,
      'desa_id': _selectedDesaId,
      'rt': _rtController.text,
      'rw': _rwController.text,
      'jenis_kapal': _selectedJenisKapal,
      'nama_kapal': _namaKapalController.text.trim().isEmpty ? 'Kapal Mandiri' : _namaKapalController.text.trim(),
      'no_registrasi_kapal': _noRegistrasiKapalController.text.trim().isEmpty ? 'REG-01' : _noRegistrasiKapalController.text.trim(),
      'jenis_tangkapan_utama': _selectedJenisTangkapan,
    };

    final response = await ApiService.register(payload);
    setState(() => _isSubmitting = false);

    if (response['status'] == 'success') {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Pendaftaran Berhasil', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Akun Anda berhasil didaftarkan. Harap tunggu persetujuan verifikasi dari admin Dinas Perikanan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Pendaftaran gagal')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Daftar Akun',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: _isLoadingReference
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Gunakan data KTP asli untuk memudahkan proses verifikasi oleh Dinas Perikanan Cilacap.',
                            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel('NAMA LENGKAP'),
                  _buildTextField(_namaController, 'Sesuai KTP'),
                  const SizedBox(height: 16),
                  _buildLabel('EMAIL'),
                  _buildTextField(_emailController, 'nama@email.com', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildLabel('KATA SANDI'),
                  _buildTextField(_passwordController, '••••••••', obscure: true),
                  const SizedBox(height: 16),
                  _buildLabel('NO. TELEPON'),
                  _buildTextField(_noTelpController, '0812xxxxxxxx', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TEMPAT LAHIR'),
                            _buildTextField(_tempatLahirController, 'Cilacap'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TGL LAHIR'),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(_selectedDate),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('KELOMPOK NELAYAN'),
                  _buildDropdown(
                    value: _selectedKelompokId,
                    items: _kelompokList.map((k) {
                      return DropdownMenuItem<String>(
                        value: k['id'].toString(),
                        child: Text(k['nama_kelompok']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedKelompokId = val),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('KECAMATAN'),
                  _buildDropdown(
                    value: _selectedKecamatanId,
                    items: _kecamatanList.map((k) {
                      return DropdownMenuItem<String>(
                        value: k['id'].toString(),
                        child: Text(k['nama']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedKecamatanId = val;
                        _filterDesa(val!);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('DESA'),
                  _buildDropdown(
                    value: _selectedDesaId,
                    items: _filteredDesaList.map((d) {
                      return DropdownMenuItem<String>(
                        value: d['id'].toString(),
                        child: Text(d['nama']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDesaId = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('RT'),
                            _buildTextField(_rtController, '001', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('RW'),
                            _buildTextField(_rwController, '001', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('JENIS KAPAL'),
                  _buildDropdown(
                    value: _selectedJenisKapal,
                    items: _kapalList.map((k) {
                      return DropdownMenuItem<String>(
                        value: k,
                        child: Text(k),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedJenisKapal = val!),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('NAMA KAPAL'),
                  _buildTextField(_namaKapalController, 'Nama Kapal Anda'),
                  const SizedBox(height: 16),
                  _buildLabel('NO REGISTRASI KAPAL'),
                  _buildTextField(_noRegistrasiKapalController, 'No Registrasi'),
                  const SizedBox(height: 16),
                  _buildLabel('JENIS TANGKAPAN UTAMA'),
                  _buildDropdown(
                    value: _selectedJenisTangkapan,
                    items: _tangkapanList.map((k) {
                      return DropdownMenuItem<String>(
                        value: k,
                        child: Text(k),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedJenisTangkapan = val!),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Kirim Pendaftaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) { /* same as original */
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder, {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String? value, required List<DropdownMenuItem<String>> items, required void Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _rtController = TextEditingController(text: '001');
  final _rwController = TextEditingController(text: '001');
  final _namaKapalController = TextEditingController();
  final _noRegistrasiKapalController = TextEditingController();

  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 30));
  bool _isLoadingReference = true;
  bool _isSubmitting = false;

  List<dynamic> _kecamatanList = [];
  List<dynamic> _desaList = [];
  List<dynamic> _kelompokList = [];
  List<dynamic> _filteredDesaList = [];

  String? _selectedKecamatanId;
  String? _selectedDesaId;
  String? _selectedKelompokId;
  String _selectedJenisKapal = 'Jukung';
  String _selectedJenisTangkapan = 'Pelagis';

  final List<String> _kapalList = ['Compreng', 'Jukung', 'Kolek', 'Perahu Motor'];
  final List<String> _tangkapanList = ['Pelagis', 'Demersal', 'Udang / Krustasea', 'Campuran'];

  @override
  void initState() {
    super.initState();
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    final data = await ApiService.getReferenceData();
    if (data != null && data['status'] == 'success') {
      setState(() {
        _kecamatanList = data['kecamatan'] ?? [];
        _desaList = data['desa'] ?? [];
        _kelompokList = data['kelompok_nelayan'] ?? [];

        if (_kecamatanList.isNotEmpty) {
          _selectedKecamatanId = _kecamatanList.first['id'].toString();
          _filterDesa(_selectedKecamatanId!);
        }
        if (_kelompokList.isNotEmpty) {
          _selectedKelompokId = _kelompokList.first['id'].toString();
        }
        _isLoadingReference = false;
      });
    } else {
      setState(() {
        _kecamatanList = [
          {'id': 'kec1', 'nama': 'Cilacap Selatan'},
          {'id': 'kec2', 'nama': 'Adipala'},
          {'id': 'kec3', 'nama': 'Kesugihan'}
        ];
        _desaList = [
          {'id': 'desa1', 'kecamatan_id': 'kec1', 'nama': 'Tegalkamulyan'},
          {'id': 'desa2', 'kecamatan_id': 'kec1', 'nama': 'Cilacap'},
          {'id': 'desa3', 'kecamatan_id': 'kec2', 'nama': 'Adipala'},
          {'id': 'desa4', 'kecamatan_id': 'kec3', 'nama': 'Kesugihan'}
        ];
        _kelompokList = [
          {'id': 'kel1', 'nama_kelompok': 'Mina Makmur'},
          {'id': 'kel2', 'nama_kelompok': 'Samudra Jaya'},
          {'id': 'kel3', 'nama_kelompok': 'Bakti Laut'}
        ];
        _selectedKecamatanId = 'kec1';
        _selectedKelompokId = 'kel1';
        _filterDesa('kec1');
        _isLoadingReference = false;
      });
    }
  }

  void _filterDesa(String kecamatanId) {
    setState(() {
      _filteredDesaList = _desaList.where((d) => d['kecamatan_id'].toString() == kecamatanId).toList();
      if (_filteredDesaList.isNotEmpty) {
        _selectedDesaId = _filteredDesaList.first['id'].toString();
      } else {
        _selectedDesaId = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F172A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _tempatLahirController.text.isEmpty ||
        _selectedDesaId == null ||
        _selectedKelompokId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua kolom')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'nama_lengkap': _namaController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'no_telepon': _noTelpController.text.trim(),
      'tempat_lahir': _tempatLahirController.text.trim(),
      'tanggal_lahir': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'kelompok_id': _selectedKelompokId,
      'desa_id': _selectedDesaId,
      'rt': _rtController.text,
      'rw': _rwController.text,
      'jenis_kapal': _selectedJenisKapal,
      'nama_kapal': _namaKapalController.text.trim().isEmpty ? 'Kapal Mandiri' : _namaKapalController.text.trim(),
      'no_registrasi_kapal': _noRegistrasiKapalController.text.trim().isEmpty ? 'REG-01' : _noRegistrasiKapalController.text.trim(),
      'jenis_tangkapan_utama': _selectedJenisTangkapan,
    };

    final response = await ApiService.register(payload);
    setState(() => _isSubmitting = false);

    if (response['status'] == 'success') {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Pendaftaran Berhasil', style: TextStyle(fontWeight: FontWeight.bold)),
            content: const Text('Akun Anda berhasil didaftarkan. Harap tunggu persetujuan verifikasi dari admin Dinas Perikanan.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
              )
            ],
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Pendaftaran gagal')),
        );
      }
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String placeholder, {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildDropdown({required String? value, required List<DropdownMenuItem<String>> items, required void Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Daftar Akun',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: _isLoadingReference
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.blue.shade600),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Gunakan data KTP asli untuk memudahkan proses verifikasi oleh Dinas Perikanan Cilacap.',
                            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel('NAMA LENGKAP'),
                  _buildTextField(_namaController, 'Sesuai KTP'),
                  const SizedBox(height: 16),

                  _buildLabel('EMAIL'),
                  _buildTextField(_emailController, 'nama@email.com', keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),

                  _buildLabel('KATA SANDI'),
                  _buildTextField(_passwordController, '••••••••', obscure: true),
                  const SizedBox(height: 16),

                  _buildLabel('NO. TELEPON'),
                  _buildTextField(_noTelpController, '0812xxxxxxxx', keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TEMPAT LAHIR'),
                            _buildTextField(_tempatLahirController, 'Cilacap'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('TGL LAHIR'),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd-MM-yyyy').format(_selectedDate),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('KELOMPOK NELAYAN'),
                  _buildDropdown(
                    value: _selectedKelompokId,
                    items: _kelompokList.map((k) {
                      return DropdownMenuItem<String>(
                        value: k['id'].toString(),
                        child: Text(k['nama_kelompok']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedKelompokId = val),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('KECAMATAN'),
                  _buildDropdown(
                    value: _selectedKecamatanId,
                    items: _kecamatanList.map((k) {
                      return DropdownMenuItem<String>(
                        value: k['id'].toString(),
                        child: Text(k['nama']),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedKecamatanId = val;
                        _filterDesa(val!);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('DESA'),
                  _buildDropdown(
                    value: _selectedDesaId,
                    items: _filteredDesaList.map((d) {
                      return DropdownMenuItem<String>(
                        value: d['id'].toString(),
                        child: Text(d['nama']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDesaId = val),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('RT'),
                            _buildTextField(_rtController, '001', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('RW'),
                            _buildTextField(_rwController, '001', keyboardType: TextInputType.number),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('JENIS KAPAL'),
                  _buildDropdown(
                    value: _selectedJenisKapal,
                    items: _kapalList.map((k) {
                      return DropdownMenuItem<String>(
                        value: k,
                        child: Text(k),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedJenisKapal = val!),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('NAMA KAPAL'),
                  _buildTextField(_namaKapalController, 'Nama Kapal Anda'),
                  const SizedBox(height: 16),

                  _buildLabel('NO REGISTRASI KAPAL'),
                  _buildTextField(_noRegistrasiKapalController, 'No Registrasi'),
                  const SizedBox(height: 16),

                  _buildLabel('JENIS TANGKAPAN UTAMA'),
                  _buildDropdown(
                    value: _selectedJenisTangkapan,
                    items: _tangkapanList.map((k) {
                      return DropdownMenuItem<String>(
                        value: k,
                        child: Text(k),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedJenisTangkapan = val!),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Kirim Pendaftaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
