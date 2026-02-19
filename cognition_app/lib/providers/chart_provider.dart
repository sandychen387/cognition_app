// lib/providers/chart_provider.dart

import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class ChartProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  
  // 缓存数据
  Map<DateTime, int> _dailyReadCounts = {};
  Map<DateTime, double> _dailyConfidenceScores = {};
  Map<String, int> _topicDistribution = {};
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  Map<DateTime, int> get dailyReadCounts => _dailyReadCounts;
  Map<DateTime, double> get dailyConfidenceScores => _dailyConfidenceScores;
  Map<String, int> get topicDistribution => _topicDistribution;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 📊 获取阅读量趋势数据（从Supabase）
  Future<void> loadReadingTrend(String userId, {int days = 30}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      // 从数据库获取用户的认知日志
      final logs = await _supabaseService.getLogsByDateRange(
        userId,
        startDate,
        endDate,
      );
      
      // 按日期统计阅读量
      final Map<DateTime, int> counts = {};
      
      // 初始化日期范围（确保没有空缺）
      for (int i = 0; i <= days; i++) {
        final date = startDate.add(Duration(days: i));
        counts[DateTime(date.year, date.month, date.day)] = 0;
      }
      
      // 统计实际数据
      for (var log in logs) {
        // 从日志中提取日期
        final dateStr = log['created_date'] as String?;
        if (dateStr != null) {
          final date = DateTime.parse(dateStr);
          final dateKey = DateTime(date.year, date.month, date.day);
          counts[dateKey] = (counts[dateKey] ?? 0) + 1;
        }
      }
      
      _dailyReadCounts = counts;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('加载阅读趋势失败: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// 📈 加载信心指数趋势
  Future<void> loadConfidenceTrend(String userId, {int days = 30}) async {
    // TODO: 实现信心指数趋势
    _isLoading = true;
    notifyListeners();
    
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final logs = await _supabaseService.getLogsByDateRange(
        userId,
        startDate,
        endDate,
      );
      
      final Map<DateTime, double> confidenceScores = {};
      
      for (var log in logs) {
        final dateStr = log['created_date'] as String?;
        final confidence = log['confidence_level'] as int?;
        
        if (dateStr != null && confidence != null) {
          final date = DateTime.parse(dateStr);
          final dateKey = DateTime(date.year, date.month, date.day);
          confidenceScores[dateKey] = confidence.toDouble();
        }
      }
      
      _dailyConfidenceScores = confidenceScores;
    } catch (e) {
      debugPrint('加载信心指数失败: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// 🎯 加载主题偏向分布
  Future<void> loadTopicDistribution(String userId, {int days = 30}) async {
    // TODO: 实现主题分布
    _isLoading = true;
    notifyListeners();
    
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final logs = await _supabaseService.getLogsByDateRange(
        userId,
        startDate,
        endDate,
      );
      
      final Map<String, int> topics = {};
      
      for (var log in logs) {
        final tags = log['tags'] as List?;
        if (tags != null) {
          for (var tag in tags) {
            final tagStr = tag.toString();
            topics[tagStr] = (topics[tagStr] ?? 0) + 1;
          }
        }
      }
      
      _topicDistribution = topics;
    } catch (e) {
      debugPrint('加载主题分布失败: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// 清除数据
  void clear() {
    _dailyReadCounts = {};
    _dailyConfidenceScores = {};
    _topicDistribution = {};
    notifyListeners();
  }
}