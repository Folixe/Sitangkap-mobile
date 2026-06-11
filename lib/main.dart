import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';

void main() {
  runApp(const SitangkapApp());
}

class SitangkapApp extends StatelessWidget {
  const SitangkapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SITANGKAP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A),
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await ApiService.getToken();
    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF0F172A)),
        ),
      );
    }

    return _isLoggedIn ? const MainTabScreen() : const LoginScreen();
  }
}

// LOGIN SCREEN
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final response = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainTabScreen()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login gagal')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background blurs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.anchor, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SITANGKAP.',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sistem pendataan tangkapan nelayan modern untuk perairan Cilacap.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Form
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EMAIL / NO. HP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'nelayan@cilacap.go.id',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'KATA SANDI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Lupa sandi?',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum terdaftar? ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                'Buat akun',
                                style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

// REGISTER SCREEN
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
      // Mock references fallback
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
                  Navigator.of(context).pop(); // Back to Login
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
                  // Info banner
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

                  // Inputs
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
}

// MAIN TAB CONTAINER
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    const HomeTab(),
    const HistoryTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0F172A),
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time_filled),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// HOME TAB
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
          // Background blobs
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
                  // Header
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

                  // Monthly catch card
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

                  // Action Button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InputCatchScreen()),
                      ).then((_) => _fetchData()); // Reload on return
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

                  // Recent catches header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Aktivitas Terakhir', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      TextButton(onPressed: () {}, child: const Text('Lihat Semua', style: TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Catches List
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

// HISTORY TAB
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  List<dynamic> _catches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCatches();
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

// PROFILE TAB
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final data = await ApiService.getProfile();
    if (data != null && data['status'] == 'success') {
      setState(() {
        _profile = data['nelayan'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0F172A))));
    }

    final name = _profile?['nama_lengkap'] ?? 'Nelayan';
    final desa = _profile?['profil']?['desa']?['nama'] ?? 'Cilacap';
    final kelompok = _profile?['profil']?['kelompok_nelayan']?['nama_kelompok'] ?? 'Kelompok Mandiri';
    final kapal = _profile?['profil']?['jenis_kapal'] ?? 'Jukung';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.only(top: 64, bottom: 32, left: 24, right: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profil.',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0ea5e9&color=fff',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0F172A))),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('$desa, Cilacap', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            // Profile info cards
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.anchor, size: 18, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text('KELOMPOK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(kelompok, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.directions_boat, size: 18, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text('KAPAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                              const SizedBox(height: 4),
                              Text(kapal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile settings list
                  _buildProfileMenu(Icons.edit, 'Ubah Data Profil', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Ubah Data Profil segera hadir!')),
                    );
                  }),
                  const SizedBox(height: 12),
                  _buildProfileMenu(Icons.settings, 'Pengaturan Aplikasi', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur Pengaturan Aplikasi segera hadir!')),
                    );
                  }),
                  const SizedBox(height: 24),
                  
                  // Log Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Keluar Akun', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
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

  Widget _buildProfileMenu(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 16),
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// INPUT CATCH SCREEN
class InputCatchScreen extends StatefulWidget {
  const InputCatchScreen({super.key});

  @override
  State<InputCatchScreen> createState() => _InputCatchScreenState();
}

class _InputCatchScreenState extends State<InputCatchScreen> {
  final _beratController = TextEditingController();
  DateTime _tanggalMelaut = DateTime.now();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoadingReference = true;
  bool _isSubmitting = false;
  List<dynamic> _jenisIkanList = [];
  String? _selectedJenisIkanId;

  @override
  void initState() {
    super.initState();
    _loadReference();
  }

  Future<void> _loadReference() async {
    final data = await ApiService.getReferenceData();
    if (data != null && data['status'] == 'success') {
      setState(() {
        _jenisIkanList = data['jenis_ikan'] ?? [];
        if (_jenisIkanList.isNotEmpty) {
          _selectedJenisIkanId = _jenisIkanList.first['id'].toString();
        }
        _isLoadingReference = false;
      });
    } else {
      // Mock fish species fallback
      setState(() {
        _jenisIkanList = [
          {'id': 'f1', 'nama_lokal': 'Tuna Yellowfin'},
          {'id': 'f2', 'nama_lokal': 'Cakalang'},
          {'id': 'f3', 'nama_lokal': 'Tongkol'},
          {'id': 'f4', 'nama_lokal': 'Layur'}
        ];
        _selectedJenisIkanId = 'f1';
        _isLoadingReference = false;
      });
    }
  }

  Future<void> _pickImage() async {
    // Show select source dialog
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    setState(() => _imageFile = File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                  if (image != null) {
                    setState(() => _imageFile = File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (_selectedJenisIkanId == null || _beratController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data dan foto bukti')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final response = await ApiService.storeCatch(
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggalMelaut),
      jenisIkanId: _selectedJenisIkanId!,
      berat: double.parse(_beratController.text),
      fotoFile: _imageFile!,
    );

    setState(() => _isSubmitting = false);

    if (response['status'] == 'success') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data tangkapan berhasil dikirim dan menunggu verifikasi admin.')),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal mengirim data.')),
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
          'Input Baru',
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
                  const Text(
                    'TANGGAL MELAUT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _tanggalMelaut,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _tanggalMelaut = picked);
                      }
                    },
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
                          Text(DateFormat('dd-MM-yyyy').format(_tanggalMelaut), style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'JENIS IKAN UTAMA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedJenisIkanId,
                        isExpanded: true,
                        items: _jenisIkanList.map((k) {
                          return DropdownMenuItem<String>(
                            value: k['id'].toString(),
                            child: Text(k['nama_lokal'] ?? 'Ikan'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedJenisIkanId = val),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'TOTAL BERAT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _beratController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    decoration: InputDecoration(
                      hintText: '0.0',
                      suffixText: 'Kg',
                      suffixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'FOTO BUKTI TANGKAPAN',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  _imageFile == null
                      ? GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: CustomPaint(
                              painter: DashRectPainter(color: Colors.grey.shade400, strokeWidth: 1.5, gap: 5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt, color: Color(0xFF475569), size: 24),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Ambil Foto Tangkapan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 4),
                                  Text('Gunakan pencahayaan yang terang', style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 220,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(image: FileImage(_imageFile!), fit: BoxCoverFit.cover),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.9),
                                    foregroundColor: const Color(0xFF0F172A),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    elevation: 2,
                                  ),
                                  child: const Text('Ganti Foto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: const Icon(Icons.cloud_upload, size: 20),
                      label: const Text('Simpan Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// DASHED BORDER PAINTER
class DashRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashRectPainter({this.color = Colors.black, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(24)));

    // Simple custom dashed effect
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
class BoxCoverFit {
  static const cover = BoxFit.cover;
}
