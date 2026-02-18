import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/blood_pressure_record.dart';
import '../repositories/blood_pressure_repository.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final BloodPressureRepository _repo = BloodPressureRepository();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedFormat = 'Excel';
  bool _isLoading = false;
  int _recordCount = 0;

  final List<String> _formats = ['CSV', 'Excel'];
  String _selectedDestination = 'email';

  @override
  void initState() {
    super.initState();
    _updateRecordCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Export Data',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('SELECT PERIOD'),
            const SizedBox(height: 16),
            _buildDateRangeSelector(),
            const SizedBox(height: 24),
            _buildSummaryCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('EXPORT FORMAT'),
            const SizedBox(height: 16),
            _buildFormatSelector(),
            const SizedBox(height: 24),
            _buildSectionTitle('DESTINATION'),
            const SizedBox(height: 16),
            _buildDestinationSelector(),
            const SizedBox(height: 32),
            _buildExportButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF6B8A8E),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildDateButton(
            label: 'Start Date',
            date: _startDate,
            onTap: () => _pickDate(isStart: true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDateButton(
            label: 'End Date',
            date: _endDate,
            onTap: () => _pickDate(isStart: false),
          ),
        ),
      ],
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final dateStr = '${date.day.toString().padLeft(2, '0')} ${_getMonthAbbrev(date.month)}, ${date.year}';
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E33),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B8A8E),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF00D4C7), size: 16),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4C7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder_copy, color: Color(0xFF00D4C7)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_recordCount reading${_recordCount == 1 ? '' : 's'} found in this range.',
                  style: const TextStyle(
                    color: Color(0xFF6B8A8E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: _formats.map((format) {
        final isSelected = _selectedFormat == format;
        IconData icon;
        switch (format) {
          case 'PDF':
            icon = Icons.picture_as_pdf;
            break;
          case 'CSV':
            icon = Icons.table_chart;
            break;
          case 'Excel':
            icon = Icons.grid_on;
            break;
          default:
            icon = Icons.insert_drive_file;
        }
        
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedFormat = format),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00D4C7) : const Color(0xFF1A2E33),
                borderRadius: BorderRadius.circular(12),
                border: isSelected 
                    ? null 
                    : Border.all(color: const Color(0xFF2A3E44)),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? const Color(0xFF0D1B1E) : const Color(0xFF6B8A8E),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    format,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF0D1B1E) : const Color(0xFF6B8A8E),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDestinationSelector() {
    return Column(
      children: [
        _buildDestinationOption(
          icon: Icons.email_outlined,
          title: 'Email Report',
          subtitle: 'Send as PDF attachment',
          value: 'email',
        ),
        const SizedBox(height: 12),
        _buildDestinationOption(
          icon: Icons.save_alt_outlined,
          title: 'Save to Device',
          subtitle: 'Download to local storage',
          value: 'device',
        ),
      ],
    );
  }

  Widget _buildDestinationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _selectedDestination == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedDestination = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E33),
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: const Color(0xFF00D4C7))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1B1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF00D4C7)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B8A8E),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D4C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Color(0xFF0D1B1E), size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _exportData,
        icon: _isLoading 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF0D1B1E),
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.upload_file, color: Color(0xFF0D1B1E)),
        label: Text(
          _isLoading ? 'Exporting...' : 'Export & Send',
          style: const TextStyle(
            color: Color(0xFF0D1B1E),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D4C7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B1E),
        border: Border(
          top: BorderSide(color: const Color(0xFF2A3E44), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00D4C7),
        unselectedItemColor: const Color(0xFF6B8A8E),
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.pop(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Export',
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00D4C7),
              surface: Color(0xFF1A2E33),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
      await _updateRecordCount();
    }
  }

  Future<void> _updateRecordCount() async {
    final adjustedEndDate = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );
    final records = await _repo.getRecordsByDateRange(_startDate, adjustedEndDate);
    setState(() {
      _recordCount = records.length;
    });
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);

    try {
      // Adjust end date to include the entire day
      final adjustedEndDate = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        23,
        59,
        59,
      );

      final records = await _repo.getRecordsByDateRange(_startDate, adjustedEndDate);

      if (records.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No records found in selected date range'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      String filePath;
      if (_selectedFormat == 'Excel') {
        filePath = await _repo.exportToExcel(records);
      } else {
        filePath = await _repo.exportToCsv(records);
      }

      if (_selectedDestination == 'email') {
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: 'Blood Pressure Records',
          text: 'Here are my blood pressure records from ${_formatDate(_startDate)} to ${_formatDate(_endDate)}.',
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved to: $filePath'),
              backgroundColor: const Color(0xFF00D4C7),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getMonthAbbrev(int month) {
    const months = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month];
  }
}
