import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AddMagazineScreen extends StatefulWidget {
  const AddMagazineScreen({super.key});

  @override
  State<AddMagazineScreen> createState() => _AddMagazineScreenState();
}

class _AddMagazineScreenState extends State<AddMagazineScreen> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _copiesController = TextEditingController(text: '10');
  final _orderQtyController = TextEditingController(text: '100');
  final _currentIssueController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _saving = false;

  Future<void> _save() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() => _saving = true);

    String currentIssue = _currentIssueController.text.trim();
    if (currentIssue.isNotEmpty && currentIssue.length == 16) {
      currentIssue = '$currentIssue:00';
    }

    final body = {
      'title': _titleController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'copies': int.tryParse(_copiesController.text.trim()) ?? 10,
      'orderQty': int.tryParse(_orderQtyController.text.trim()) ?? 100,
      'currentIssue': currentIssue,
    };

    final response = await _apiService.addMagazine(token, body);

    if (!mounted) return;
    setState(() => _saving = false);

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save magazine')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Magazine')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price')),
            TextField(controller: _copiesController, decoration: const InputDecoration(labelText: 'Copies')),
            TextField(controller: _orderQtyController, decoration: const InputDecoration(labelText: 'Order Qty')),
            TextField(
              controller: _currentIssueController,
              decoration: const InputDecoration(
                labelText: 'Current Issue',
                hintText: '2026-04-04T10:30:00',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'Saving...' : 'Save Magazine'),
            ),
          ],
        ),
      ),
    );
  }
}