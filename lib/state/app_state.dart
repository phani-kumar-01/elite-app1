export '../data/models/app_models.dart';
import 'package:flutter/material.dart';
import '../data/models/app_models.dart';
import '../data/repositories/mock_repository.dart';
import '../core/services/supabase_service.dart';

class AppState extends ChangeNotifier {
  final SupabaseService _supabaseService;

  UserModel _currentUser = MockRepository.studentUser;
  List<EventModel> _events = MockRepository.getInitialEvents();
  List<ServiceTicket> _tickets = MockRepository.getInitialTickets();
  final List<SubjectAttendance> _subjectAttendance = MockRepository.getSubjectAttendance();
  final List<AttendanceLog> _attendanceLogs = MockRepository.getAttendanceLogs();
  List<PollModel> _polls = MockRepository.getInitialPolls();
  List<AppNotification> _notifications = MockRepository.getInitialNotifications();

  String _selectedEventCategory = "All";
  bool _isLoadingFromSupabase = false;

  AppState([SupabaseService? supabaseService])
      : _supabaseService = supabaseService ?? SupabaseService() {
    syncFromSupabase();
  }

  UserModel get currentUser => _currentUser;
  List<EventModel> get events => _events;
  List<ServiceTicket> get tickets => _tickets;
  List<SubjectAttendance> get subjectAttendance => _subjectAttendance;
  List<AttendanceLog> get attendanceLogs => _attendanceLogs;
  List<PollModel> get polls => _polls;
  List<AppNotification> get notifications => _notifications;
  String get selectedEventCategory => _selectedEventCategory;
  bool get isLoadingFromSupabase => _isLoadingFromSupabase;
  bool get isSupabaseConnected => _supabaseService.isInitialized;

  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  List<EventModel> get filteredEvents {
    if (_selectedEventCategory == "All") return _events;
    return _events.where((e) => e.category == _selectedEventCategory).toList();
  }

  List<EventModel> get registeredEvents => _events.where((e) => e.isRegistered).toList();

  Future<void> syncFromSupabase() async {
    if (!_supabaseService.isInitialized) return;

    _isLoadingFromSupabase = true;
    notifyListeners();

    try {
      // 0. Fetch live user profile from Supabase
      final liveUser = await _supabaseService.fetchUserProfile(_currentUser.rollNumber);
      if (liveUser != null) {
        _currentUser = liveUser;
      }

      // 0b. Fetch live attendance logs from Supabase
      final liveLogs = await _supabaseService.fetchAttendanceLogs(_currentUser.rollNumber);
      if (liveLogs.isNotEmpty) {
        _attendanceLogs.clear();
        _attendanceLogs.addAll(liveLogs);
      }

      // 1. Fetch live events from Supabase
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

      // 2. Fetch live polls from Supabase
      final supaPolls = await _supabaseService.fetchPolls(userId: _currentUser.id);
      if (supaPolls.isNotEmpty) {
        _polls = supaPolls;
      }

      // 3. Fetch live notifications from Supabase
      final supaNotifs = await _supabaseService.fetchNotifications(userId: _currentUser.id);
      if (supaNotifs.isNotEmpty) {
        _notifications = supaNotifs;
      }

      // 4. Fetch service tickets from Supabase
      final supaTickets = await _supabaseService.fetchTickets(rollNo: _currentUser.rollNumber);
      if (supaTickets.isNotEmpty) {
        _tickets = supaTickets;
      }
    } catch (e) {
      debugPrint('AppState syncFromSupabase error: $e');
    } finally {
      _isLoadingFromSupabase = false;
      notifyListeners();
    }
  }

  void switchRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        _currentUser = MockRepository.studentUser;
        break;
      case UserRole.staff:
        _currentUser = MockRepository.staffUser;
        break;
      case UserRole.admin:
        _currentUser = MockRepository.adminUser;
        break;
    }
    syncFromSupabase();
    notifyListeners();
  }

  void setEventCategory(String category) {
    _selectedEventCategory = category;
    notifyListeners();
  }

  Future<void> toggleEventRegistration(String eventId) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return;

    final target = _events[index];
    final willRegister = !target.isRegistered;

    // Optimistic UI update
    target.isRegistered = willRegister;
    if (willRegister) {
      target.seatsLeft = (target.seatsLeft - 1).clamp(0, target.totalSeats);
    } else {
      target.seatsLeft = (target.seatsLeft + 1).clamp(0, target.totalSeats);
    }
    notifyListeners();

    // Supabase synchronization
    if (_supabaseService.isInitialized) {
      if (willRegister) {
        await _supabaseService.registerEvent(eventId: eventId, user: _currentUser);
      } else {
        await _supabaseService.cancelRegistration(eventId: eventId, userId: _currentUser.id);
      }
    }
  }

  Future<void> voteOnPoll(String pollId, int optionIndex) async {
    final pollIndex = _polls.indexWhere((p) => p.id == pollId);
    if (pollIndex == -1) return;

    final poll = _polls[pollIndex];
    if (poll.userVotedIndex != null) {
      poll.options[poll.userVotedIndex!].votes--;
    }
    poll.userVotedIndex = optionIndex;
    poll.options[optionIndex].votes++;
    notifyListeners();

    // Supabase sync
    if (_supabaseService.isInitialized) {
      final opt = poll.options[optionIndex];
      await _supabaseService.castVote(
        pollId: pollId,
        optionId: opt.id,
        userId: _currentUser.id,
      );
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();

      if (_supabaseService.isInitialized) {
        await _supabaseService.markNotificationRead(id, _currentUser.id);
      }
    }
  }

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
      if (_supabaseService.isInitialized) {
        _supabaseService.markNotificationRead(n.id, _currentUser.id);
      }
    }
    notifyListeners();
  }

  Future<void> addAttendanceLog({
    required String subject,
    required String room,
    String status = "Present",
  }) async {
    final now = DateTime.now();
    _attendanceLogs.insert(
      0,
      AttendanceLog(
        id: "log-${now.millisecondsSinceEpoch}",
        date: "Today, Just now",
        time: "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
        subject: subject,
        room: room,
        status: status,
      ),
    );
    notifyListeners();

    if (_supabaseService.isInitialized) {
      await _supabaseService.logAttendance(
        subject: subject,
        room: room,
        user: _currentUser,
        status: status,
      );
    }
  }

  Future<void> addServiceTicket({required String title, required String description}) async {
    final newTicket = ServiceTicket(
      id: "TICK-#${1000 + _tickets.length}",
      title: title,
      description: description,
      status: "QUEUED",
      updatedAt: "Just now",
      assignee: "IT Helpdesk",
    );
    _tickets.insert(0, newTicket);
    notifyListeners();

    if (_supabaseService.isInitialized) {
      await _supabaseService.submitTicket(
        title: title,
        description: description,
        user: _currentUser,
      );
    }
  }
}
