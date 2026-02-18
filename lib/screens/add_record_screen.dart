import 'package:flutter/material.dart';
import '../models/blood_pressure_record.dart';
import '../repositories/blood_pressure_repository.dart';

class AddRecordScreen extends StatefulWidget {
  final BloodPressureRecord? record;

  const AddRecordScreen({super.key, this.record});

  bool get isEditing => record != null;

  @override
  State<AddRecordScreen> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  late final TextEditingController _systolicController;
  late final TextEditingController _diastolicController;
  late final TextEditingController _heartRateController;
  late final TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final BloodPressureRepository _repo = BloodPressureRepository();

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    if (record != null) {
      // Editing mode - populate fields
      _systolicController = TextEditingController(text: record.systolic.toString());
      _diastolicController = TextEditingController(text: record.diastolic.toString());
      _heartRateController = TextEditingController(text: record.heartRate.toString());
      _notesController = TextEditingController(text: record.notes ?? '');
      _selectedDate = record.timestamp;
      _selectedTime = TimeOfDay.fromDateTime(record.timestamp);
    } else {
      // Adding new record
      _systolicController = TextEditingController();
      _diastolicController = TextEditingController();
      _heartRateController = TextEditingController();
      _notesController = TextEditingController();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Edit Record' : 'Add Record',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF00D4C7)),
            onPressed: _saveRecord,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('BLOOD PRESSURE (mmHg)'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Systolic',
                    controller: _systolicController,
                    hint: '120',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    label: 'Diastolic',
                    controller: _diastolicController,
                    hint: '80',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('HEART RATE'),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Pulse (bpm)',
              controller: _heartRateController,
              hint: '72',
              icon: Icons.favorite,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('TIME OF MEASUREMENT'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeButton(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateTimeButton(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _selectedTime.format(context),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('ADDITIONAL DETAILS'),
            const SizedBox(height: 16),
            _buildInputField(
              label: 'Notes (Optional)',
              controller: _notesController,
              hint: 'E.g. After morning coffee, sitting down...',
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveRecord,
                icon: const Icon(Icons.save, color: Colors.white),
                label: Text(
                  widget.isEditing ? 'Update Record' : 'Save Record',
                  style: const TextStyle(
                    color: Colors.white,
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
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF6B8A8E)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF00D4C7),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B8A8E),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: maxLines == 1 ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF6B8A8E).withOpacity(0.5)),
            filled: true,
            fillColor: const Color(0xFF1A2E33),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: icon != null 
                ? Icon(icon, color: const Color(0xFF00D4C7), size: 20)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E33),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00D4C7), size: 18),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B8A8E),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveRecord() async {
    final systolic = int.tryParse(_systolicController.text);
    final diastolic = int.tryParse(_diastolicController.text);
    final heartRate = int.tryParse(_heartRateController.text);
    final notes = _notesController.text.trim();

    if (systolic == null || diastolic == null || heartRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final timestamp = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (widget.isEditing) {
      // Update existing record
      final updatedRecord = widget.record!.copyWith(
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
        timestamp: timestamp,
        notes: notes.isEmpty ? null : notes,
      );
      await _repo.updateRecord(updatedRecord);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record updated successfully'),
            backgroundColor: Color(0xFF00D4C7),
          ),
        );
        Navigator.pop(context, true);
      }
    } else {
      // Add new record
      await _repo.addRecord(
        systolic,
        diastolic,
        heartRate,
        notes: notes.isEmpty ? null : notes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record saved successfully'),
            backgroundColor: Color(0xFF00D4C7),
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
