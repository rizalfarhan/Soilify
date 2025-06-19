import 'package:flutter/material.dart';
import 'dart:io';
import '../services/image_helper.dart';
import '../services/classifier_service.dart';
import '../widgets/result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  String _predictionResult = '';
  double _confidence = 0.0;
  bool _isLoading = false;

  final ClassifierService _classifierService = ClassifierService();

  @override
  void initState() {
    super.initState();
    _initializeClassifier();
  }

  Future<void> _initializeClassifier() async {
    try {
      await _classifierService.loadModel();
      print('Classifier initialized successfully');
    } catch (e) {
      print('Error initializing classifier: $e');
      _showErrorSnackBar('Gagal memuat model: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromCamera() async {
    setState(() => _isLoading = true);

    try {
      final image = await ImageHelper.captureFromCamera();
      if (image != null) {
        await _classifyImage(image);
      }
    } catch (e) {
      print('Error picking image from camera: $e');
      _showErrorSnackBar('Gagal mengambil gambar dari kamera');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isLoading = true);

    try {
      final image = await ImageHelper.pickFromGallery();
      if (image != null) {
        await _classifyImage(image);
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
      _showErrorSnackBar('Gagal mengambil gambar dari galeri');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _classifyImage(File image) async {
    try {
      final result = await _classifierService.predict(image);

      setState(() {
        _selectedImage = image;
        _predictionResult = result['label'] ?? 'Tidak diketahui';
        _confidence = result['confidence'] ?? 0.0;
      });
    } catch (e) {
      print('Error classifying image: $e');
      setState(() {
        _selectedImage = image;
        _predictionResult = 'Error';
        _confidence = 0.0;
      });
      _showErrorSnackBar('Gagal melakukan klasifikasi: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _resetSelection() {
    setState(() {
      _selectedImage = null;
      _predictionResult = '';
      _confidence = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Klasifikasi Jenis Tanah',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_selectedImage != null)
            IconButton(
              onPressed: _resetSelection,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Card
            Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pilih gambar untuk klasifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gunakan tombol di bawah untuk memilih gambar',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImageFromCamera,
                    icon: const Icon(Icons.camera_alt, size: 24),
                    label: const Text(
                      'Kamera',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library, size: 24),
                    label: const Text(
                      'Galeri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Result Card - menggunakan widget ResultCard
            if (_predictionResult.isNotEmpty || _isLoading)
              ResultCard(
                label: _predictionResult,
                confidence: _confidence,
                isLoading: _isLoading,
              ),

            // Info Card
            if (_selectedImage == null && !_isLoading)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[600],
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tips Penggunaan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Pastikan gambar tanah terlihat jelas\n'
                        '• Gunakan pencahayaan yang baik\n'
                        '• Ambil foto dari jarak yang cukup dekat',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _classifierService.dispose();
    super.dispose();
  }
}
