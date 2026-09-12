import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/widgets/permission_dialog.dart';
import '../../core/services/permission_service.dart';
import '../../ui/features/contacts/contacts_screen.dart';
import '../../state/app_state.dart';

class StudentHomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const StudentHomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final permService = context.watch<PermissionService>();
    final hasPendingPerms = !permService.status.cameraGranted ||
        !permService.status.contactsGranted ||
        !permService.status.notificationsGranted;

    return Scaffold(
      appBar: AppHeader(
        onNotificationTap: () => onNavigateTab?.call(3),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Permissions Notification Banner
              if (hasPendingPerms)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device Permissions Setup',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.secondary),
                            ),
                            Text(
                              'Camera, Contacts & Notifications needed for full features.',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => PermissionDialog.show(context),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text('Review', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.secondary)),
                      ),
                    ],
                  ),
                ),

              // Welcome Greeting & Semester Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WELCOME BACK',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.name,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          user.academicDetails,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Active Lab Pass Banner (Stitch Card)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.qr_code_2, color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'ACTIVE PASS',
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ID: #${user.labPassId}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.labPassRoom,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => QrPassDialog.show(context, user),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.fullscreen, size: 16),
                          label: const Text('View QR'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Color(0xFF2E384D))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule, size: 14, color: AppColors.secondaryContainer),
                              const SizedBox(width: 4),
                              Text(
                                'Expires at ${user.labPassExpiry}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Authorized: AI & Systems Lab',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Quick Actions Grid (4 working cards)
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.qr_code,
                      label: 'Lab QR Pass',
                      onTap: () => QrPassDialog.show(context, user),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.contacts_outlined,
                      label: 'Contacts',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ContactsScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.report_problem_outlined,
                      label: 'Report Issue',
                      onTap: () => _showReportIssueDialog(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _quickActionButton(
                      context,
                      icon: Icons.terminal,
                      label: 'Software',
                      onTap: () => _showSoftwareHubModal(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Active Service Tickets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Service Tickets',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showReportIssueDialog(context),
                    child: Text(
                      '+ New Ticket',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...state.tickets.map((t) => _ticketCard(t)),
              const SizedBox(height: 22),

              // Upcoming IT Workshops
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming IT Workshops',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onNavigateTab?.call(1),
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...state.events.take(2).map((e) => _eventWorkshopCard(context, e)),
              const SizedBox(height: 24),

              // System Health Status Widget (Infrastructure & Network)
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
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Campus IT Infrastructure',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'All Systems Operational',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.outline, height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _healthItem('Campus Wi-Fi', '99.9%', Icons.wifi),
                        _healthItem('Internet Latency', '18ms', Icons.speed),
                        _healthItem('Lab Cloud Rig', 'Online', Icons.cloud_done),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketCard(dynamic t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
              Row(
                children: [
                  StatusBadge.inProgress(t.status),
                  const SizedBox(width: 8),
                  Text(
                    t.id,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                t.updatedAt,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t.title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _eventWorkshopCard(BuildContext context, dynamic e) {
    final state = context.watch<AppState>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  e.dateMonth,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  e.dateDay,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  e.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              state.toggleEventRegistration(e.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.isRegistered ? 'Unregistered from ${e.title}' : 'Registered for ${e.title}!'),
                  backgroundColor: e.isRegistered ? AppColors.onSurfaceVariant : AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: e.isRegistered ? AppColors.surfaceContainerHigh : AppColors.primary,
              foregroundColor: e.isRegistered ? AppColors.onSurface : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(
              e.isRegistered ? 'Registered' : 'Register',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.success),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showReportIssueDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            const Icon(Icons.report_problem, color: AppColors.secondary, size: 22),
            const SizedBox(width: 8),
            Text('Report IT Issue', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Issue Subject / Workstation ID',
                hintText: 'e.g. Lab 402 Workstation #14 HDMI signal lost',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Detailed Problem Description',
                hintText: 'Include error codes or hardware behavior...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                context.read<AppState>().addServiceTicket(
                      title: titleController.text.trim(),
                      description: descController.text.trim().isEmpty
                          ? "Reported via Student Portal Mobile App"
                          : descController.text.trim(),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket created and dispatched to SysAdmin!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Submit Ticket'),
          ),
        ],
      ),
    );
  }

  void _showSoftwareHubModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.terminal, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Department Software Hub',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Institutional licenses available for enrolled students:',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            _softwareTile('JetBrains All Products Pack', 'Institutional License Active', Icons.code),
            _softwareTile('MATLAB & Simulink R2026b', 'Campus-wide Concurrent License', Icons.insights),
            _softwareTile('Docker Desktop Enterprise', 'Single Sign-On Enabled', Icons.layers),
            _softwareTile('NVIDIA CUDA Toolkit 12.6', 'Installed on Lab 402 GPU Rig', Icons.memory),
          ],
        ),
      ),
    );
  }

  Widget _softwareTile(String title, String subtitle, IconData icon) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.download, size: 18, color: AppColors.secondary),
    );
  }
}
