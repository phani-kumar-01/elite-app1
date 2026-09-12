export '../data/models/app_models.dart';
import 'package:flutter/material.dart';
import '../data/models/app_models.dart';
import '../data/repositories/mock_repository.dart';
import '../core/services/supabase_service.dart';
import '../core/config/supabase_config.dart';

class AppState extends ChangeNotifier {
  final SupabaseService _supabaseService;

  UserModel _currentUser = MockRepository.studentUser;
  List<EventModel> _events = MockRepository.getInitialEvents();
  final List<SubjectAttendance> _subjectAttendance = MockRepository.getSubjectAttendance();
  final List<AttendanceLog> _attendanceLogs = MockRepository.getAttendanceLogs();
  List<PollModel> _polls = MockRepository.getInitialPolls();
  List<AppNotification> _notifications = MockRepository.getInitialNotifications();
  List<LiveLeaderboardEntry> _leaderboard = [];

  // Registrations (Individual & Team)
  final List<EventRegistrationModel> _registrations = [
    EventRegistrationModel(
      id: 'team_ev_tech_quiz_alpha',
      eventId: 'ev_tech_quiz',
      isTeam: true,
      teamName: 'Team Alpha',
      studentId: 's_01',
      studentRoll: '24K61A1259',
      studentName: 'Phani Kumar',
      studentEmail: '24K61A1259@sasi.ac.in',
      studentYear: '3rd Year',
      members: [
        TeamMemberInfo(studentId: 's_01', studentRoll: '24K61A1259', studentName: 'Phani Kumar', studentEmail: '24K61A1259@sasi.ac.in', studentDept: 'IT', studentYear: '3rd Year', isLeader: true),
        TeamMemberInfo(studentId: 's_02', studentRoll: '23CS042', studentName: 'Rahul Kumar', studentEmail: '23CS042@sasi.ac.in', studentDept: 'CSE', studentYear: '2nd Year'),
        TeamMemberInfo(studentId: 's_03', studentRoll: '23IT015', studentName: 'Sathvik Varma', studentEmail: '23IT015@sasi.ac.in', studentDept: 'IT', studentYear: '2nd Year'),
        TeamMemberInfo(studentId: 's_04', studentRoll: '23IT088', studentName: 'Bhavitha S', studentEmail: '23IT088@sasi.ac.in', studentDept: 'IT', studentYear: '2nd Year'),
      ],
      status: 'CONFIRMED',
      registeredAt: '2026-09-12T10:00:00Z',
    ),
  ];

  // Staff & Admin Directory Cache
  List<UserModel> _studentsRoster = [
    UserModel(id: 's_01', name: 'Phani Kumar', email: '24K61A1259@sasi.ac.in', rollNumber: '24K61A1259', role: UserRole.student, department: 'Information Technology', academicDetails: 'B.Tech IT • 3rd Year', yearLevel: '3rd Year', section: 'B'),
    UserModel(id: 's_02', name: 'Rahul Kumar', email: '23CS042@sasi.ac.in', rollNumber: '23CS042', role: UserRole.student, department: 'Computer Science & Eng', academicDetails: 'B.Tech CSE • 2nd Year', yearLevel: '2nd Year', section: 'A'),
    UserModel(id: 's_03', name: 'Sathvik Varma', email: '23IT015@sasi.ac.in', rollNumber: '23IT015', role: UserRole.student, department: 'Information Technology', academicDetails: 'B.Tech IT • 2nd Year', yearLevel: '2nd Year', section: 'A'),
    UserModel(id: 's_04', name: 'Bhavitha S', email: '23IT088@sasi.ac.in', rollNumber: '23IT088', role: UserRole.student, department: 'Information Technology', academicDetails: 'B.Tech IT • 2nd Year', yearLevel: '2nd Year', section: 'B'),
    UserModel(id: 's_05', name: 'M. Manoj Reddy', email: '22IT049@sasi.ac.in', rollNumber: '22IT049', role: UserRole.student, department: 'Information Technology', academicDetails: 'B.Tech IT • 4th Year', yearLevel: '4th Year', section: 'A'),
    UserModel(id: 's_06', name: 'K. Sarvagna', email: '22CS102@sasi.ac.in', rollNumber: '22CS102', role: UserRole.student, department: 'Computer Science & Eng', academicDetails: 'B.Tech CSE • 4th Year', yearLevel: '4th Year', section: 'B'),
    UserModel(id: 's_07', name: 'P. Sai Teja', email: '23AI018@sasi.ac.in', rollNumber: '23AI018', role: UserRole.student, department: 'Artificial Intelligence', academicDetails: 'B.Tech AIML • 2nd Year', yearLevel: '2nd Year', section: 'A'),
  ];
  List<UserModel> _staffRoster = [];

  String _selectedEventCategory = "All";
  bool _isLoadingFromSupabase = false;

  AppState([SupabaseService? supabaseService])
      : _supabaseService = supabaseService ?? SupabaseService() {
    _leaderboard = _supabaseService.getLiveLeaderboard();
    syncFromSupabase();
  }

  UserModel get currentUser => _currentUser;
  bool get isStudent => _currentUser.isStudent;
  bool get isStaff => _currentUser.isStaff;
  bool get isAdmin => _currentUser.isAdmin;

  List<EventModel> get events => _events;
  List<EventRegistrationModel> get registrations => _registrations;
  List<SubjectAttendance> get subjectAttendance => _subjectAttendance;
  List<AttendanceLog> get attendanceLogs => _attendanceLogs;
  List<PollModel> get polls => _polls;
  List<AppNotification> get notifications => _notifications;
  List<LiveLeaderboardEntry> get leaderboard => _leaderboard;
  List<UserModel> get studentsRoster => _studentsRoster;
  List<UserModel> get staffRoster => _staffRoster;

  String get selectedEventCategory => _selectedEventCategory;
  bool get isLoadingFromSupabase => _isLoadingFromSupabase;
  bool get isSupabaseConnected => _supabaseService.isInitialized;

  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  List<EventModel> get filteredEvents {
    if (_selectedEventCategory == "All") return _events;
    return _events.where((e) => e.category.toLowerCase() == _selectedEventCategory.toLowerCase()).toList();
  }

  List<EventModel> get registeredEvents {
    return _events.where((e) => isStudentRegisteredForEvent(e.id)).toList();
  }

  /// Check if the currently logged-in student (or specified student) is registered for an event
  EventRegistrationModel? getRegistrationForEvent(String eventId, [String? studentRollOrEmail]) {
    final target = (studentRollOrEmail ?? _currentUser.rollNumber).trim().toLowerCase();
    for (final reg in _registrations) {
      if (reg.eventId == eventId && reg.containsStudent(target)) {
        return reg;
      }
    }
    return null;
  }

  bool isStudentRegisteredForEvent(String eventId, [String? studentRollOrEmail]) {
    return getRegistrationForEvent(eventId, studentRollOrEmail) != null;
  }

  /// Check if a student is already registered for this event in any team
  bool isStudentRegisteredInAnyTeam(String eventId, String studentRollOrEmail) {
    final target = studentRollOrEmail.trim().toLowerCase();
    return _registrations.any((r) => r.eventId == eventId && r.containsStudent(target));
  }

  // ─── Authentication & Role Determination ───────────────────────────────────

  Future<Map<String, dynamic>> loginWithCollegeEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Strict college domain check: ONLY sasi.ac.in
    if (!SupabaseConfig.isValidCollegeEmail(cleanEmail)) {
      return {
        'success': false,
        'message': 'Access restricted to official college email only (@${SupabaseConfig.collegeDomain}).',
      };
    }

    _isLoadingFromSupabase = true;
    notifyListeners();

    try {
      // 2. Fetch authoritative profile & role from database
      final profile = await _supabaseService.fetchUserProfile(cleanEmail);

      if (profile != null) {
        _currentUser = profile;
        await syncFromSupabase();
        _isLoadingFromSupabase = false;
        notifyListeners();

        return {
          'success': true,
          'user': profile,
          'role': profile.role,
        };
      } else {
        // Fallback for demonstration if user not in online db table yet
        final isStaffEmail = cleanEmail.contains('staff') || cleanEmail.contains('faculty') || cleanEmail.contains('hod');
        final isAdminEmail = cleanEmail.contains('admin') || cleanEmail.contains('principal');

        final fallbackRole = isAdminEmail
            ? UserRole.admin
            : isStaffEmail
                ? UserRole.staff
                : UserRole.student;

        _currentUser = UserModel(
          id: 'u_${cleanEmail.split('@').first}',
          name: cleanEmail.split('@').first.toUpperCase(),
          email: cleanEmail,
          rollNumber: cleanEmail.split('@').first.toUpperCase(),
          role: fallbackRole,
          department: 'Information Technology',
          academicDetails: fallbackRole == UserRole.student
              ? 'B.Tech IT • 3rd Year'
              : fallbackRole == UserRole.staff
                  ? 'Faculty Coordinator'
                  : 'System Administrator',
          yearLevel: fallbackRole == UserRole.student ? '3rd Year' : 'Department',
          section: 'B',
          labPassId: 'ELITE_QR_${cleanEmail.split('@').first.toUpperCase()}',
        );

        await syncFromSupabase();
        _isLoadingFromSupabase = false;
        notifyListeners();

        return {
          'success': true,
          'user': _currentUser,
          'role': fallbackRole,
        };
      }
    } catch (e) {
      _isLoadingFromSupabase = false;
      notifyListeners();
      return {'success': false, 'message': 'Authentication failed: $e'};
    }
  }

  void logout() {
    _currentUser = MockRepository.studentUser;
    notifyListeners();
  }

  // ─── Supabase Data Synchronization ─────────────────────────────────────────

  Future<void> syncFromSupabase() async {
    if (!_supabaseService.isInitialized) return;

    _isLoadingFromSupabase = true;
    notifyListeners();

    try {
      // 1. Fetch live user profile
      final liveUser = await _supabaseService.fetchUserProfile(_currentUser.rollNumber);
      if (liveUser != null) {
        _currentUser = liveUser;
      }

      // 2. Fetch live attendance logs
      final liveLogs = await _supabaseService.fetchAttendanceLogs(
        _currentUser.isStudent ? _currentUser.rollNumber : null,
      );
      if (liveLogs.isNotEmpty) {
        _attendanceLogs.clear();
        _attendanceLogs.addAll(liveLogs);
      }

      // 3. Fetch live events
      final supaEvents = await _supabaseService.fetchEvents();
      if (supaEvents.isNotEmpty) {
        final registeredIds = await _supabaseService.fetchUserRegisteredEventIds(_currentUser.id);
        for (var ev in supaEvents) {
          if (registeredIds.contains(ev.id)) {
            ev.isRegistered = true;
          }
        }
        _events = supaEvents;
      }

      // 4. Fetch live polls
      final supaPolls = await _supabaseService.fetchPolls(userId: _currentUser.id);
      if (supaPolls.isNotEmpty) {
        _polls = supaPolls;
      }

      // 5. Fetch live notifications
      final supaNotifs = await _supabaseService.fetchNotifications(userId: _currentUser.id);
      if (supaNotifs.isNotEmpty) {
        _notifications = supaNotifs;
      }

      // 6. If Staff or Admin, fetch student and staff rosters
      if (_currentUser.isStaff || _currentUser.isAdmin) {
        final students = await _supabaseService.fetchStudentsList();
        if (students.isNotEmpty) _studentsRoster = students;

        final staff = await _supabaseService.fetchStaffList();
        if (staff.isNotEmpty) _staffRoster = staff;
      }

      _leaderboard = _supabaseService.getLiveLeaderboard();
    } catch (e) {
      debugPrint('AppState syncFromSupabase error: $e');
    } finally {
      _isLoadingFromSupabase = false;
      notifyListeners();
    }
  }

  void setEventCategory(String category) {
    _selectedEventCategory = category;
    notifyListeners();
  }

  // ─── Event Registration: Individual & Team Flows ───────────────────────────

  Future<Map<String, dynamic>> registerIndividualEvent({required String eventId}) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) {
      return {'success': false, 'message': 'Event not found.'};
    }

    if (isStudentRegisteredForEvent(eventId)) {
      return {'success': false, 'message': 'You are already registered for this event.'};
    }

    final target = _events[index];
    if (target.seatsLeft <= 0) {
      return {'success': false, 'message': 'Registration closed: No seats left.'};
    }

    final reg = EventRegistrationModel(
      id: 'reg_${eventId}_${_currentUser.id}',
      eventId: eventId,
      isTeam: false,
      studentId: _currentUser.id,
      studentRoll: _currentUser.rollNumber,
      studentName: _currentUser.name,
      studentEmail: _currentUser.email,
      studentYear: _currentUser.yearLevel,
      members: [
        TeamMemberInfo(
          studentId: _currentUser.id,
          studentRoll: _currentUser.rollNumber,
          studentName: _currentUser.name,
          studentEmail: _currentUser.email,
          studentDept: _currentUser.department,
          studentYear: _currentUser.yearLevel,
          isLeader: true,
        ),
      ],
      registeredAt: DateTime.now().toIso8601String(),
    );

    _registrations.insert(0, reg);
    target.isRegistered = true;
    target.seatsLeft = (target.seatsLeft - 1).clamp(0, target.totalSeats);
    notifyListeners();

    if (_supabaseService.isInitialized) {
      await _supabaseService.registerEvent(eventId: eventId, user: _currentUser);
    }
    return {'success': true, 'message': 'Registration confirmed for ${target.title}!'};
  }

  Future<Map<String, dynamic>> registerTeamEvent({
    required String eventId,
    required String teamName,
    required List<TeamMemberInfo> members,
  }) async {
    final cleanTeamName = teamName.trim();
    if (cleanTeamName.isEmpty) {
      return {'success': false, 'message': 'Please provide a valid team name.'};
    }

    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) {
      return {'success': false, 'message': 'Event not found.'};
    }

    final target = _events[index];

    if (members.length < target.minTeamSize) {
      return {
        'success': false,
        'message': 'Team must have at least ${target.minTeamSize} members.',
      };
    }

    if (members.length > target.maxTeamSize) {
      return {
        'success': false,
        'message': 'Team exceeds maximum allowed size of ${target.maxTeamSize} members.',
      };
    }

    // Check duplicate registrations across team members
    for (final m in members) {
      if (isStudentRegisteredInAnyTeam(eventId, m.studentRoll) ||
          isStudentRegisteredInAnyTeam(eventId, m.studentEmail)) {
        return {
          'success': false,
          'message': '${m.studentName} (${m.studentRoll}) is already registered for this event.',
        };
      }
    }

    final reg = EventRegistrationModel(
      id: 'team_${eventId}_${DateTime.now().millisecondsSinceEpoch}',
      eventId: eventId,
      isTeam: true,
      teamName: cleanTeamName,
      studentId: _currentUser.id,
      studentRoll: _currentUser.rollNumber,
      studentName: _currentUser.name,
      studentEmail: _currentUser.email,
      studentYear: _currentUser.yearLevel,
      members: members,
      registeredAt: DateTime.now().toIso8601String(),
    );

    _registrations.insert(0, reg);
    target.isRegistered = true;
    target.seatsLeft = (target.seatsLeft - members.length).clamp(0, target.totalSeats);
    notifyListeners();

    if (_supabaseService.isInitialized) {
      await _supabaseService.registerTeam(
        eventId: eventId,
        teamName: cleanTeamName,
        leader: _currentUser,
        members: members,
      );
    }

    return {
      'success': true,
      'message': 'Team "$cleanTeamName" successfully registered with ${members.length} members!',
    };
  }

  Future<void> cancelEventRegistration(String eventId) async {
    _registrations.removeWhere((r) => r.eventId == eventId && r.containsStudent(_currentUser.rollNumber));
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      _events[index].isRegistered = false;
      _events[index].seatsLeft = (_events[index].seatsLeft + 1).clamp(0, _events[index].totalSeats);
    }
    notifyListeners();
    if (_supabaseService.isInitialized) {
      await _supabaseService.cancelRegistration(eventId: eventId, userId: _currentUser.id);
    }
  }

  // Backward compatibility alias
  Future<void> toggleEventRegistration(String eventId) async {
    if (isStudentRegisteredForEvent(eventId)) {
      await cancelEventRegistration(eventId);
    } else {
      await registerIndividualEvent(eventId: eventId);
    }
  }

  // ─── Event Management (Staff & Admin) ──────────────────────────────────────

  Future<bool> createEvent({
    required String title,
    required String description,
    required String category,
    required String venue,
    required String eventDate,
    required String startTime,
    required String endTime,
    required int maxCapacity,
    required String facultyCoordinators,
    required String rules,
  }) async {
    final success = await _supabaseService.createEvent(
      title: title,
      description: description,
      category: category,
      venue: venue,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      maxCapacity: maxCapacity,
      facultyCoordinators: facultyCoordinators,
      rules: rules,
    );
    if (success) {
      await syncFromSupabase();
    }
    return success;
  }

  Future<bool> deleteEvent(String eventId) async {
    final success = await _supabaseService.deleteEvent(eventId);
    if (success) {
      _events.removeWhere((e) => e.id == eventId);
      notifyListeners();
    }
    return success;
  }

  Future<List<EventRegistrationModel>> fetchEventRegistrations(String eventId) async {
    final remote = await _supabaseService.fetchEventRegistrations(eventId);
    if (remote.isNotEmpty) return remote;
    return _registrations.where((r) => r.eventId == eventId).toList();
  }

  // ─── QR Attendance (Staff & Admin Only) ────────────────────────────────────

  Future<Map<String, dynamic>> scanAndMarkAttendance({
    required String qrOrRoll,
    required String eventId,
    required String session,
  }) async {
    final result = await _supabaseService.validateAndMarkAttendanceByQr(
      qrOrRoll: qrOrRoll,
      eventId: eventId,
      session: session,
      scannedBy: _currentUser.name,
    );

    if (result['success'] == true) {
      final now = DateTime.now();
      _attendanceLogs.insert(
        0,
        AttendanceLog(
          id: 'log-${now.millisecondsSinceEpoch}',
          date: 'Today',
          time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          subject: eventId,
          room: session,
          status: 'Present',
        ),
      );
      notifyListeners();
    }
    return result;
  }

  // ─── Polls (Students Vote; Staff & Admin Create; Staff CANNOT Vote) ─────────

  Future<bool> voteOnPoll(String pollId, int optionIndex) async {
    // Restriction: Staff cannot vote in polls!
    if (_currentUser.isStaff) {
      debugPrint('Staff accounts are prohibited from voting in student polls.');
      return false;
    }

    final pollIndex = _polls.indexWhere((p) => p.id == pollId);
    if (pollIndex == -1) return false;

    final poll = _polls[pollIndex];
    if (poll.userVotedIndex != null) {
      poll.options[poll.userVotedIndex!].votes--;
    }
    poll.userVotedIndex = optionIndex;
    poll.options[optionIndex].votes++;
    notifyListeners();

    if (_supabaseService.isInitialized) {
      final opt = poll.options[optionIndex];
      await _supabaseService.castVote(
        pollId: pollId,
        optionId: opt.id,
        userId: _currentUser.id,
      );
    }
    return true;
  }

  Future<bool> createPoll({
    required String question,
    required String description,
    required String category,
    required List<String> options,
  }) async {
    final success = await _supabaseService.createPoll(
      question: question,
      description: description,
      category: category,
      options: options,
    );
    if (success) {
      await syncFromSupabase();
    }
    return success;
  }

  // ─── Notifications & Alerts (Staff & Admin Dispatch) ───────────────────────

  Future<bool> broadcastNotice({
    required String title,
    required String message,
    String category = 'Urgent',
    String targetAudience = 'ALL',
  }) async {
    final success = await _supabaseService.broadcastNotification(
      title: title,
      message: message,
      category: category,
      targetAudience: targetAudience,
    );
    if (success) {
      await syncFromSupabase();
    }
    return success;
  }

  Future<void> markNotificationAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
      if (_supabaseService.isInitialized) {
        await SupabaseService.client?.from('notification_reads').upsert({
          'id': '${id}_${_currentUser.id}',
          'notification_id': id,
          'user_id': _currentUser.id,
          'read_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  void markAllNotificationsAsRead() {
    for (final notif in _notifications) {
      notif.isRead = true;
    }
    notifyListeners();
  }

  void switchRole(UserRole role) {
    _currentUser = UserModel(
      id: 'demo_${role.name}',
      name: role == UserRole.student
          ? 'Phani Kumar'
          : role == UserRole.staff
              ? 'Dr. K. Srinivas (Faculty)'
              : 'SysAdmin IT Dept',
      email: role == UserRole.student
          ? '24K61A1259@sasi.ac.in'
          : role == UserRole.staff
              ? 'hod_it@sasi.ac.in'
              : 'admin@sasi.ac.in',
      rollNumber: role == UserRole.student ? '24K61A1259' : (role == UserRole.staff ? 'FAC104' : 'HOD-IT'),
      role: role,
      department: 'Information Technology',
      academicDetails: role == UserRole.student
          ? 'B.Tech IT • 3rd Year • Section B'
          : (role == UserRole.staff ? 'Associate Professor & Lab In-charge' : 'Lead Administrator'),
      yearLevel: role == UserRole.student ? '3rd Year' : 'Faculty',
      section: 'B',
      labPassId: 'ELITE_QR_${role.name.toUpperCase()}',
    );
    notifyListeners();
  }

  void addAttendanceLog({required String subject, required String room, String status = 'Present'}) {
    final now = DateTime.now();
    _attendanceLogs.insert(
      0,
      AttendanceLog(
        id: 'log-${now.millisecondsSinceEpoch}',
        date: 'Today',
        time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        subject: subject,
        room: room,
        status: status,
      ),
    );
    notifyListeners();
  }

}

