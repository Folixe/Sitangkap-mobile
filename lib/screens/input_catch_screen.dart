import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../widgets/dash_rect_painter.dart';

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
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(18),
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
                            image: DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover),
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
