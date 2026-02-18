import 'package:flutter/material.dart';
import '../models/blood_pressure_record.dart';
import '../repositories/blood_pressure_repository.dart';
import 'record_detail_screen.dart';
import 'add_record_screen.dart';
import 'export_screen.dart';

class RecordsListScreen extends StatefulWidget {
  const RecordsListScreen({super.key});

  @override
  State<RecordsListScreen> createState() => _RecordsListScreenState();
}

class _RecordsListScreenState extends State<RecordsListScreen> {
  final BloodPressureRepository _repo = BloodPressureRepository();
  List<BloodPressureRecord> _records = [];
  List<BloodPressureRecord> _filteredRecords = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await _repo.getAllRecords();
    setState(() {
      _records = records;
      _filteredRecords = records;
      _isLoading = false;
    });
  }

  void _filterRecords() {
    setState(() {
      _filteredRecords = _records.where((record) {
        final matchesSearch = _searchQuery.isEmpty ||
            record.bloodPressure.contains(_searchQuery) ||
            record.heartRate.toString().contains(_searchQuery);
        
        if (!matchesSearch) return false;
        
        final now = DateTime.now();
        switch (_selectedFilter) {
          case 'Last 7 days':
            return record.timestamp.isAfter(now.subtract(const Duration(days: 7)));
          case 'Last 30 days':
            return record.timestamp.isAfter(now.subtract(const Duration(days: 30)));
          case 'Last 3 months':
            return record.timestamp.isAfter(now.subtract(const Duration(days: 90)));
          default:
            return true;
        }
      }).toList();
    });
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
        title: const Row(
          children: [
            Icon(Icons.folder_copy_outlined, color: Color(0xFF00D4C7), size: 20),
            SizedBox(width: 8),
            Text(
              'Records',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF00D4C7)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExportScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildFilterChips(),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4C7)))
                : _filteredRecords.isEmpty
                    ? _buildEmptyState()
                    : _buildRecordsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordScreen()),
          );
          _loadRecords();
        },
        backgroundColor: const Color(0xFF00D4C7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterRecords();
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search by date or note...',
          hintStyle: TextStyle(color: const Color(0xFF6B8A8E).withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B8A8E)),
          filled: true,
          fillColor: const Color(0xFF1A2E33),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Last 7 days', 'Last 30 days', 'Last 3 months'];
    
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
                _filterRecords();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00D4C7) : const Color(0xFF1A2E33),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF0D1B1E) : const Color(0xFF6B8A8E),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: const Color(0xFF6B8A8E).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: TextStyle(
              color: const Color(0xFF6B8A8E).withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList() {
    final groupedRecords = _groupRecordsByDate();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: groupedRecords.length,
      itemBuilder: (context, index) {
        final group = groupedRecords[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 8),
              child: Text(
                group['title'] as String,
                style: const TextStyle(
                  color: Color(0xFF6B8A8E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...(group['records'] as List<BloodPressureRecord>)
                .map((record) => _buildRecordCard(record)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _groupRecordsByDate() {
    final groups = <String, List<BloodPressureRecord>>{};
    final now = DateTime.now();
    
    for (final record in _filteredRecords) {
      final date = record.timestamp;
      String title;
      
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        title = 'TODAY, ${_getMonthAbbrev(date.month)} ${date.day}';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        title = 'YESTERDAY, ${_getMonthAbbrev(date.month)} ${date.day}';
      } else {
        title = '${_getMonthAbbrev(date.month)} ${date.day}';
      }
      
      groups.putIfAbsent(title, () => []).add(record);
    }
    
    return groups.entries.map((e) => {
      'title': e.key,
      'records': e.value,
    }).toList();
  }

  Widget _buildRecordCard(BloodPressureRecord record) {
    final timeStr = '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}';
    
    Color statusColor;
    if (record.category == 'Normal') {
      statusColor = const Color(0xFF00D4C7);
    } else if (record.category == 'Elevated') {
      statusColor = Colors.yellow;
    } else {
      statusColor = Colors.red;
    }
    
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecordDetailScreen(record: record),
          ),
        );
        _loadRecords();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2E33),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A3E44), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${record.systolic}/${record.diastolic} mmHg',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.favorite, color: statusColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${record.heartRate} bpm',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          color: Color(0xFF6B8A8E),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExportScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_outlined),
            label: 'Export',
          ),
        ],
      ),
    );
  }

  String _getMonthAbbrev(int month) {
    const months = ['', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 
                    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month];
  }
}
