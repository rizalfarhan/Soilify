import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 4 : 8,
      shadowColor: isDark ? Colors.black54 : Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: isDark ? Colors.green[400] : Colors.green[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Hasil Klasifikasi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Content
            if (isLoading)
              _buildLoadingContent(isDark)
            else
              _buildResultContent(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent(bool isDark) {
    return Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            isDark ? Colors.green[400]! : Colors.green[600]!,
          ),
          strokeWidth: 3,
        ),
        const SizedBox(height: 16),
        Text(
          'Memproses gambar...',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(bool isDark) {
    return Column(
      children: [
        // Label Container
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color:
                isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.green[400]! : Colors.green[200]!,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.green[400] : Colors.green[800],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 20),

        // Confidence Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              color: isDark ? Colors.blue[400] : Colors.blue[600],
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Kepercayaan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.blue[400] : Colors.blue[700],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Confidence Bar
        _buildConfidenceBar(isDark),
      ],
    );
  }

  Widget _buildConfidenceBar(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            Text(
              '100%',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [
                    isDark ? Colors.green[400]! : Colors.green[500]!,
                    isDark ? Colors.blue[400]! : Colors.blue[500]!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Alternative Compact Version
class CompactResultCard extends StatelessWidget {
  final String label;
  final double confidence;

  const CompactResultCard({
    Key? key,
    required this.label,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 2 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: isDark ? Colors.green[400] : Colors.green[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(confidence * 100).toStringAsFixed(1)}% kepercayaan',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
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
