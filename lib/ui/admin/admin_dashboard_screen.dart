import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../state/app_state.dart';
//

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final List<Map<String, String>> _studentsList = [
    {"name": "Alex Vance", "roll": "22IT049", "sem": "Sem 6", "cgpa": "8.94", "status": "Active"},
    {"name": "Marcus Vance", "roll": "22IT012", "sem": "Sem 6", "cgpa": "9.10", "status": "Active"},
    {"name": "Priya Sharma", "roll": "22IT038", "sem": "Sem 6", "cgpa": "8.65", "status": "Active"},
    {"name": "David Chen", "roll": "22IT021", "sem": "Sem 6", "cgpa": "7.80", "status": "Flagged"},
    {"name": "Samantha Wu", "roll": "23IT004", "sem": "Sem 4", "cgpa": "9.45", "status": "Active"},
  ];

  final List<Map<String, String>> _auditLogs = [
    {"action": "Turnstile Gate #2 Entry", "user": "Alex Vance (#IT-9942)", "time": "09:02 AM", "status": "Success"},
    {"action": "GPU Node #4 Kernel Update", "user": "Root / SysAdmin", "time": "08:30 AM", "status": "Success"},
    {"action": "Unauthorized Room 102 Access", "user": "Card UID 8B:2A:9F", "time": "Yesterday", "status": "Denied"},
    {"action": "Mid-Term Results Upload", "user": "Prof. Sterling", "time": "Oct 22", "status": "Success"},
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Identity Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEPARTMENT ADMINISTRATION',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppColors.secondaryContainer,
                          ),
                        ),
                        Text(
                          user.name,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          user.academicDetails,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // High-Level Metrics Bento
            Text(
              'Department Overview',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _metricCard('Enrolled Students', '480', Icons.school, AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _metricCard('Faculty & Staff', '28', Icons.badge, AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metricCard('Active Lab Passes', '64', Icons.qr_code, AppColors.info)),
                const SizedBox(width: 12),
                Expanded(child: _metricCard('System Uptime', '99.9%', Icons.check_circle, AppColors.success)),
              ],
            ),
            const SizedBox(height: 24),

            // Announcements Publisher
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.campaign, color: AppColors.secondary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Broadcast Department Notice',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _showBroadcastDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Publish'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Push emergency alerts or academic circulars directly to student and staff portals.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Student Directory
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Directory',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                Text(
                  '480 Total Records',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _studentsList.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.outline),
                itemBuilder: (ctx, i) {
                  final s = _studentsList[i];
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceContainerLow,
                      child: Text(
                        s["name"]![0],
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    title: Text(s["name"]!, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: Text('${s["roll"]} • ${s["sem"]} • CGPA: ${s["cgpa"]}', style: GoogleFonts.inter(fontSize: 11)),
                    trailing: StatusBadge(
                      text: s["status"]!,
                      backgroundColor: s["status"] == "Active" ? AppColors.successContainer : AppColors.errorContainer,
                      textColor: s["status"] == "Active" ? AppColors.success : AppColors.error,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Audit Logs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'System Security Audit Logs',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                const Icon(Icons.shield_outlined, size: 18, color: AppColors.secondary),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _auditLogs.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.outline),
                itemBuilder: (ctx, i) {
                  final log = _auditLogs[i];
                  final isDenied = log["status"] == "Denied";
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isDenied ? Icons.gpp_bad : Icons.gpp_good,
                      color: isDenied ? AppColors.error : AppColors.success,
                      size: 20,
                    ),
                    title: Text(log["action"]!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                    subtitle: Text(log["user"]!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                    trailing: Text(
                      log["time"]!,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              Icon(icon, size: 16, color: accent),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Publish Announcement', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Announcement Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message Body'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notice broadcast to all department devices!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Broadcast'),
          ),
        ],
      ),
    );
  }
}



