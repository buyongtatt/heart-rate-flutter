import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/blood_pressure_record.dart';

class ExcelExportService {
  static final ExcelExportService instance = ExcelExportService._init();

  ExcelExportService._init();

  Map<DateTime, Map<String, BloodPressureRecord?>> _groupByDayAndPeriod(
      List<BloodPressureRecord> records) {
    final grouped = <DateTime, Map<String, BloodPressureRecord?>>{};

    for (final record in records) {
      final ts = record.timestamp;
      DateTime reportDate = DateTime(ts.year, ts.month, ts.day);
      if (ts.hour < 5) {
        reportDate = reportDate.subtract(const Duration(days: 1));
      }
      final dateOnly = DateTime(reportDate.year, reportDate.month, reportDate.day);

      String period;
      if (ts.hour >= 5 && ts.hour < 12) {
        period = 'morning';
      } else if (ts.hour >= 12 && ts.hour < 18) {
        period = 'afternoon';
      } else {
        period = 'night';
      }

      grouped.putIfAbsent(dateOnly, () => {});
      if (!grouped[dateOnly]!.containsKey(period)) {
        grouped[dateOnly]![period] = record;
      }
    }
    return grouped;
  }

  Future<String> exportToExcel(List<BloodPressureRecord> records) async {
    final excel = Excel.createExcel();
  final sheet = excel['Blood Pressure Records'];

  // Header
  sheet.appendRow([
    TextCellValue('Date'),
    TextCellValue('Time'),
    TextCellValue('Systolic'),
    TextCellValue('Diastolic'),
    TextCellValue('Heart Rate'),
    TextCellValue('Category'),
    TextCellValue('Notes'),
  ]);

  // Sort by timestamp
  final sorted = List<BloodPressureRecord>.from(records)..sort((a,b) => a.timestamp.compareTo(b.timestamp));

  for (final record in sorted) {
    sheet.appendRow([
      TextCellValue(DateFormat('yyyy-MM-dd').format(record.timestamp)),
      TextCellValue(DateFormat('HH:mm').format(record.timestamp)),
      IntCellValue(record.systolic),
      IntCellValue(record.diastolic),
      IntCellValue(record.heartRate),
      TextCellValue(record.category),
      TextCellValue(record.notes ?? ''),
    ]);
  }

    for (var i = 0; i < 16; i++) {
      sheet.setColumnWidth(i, 20);
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/blood_pressure_$timestamp.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  Future<String> exportToCsv(List<BloodPressureRecord> records) async {
    final grouped = _groupByDayAndPeriod(records);
    final buffer = StringBuffer();

    buffer.writeln(
      'Date,Morning Systolic,Morning Diastolic,Morning Heart Rate,Morning Category,Morning Notes,'
      'Afternoon Systolic,Afternoon Diastolic,Afternoon Heart Rate,Afternoon Category,Afternoon Notes,'
      'Night Systolic,Night Diastolic,Night Heart Rate,Night Category,Night Notes',
    );

    final sortedDates = grouped.keys.toList()..sort();

    for (final date in sortedDates) {
      final dayRecords = grouped[date]!;
      final morning = dayRecords['morning'];
      final afternoon = dayRecords['afternoon'];
      final night = dayRecords['night'];

      final row = [
        DateFormat('yyyy-MM-dd').format(date),
        morning?.systolic.toString() ?? '',
        morning?.diastolic.toString() ?? '',
        morning?.heartRate.toString() ?? '',
        morning?.category ?? '',
        morning?.notes ?? '',
        afternoon?.systolic.toString() ?? '',
        afternoon?.diastolic.toString() ?? '',
        afternoon?.heartRate.toString() ?? '',
        afternoon?.category ?? '',
        afternoon?.notes ?? '',
        night?.systolic.toString() ?? '',
        night?.diastolic.toString() ?? '',
        night?.heartRate.toString() ?? '',
        night?.category ?? '',
        night?.notes ?? '',
      ];
      buffer.writeln(row.join(','));
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/blood_pressure_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    return filePath;
  }
}