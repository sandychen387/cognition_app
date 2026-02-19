// lib/models/time_capsule_model.dart
import 'package:flutter/material.dart'; 
import 'package:flutter/foundation.dart';

/// 📦 时间胶囊模型
/// 对应Supabase数据库中的time_capsules表
@immutable
class TimeCapsule {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime unlockDate;
  final bool isOpened;
  final DateTime? openedAt;
  final String? aiSummary;
  final DateTime createdAt;
  final List<String>? sourceLogIds; // 关联的认知日志ID列表

  const TimeCapsule({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.unlockDate,
    required this.isOpened,
    this.openedAt,
    this.aiSummary,
    required this.createdAt,
    this.sourceLogIds,
  });

  /// 从JSON创建模型（从Supabase查询结果转换）
  factory TimeCapsule.fromJson(Map<String, dynamic> json) {
    return TimeCapsule(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      unlockDate: DateTime.parse(json['unlock_date'] as String),
      isOpened: json['is_opened'] as bool,
      openedAt: json['opened_at'] != null 
          ? DateTime.parse(json['opened_at'] as String) 
          : null,
      aiSummary: json['ai_summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      sourceLogIds: json['source_log_ids'] != null
          ? List<String>.from(json['source_log_ids'] as List)
          : null,
    );
  }

  /// 转换为JSON（用于插入数据库）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'unlock_date': unlockDate.toIso8601String().split('T')[0],
      'is_opened': isOpened,
      'opened_at': openedAt?.toIso8601String(),
      'ai_summary': aiSummary,
      'created_at': createdAt.toIso8601String(),
      'source_log_ids': sourceLogIds,
    };
  }

  /// 计算剩余天数
  int get daysUntilUnlock {
    final now = DateTime.now();
    return unlockDate.difference(now).inDays;
  }

  /// 是否已解锁
  bool get isUnlocked => unlockDate.isBefore(DateTime.now()) && !isOpened;

  /// 胶囊状态描述
  String get statusText {
    if (isOpened) return '已开启';
    if (unlockDate.isBefore(DateTime.now())) return '待开启';
    return '${daysUntilUnlock}天后解锁';
  }

  /// 胶囊状态颜色
  Color get statusColor {
    if (isOpened) return Colors.green;
    if (unlockDate.isBefore(DateTime.now())) return Colors.orange; 
    return Colors.grey;
  }
}