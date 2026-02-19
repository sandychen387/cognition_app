// lib/screens/capsules/time_capsule_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/capsule_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/time_capsule_model.dart';
import 'create_time_capsule_screen.dart';
import 'time_capsule_detail_screen.dart';  // ✅ 现在这个文件存在了

/// 📦 时间胶囊列表页
class TimeCapsuleListScreen extends StatefulWidget {
  const TimeCapsuleListScreen({Key? key}) : super(key: key);

  @override
  State<TimeCapsuleListScreen> createState() => _TimeCapsuleListScreenState();
}

class _TimeCapsuleListScreenState extends State<TimeCapsuleListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        capsuleProvider.init(authProvider.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('时间胶囊'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTimeCapsuleScreen(),  // ✅ 现在这个文件存在了
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CapsuleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.capsules.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          final capsules = provider.capsules;
              
          if (capsules.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: capsules.length,
            itemBuilder: (context, index) {
              final capsule = capsules[index];
              final isUnlocked = capsule.unlockDate.isBefore(DateTime.now());
              
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: capsule.statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      capsule.isOpened 
                        ? Icons.mark_chat_read
                        : isUnlocked 
                          ? Icons.lock_open 
                          : Icons.lock,
                      color: capsule.statusColor,
                    ),
                  ),
                  title: Text(
                    capsule.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        capsule.statusText,
                        style: TextStyle(
                          color: capsule.statusColor,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '封存于 ${capsule.createdAt.year}.${capsule.createdAt.month}',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: capsule.isUnlocked && !capsule.isOpened
                      ? ElevatedButton(
                          onPressed: () => _openCapsule(context, capsule),
                          child: Text('开启'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        )
                      : capsule.isOpened
                          ? Icon(Icons.chevron_right)
                          : null,
                  onTap: capsule.isOpened || capsule.isUnlocked
                      ? () => _navigateToDetail(context, capsule)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_clock,
            size: 80,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            '还没有时间胶囊',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '给未来的自己写一封信\n1年、3年、5年、10年后开启',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTimeCapsuleScreen(),
                ),
              );
            },
            icon: Icon(Icons.add),
            label: Text('创建第一个胶囊'),
          ),
        ],
      ),
    );
  }

  void _openCapsule(BuildContext context, TimeCapsule capsule) async {
    final provider = Provider.of<CapsuleProvider>(context, listen: false);
    await provider.openCapsule(capsule);
    
    if (mounted) {
      _navigateToDetail(context, capsule);
    }
  }

  void _navigateToDetail(BuildContext context, TimeCapsule capsule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeCapsuleDetailScreen(capsule: capsule),
      ),
    );
  }
}