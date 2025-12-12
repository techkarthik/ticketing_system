import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/master_provider.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _personNameController = TextEditingController();
  String _selectedRole = 'STAFF';
  String? _selectedBranchId;
  String? _selectedDeptId;
  bool _isAdmin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final master = Provider.of<MasterProvider>(context, listen: false);
      master.fetchBranches(auth.token);
      master.fetchDepartments(auth.token);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();

    _mobileController.dispose();
    _personNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).addUser({
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'mobilenumber': _mobileController.text.trim(),
        'personName': _personNameController.text.trim(),
        'role': _selectedRole,
        'isadmin': _isAdmin,
        'branch': _selectedBranchId,
        'department': _selectedDeptId,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User added successfully')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${e.toString().replaceAll('Exception: ', '')}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Add User', style: GoogleFonts.montserrat(color: Colors.white)),
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
          child: Container(
            width: isSmallScreen ? size.width * 0.9 : 500,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
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
              child: ListView(
                shrinkWrap: true,
                children: [
                   Text(
                      'Create New User',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 30),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email (Username)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _personNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Person Name',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Initial Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _mobileController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      labelStyle: const TextStyle(color: Colors.white70),
                       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    dropdownColor: const Color(0xFF2C5364),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: const TextStyle(color: Colors.white70),
                       enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    items: ['SUPERADMIN', 'ADMIN', 'STAFF']
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedRole = val!;
                        if (_selectedRole == 'SUPERADMIN' || _selectedRole == 'ADMIN') {
                            _isAdmin = true;
                        } else {
                            _isAdmin = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 20),
                  Consumer<MasterProvider>(
                    builder: (ctx, master, _) {
                      return DropdownButtonFormField<String>(
                        value: _selectedBranchId,
                        dropdownColor: const Color(0xFF2C5364),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Branch',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        ),
                        items: master.branches.map<DropdownMenuItem<String>>((branch) {
                          return DropdownMenuItem<String>(
                            value: branch['_id'],
                            child: Text(branch['branchname']),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedBranchId = val),
                        validator: (val) => val == null ? 'Please select a branch' : null,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Consumer<MasterProvider>(
                    builder: (ctx, master, _) {
                      return DropdownButtonFormField<String>(
                        value: _selectedDeptId,
                        dropdownColor: const Color(0xFF2C5364),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Department (Optional)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                        ),
                        items: master.departments.map<DropdownMenuItem<String>>((dept) {
                          return DropdownMenuItem<String>(
                            value: dept['_id'],
                            child: Text(dept['name']),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedDeptId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text('Is Admin Access?', style: TextStyle(color: Colors.white)),
                    value: _isAdmin,
                    checkColor: const Color(0xFF2C5364),
                    fillColor: MaterialStateProperty.all(Colors.white),
                    onChanged: (val) => setState(() => _isAdmin = val!),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2C5364),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Color(0xFF2C5364))
                      : const Text('Create User', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
