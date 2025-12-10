import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Staff';
  String? _selectedBranch;

  List<dynamic> _branches = [];
  bool _loadingBranches = true;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      final branches = await ApiService.get('/master/branches');
      if (mounted) {
        setState(() {
          _branches = branches;
          _loadingBranches = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingBranches = false);
    }
  }

  void _createUser() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranch == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select Branch')));
        return;
      }

      try {
        await ApiService.post('/admin/create-user', {
          'username': _usernameController.text,
          'password': _passwordController.text,
          'role': _selectedRole,
          'branch': _selectedBranch,
        });
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Created Successfully')));
           Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create User')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _selectedRole,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: ['Staff', 'Supervisor', 'Admin']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedRole = v as String),
                      ),
                      const SizedBox(height: 16),
                      _loadingBranches
                          ? const LinearProgressIndicator()
                          : DropdownButtonFormField(
                              value: _selectedBranch,
                              decoration: const InputDecoration(labelText: 'Branch'),
                              hint: const Text('Select Branch'),
                              items: _branches
                                  .map((b) => DropdownMenuItem(value: b['name'], child: Text(b['name'])))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedBranch = v as String?),
                            ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _createUser,
                        child: const Text('Create User'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
