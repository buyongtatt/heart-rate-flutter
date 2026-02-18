import 'package:flutter/material.dart';
import '../models/blood_pressure_record.dart';
import '../repositories/blood_pressure_repository.dart';
import '../services/dashboard_service.dart';
import '../services/user_preferences_service.dart';
import 'add_record_screen.dart';
import 'records_list_screen.dart';
import 'export_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final BloodPressureRepository _repo = BloodPressureRepository();
  final UserPreferencesService _prefs = UserPreferencesService.instance;
  List<BloodPressureRecord> _records = [];
  DashboardStats? _stats;
  bool _isLoading = true;
  String _userName = 'Alex Johnson';

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    await _prefs.init();
    setState(() {
      _userName = _prefs.userName;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final records = await _repo.getAllRecords();
    final stats = _repo.getStats(records);
    setState(() {
      _records = records;
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentRecords = _repo.getRecentRecords(_records, limit: 3);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4C7)))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF00D4C7),
                backgroundColor: const Color(0xFF1A2E33),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildAverageBPCard(),
                        const SizedBox(height: 20),
                        _buildStatsRow(),
                        const SizedBox(height: 24),
                        _buildHealthStatus(),
                        const SizedBox(height: 24),
                        _buildRecentRecordsSection(recentRecords),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordScreen()),
          );
          _loadData();
        },
        backgroundColor: const Color(0xFF00D4C7),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Record', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _showEditNameDialog,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WELCOME BACK',
                style: TextStyle(
                  color: Color(0xFF6B8A8E),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.edit,
                    color: Color(0xFF6B8A8E),
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _showEditNameDialog,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00D4C7), width: 2),
            ),
            child: const Icon(Icons.person, color: Color(0xFF00D4C7)),
          ),
        ),
      ],
    );
  }

  void _showEditNameDialog() {
    final textController = TextEditingController(text: _userName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2E33),
        title: const Text(
          'Edit Your Name',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: Color(0xFF6B8A8E)),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF2A3E44)),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF00D4C7)),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B8A8E)),
            ),
          ),
          TextButton(
            onPressed: () async {
              final newName = textController.text.trim();
              if (newName.isNotEmpty) {
                await _prefs.setUserName(newName);
                setState(() {
                  _userName = newName;
                });
              }
              Navigator.pop(context);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: Color(0xFF00D4C7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageBPCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2E33), Color(0xFF0D1B1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3E44), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AVERAGE BLOOD PRESSURE',
                style: TextStyle(
                  color: Color(0xFF6B8A8E),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4C7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_down, color: Color(0xFF00D4C7), size: 14),
                    SizedBox(width: 4),
                    Text(
                      '2% lower',
                      style: TextStyle(
                        color: Color(0xFF00D4C7),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _records.isNotEmpty 
                    ? '${_stats?.avgSystolic.toStringAsFixed(0)}/${_stats?.avgDiastolic.toStringAsFixed(0)}'
                    : '---/--',
                style: const TextStyle(
                  color: Color(0xFF00D4C7),
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'mmHg',
                  style: TextStyle(
                    color: Color(0xFF6B8A8E),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'than last week',
            style: TextStyle(
              color: Color(0xFF6B8A8E),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'AVG HEART RATE',
            _records.isNotEmpty ? '${_stats?.avgHeartRate.toStringAsFixed(0)}' : '--',
            'bpm',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'TOTAL READINGS',
            '${_stats?.totalRecords ?? 0}',
            'records',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A3E44), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B8A8E),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFF6B8A8E),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatus() {
    final status = _stats != null ? _repo.getHealthStatus(_stats!) : 'Unknown';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3E44), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF00D4C7).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF00D4C7),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Health Status: Optimal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your BP is in the $status range. Keep maintaining your current routine.',
                  style: const TextStyle(
                    color: Color(0xFF6B8A8E),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRecordsSection(List<BloodPressureRecord> records) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Records',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RecordsListScreen()),
                );
              },
              child: const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF00D4C7),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2E33),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No records yet',
                style: TextStyle(color: Color(0xFF6B8A8E)),
              ),
            ),
          )
        else
          ...records.map((record) => _buildRecordItem(record)),
      ],
    );
  }

  Widget _buildRecordItem(BloodPressureRecord record) {
    final dateStr = '${record.timestamp.day.toString().padLeft(2, '0')}';
    final monthStr = _getMonthAbbrev(record.timestamp.month);
    final timeStr = '${record.timestamp.hour.toString().padLeft(2, '0')}:${record.timestamp.minute.toString().padLeft(2, '0')}';
    
    return Container(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Color(0xFF00D4C7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  monthStr,
                  style: const TextStyle(
                    color: Color(0xFF6B8A8E),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today, $timeStr AM',
                  style: const TextStyle(
                    color: Color(0xFF6B8A8E),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Manual entry',
                  style: TextStyle(
                    color: Color(0xFF4A5E64),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${record.systolic}/${record.diastolic}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'mmHg',
            style: TextStyle(
              color: Color(0xFF6B8A8E),
              fontSize: 11,
            ),
          ),
        ],
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecordsListScreen()),
            );
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
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_outlined),
            activeIcon: Icon(Icons.download),
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
