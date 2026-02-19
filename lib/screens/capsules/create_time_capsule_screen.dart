// lib/screens/capsules/create_time_capsule_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/capsule_provider.dart';
import '../../providers/auth_provider.dart';

class CreateTimeCapsuleScreen extends StatefulWidget {
  const CreateTimeCapsuleScreen({Key? key}) : super(key: key);

  @override
  State<CreateTimeCapsuleScreen> createState() => _CreateTimeCapsuleScreenState();
}

class _CreateTimeCapsuleScreenState extends State<CreateTimeCapsuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int _selectedYears = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('创建时间胶囊')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '胶囊标题',
                hintText: '例如：给5年后的自己',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? '请输入标题' : null,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: '封存内容',
                hintText: '写下你想对未来的自己说的话...',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v?.isEmpty == true ? '请输入内容' : null,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedYears,
              decoration: InputDecoration(
                labelText: '解锁时间',
                border: OutlineInputBorder(),
              ),
              items: [1, 3, 5, 10].map((years) {
                return DropdownMenuItem(
                  value: years,
                  child: Text('$years 年后'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedYears = v!),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCapsule,
              child: Text('封存胶囊'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCapsule() async {
    if (_formKey.currentState?.validate() != true) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) return;
    
    final success = await capsuleProvider.createCapsule(
      userId: authProvider.currentUser!.id,
      title: _titleController.text,
      content: _contentController.text,
      years: _selectedYears,
    );
    
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('时间胶囊已封存')),
      );
    }
  }
}