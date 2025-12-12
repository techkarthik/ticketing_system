import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/master_provider.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<MasterProvider>(context, listen: false).fetchDepartments(token);
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Manage Departments', style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1497215728101-856f4ea42174?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Consumer<MasterProvider>(
              builder: (ctx, master, _) {
                if (master.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));
                
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 80),
                  itemCount: master.departments.length,
                  itemBuilder: (ctx, i) {
                    final dept = master.departments[i];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2C5364),
                          child: const Icon(Icons.category, color: Colors.white),
                        ),
                        title: Text(dept['name'], style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () => _showEditDialog(department: dept),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(),
        backgroundColor: const Color(0xFF2C5364),
        icon: const Icon(Icons.add),
        label: const Text('Add Department'),
      ),
    );
  }

  void _showEditDialog({Map<String, dynamic>? department}) {
    final isEditing = department != null;
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: isEditing ? department['name'] : '');

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Edit Department' : 'Add Department',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C5364),
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Department Name', border: OutlineInputBorder()),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
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
                          final token = Provider.of<AuthProvider>(context, listen: false).token;
                          if (token == null) throw Exception("Not authenticated");

                          if (isEditing) {
                             await Provider.of<MasterProvider>(context, listen: false).updateDepartment(token, department['_id'], {
                              'name': _nameController.text.trim(),
                            });
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Department Updated')));
                          } else {
                            await Provider.of<MasterProvider>(context, listen: false).createDepartment(token, {
                              'name': _nameController.text.trim(),
                            });
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Department Added')));
                          }
                          Navigator.of(ctx).pop();
                         
                        } catch (e) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                      child: Text(isEditing ? 'Update' : 'Save'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
