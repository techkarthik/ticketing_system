import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ManageBranchesScreen extends StatefulWidget {
  const ManageBranchesScreen({super.key});

  @override
  State<ManageBranchesScreen> createState() => _ManageBranchesScreenState();
}

class _ManageBranchesScreenState extends State<ManageBranchesScreen> {
  List<dynamic> _branches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      final branches = await ApiService.get('/master/branches');
      setState(() {
        _branches = branches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _showBranchDialog({String? id, String? initialName}) {
    final nameController = TextEditingController(text: initialName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(id == null ? 'Add Branch' : 'Edit Branch'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Branch Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context); // Close dialog
                setState(() => _isLoading = true);
                try {
                  if (id == null) {
                    await ApiService.post('/master/branches', {'name': nameController.text});
                  } else {
                    await ApiService.put('/master/branches/$id', {'name': nameController.text}); // Assuming PUT exists
                  }
                  _fetchBranches();
                } catch (e) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Branches')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _branches.length,
                  itemBuilder: (context, index) {
                    final branch = _branches[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.business),
                        title: Text(branch['name']),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showBranchDialog(
                            id: branch['id'] ?? branch['_id'],
                            initialName: branch['name'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBranchDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
