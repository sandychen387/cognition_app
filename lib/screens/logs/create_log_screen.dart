// lib/screens/logs/create_log_screen.dart

import 'package:flutter/material.dart';
import '../../models/book_model.dart';

// 添加 LogType 类型定义
typedef LogType = String;

class CreateLogScreen extends StatefulWidget {
  final LogType? presetType;
  final Book? relatedBook;
  
  const CreateLogScreen({
    Key? key,
    this.presetType,
    this.relatedBook,
  }) : super(key: key);

  @override
  State<CreateLogScreen> createState() => _CreateLogScreenState();
}

class _CreateLogScreenState extends State<CreateLogScreen> {
  final _formKey = GlobalKey<FormState>();
  String _logType = 'post_read';
  String _content = '';
  List<String> _tags = [];
  String _emotion = 'calm';
  int _confidence = 3;
  
  String get _promptText {
    switch (_logType) {
      case 'pre_read':
        return '阅读前：你对这本书有什么期待？想解决什么问题？';
      case 'during_read':
        return '阅读中：哪段话触动了你？你的联想是什么？';
      case 'post_read':
        return '阅读后：这本书改变了你哪个认知？';
      case 'action':
        return '行动记录：你应用了什么知识？结果如何？';
      default:
        return '记录你的思考...';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('认知日志'),
        backgroundColor: widget.relatedBook != null ? Colors.blue : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 日志类型选择器
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'pre_read', label: Text('读前')),
                ButtonSegment(value: 'during_read', label: Text('读中')),
                ButtonSegment(value: 'post_read', label: Text('读后')),
                ButtonSegment(value: 'action', label: Text('行动')),
              ],
              selected: {_logType},
              onSelectionChanged: (Set<String> selected) {
                setState(() => _logType = selected.first);
              },
            ),
            const SizedBox(height: 16),
            
            // 相关书籍提示
            if (widget.relatedBook != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.book, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '关联书籍：${widget.relatedBook!.title}',
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // 引导文案
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Text(
                _promptText,
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
            const SizedBox(height: 16),
            
            // 思考内容输入
            TextFormField(
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '写下你的思考...',
                border: OutlineInputBorder(),
              ),
              onSaved: (val) => _content = val ?? '',
            ),
            const SizedBox(height: 16),
            
            // 情绪状态选择
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('😊 平静'),
                  selected: _emotion == 'calm',
                  onSelected: (_) => setState(() => _emotion = 'calm'),
                ),
                ChoiceChip(
                  label: const Text('🤔 好奇'),
                  selected: _emotion == 'curious',
                  onSelected: (_) => setState(() => _emotion = 'curious'),
                ),
                ChoiceChip(
                  label: const Text('💡 顿悟'),
                  selected: _emotion == 'insight',
                  onSelected: (_) => setState(() => _emotion = 'insight'),
                ),
                ChoiceChip(
                  label: const Text('😌 满足'),
                  selected: _emotion == 'content',
                  onSelected: (_) => setState(() => _emotion = 'content'),
                ),
                ChoiceChip(
                  label: const Text('😤 困惑'),
                  selected: _emotion == 'confused',
                  onSelected: (_) => setState(() => _emotion = 'confused'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 信心指数滑动条
            Text('信心指数：$_confidence'),
            Slider(
              value: _confidence.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => _confidence = v.round()),
            ),
            
            const SizedBox(height: 16),
            
            // 标签输入
            TextField(
              decoration: const InputDecoration(
                labelText: '标签（用逗号分隔）',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _tags = value.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
                });
              },
            ),
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveLog,
              child: const Text('保存认知记录'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveLog() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      // TODO: 保存到数据库
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('认知日志已保存')),
      );
    }
  }
}