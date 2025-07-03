import 'package:flutter/material.dart';

class ResultCard extends StatefulWidget {
  final String label;
  final double confidence;
  final bool isLoading;

  const ResultCard({
    Key? key,
    required this.label,
    required this.confidence,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _barAnimation = Tween<double>(
      begin: 0.0,
      end: widget.confidence.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (!widget.isLoading && widget.confidence > 0) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(ResultCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && widget.confidence != oldWidget.confidence) {
      _barAnimation = Tween<double>(
        begin: 0.0,
        end: widget.confidence.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _getConfidenceColor(widget.confidence);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(confidenceColor),
          const SizedBox(height: 24),
          widget.isLoading ? _buildLoadingContent() : _buildResultContent(confidenceColor),
        ],
      ),
    );
  }

  Widget _buildHeader(Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.analytics_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Hasil Klasifikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        const SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B4E3D)),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Menganalisis gambar tanah...',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(Color confidenceColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label jenis tanah
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: confidenceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: confidenceColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kepercayaan ${(widget.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: confidenceColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Tingkat Kepercayaan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 10),

        // Bar confidence dengan animasi
        Container(
          height: 14,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.grey[200],
          ),
          child: AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _barAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: LinearGradient(
                      colors: [
                        confidenceColor.withOpacity(0.7),
                        confidenceColor,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(widget.confidence * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: confidenceColor,
            ),
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return const Color(0xFF388E3C); // Hijau tua
    } else if (confidence >= 0.6) {
      return const Color(0xFFF57C00); // Oranye
    } else {
      return const Color(0xFFD32F2F); // Merah
    }
  }
}
