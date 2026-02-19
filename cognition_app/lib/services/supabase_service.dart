// lib/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/time_capsule_model.dart';

class SupabaseService {
  final client = Supabase.instance.client;
  final _uuid = const Uuid();

  // ============ 认知日志相关方法 ============

  /// 📊 获取指定日期范围内的认知日志
  Future<List<Map<String, dynamic>>> getLogsByDateRange(
    String userId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    try {
      final response = await client
          .from('cognition_logs')
          .select()
          .eq('user_id', userId)
          .gte('created_date', startDate.toIso8601String().split('T')[0])
          .lte('created_date', endDate.toIso8601String().split('T')[0])
          .order('created_date', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('获取日志失败: $e');
      return [];
    }
  }

  // ============ 时间胶囊相关方法 ============

  /// 📦 1. 创建时间胶囊
  Future<void> createTimeCapsule(TimeCapsule capsule) async {
    await client
        .from('time_capsules')
        .insert(capsule.toJson())
        .select();
  }

  /// 📦 2. 获取用户的所有时间胶囊（实时流）
  Stream<List<TimeCapsule>> getUserCapsulesStream(String userId) {
    return client
        .from('time_capsules')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('unlock_date', ascending: true)
        .map((data) {
          return (data as List)
              .map((e) => TimeCapsule.fromJson(e))
              .toList();
        });
  }

  /// 📦 3. 获取即将解锁的时间胶囊
  Future<List<TimeCapsule>> getUpcomingCapsules(String userId, {int daysAhead = 7}) async {
    final today = DateTime.now();
    final futureDate = today.add(Duration(days: daysAhead));
    
    final response = await client
        .from('time_capsules')
        .select()
        .eq('user_id', userId)
        .eq('is_opened', false)
        .lte('unlock_date', futureDate.toIso8601String().split('T')[0])
        .order('unlock_date', ascending: true);
    
    return (response as List)
        .map((e) => TimeCapsule.fromJson(e))
        .toList();
  }

  /// 📦 4. 获取单个时间胶囊详情
  Future<TimeCapsule> getTimeCapsule(String capsuleId) async {
    final response = await client
        .from('time_capsules')
        .select()
        .eq('id', capsuleId)
        .single();
    
    return TimeCapsule.fromJson(response);
  }

  /// 📦 5. 开启时间胶囊
  Future<void> openTimeCapsule(String capsuleId, {String? aiSummary}) async {
    await client
        .from('time_capsules')
        .update({
          'is_opened': true,
          'opened_at': DateTime.now().toIso8601String(),
          if (aiSummary != null) 'ai_summary': aiSummary,
        })
        .eq('id', capsuleId)
        .select();
  }

  /// 📦 6. 删除时间胶囊
  Future<void> deleteTimeCapsule(String capsuleId) async {
    await client
        .from('time_capsules')
        .delete()
        .eq('id', capsuleId);
  }

  /// 📦 7. 从认知日志创建时间胶囊
  Future<void> createCapsuleFromLogs({
    required String userId,
    required String title,
    required List<String> logIds,
    required int yearsLater,
  }) async {
    try {
      // 获取选中的日志内容
      final logsResponse = await client
          .from('cognition_logs')
          .select('content, created_date')
          .inFilter('id', logIds);
      
      final logs = logsResponse as List;
      
      // 拼接日志内容
      final content = logs.map((log) {
        final date = log['created_date'];
        final text = log['content'];
        return '[$date] $text';
      }).join('\n\n---\n\n');
      
      final capsule = TimeCapsule(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        content: content,
        unlockDate: DateTime.now().add(Duration(days: 365 * yearsLater)),
        isOpened: false,
        createdAt: DateTime.now(),
        sourceLogIds: logIds,
      );
      
      await createTimeCapsule(capsule);
    } catch (e) {
      print('创建胶囊失败: $e');
      rethrow;
    }
  }
}