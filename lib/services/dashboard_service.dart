import '../models/blood_pressure_record.dart';

class DashboardStats {
  final double avgSystolic;
  final double avgDiastolic;
  final double avgHeartRate;
  final int minSystolic;
  final int maxSystolic;
  final int minDiastolic;
  final int maxDiastolic;
  final int minHeartRate;
  final int maxHeartRate;
  final int totalRecords;
  final Map<String, int> categoryDistribution;

  DashboardStats({
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.avgHeartRate,
    required this.minSystolic,
    required this.maxSystolic,
    required this.minDiastolic,
    required this.maxDiastolic,
    required this.minHeartRate,
    required this.maxHeartRate,
    required this.totalRecords,
    required this.categoryDistribution,
  });
}

class DashboardService {
  static final DashboardService instance = DashboardService._init();
  
  DashboardService._init();

  DashboardStats calculateStats(List<BloodPressureRecord> records) {
    if (records.isEmpty) {
      return DashboardStats(
        avgSystolic: 0,
        avgDiastolic: 0,
        avgHeartRate: 0,
        minSystolic: 0,
        maxSystolic: 0,
        minDiastolic: 0,
        maxDiastolic: 0,
        minHeartRate: 0,
        maxHeartRate: 0,
        totalRecords: 0,
        categoryDistribution: {},
      );
    }

    final systolicValues = records.map((r) => r.systolic).toList();
    final diastolicValues = records.map((r) => r.diastolic).toList();
    final heartRateValues = records.map((r) => r.heartRate).toList();

    final categoryCount = <String, int>{};
    for (final record in records) {
      final category = record.category;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return DashboardStats(
      avgSystolic: _calculateAverage(systolicValues),
      avgDiastolic: _calculateAverage(diastolicValues),
      avgHeartRate: _calculateAverage(heartRateValues),
      minSystolic: systolicValues.reduce((a, b) => a < b ? a : b),
      maxSystolic: systolicValues.reduce((a, b) => a > b ? a : b),
      minDiastolic: diastolicValues.reduce((a, b) => a < b ? a : b),
      maxDiastolic: diastolicValues.reduce((a, b) => a > b ? a : b),
      minHeartRate: heartRateValues.reduce((a, b) => a < b ? a : b),
      maxHeartRate: heartRateValues.reduce((a, b) => a > b ? a : b),
      totalRecords: records.length,
      categoryDistribution: categoryCount,
    );
  }

  List<BloodPressureRecord> getRecentRecords(List<BloodPressureRecord> records, {int limit = 7}) {
    final sorted = List<BloodPressureRecord>.from(records)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  List<BloodPressureRecord> getTodayRecords(List<BloodPressureRecord> records) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return records.where((r) => 
      r.timestamp.isAfter(startOfDay) && r.timestamp.isBefore(endOfDay)
    ).toList();
  }

  List<BloodPressureRecord> getThisWeekRecords(List<BloodPressureRecord> records) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return records.where((r) => r.timestamp.isAfter(startOfWeekDay)).toList();
  }

  List<BloodPressureRecord> getThisMonthRecords(List<BloodPressureRecord> records) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    
    return records.where((r) => r.timestamp.isAfter(startOfMonth)).toList();
  }

  double _calculateAverage(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  String getHealthStatus(DashboardStats stats) {
    final avgSys = stats.avgSystolic;
    final avgDia = stats.avgDiastolic;

    if (avgSys < 120 && avgDia < 80) return 'Normal';
    if (avgSys < 130 && avgDia < 80) return 'Elevated';
    if (avgSys < 140 || avgDia < 90) return 'High (Stage 1)';
    return 'High (Stage 2)';
  }
}
