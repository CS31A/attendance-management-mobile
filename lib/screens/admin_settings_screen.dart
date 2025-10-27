import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  
  const AdminSettingsScreen({super.key, this.onBackPressed});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool emailNotifications = true;
  bool smsNotifications = false;
  bool autoBackup = true;
  bool maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Admin Settings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBackPressed != null) {
              widget.onBackPressed!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Admin Profile Card
            _buildAdminProfileCard(),
            const SizedBox(height: 24),

            // System Management
            _buildSection(
              title: "System Management",
              children: [
                _buildModernTile(
                  icon: Icons.admin_panel_settings_outlined,
                  title: "User Management",
                  subtitle: "Manage students, teachers & staff",
                  onTap: () {},
                ),
                _buildModernTile(
                  icon: Icons.school_outlined,
                  title: "Academic Settings",
                  subtitle: "Manage semesters, subjects & classes",
                  onTap: () => _showAcademicSettingsDialog(),
                ),
                _buildModernTile(
                  icon: Icons.schedule_outlined,
                  title: "Attendance Rules",
                  subtitle: "Set attendance policies & thresholds",
                  onTap: () => _showAttendanceRulesDialog(),
                ),
                _buildModernTile(
                  icon: Icons.security_outlined,
                  title: "Security Settings",
                  subtitle: "Configure access controls & permissions",
                  onTap: () => _showSecurityDialog(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data & Reports
            _buildSection(
              title: "Data & Reports",
              children: [
                _buildModernTile(
                  icon: Icons.backup_outlined,
                  title: "System Backup",
                  subtitle: "Backup & restore system data",
                  onTap: () => _showBackupDialog(),
                ),
                _buildModernTile(
                  icon: Icons.analytics_outlined,
                  title: "System Analytics",
                  subtitle: "View system usage & performance",
                  onTap: () {},
                ),
                _buildModernTile(
                  icon: Icons.file_download_outlined,
                  title: "Export Data",
                  subtitle: "Export attendance records & reports",
                  onTap: () => _showExportDialog(),
                ),
                _buildModernTile(
                  icon: Icons.history_outlined,
                  title: "Activity Logs",
                  subtitle: "View system activity & audit trails",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 24),

            // System Preferences
            _buildSection(
              title: "System Preferences",
              children: [
                _buildSwitchTile(
                  icon: Icons.email_outlined,
                  title: "Email Notifications",
                  subtitle: "Send email alerts for attendance",
                  value: emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      emailNotifications = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.sms_outlined,
                  title: "SMS Notifications",
                  subtitle: "Send SMS alerts to parents",
                  value: smsNotifications,
                  onChanged: (value) {
                    setState(() {
                      smsNotifications = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.cloud_sync_outlined,
                  title: "Auto Backup",
                  subtitle: "Automatically backup data daily",
                  value: autoBackup,
                  onChanged: (value) {
                    setState(() {
                      autoBackup = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  icon: Icons.construction_outlined,
                  title: "Maintenance Mode",
                  subtitle: "Enable system maintenance mode",
                  value: maintenanceMode,
                  onChanged: (value) {
                    setState(() {
                      maintenanceMode = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Support & System Info
            _buildSection(
              title: "Support & System",
              children: [
                _buildModernTile(
                  icon: Icons.help_outline,
                  title: "Admin Guide",
                  subtitle: "System administration documentation",
                  onTap: () => _showAdminGuideDialog(),
                ),
                _buildModernTile(
                  icon: Icons.support_agent_outlined,
                  title: "Technical Support",
                  subtitle: "Contact system administrators",
                  onTap: () => _showTechnicalSupportDialog(),
                ),
                _buildModernTile(
                  icon: Icons.info_outline,
                  title: "System Information",
                  subtitle: "View system version & details",
                  onTap: () => _showSystemInfoDialog(),
                ),
                _buildModernTile(
                  icon: Icons.update_outlined,
                  title: "System Updates",
                  subtitle: "Check for system updates",
                  onTap: () => _showUpdateDialog(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Admin Logout Button
            _buildAdminLogoutButton(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "System Administrator",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Christian Dave • Admin Access",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Full Access",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showAdminProfileDialog(),
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  return Column(
                    children: [
                      child,
                      if (index < children.length - 1)
                        Divider(
                          height: 1,
                          indent: 60,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                    ],
                  );
                })
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue[700], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue[700], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildAdminLogoutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAdminLogoutDialog(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.exit_to_app_outlined, color: Colors.red[600]),
              const SizedBox(width: 12),
              Text(
                "End Admin Session",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog methods
  void _showAdminProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Admin Profile"),
        content: const Text("Admin profile management coming soon!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showAcademicSettingsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Academic Settings",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text("Manage Semesters"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.subject_outlined),
              title: const Text("Manage Subjects"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.class_outlined),
              title: const Text("Manage Classes"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttendanceRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Attendance Rules"),
        content: const Text("Configure attendance policies, thresholds, and automatic notifications."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Configure"),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Security Settings"),
        content: const Text("Configure user permissions, access controls, and security policies."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Configure"),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("System Backup"),
        content: const Text("Create a full system backup including all user data and attendance records."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Start Backup"),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Export Data",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text("Export to Excel"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text("Export to PDF"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.code_outlined),
              title: const Text("Export to CSV"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdminGuideDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Admin Guide"),
        content: const Text("Access comprehensive system administration documentation and user guides."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Open Guide"),
          ),
        ],
      ),
    );
  }

  void _showTechnicalSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Technical Support"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Contact Technical Support:"),
            SizedBox(height: 10),
            Text("📧 admin@school.edu"),
            Text("📞 +1 (555) 123-4567"),
            Text("🕒 Mon-Fri 8AM-6PM"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Contact Support"),
          ),
        ],
      ),
    );
  }

  void _showSystemInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("System Information"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Attendance Management System"),
            SizedBox(height: 8),
            Text("Version: 2.1.3"),
            Text("Build: 20240315"),
            Text("Database: PostgreSQL 14.2"),
            Text("Server: Active"),
            Text("Last Update: March 15, 2024"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("System Updates"),
        content: const Text("System is up to date. Last checked: Today at 2:30 PM"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Check Again"),
          ),
        ],
      ),
    );
  }

  void _showAdminLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("End Admin Session"),
        content: const Text("Are you sure you want to end your admin session? You'll be logged out of the system."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Add admin logout logic here
            },
            child: const Text("End Session"),
          ),
        ],
      ),
    );
  }
}