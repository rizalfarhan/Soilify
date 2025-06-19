import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
  Interpreter? _interpreter;
  static const int inputSize = 150;

  // ✅ FIX: Sesuai urutan alfabetis hasil class_indices
  static const List<String> labels = [
    'Black Soil',
    'Bukan_Tanah',
    'Cinder Soil',
    'Laterite Soil',
    'Peat Soil',
    'Yellow Soil',
  ];

  bool get isModelLoaded => _interpreter != null;

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(
        'assets/models/soil_model.tflite',
        options: options,
      );
      print('Model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('Error loading model: $e');
      throw Exception('Gagal memuat model: $e');
    }
  }

  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Model belum dimuat');
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Gagal memuat gambar');

      final inputTensor = _preprocessImage(image);

      var output = List.filled(1 * labels.length, 0.0).reshape([1, labels.length]);
      _interpreter!.run(inputTensor, output);

      return _processOutput(output[0]);
    } catch (e) {
      print('Error during prediction: $e');
      throw Exception('Prediksi gagal: $e');
    }
  }

  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    return List.generate(
      1,
      (batch) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r.toDouble() / 255.0,
            pixel.g.toDouble() / 255.0,
            pixel.b.toDouble() / 255.0,
          ];
        }),
      ),
    );
  }

  Map<String, dynamic> _processOutput(List<double> predictions) {
    int maxIndex = 0;
    double maxConfidence = predictions[0];

    for (int i = 1; i < predictions.length; i++) {
      if (predictions[i] > maxConfidence) {
        maxConfidence = predictions[i];
        maxIndex = i;
      }
    }

    const double confidenceThreshold = 0.6;

    final label = (maxConfidence >= confidenceThreshold)
        ? labels[maxIndex]
        : 'Bukan tanah';

    final Map<String, double> allPredictions = {
      for (int i = 0; i < labels.length; i++) labels[i]: predictions[i],
    };

    return {
      'label': label,
      'confidence': maxConfidence,
      'all_predictions': allPredictions,
    };
  }

  Future<List<Map<String, dynamic>>> getAllPredictions(File imageFile) async {
    final result = await predict(imageFile);
    final allPredictions = result['all_predictions'] as Map<String, double>;

    return allPredictions.entries
        .map((entry) => {
              'label': entry.key,
              'confidence': entry.value,
            })
        .toList()
      ..sort((a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double));
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
