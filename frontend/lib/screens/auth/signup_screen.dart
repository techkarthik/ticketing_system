import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'Staff';
  String? _selectedBranch; // Will be populated from API
  
  List<dynamic> _branches = [];
  bool _loadingBranches = true;

  @override
  void initState() {
    super.initState();
    _fetchBranches();
  }

  Future<void> _fetchBranches() async {
    try {
      final fetchedBranches = await ApiService.get('/master/branches');
      print('Branches fetched: $fetchedBranches'); // Debug log
      if (mounted) {
        setState(() {
          _branches = fetchedBranches;
          _loadingBranches = false;
        });
      }
    } catch (e) {
      print('Error fetching branches: $e'); // Debug log
      if (mounted) {
        setState(() => _loadingBranches = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading branches: $e')),
        );
      }
    }
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a branch')),
        );
        return;
      }

      final success = await Provider.of<AuthProvider>(context, listen: false)
          .signup(_usernameController.text, _passwordController.text, _selectedRole, _selectedBranch!);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup Successful! Please Login.')),
          );
          Navigator.of(context).pop(); // Go back to Login
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signup Failed. Username might exist.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card( // Added Card for consistency
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
              Text(
                'Join Us',
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Create your account to access the portal', style: GoogleFonts.poppins(color: Colors.grey)),
              const SizedBox(height: 32),
              
              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge)),
                items: ['Staff', 'Supervisor', 'Admin'].map((role) {
                  return DropdownMenuItem(value: role, child: Text(role));
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 16),

              // Branch Dropdown (Dynamic)
              _loadingBranches 
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedBranch,
                      decoration: const InputDecoration(labelText: 'Branch', prefixIcon: Icon(Icons.business)),
                      hint: const Text('Select Branch'),
                      items: _branches.map<DropdownMenuItem<String>>((branch) {
                        return DropdownMenuItem<String>(
                          value: branch['name'],
                          child: Text(branch['name']),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedBranch = val!),
                    ),

              const SizedBox(height: 32),
              
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return ElevatedButton(
                    onPressed: auth.isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: auth.isLoading 
                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                       : const Text('SIGN UP'),
                  );
                },
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
