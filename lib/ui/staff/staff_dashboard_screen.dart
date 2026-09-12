import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_widgets.dart';
import '../../core/services/permission_service.dart';
import '../../state/app_state.dart';

class StaffDashboardScreen extends StatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  State<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  final List<Map<String, String>> _approvalRequests = [
    {
      "name": "Marcus Vance",
      "roll": "22IT012",
      "reason": "ACM ICPC Regionals On-Duty (OD)",
      "subject": "CS301 Cloud Lab",
      "date": "Oct 24",
    },
    {
      "name": "Priya Sharma",
      "roll": "22IT038",
      "reason": "Hospital Medical Certificate Verified",
      "subject": "CS302 Distributed Systems",
      "date": "Oct 22",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final permService = context.watch<PermissionService>();

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Faculty Welcome Header
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
                    child: const Icon(Icons.badge, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FACULTY PORTAL',
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

            // Today's Scheduled Sessions
            Text(
              "Today's Teaching Schedule",
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
            ),
            const SizedBox(height: 10),
            _classScheduleCard(
              code: 'CS301',
              title: 'Cloud Architecture & DevOps Lab',
              time: '09:00 AM - 11:00 AM',
              room: 'Advanced Lab 402',
              attendance: '38 / 40 Present (95%)',
              isActive: true,
            ),
            _classScheduleCard(
              code: 'CS302',
              title: 'Distributed Database Systems',
              time: '02:00 PM - 03:30 PM',
              room: 'Lecture Hall 204',
              attendance: 'Upcoming session',
              isActive: false,
            ),
            const SizedBox(height: 22),

            // Live Attendance QR Scanner Launcher with Camera Permission Integration
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.qr_code_scanner, color: AppColors.secondary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Camera Turnstile Scanner',
                              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              permService.status.cameraGranted
                                  ? 'Camera hardware linked. Ready to scan.'
                                  : 'Camera permission required for live scanning.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: permService.status.cameraGranted ? AppColors.success : AppColors.secondary,
                                fontWeight: permService.status.cameraGranted ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openScannerModal(context, permService),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: Text(
                        permService.status.cameraGranted
                            ? 'Open Turnstile Camera Scanner'
                            : 'Request Camera & Launch Scanner',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Attendance Approval Queue
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Leave / OD Approvals',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_approvalRequests.length} Pending',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ..._approvalRequests.map((req) => _approvalCard(req)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _classScheduleCard({
    required String code,
    required String title,
    required String time,
    required String room,
    required String attendance,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppColors.secondary : AppColors.outline, width: isActive ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.secondary : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  code,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isActive ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              if (isActive)
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('LIVE NOW', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(time, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
              const SizedBox(width: 12),
              const Icon(Icons.room, size: 14, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(room, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            attendance,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.success : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _approvalCard(Map<String, String> req) {
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
              Text(
                '${req["name"]} • ${req["roll"]}',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(req["date"]!, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            req["reason"]!,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
          ),
          Text(
            'Missed session: ${req["subject"]}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() => _approvalRequests.remove(req));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Request Rejected')),
                  );
                },
                style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text('Reject'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() => _approvalRequests.remove(req));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attendance Granted & Synced'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Approve'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openScannerModal(BuildContext context, PermissionService permService) async {
    if (!permService.status.cameraGranted) {
      final granted = await permService.requestCamera();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission required to open scanner viewfinder'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: Color(0xFF111827),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(
              'ELITE Turnstile Camera Viewfinder',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              'Live Camera Stream Active • Auto-focusing QR & RFID Barcode',
              style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
            ),
            const Spacer(),
            // Mock Scanner Reticle with animation
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary, width: 2.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Container(
                  width: 190,
                  height: 2,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.read<AppState>().addAttendanceLog(
                          subject: "CS301 Cloud Lab (Scanned)",
                          room: "Lab 402 Turnstile",
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Verified Student: Alex Vance (#IT-9942) - Attendance Marked!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.qr_code, size: 20),
                  label: const Text('Capture & Verify Student Pass'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
