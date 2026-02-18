import '../database/database_helper.dart';
import '../models/blood_pressure_record.dart';
import '../services/dashboard_service.dart';
import '../services/excel_export_service.dart';

class BloodPressureRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final DashboardService _dashboard = DashboardService.instance;
  final ExcelExportService _excel = ExcelExportService.instance;

  Future<int> addRecord(int systolic, int diastolic, int heartRate, {String? notes}) async {
    final record = BloodPressureRecord(
      systolic: systolic,
      diastolic: diastolic,
      heartRate: heartRate,
      notes: notes,
    );
    return await _db.insertRecord(record);
  }

  Future<List<BloodPressureRecord>> getAllRecords() async {
    return await _db.getAllRecords();
  }

  Future<BloodPressureRecord?> getRecord(int id) async {
    return await _db.getRecord(id);
  }

  Future<int> updateRecord(BloodPressureRecord record) async {
    return await _db.updateRecord(record);
  }

  Future<int> deleteRecord(int id) async {
    return await _db.deleteRecord(id);
  }

  Future<List<BloodPressureRecord>> getRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _db.getRecordsByDateRange(start, end);
  }

  DashboardStats getStats(List<BloodPressureRecord> records) {
    return _dashboard.calculateStats(records);
  }

  List<BloodPressureRecord> getRecentRecords(List<BloodPressureRecord> records, {int limit = 7}) {
    return _dashboard.getRecentRecords(records, limit: limit);
  }

  List<BloodPressureRecord> getTodayRecords(List<BloodPressureRecord> records) {
    return _dashboard.getTodayRecords(records);
  }

  List<BloodPressureRecord> getThisWeekRecords(List<BloodPressureRecord> records) {
    return _dashboard.getThisWeekRecords(records);
  }

  List<BloodPressureRecord> getThisMonthRecords(List<BloodPressureRecord> records) {
    return _dashboard.getThisMonthRecords(records);
  }

  String getHealthStatus(DashboardStats stats) {
    return _dashboard.getHealthStatus(stats);
  }

  Future<String> exportToExcel(List<BloodPressureRecord> records) async {
    return await _excel.exportToExcel(records);
  }

  Future<String> exportToCsv(List<BloodPressureRecord> records) async {
    return await _excel.exportToCsv(records);
  }
}
