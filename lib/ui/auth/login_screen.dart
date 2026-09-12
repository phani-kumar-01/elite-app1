import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/app_state.dart';
//
import '../student/student_main_navigation.dart';
import '../staff/staff_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.student;
  final TextEditingController _idController = TextEditingController(text: "22IT049");
  final TextEditingController _passwordController = TextEditingController(text: "••••••••");
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      if (role == UserRole.student) {
        _idController.text = "22IT049";
      } else if (role == UserRole.staff) {
        _idController.text = "FAC104";
      } else {
        _idController.text = "HOD-IT";
      }
    });
  }

  void _handleSignIn() async {
    setState(() => _isLoading = true);
    final state = context.read<AppState>();
    state.switchRole(_selectedRole);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _isLoading = false);

    Widget targetScreen;
    if (_selectedRole == UserRole.student) {
      targetScreen = const StudentMainNavigation();
    } else if (_selectedRole == UserRole.staff) {
      targetScreen = const StaffDashboardScreen();
    } else {
      targetScreen = const AdminDashboardScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Branding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.outline, width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(Icons.account_balance, color: AppColors.primary, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ELITE IT',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Department of Information Technology',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Top Welcome Emblem
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Icon(
                      _selectedRole == UserRole.student
                          ? Icons.school
                          : _selectedRole == UserRole.staff
                              ? Icons.badge
                              : Icons.admin_panel_settings,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    _selectedRole == UserRole.student
                        ? 'Student Portal'
                        : _selectedRole == UserRole.staff
                            ? 'Faculty Portal'
                            : 'Administration Portal',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Access department labs, attendance metrics, and secure single sign-on credentials.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),

                  // Login Card Container
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outline),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Role Pill Switcher
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              _roleTab('Student', UserRole.student),
                              _roleTab('Faculty', UserRole.staff),
                              _roleTab('Admin', UserRole.admin),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ID or Email Field
                        Text(
                          'University ID or Institutional Email',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _idController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.onSurfaceVariant),
                            hintText: 'Enter ID',
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Password Field
                        Text(
                          'Password',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
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
                        const SizedBox(height: 12),

                        // Remember & Forgot
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.secondary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (val) => setState(() => _rememberMe = val ?? true),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Remember ID',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password reset link dispatched to IT Helpdesk')),
                                );
                              },
                              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
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
                                        'Sign In to Dashboard',
                                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 16),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Biometrics / SSO Button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: _handleSignIn,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.outline),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.fingerprint, size: 20, color: AppColors.secondary),
                            label: Text(
                              'Sign in with Biometrics / NFC Pass',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer Institutional Notice
                  Text(
                    'Elite Autonomous IT Department • System Ver 4.2.0\nProtected by Hardware Security Module (HSM) Encryption',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTab(String label, UserRole role) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onRoleChanged(role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}




