// lib/screens/capsules/time_capsule_detail_screen.dart

import 'package:flutter/material.dart';
import '../../models/time_capsule_model.dart';

class TimeCapsuleDetailScreen extends StatelessWidget {
  final TimeCapsule capsule;

  const TimeCapsuleDetailScreen({
    Key? key,
    required this.capsule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(capsule.title),
        actions: [
          if (!capsule.isOpened && capsule.isUnlocked)
            IconButton(
              icon: Icon(Icons.mark_chat_read),
              onPressed: () {
                // 这里可以触发开启胶囊的逻辑
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 胶囊状态卡片
            Card(
              color: capsule.statusColor.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      capsule.isOpened
                          ? Icons.mark_chat_read
                          : capsule.isUnlocked
                              ? Icons.lock_open
                              : Icons.lock,
                      color: capsule.statusColor,
                      size: 32,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capsule.statusText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: capsule.statusColor,
                            ),
                          ),
                          Text(
                            '封存于 ${capsule.createdAt.year}年${capsule.createdAt.month}月${capsule.createdAt.day}日',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // AI总结（如果已开启）
            if (capsule.isOpened && capsule.aiSummary != null) ...[
              Text(
                '🤖 AI 时光对话',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    capsule.aiSummary!,
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],

            // 胶囊内容
            Text(
              capsule.isOpened ? '📝 你的思考' : '🔒 封存的内容',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  capsule.content,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            ),

            SizedBox(height: 24),

            // 解锁时间信息
            if (!capsule.isOpened)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        capsule.isUnlocked
                            ? '胶囊已到解锁时间，点击右上角开启'
                            : '将在 ${capsule.daysUntilUnlock} 天后解锁',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}