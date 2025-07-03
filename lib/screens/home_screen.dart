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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  File? _selectedImage;
  String _predictionResult = '';
  double _confidence = 0.0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ClassifierService _classifierService = ClassifierService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
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
    _resetPredictionState();

    try {
      final image = await ImageHelper.captureFromCamera();
      if (image != null) {
        await _classifyImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil gambar dari kamera');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isLoading = true);
    _resetPredictionState();

    try {
      final image = await ImageHelper.pickFromGallery();
      if (image != null) {
        await _classifyImage(image);
      }
    } catch (e) {
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

      _animationController.forward(from: 0.0);
    } catch (e) {
      _showErrorSnackBar('Gagal melakukan klasifikasi: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetSelection() {
    setState(() {
      _selectedImage = null;
      _resetPredictionState();
    });
    _animationController.reverse();
  }

  void _resetPredictionState() {
    _predictionResult = '';
    _confidence = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: const Text(
          'Klasifikasi Jenis Tanah',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6B4E3D),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8D6748), Color(0xFF6B4E3D)],
            ),
          ),
        ),
        actions: [
          if (_selectedImage != null)
            IconButton(
              onPressed: _resetSelection,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionButtons(),
            const SizedBox(height: 24),

            if (_selectedImage != null)
              _buildImagePreviewCard(),
            if (_selectedImage != null)
              const SizedBox(height: 24),

            if (_predictionResult.isNotEmpty || _isLoading)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ResultCard(
                    label: _predictionResult,
                    confidence: _confidence,
                    isLoading: _isLoading,
                  ),
                ),
              ),
            if (_predictionResult.isNotEmpty &&
                _predictionResult != 'Bukan tanah' &&
                _predictionResult != 'Bukan_Tanah' &&
                !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildPlantRecommendations(),
                  ),
                ),
              ),
            if (_selectedImage == null && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: _buildInfoCard(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewCard() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFE8DDD4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildGradientButton(
            onPressed: _isLoading ? null : _pickImageFromCamera,
            icon: Icons.camera_alt_rounded,
            label: 'Ambil Foto',
            gradientColors: const [Color(0xFF8D6748), Color(0xFF6B4E3D)],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGradientButton(
            onPressed: _isLoading ? null : _pickImageFromGallery,
            icon: Icons.photo_library_rounded,
            label: 'Dari Galeri',
            gradientColors: const [Color(0xFFC8A276), Color(0xFFD2B48C)],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getPlantRecommendations(String soilType) {
    switch (soilType.toLowerCase()) {
      case 'black soil':
        return ['Padi', 'Jagung', 'Kedelai', 'Tebu', 'Singkong', 'Ubi Jalar'];
      case 'cinder soil':
        return ['Pinus', 'Anggur', 'Kopi', 'Kentang', 'Wortel', 'Kol'];
      case 'laterite soil':
        return ['Kopi', 'Teh', 'Jambu Mete', 'Karet', 'Kelapa', 'Padi'];
      case 'peat soil':
        return ['Nanas', 'Kelapa', 'Sagu', 'Pisang', 'Sawit', 'Lada'];
      case 'yellow soil':
        return ['Teh', 'Jagung', 'Tembakau', 'Ubi Jalar', 'Nanas', 'Pepaya'];
      default:
        return [];
    }
  }

  Widget _buildPlantRecommendations() {
    final recommendations = _getPlantRecommendations(_predictionResult);
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.green.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_florist_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 15),
                const Text(
                  'Rekomendasi Tanaman',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE8F5E8)),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: recommendations
                  .map(
                    (plant) => Chip(
                      label: Text(
                        plant,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: const Color(0xFFE8F5E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: const Color(0xFF4CAF50).withOpacity(0.5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      shadowColor: Colors.orange.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9800),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                const Text(
                  'Tips Pengambilan Foto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFFFF3E0)),
            const Column(
              children: [
                _InfoTip(
                  icon: Icons.wb_sunny_rounded,
                  text: 'Gunakan pencahayaan alami yang cukup untuk hasil terbaik.',
                ),
                SizedBox(height: 12),
                _InfoTip(
                  icon: Icons.texture_rounded,
                  text: 'Pastikan fokus pada tekstur, warna, dan detail tanah.',
                ),
                SizedBox(height: 12),
                _InfoTip(
                  icon: Icons.camera_alt_rounded,
                  text: 'Ambil gambar dari jarak sekitar 15-30 cm dari permukaan tanah.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _classifierService.dispose();
    super.dispose();
  }
}

class _InfoTip extends StatelessWidget {
  const _InfoTip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Color(0xFFFF9800)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFE65100),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
