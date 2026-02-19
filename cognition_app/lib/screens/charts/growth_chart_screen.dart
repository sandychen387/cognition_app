// lib/screens/charts/growth_chart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chart_widgets.dart';

/// 📊 成长图谱主页面
/// 展示用户的认知复利可视化
class GrowthChartScreen extends StatefulWidget {
  const GrowthChartScreen({Key? key}) : super(key: key);

  @override
  State<GrowthChartScreen> createState() => _GrowthChartScreenScreenState();
}

class _GrowthChartScreenScreenState extends State<GrowthChartScreen> {
  // 时间范围选项
  final List<String> _timeRanges = ['7天', '30天', '90天', '1年'];
  String _selectedRange = '30天';
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final chartProvider = Provider.of<ChartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      // 根据选择的时间范围加载数据
      int days = _getDaysFromRange(_selectedRange);
      await chartProvider.loadReadingTrend(
        authProvider.currentUser!.id,
        days: days,
      );
    }
  }

  int _getDaysFromRange(String range) {
    switch (range) {
      case '7天': return 7;
      case '30天': return 30;
      case '90天': return 90;
      case '1年': return 365;
      default: return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('成长图谱'),
        actions: [
          // 时间范围选择器
          PopupMenuButton<String>(
            icon: Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() => _selectedRange = value);
              _loadData();
            },
            itemBuilder: (context) {
              return _timeRanges.map((range) {
                return PopupMenuItem(
                  value: range,
                  child: Text(range),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Consumer<ChartProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text('加载失败: ${provider.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text('重试'),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📊 1. 阅读量趋势图（我们的折线图）
                _buildChartCard(
                  title: '阅读量趋势',
                  subtitle: '你每天的思考密度',
                  chart: ReadingTrendChart(
                    dailyReadCounts: provider.dailyReadCounts,
                    showAverageLine: true,  // 显示平均水平线
                  ),
                ),
                
                SizedBox(height: 20),
                
                // 📈 2. 信心指数趋势（折线图）
                _buildChartCard(
                  title: '信心指数',
                  subtitle: '你的思维确定性变化',
                  chart: ConfidenceTrendChart(
                    dailyConfidence: provider.dailyConfidenceScores,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // 🎯 3. 认知领域分布（雷达图/饼图）
                _buildChartCard(
                  title: '认知版图',
                  subtitle: '你正在拓展的思维领域',
                  chart: CognitiveRadarChart(
                    topicData: provider.topicDistribution,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget chart,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 220,  // 图表固定高度
              child: chart,
            ),
          ],
        ),
      ),
    );
  }
}