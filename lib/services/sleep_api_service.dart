import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/sleep_assessment_input.dart';
import '../models/sleep_result.dart';

/// Interface กลางที่ทุกหน้าจอเรียกใช้ (ไม่สนว่าข้างหลังเป็น Mock หรือของจริง)
///
/// วิธีสลับจาก Mock ไปของจริงเมื่อเพื่อนทำ FastAPI เสร็จ:
/// ไปที่ lib/main.dart แล้วเปลี่ยนบรรทัดเดียว จาก
///   SleepApiService api = MockSleepApiService();
/// เป็น
///   SleepApiService api = RealSleepApiService(baseUrl: 'https://...');
/// ที่เหลือทั้งแอปไม่ต้องแก้อะไรเลย เพราะทุกหน้าจอคุยผ่าน interface นี้เท่านั้น
abstract class SleepApiService {
  Future<SleepResult> predict(SleepAssessmentInput input);
}

/// ตัวปลอม ใช้ตอนที่ยังไม่มี ML model และ FastAPI จริงจากเพื่อน
///
/// หมายเหตุ (ตาม project context ข้อ 12): นี่เป็นเพียง Mock Prediction
/// ห้ามถือว่าเป็น API หรือ Feature จริง — ตรรกะข้างล่างเป็นสูตรคร่าวๆ
/// เขียนขึ้นเองฝั่ง Flutter เพื่อให้ demo ดูสมเหตุสมผล ไม่ใช่ ML จริง
class MockSleepApiService implements SleepApiService {
  @override
  Future<SleepResult> predict(SleepAssessmentInput input) async {
    // จำลองเวลาที่ API จริงต้องใช้ในการประมวลผล
    await Future.delayed(const Duration(milliseconds: 1800));

    // สูตรคร่าวๆ: นอนน้อย / เครียดมาก / ออกกำลังกายน้อย = คะแนนแย่ลง
    // age ใส่เป็น factor เล็กน้อยเพื่อให้ demo ดูมีมิติ ไม่ใช่ตรรกะจริงจากงานวิจัย
    double score = 100;
    score -= (8 - input.sleepDuration).clamp(0, 8) * 6; // นอนน้อยกว่า 8 ชม.
    score -= input.stressLevel * 3.5;
    score += (input.physicalActivity / 60).clamp(0, 2) * 8; // ออกกำลังกายช่วยได้
    if (input.age < 18 || input.age > 60) {
      score -= 4; // ช่วงอายุที่มักมีรูปแบบการนอนแปรปรวนกว่า (สมมติฐานคร่าวๆ)
    }
    score = score.clamp(5, 98);

    // ใส่ noise เล็กน้อยให้ดูเป็นธรรมชาติขึ้น ไม่ตายตัวทุกครั้ง
    score += Random().nextDouble() * 6 - 3;
    score = score.clamp(5, 98);

    final String quality;
    final String recommendation;
    if (score >= 70) {
      quality = 'Good';
      recommendation =
          'Keep up your current routine — consistency is what helps most.';
    } else if (score >= 45) {
      quality = 'Fair';
      recommendation =
          'Try winding down screens 30 minutes before bed to help you fall asleep faster.';
    } else {
      quality = 'Poor';
      recommendation =
          'Consider an earlier, more consistent bedtime and a short walk during the day.';
    }

    final factors = <String>[];
    if (input.sleepDuration < 6.5) factors.add('Short sleep duration');
    if (input.stressLevel >= 7) factors.add('High stress level');
    if (input.physicalActivity < 20) factors.add('Low physical activity');
    if (factors.isEmpty) factors.add('No major risk factors found');

    return SleepResult(
      quality: quality,
      confidence: (score / 100),
      factors: factors,
      recommendation: recommendation,
      timestamp: DateTime.now(),
      input: input,
    );
  }
}

/// ของจริง ใช้เมื่อเพื่อนทำ FastAPI + ML model เสร็จแล้ว
///
/// ตอนนี้ยังไม่ต้องใช้ไฟล์นี้เลย แค่เตรียมโครงไว้ล่วงหน้าตาม API contract
/// เบื้องต้นใน project context (ข้อ 14) — ต้องปรับ endpoint/field ให้ตรงกับ
/// ของจริงที่เพื่อนส่งมาอีกที ห้ามถือว่า path หรือ field พวกนี้ final
class RealSleepApiService implements SleepApiService {
  final String baseUrl; // เช่น 'https://your-fastapi-server.com'

  RealSleepApiService({required this.baseUrl});

  @override
  Future<SleepResult> predict(SleepAssessmentInput input) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return SleepResult.fromJson(json, input: input);
    } else {
      throw Exception(
          'Prediction request failed (status ${response.statusCode})');
    }
  }
}
