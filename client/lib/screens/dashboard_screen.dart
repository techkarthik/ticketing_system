import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'add_user_screen.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';
import 'branch_screen.dart';
import 'department_screen.dart';
import 'manage_users_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final role = user?['role'] ?? 'GUEST';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.montserrat(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2C5364)),
              accountName: Text(user?['username'] ?? 'User'),
              accountEmail: Text('Role: $role'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF2C5364)),
              ),
            ),
            if (role == 'SUPERADMIN' || role == 'ADMIN')
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('Add User'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddUserScreen()),
                  );
                },
              ),
               if (role == 'SUPERADMIN' || role == 'ADMIN')
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Manage Users'),
                onTap: () {
                  Navigator.of(context).push(
                     MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                   );
                },
              ),
               if (role == 'SUPERADMIN' || role == 'ADMIN')
               ListTile(
                 leading: const Icon(Icons.business),
                 title: const Text('Manage Branches'),
                 onTap: () {
                   Navigator.of(context).push(
                     MaterialPageRoute(builder: (context) => const BranchScreen()),
                   );
                 },
               ),
               if (role == 'SUPERADMIN' || role == 'ADMIN')
               ListTile(
                 leading: const Icon(Icons.category),
                 title: const Text('Manage Departments'),
                 onTap: () {
                   Navigator.of(context).push(
                     MaterialPageRoute(builder: (context) => const DepartmentScreen()),
                   );
                 },
               ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: const Text('Change Password'),
              onTap: () {
                 Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: const Text('My Tickets'),
              onTap: () {},
            ),
          ],
        ),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome, ${user?['username']}',
                style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'Role: $role',
                style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              // Dashboard Widgets Placeholder
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatCard('Open Tickets', '12', Colors.orange),
                  _buildStatCard('Resolved', '45', Colors.green),
                  _buildStatCard('Pending', '5', Colors.red),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        border: Border(left: BorderSide(color: color, width: 5))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(title, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[800])),
        ],
      ),
    );
  }
}
