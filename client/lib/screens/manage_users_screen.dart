import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/master_provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    // Pre-fetch masters for editing
    Future.delayed(Duration.zero, () {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final master = Provider.of<MasterProvider>(context, listen: false);
      master.fetchBranches(auth.token);
      master.fetchDepartments(auth.token);
    });
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await Provider.of<AuthProvider>(context, listen: false).fetchAllUsers();
      setState(() => _users = users);
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: user['personName']);
    final _mobileController = TextEditingController(text: user['mobilenumber']);
    
    String _selectedRole = user['role'] ?? 'STAFF';
    // Handle embedded objects or ID strings for initial values
    String? _selectedBranchId = user['branch'] is Map ? user['branch']['_id'] : user['branch'];
    String? _selectedDeptId = user['department'] is Map ? user['department']['_id'] : user['department'];
    bool _isAdmin = user['isadmin'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              )
            ],
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Edit User',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C5364),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Person Name', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _mobileController,
                    decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                    items: ['SUPERADMIN', 'ADMIN', 'STAFF']
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (val) {
                         setState(() { // Note: Dialog needs StatefulBuilder for robust state, but usually works if parent rebuilds or simple var
                           _selectedRole = val!;
                           // Auto-toggle admin
                           if (['SUPERADMIN', 'ADMIN'].contains(val)) _isAdmin = true;
                         });
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<MasterProvider>(
                    builder: (ctx, master, _) {
                      return DropdownButtonFormField<String>(
                        value: _selectedBranchId,
                        decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
                        items: master.branches.map<DropdownMenuItem<String>>((branch) {
                          return DropdownMenuItem<String>(
                            value: branch['_id'],
                            child: Text(branch['branchname']),
                          );
                        }).toList(),
                        onChanged: (val) => _selectedBranchId = val,
                        validator: (val) => val == null ? 'Required' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                   Consumer<MasterProvider>(
                    builder: (ctx, master, _) {
                      return DropdownButtonFormField<String>(
                        value: _selectedDeptId,
                        decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                        items: master.departments.map<DropdownMenuItem<String>>((dept) {
                          return DropdownMenuItem<String>(
                            value: dept['_id'],
                            child: Text(dept['name']),
                          );
                        }).toList(),
                        onChanged: (val) => _selectedDeptId = val,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                   CheckboxListTile(
                    title: const Text('Is Admin Access?'),
                    value: _isAdmin,
                    onChanged: (val) => _isAdmin = val!,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5364),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          try {
                            await Provider.of<AuthProvider>(context, listen: false).updateUser(user['_id'], {
                              'personName': _nameController.text.trim(),
                              'mobilenumber': _mobileController.text.trim(),
                              'role': _selectedRole,
                              'isadmin': _isAdmin,
                              'branch': _selectedBranchId,
                              'department': _selectedDeptId
                            });
                             Navigator.of(ctx).pop();
                             _loadUsers(); // Refresh list
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User Updated')));
                          } catch (e) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        },
                        child: const Text('Update'),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Manage Users', style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1557683316-973673baf926?auto=format&fit=crop&w=1950&q=80'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView.builder(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 80),
                itemCount: _users.length,
                itemBuilder: (ctx, i) {
                  final user = _users[i];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF2C5364),
                        child: Text(
                          (user['personName'] ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        user['personName'] ?? user['username'], 
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username: ${user['username']}', style: const TextStyle(color: Colors.white70)),
                          Text(
                            'Role: ${user['role']} • Branch: ${user['branch'] is Map ? user['branch']['branchname'] : 'N/A'}',
                             style: const TextStyle(color: Colors.white70)
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _showEditUserDialog(user),
                      ),
                    ),
                  );
                },
              ),
          ),
        ),
      ),
    );
  }
}
