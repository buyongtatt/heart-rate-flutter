import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/blood_pressure_record.dart';

class ExcelExportService {
  static final ExcelExportService instance = ExcelExportService._init();

  ExcelExportService._init();

  /// Groups records by day and period (morning, afternoon, Night).
  /// Returns a map: date -> { period -> List<BloodPressureRecord> }
  Map<DateTime, Map<String, List<BloodPressureRecord>>> _groupByDayAndPeriod(
      List<BloodPressureRecord> records) {
    final grouped = <DateTime, Map<String, List<BloodPressureRecord>>>{};

    for (final record in records) {
      final ts = record.timestamp;
      // Determine the reporting date (records before 5am belong to previous day)
      DateTime reportDate = DateTime(ts.year, ts.month, ts.day);
      if (ts.hour < 5) {
        reportDate = reportDate.subtract(const Duration(days: 1));
      }
      final dateOnly =
          DateTime(reportDate.year, reportDate.month, reportDate.day);

      // Determine period
      String period;
      if (ts.hour >= 5 && ts.hour < 12) {
        period = 'Morning';
      } else if (ts.hour >= 12 && ts.hour < 18) {
        period = 'Afternoon';
      } else {
        period = 'Night'; // was 'night' before
      }

      grouped.putIfAbsent(dateOnly, () => {});
      grouped[dateOnly]!.putIfAbsent(period, () => []);
      grouped[dateOnly]![period]!.add(record);
    }
    return grouped;
  }

  /// Exports all records to Excel with an additional 'Period' column.
  Future<String> exportToExcel(List<BloodPressureRecord> records) async {
    final excel = Excel.createExcel();
    final sheet = excel['Blood Pressure Records'];

    // Header with Period
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Period'),
      TextCellValue('Time'),
      TextCellValue('Systolic (mmHg)'),
      TextCellValue('Diastolic (mmHg)'),
      TextCellValue('Heart Rate (bpm)'),
      TextCellValue('Category'),
      TextCellValue('Notes'),
    ]);

    // Sort by timestamp
    final sorted = List<BloodPressureRecord>.from(records)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final record in sorted) {
      final ts = record.timestamp;
      String period;
      if (ts.hour >= 5 && ts.hour < 12) {
        period = 'Morning';
      } else if (ts.hour >= 12 && ts.hour < 18) {
        period = 'Afternoon';
      } else {
        period = 'Night';
      }

      sheet.appendRow([
        TextCellValue(DateFormat('yyyy-MM-dd').format(ts)),
        TextCellValue(period),
        TextCellValue(DateFormat('HH:mm').format(ts)),
        IntCellValue(record.systolic),
        IntCellValue(record.diastolic),
        IntCellValue(record.heartRate),
        TextCellValue(record.category),
        TextCellValue(record.notes ?? ''),
      ]);
    }

    // Set column widths
    for (var i = 0; i < 8; i++) {
      sheet.setColumnWidth(i, 20);
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/blood_pressure_$timestamp.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    return filePath;
  }

  /// Exports all records to CSV, grouped by day and period, but without losing any record.
  Future<String> exportToCsv(List<BloodPressureRecord> records) async {
    final grouped = _groupByDayAndPeriod(records);
    final buffer = StringBuffer();

    // Header
    buffer.writeln(
        'Date,Period,Time,Systolic (mmHg),Diastolic (mmHg),Heart Rate (bpm),Category,Notes');

    // Sort dates and periods
    final sortedDates = grouped.keys.toList()..sort();
    final periodOrder = {'Morning': 0, 'Afternoon': 1, 'Night': 2};

    for (final date in sortedDates) {
      final dayRecords = grouped[date]!;
      // Sort periods by Morning → Afternoon → Night
      final sortedPeriods = dayRecords.keys.toList()
        ..sort((a, b) => periodOrder[a]!.compareTo(periodOrder[b]!));

      for (final period in sortedPeriods) {
        final recordsInPeriod = dayRecords[period]!;
        // Sort records by time
        recordsInPeriod.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        for (final record in recordsInPeriod) {
          buffer.writeln(
            '${DateFormat('yyyy-MM-dd').format(date)},'
            '$period,'
            '${DateFormat('HH:mm').format(record.timestamp)},'
            '${record.systolic},'
            '${record.diastolic},'
            '${record.heartRate},'
            '${record.category},'
            '${record.notes ?? ''}',
          );
        }
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/blood_pressure_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    return filePath;
  }
}