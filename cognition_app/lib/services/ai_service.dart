// lib/services/ai_service.dart

import 'package:ai_providers/ai_providers.dart';

class AIService {
  static bool _initialized = false;
  
  // 🔴 修复：添加初始化方法
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await AI.initialize();
      await AI.setModel('gemini', 'gemini-1.5-flash', AICapability.textGeneration);
      _initialized = true;
    }
  }

  /// 🤖 生成时间胶囊总结（过去与现在的对话）
  Future<String> generateCapsuleSummary(String pastContent, DateTime pastDate) async {
    await _ensureInitialized();  // ✅ 确保已初始化
    
    final prompt = '''
    这是用户在${pastDate.year}年${pastDate.month}月写下的思考：
    
    "$pastContent"
    
    请以"给${pastDate.year}年的自己"为题，生成一段温暖的总结：
    1. 提炼当时的核心困惑/思考
    2. 现在的你可以如何回应当时的自己
    3. 看到了怎样的成长
    
    语气温暖、鼓励，200字左右。
    ''';
   
       // 认知盲区提示（付费功能）
  Future<String> identifyBlindSpots(List<String> userTags) async {
    final prompt = '''
    用户经常思考的领域：${userTags.join('、')}
    请推荐3个可能被忽略但相关的认知领域，并简述为什么值得探索。
    ''';
    final response = await AI.text(prompt);
    return response.text ?? '';
  }

    try {
      final response = await AI.text(prompt);
      return response.text ?? '时间会见证成长，感谢曾经的记录。';
    } catch (e) {
      return '无法生成总结：$e';
    }
  }

}
  
