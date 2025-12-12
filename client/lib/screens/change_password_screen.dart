import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).changePassword(
        _oldPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed successfully')));
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
        title: Text('Change Password', style: GoogleFonts.montserrat(color: Colors.white)),
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
            width: isSmallScreen ? size.width * 0.9 : 450,
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
                      'Update Password',
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
                    controller: _oldPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'Old Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                     decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    validator: (val) {
                      if (val!.isEmpty) return 'Required';
                      if (val != _newPasswordController.text) return 'Passwords do not match';
                      return null;
                    },
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
                        : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold)),
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
