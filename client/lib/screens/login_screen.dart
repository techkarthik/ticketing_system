import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:animate_do/animate_do.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      print('LoginScreen: Submitting...');
      await Provider.of<AuthProvider>(context, listen: false).login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        _rememberMe,
      );
      print('LoginScreen: Login successful, navigating...');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      print('LoginScreen: Error $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1497215728101-856f4ea42174?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: FadeInDown(
            duration: const Duration(milliseconds: 800),
            child: Container(
              width: isSmallScreen ? size.width * 0.9 : 450,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15), // Glassmorphism
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'TICKETING SYSTEM',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Internal Login',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter email' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(10)
                        ),
                         focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter password' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          fillColor: MaterialStateProperty.all(const Color(0xFF2C5364)),
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val!;
                            });
                          },
                        ),
                        Text('Keep me logged in', style: GoogleFonts.montserrat(color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2C5364),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: Provider.of<AuthProvider>(context).isLoading ? null : _submit,
                        child: Provider.of<AuthProvider>(context).isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('LOGIN', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
