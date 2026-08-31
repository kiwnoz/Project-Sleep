import 'sleep_assessment_input.dart';

/// ผลลัพธ์การประเมินคุณภาพการนอน 1 ครั้ง
///
/// เก็บทั้งผลจาก model (quality, confidence, factors, recommendation)
/// และข้อมูล input ที่ใช้ทำนายไว้ด้วย เพื่อเอาไปแสดงกราฟ/ประวัติย้อนหลังได้
class SleepResult {
  final String quality; // 'Good' | 'Fair' | 'Poor' (ตรงกับ label จาก model)
  final double? confidence; // 0.0 - 1.0, เผื่อ model ไม่ส่งค่านี้มาก็ได้ (nullable)
  final List<String> factors; // ปัจจัยที่สัมพันธ์กับผลลัพธ์ (ไม่ใช่สาเหตุ/การวินิจฉัย)
  final String recommendation; // คำแนะนำทั่วไปเกี่ยวกับ sleep hygiene
  final DateTime timestamp;
  final SleepAssessmentInput input;

  const SleepResult({
    required this.quality,
    required this.confidence,
    required this.factors,
    required this.recommendation,
    required this.timestamp,
    required this.input,
  });

  /// คะแนน 0-100 ไว้ใช้วาดกราฟ/gauge เท่านั้น เป็นการแปลงจาก quality
  /// แบบคร่าวๆ ฝั่ง Flutter เอง ไม่ใช่คะแนนที่ model คำนวณมา
  int get displayScore {
    if (confidence != null) return (confidence! * 100).round();
    switch (quality.toLowerCase()) {
      case 'good':
        return 85;
      case 'fair':
        return 60;
      case 'poor':
        return 30;
      default:
        return 50;
    }
  }

  factory SleepResult.fromJson(
    Map<String, dynamic> json, {
    required SleepAssessmentInput input,
  }) {
    return SleepResult(
      quality: json['sleep_quality'] as String? ?? 'Fair',
      confidence: (json['confidence'] as num?)?.toDouble(),
      factors: (json['factors'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      recommendation: json['recommendation'] as String? ??
          'Try keeping a consistent sleep schedule.',
      timestamp: DateTime.now(),
      input: input,
    );
  }

  /// เก็บ/อ่านจาก local storage (SharedPreferences) สำหรับหน้า History/Home
  Map<String, dynamic> toStorageJson() => {
        'quality': quality,
        'confidence': confidence,
        'factors': factors,
        'recommendation': recommendation,
        'timestamp': timestamp.toIso8601String(),
        'sleep_duration': input.sleepDuration,
        'stress_level': input.stressLevel,
        'physical_activity': input.physicalActivity,
        'age': input.age,
        'gender': input.gender,
      };

  factory SleepResult.fromStorageJson(Map<String, dynamic> json) {
    return SleepResult(
      quality: json['quality'] as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
      factors: (json['factors'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      recommendation: json['recommendation'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      input: SleepAssessmentInput(
        sleepDuration: (json['sleep_duration'] as num).toDouble(),
        stressLevel: json['stress_level'] as int,
        physicalActivity: json['physical_activity'] as int,
        age: json['age'] as int,
        gender: json['gender'] as String,
      ),
    );
  }
}
