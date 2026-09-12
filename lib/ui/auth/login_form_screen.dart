import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/supabase_config.dart';
import '../../state/app_state.dart';
import '../student/student_main_navigation.dart';
import '../staff/staff_main_navigation.dart';
import '../admin/admin_main_navigation.dart';

class LoginFormScreen extends StatefulWidget {
  final bool isStaffOrAdmin;

  const LoginFormScreen({
    super.key,
    required this.isStaffOrAdmin,
  });

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  late TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController(text: "••••••••");
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill with a valid sasi.ac.in email for easy testing
    if (widget.isStaffOrAdmin) {
      _emailController = TextEditingController(text: "hod_it@sasi.ac.in");
    } else {
      _emailController = TextEditingController(text: "24K61A1259@sasi.ac.in");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim().toLowerCase();

    // 1. Strict college domain check: ONLY sasi.ac.in
    if (!SupabaseConfig.isValidCollegeEmail(email)) {
      setState(() {
        _errorMessage = "Authentication failed: Only @${SupabaseConfig.collegeDomain} domain is permitted.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final appState = context.read<AppState>();
    final result = await appState.loginWithCollegeEmail(email);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final UserRole role = result['role'];

      // Route strictly based on the database-resolved role
      Widget targetScreen;
      if (role == UserRole.student) {
        targetScreen = const StudentMainNavigation();
      } else if (role == UserRole.staff) {
        targetScreen = const StaffMainNavigation();
      } else {
        targetScreen = const AdminMainNavigation();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Login failed. Please verify credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailText = _emailController.text.trim().toLowerCase();
    final isDomainValid = SupabaseConfig.isValidCollegeEmail(emailText);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Emblem
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: widget.isStaffOrAdmin ? AppColors.primary : AppColors.secondary,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Icon(
                      widget.isStaffOrAdmin ? Icons.admin_panel_settings : Icons.school,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    widget.isStaffOrAdmin ? 'Staff & Admin Portal' : 'Student Portal',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Role and privileges are strictly verified from the institutional database.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.outline),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        Text(
                          'Institutional College Email',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.mail_outline, size: 20, color: AppColors.onSurfaceVariant),
                            hintText: widget.isStaffOrAdmin ? 'faculty@sasi.ac.in' : '24K61A1259@sasi.ac.in',
                            suffixIcon: isDomainValid
                                ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Domain Validation Indicator
                        Row(
                          children: [
                            Icon(
                              isDomainValid ? Icons.verified : Icons.info_outline,
                              size: 13,
                              color: isDomainValid ? AppColors.success : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isDomainValid
                                  ? 'Verified @sasi.ac.in institutional domain'
                                  : 'Must end with @sasi.ac.in',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDomainValid ? AppColors.success : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        Text(
                          'Password',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.onSurfaceVariant),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                                color: AppColors.onSurfaceVariant,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Error message if any
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.isStaffOrAdmin ? AppColors.primary : AppColors.secondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Authenticate & Enter',
                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick test credentials pills
                  Text(
                    'Quick Test Accounts (@sasi.ac.in):',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      _QuickPill(
                        label: 'Student: 24K61A1259',
                        onTap: () => setState(() => _emailController.text = "24K61A1259@sasi.ac.in"),
                      ),
                      _QuickPill(
                        label: 'Staff: hod_it',
                        onTap: () => setState(() => _emailController.text = "hod_it@sasi.ac.in"),
                      ),
                      _QuickPill(
                        label: 'Admin: admin',
                        onTap: () => setState(() => _emailController.text = "admin@sasi.ac.in"),
                      ),
                    ],
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

class _QuickPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.outline),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
