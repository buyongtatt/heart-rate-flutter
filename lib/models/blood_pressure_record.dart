class BloodPressureRecord {
  final int? id;
  final int systolic;
  final int diastolic;
  final int heartRate;
  final DateTime timestamp;
  final String? notes;

  BloodPressureRecord({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
    DateTime? timestamp,
    this.notes,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory BloodPressureRecord.fromMap(Map<String, dynamic> map) {
    return BloodPressureRecord(
      id: map['id'] as int?,
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      heartRate: map['heartRate'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      notes: map['notes'] as String?,
    );
  }

  BloodPressureRecord copyWith({
    int? id,
    int? systolic,
    int? diastolic,
    int? heartRate,
    DateTime? timestamp,
    String? notes,
  }) {
    return BloodPressureRecord(
      id: id ?? this.id,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      heartRate: heartRate ?? this.heartRate,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  String get bloodPressure => '$systolic/$diastolic';

  String get category {
    if (systolic < 120 && diastolic < 80) return 'Normal';
    if (systolic < 130 && diastolic < 80) return 'Elevated';
    if (systolic < 140 || diastolic < 90) return 'High BP Stage 1';
    if (systolic >= 140 || diastolic >= 90) return 'High BP Stage 2';
    if (systolic > 180 || diastolic > 120) return 'Crisis';
    return 'Unknown';
  }
}
