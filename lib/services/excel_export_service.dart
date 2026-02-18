import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/blood_pressure_record.dart';

class ExcelExportService {
  static final ExcelExportService instance = ExcelExportService._init();
  
  ExcelExportService._init();

  Future<String> exportToExcel(List<BloodPressureRecord> records) async {
    final excel = Excel.createExcel();
    final sheet = excel['Blood Pressure Records'];

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    sheet.appendRow([
      TextCellValue('Date/Time'),
      TextCellValue('Systolic (mmHg)'),
      TextCellValue('Diastolic (mmHg)'),
      TextCellValue('Heart Rate (bpm)'),
      TextCellValue('Category'),
      TextCellValue('Notes'),
    ]);

    for (final record in records) {
      sheet.appendRow([
        TextCellValue(dateFormat.format(record.timestamp)),
        IntCellValue(record.systolic),
        IntCellValue(record.diastolic),
        IntCellValue(record.heartRate),
        TextCellValue(record.category),
        TextCellValue(record.notes ?? ''),
      ]);
    }

    for (var i = 0; i < 6; i++) {
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
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final buffer = StringBuffer();
    
    buffer.writeln('Date/Time,Systolic (mmHg),Diastolic (mmHg),Heart Rate (bpm),Category,Notes');

    for (final record in records) {
      buffer.writeln(
        '${dateFormat.format(record.timestamp)},'
        '${record.systolic},'
        '${record.diastolic},'
        '${record.heartRate},'
        '${record.category},'
        '${record.notes ?? ''}'
      );
    }

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/blood_pressure_$timestamp.csv';
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    return filePath;
  }
}
