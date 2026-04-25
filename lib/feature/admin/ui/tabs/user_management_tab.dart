import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unilib/core/model/user_model.dart';
import 'package:unilib/core/theme/app_colors.dart';
import 'package:unilib/feature/admin/logic/admin_provider.dart';
import 'package:unilib/feature/admin/ui/tabs/widgets/user_management_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final users = admin.searchUsers(_searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFF070E18),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Students',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Manage and monitor student accounts',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 20),
                UserSearchBar(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ],
            ),
          ),

          Expanded(
            child: admin.isLoading && admin.allUsers.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  )
                : users.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () => admin.fetchAllUsers(),
                    color: AppColors.gold,
                    backgroundColor: const Color(0xFF0F1E30),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        return UserListTile(
                              user: users[index],
                              onTap: () => _showUserActions(
                                context,
                                users[index],
                                admin,
                              ),
                            )
                            .animate()
                            .fadeIn(delay: (index * 50).ms)
                            .slideX(begin: 0.1, end: 0);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showUserActions(
    BuildContext context,
    UserModel user,
    AdminProvider admin,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F1E30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.gold.withOpacity(0.1),
                  child: Text(
                    user.firstName[0],
                    style: TextStyle(color: AppColors.gold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      user.email,
                      style: GoogleFonts.dmSans(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildActionItem(
              icon: Icons.edit_attributes_rounded,
              label: 'Adjust Borrowing Limit',
              onTap: () {
                Navigator.pop(ctx);
                // Implementation for adjusting limits
              },
            ),
            _buildActionItem(
              icon: Icons.block_flipped,
              label: 'Suspend Account',
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(ctx);
                // Implementation for suspension
              },
            ),
            _buildActionItem(
              icon: Icons.history_rounded,
              label: 'View Borrow History',
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white70,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: GoogleFonts.dmSans(color: color)),
      onTap: onTap,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
