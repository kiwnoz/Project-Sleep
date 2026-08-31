import 'package:flutter/material.dart';

/// ตัวสังเกตการณ์กลาง ใช้บอก HomeScreen ว่า "กลับมาโผล่บนจอแล้วนะ"
/// ทุกครั้งที่มีหน้าจออื่นถูก pop ออกแล้วเจอ Home อีกครั้ง
/// (ใช้แก้ปัญหาที่ Home ไม่รีเฟรชข้อมูลหลังทำ assessment เสร็จ)
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
