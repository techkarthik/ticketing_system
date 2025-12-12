import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/master_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MasterProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          return MaterialApp(
            title: 'Ticketing System',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: const Color(0xFF2C5364),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color(0xFF2C5364),
                secondary: const Color(0xFF203A43),
              ),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: auth.isAuthenticated 
              ? const DashboardScreen() 
              : const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // tryAutoLogin will notifyListeners if true, triggering main.dart rebuild 
    // to show DashboardScreen instead of AuthWrapper/LoginScreen
    final success = await Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
    if (!success && mounted) {
       // Force manual transition if needed, but current Main logic falls back to AuthWrapper
       // We should actually let it fall through to LoginScreen?
       // Wait, if !isAuthenticated, MyApp shows AuthWrapper.
       // AuthWrapper should switch to LoginScreen if check fails.
       Navigator.of(context).pushReplacement(
         PageRouteBuilder(
           pageBuilder: (_, __, ___) => const LoginScreen(),
           transitionDuration: Duration.zero,
         )
       );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
