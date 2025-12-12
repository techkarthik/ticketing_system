import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/master_provider.dart';

class BranchScreen extends StatefulWidget {
  const BranchScreen({super.key});

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<MasterProvider>(context, listen: false).fetchBranches(token);
    });
  }

  void _showAddbranchDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _locationController = TextEditingController();
    String _selectedType = 'RETAIL';
    bool _isActive = true;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          width: 500, // Fixed width similar to login
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // Less transparent for readability
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
                    'Add New Branch',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C5364),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Branch Name', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                    items: ['RETAIL', 'FACTORY', 'WHOLESALE']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => _selectedType = val!,
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text('Active'),
                    value: _isActive,
                    onChanged: (val) => _isActive = val!,
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
                            final token = Provider.of<AuthProvider>(context, listen: false).token;
                            if (token == null) throw Exception("Not authenticated");
                            
                            await Provider.of<MasterProvider>(context, listen: false).createBranch(token, {
                              'branchname': _nameController.text.trim(),
                              'location': _locationController.text.trim(),
                              'branchtype': _selectedType,
                              'active': _isActive
                            });
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Branch Added')));
                          } catch (e) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                          }
                        },
                        child: const Text('Save'),
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
        title: Text('Manage Branches', style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1950&q=80'),
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
                  itemCount: master.branches.length,
                  itemBuilder: (ctx, i) {
                    final branch = master.branches[i];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: branch['active'] ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                          child: const Icon(Icons.business, color: Colors.white),
                        ),
                        title: Text(branch['branchname'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${branch['location']} • ${branch['branchtype']}', style: const TextStyle(color: Colors.white70)),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () => _showEditBranchDialog(branch),
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
        onPressed: _showAddbranchDialog,
        backgroundColor: const Color(0xFF2C5364),
        icon: const Icon(Icons.add),
        label: const Text('Add Branch'),
      ),
    );
  }

  void _showEditBranchDialog(Map<String, dynamic> branch) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: branch['branchname']);
    final _locationController = TextEditingController(text: branch['location']);
    String _selectedType = branch['branchtype'] ?? 'RETAIL';
    bool _isActive = branch['active'] ?? true;

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
                    'Edit Branch',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C5364),
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Branch Name', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                    items: ['RETAIL', 'FACTORY', 'WHOLESALE']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => _selectedType = val!,
                  ),
                   const SizedBox(height: 10),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return CheckboxListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val!), // This setstate might not work inside dialog builder correctly without stateful builder, but let's try or use StateSetter
                        contentPadding: EdgeInsets.zero,
                      );
                    },
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

                            // Call update method (need to implement in provider)
                            // For now assuming createBranch structure but logic update needed. 
                            // Wait, I need updateBranch in provider.
                             await Provider.of<MasterProvider>(context, listen: false).updateBranch(token, branch['_id'], {
                              'branchname': _nameController.text.trim(),
                              'location': _locationController.text.trim(),
                              'branchtype': _selectedType,
                              'active': _isActive
                            });
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Branch Updated')));
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
}
