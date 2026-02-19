// lib/widgets/chart_widgets.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// ========================================================
/// 1. 📊 阅读量趋势图（折线图）- 简化版
/// ========================================================
class ReadingTrendChart extends StatelessWidget {
  final Map<DateTime, int> dailyReadCounts;
  final bool showAverageLine;

  const ReadingTrendChart({
    Key? key,
    required this.dailyReadCounts,
    this.showAverageLine = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dailyReadCounts.isEmpty) {
      return Center(
        child: Text(
          '暂无阅读数据\n开始记录你的第一条认知日志吧',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                if (date.day % 3 != 0) return Container();
                return Text('${date.month}/${date.day}');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        gridData: FlGridData(show: true),

        borderData: FlBorderData(show: true),

        lineBarsData: [
          LineChartBarData(
            spots: _generateSpots(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
          ),
        ],

        minX: _getMinDate().millisecondsSinceEpoch.toDouble(),
        maxX: _getMaxDate().millisecondsSinceEpoch.toDouble(),
        minY: 0,
        maxY: _getMaxY(),

        // ✅ 完全移除lineTouchData，使用默认值
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    final sortedEntries = dailyReadCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sortedEntries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();
  }

  DateTime _getMinDate() {
    if (dailyReadCounts.isEmpty) return DateTime.now().subtract(const Duration(days: 30));
    return dailyReadCounts.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime _getMaxDate() {
    if (dailyReadCounts.isEmpty) return DateTime.now();
    return dailyReadCounts.keys.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  double _getMaxY() {
    if (dailyReadCounts.isEmpty) return 10;
    final max = dailyReadCounts.values.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).toDouble();
  }
}

/// ========================================================
/// 2. 📈 信心指数趋势图（折线图）- 简化版
/// ========================================================
class ConfidenceTrendChart extends StatelessWidget {
  final Map<DateTime, double> dailyConfidence;

  const ConfidenceTrendChart({
    Key? key,
    required this.dailyConfidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (dailyConfidence.isEmpty) {
      return Center(
        child: Text(
          '暂无信心指数数据',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                if (date.day % 3 != 0) return Container();
                return Text('${date.month}/${date.day}');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        gridData: FlGridData(show: true),

        borderData: FlBorderData(show: true),

        lineBarsData: [
          LineChartBarData(
            spots: _generateSpots(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
          ),
        ],

        minY: 0,
        maxY: 5,
      ),
    );
  }

  List<FlSpot> _generateSpots() {
    final sortedEntries = dailyConfidence.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sortedEntries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value.toDouble(),
      );
    }).toList();
  }
}

/// ========================================================
/// 3. 🎯 认知领域雷达图 - 极简版
/// ========================================================
class CognitiveRadarChart extends StatelessWidget {
  final Map<String, int> topicData;

  const CognitiveRadarChart({
    Key? key,
    required this.topicData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topicData.isEmpty) {
      return Center(
        child: Text(
          '暂无认知领域数据',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final topics = topicData.keys.toList();
    final values = topicData.values.map((v) => v.toDouble()).toList();
    final maxValue = values.isEmpty ? 10.0 : values.reduce((a, b) => a > b ? a : b);

    // ✅ 极简版：只用基本配置
    return RadarChart(
      RadarChartData(
        dataSets: [
          RadarDataSet(
            fillColor: Colors.purple.withOpacity(0.2),
            borderColor: Colors.purple,
            dataEntries: values.map((v) => RadarEntry(value: v / maxValue * 100)).toList(),
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        radarBorderData: BorderSide(color: Colors.grey.shade300),
        radarShape: RadarShape.polygon,
        tickCount: 5,
        // 移除所有可能有问题的参数
        getTitle: (index, angle) {
          return RadarChartTitle(
            text: topics[index],
            angle: angle,
          );
        },
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
    );
  }
}

/// ========================================================
/// 4. 🎨 图表卡片容器（复用）
/// ========================================================
class ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget chart;
  final VoidCallback? onTap;
  
  const ChartCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.chart,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: chart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}