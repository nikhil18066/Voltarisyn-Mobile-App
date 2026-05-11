import 'dart:async';
import 'dart:math';
import '../models/energy_data_model.dart';

class EnergySimulatorService {
  final Random _random = Random();
  Timer? _timer;
  String _accountType = 'home';

  void setAccountType(String type) {
    _accountType = type;
  }

  // Generate 20 initial data points for a more realistic dense graph
  List<EnergyDataPoint> generateInitialData() {
    final points = <EnergyDataPoint>[];
    final now = DateTime.now();

    // Simulate a realistic energy curve (morning ramp → midday peak → evening)
    for (int i = 19; i >= 0; i--) {
      final t = now.subtract(Duration(seconds: i * 3));
      // Create a realistic sine-wave-like pattern with noise
      final progress = (20 - i) / 20.0;
      final baseWave = 4.5 + 2.0 * sin(progress * 3.14159 * 2) + 1.0 * sin(progress * 3.14159 * 4);
      final noise = (_random.nextDouble() - 0.5) * 0.8;
      final usage = max(1.5, baseWave + noise);
      points.add(EnergyDataPoint(
        time: _formatTime(t),
        usage: double.parse(usage.toStringAsFixed(2)),
        cost: double.parse((usage * 8.5).toStringAsFixed(0)),
      ));
    }
    return points;
  }

  EnergyDataPoint generateDataPoint(double totalActiveLoad) {
    // Add realistic fluctuation — small random walk around active load
    final fluctuation = (_random.nextDouble() - 0.5) * 0.6;
    // Slight sine wave for breathing effect
    final sineOffset = 0.3 * sin(DateTime.now().millisecondsSinceEpoch / 2000.0);
    final newUsage = max(0.5, double.parse(
        (totalActiveLoad + fluctuation + sineOffset).toStringAsFixed(2)));
    final newCost = double.parse((newUsage * 8.5).toStringAsFixed(0));
    return EnergyDataPoint(
      time: _formatTime(DateTime.now()),
      usage: newUsage,
      cost: newCost,
    );
  }

  double getBaselineRange() {
    if (_accountType == 'industry') {
      return 5.0 + _random.nextDouble() * 45.0;
    }
    return 0.3 + _random.nextDouble() * 3.2;
  }

  void startSimulation({
    required Duration interval,
    required Function(EnergyDataPoint) onData,
    required double Function() getActiveLoad,
  }) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      onData(generateDataPoint(getActiveLoad()));
    });
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$hour:$min:$sec $ampm';
  }
}
