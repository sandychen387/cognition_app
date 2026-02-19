// lib/providers/capsule_provider.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/supabase_service.dart';
import '../services/ai_service.dart';
import '../models/time_capsule_model.dart';

class CapsuleProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final AIService _aiService = AIService();
  final _uuid = Uuid();
  
  List<TimeCapsule> _capsules = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<TimeCapsule> get capsules => _capsules;
  Stream<List<TimeCapsule>> get capsulesStream {
    if (_capsules.isEmpty) {
      return Stream.value([]);  // 返回空流
    }
    return Stream.value(_capsules);  // 实际应该从Supabase获取，这里简化处理
  }
  List<TimeCapsule> get unopenedCapsules => 
      _capsules.where((c) => !c.isOpened).toList();
  List<TimeCapsule> get openedCapsules => 
      _capsules.where((c) => c.isOpened).toList();
  List<TimeCapsule> get unlockedCapsules => 
      _capsules.where((c) => c.isUnlocked && !c.isOpened).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 📦 初始化 - 开始监听胶囊流
  void init(String userId) {
    _supabaseService.getUserCapsulesStream(userId).listen((capsules) {
      _capsules = capsules;
      notifyListeners();
    });
  }

  /// 📦 创建新胶囊
  Future<bool> createCapsule({
    required String userId,
    required String title,
    required String content,
    required int years,
    List<String>? sourceLogIds,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final capsule = TimeCapsule(
        id: _uuid.v4(),
        userId: userId,
        title: title,
        content: content,
        unlockDate: DateTime.now().add(Duration(days: 365 * years)),
        isOpened: false,
        createdAt: DateTime.now(),
        sourceLogIds: sourceLogIds,
      );
      
      await _supabaseService.createTimeCapsule(capsule);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📦 开启胶囊（带AI总结）
  Future<void> openCapsule(TimeCapsule capsule) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // 调用AI生成"过去与现在的对话"
      final aiSummary = await _aiService.generateCapsuleSummary(
        capsule.content,
        capsule.createdAt,
      );
      
      await _supabaseService.openTimeCapsule(
        capsule.id,
        aiSummary: aiSummary,
      );
      
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 📦 检查并提醒即将解锁的胶囊
  Future<List<TimeCapsule>> checkUpcomingCapsules(String userId) async {
    return await _supabaseService.getUpcomingCapsules(userId);
  }

  /// 📦 清理错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}