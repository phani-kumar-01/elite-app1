import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'student_home_screen.dart';
import 'events_screen.dart';
import 'attendance_screen.dart';
import 'polls_screen.dart';
import 'student_profile_screen.dart';
import 'notifications_screen.dart';

class StudentMainNavigation extends StatefulWidget {
  const StudentMainNavigation({super.key});

  @override
  State<StudentMainNavigation> createState() => _StudentMainNavigationState();
}

class _StudentMainNavigationState extends State<StudentMainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      StudentHomeScreen(onNavigateTab: (index) => setState(() => _currentIndex = index)),
      const EventsScreen(),
      const AttendanceScreen(),
      const PollsScreen(),
      const StudentProfileScreen(),
      const NotificationsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.onSurfaceVariant,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.how_to_vote_outlined),
              activeIcon: Icon(Icons.how_to_vote),
              label: 'Polls',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
