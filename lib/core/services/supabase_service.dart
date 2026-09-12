import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../../data/models/app_models.dart';

class SupabaseService extends ChangeNotifier {
  static String _url = SupabaseConfig.url;
  static String _anonKey = SupabaseConfig.anonKey;
  static bool _isInitialized = false;

  String get url => _url;
  String get anonKey => _anonKey;
  bool get isInitialized => _isInitialized;
  bool get isConfigured => SupabaseConfig.isConfigured;

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    _url = SupabaseConfig.url.trim();
    _anonKey = SupabaseConfig.anonKey.trim();

    if (!isConfigured) {
      debugPrint('SupabaseService: SupabaseConfig.isConfigured is false. Paste keys in lib/core/config/supabase_config.dart.');
      _isInitialized = false;
      notifyListeners();
      return;
    }

    try {
      await Supabase.initialize(
        url: _url,
        // ignore: deprecated_member_use
        anonKey: _anonKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      debugPrint('SupabaseService: Successfully initialized and connected live to $_url');
    } catch (e) {
      debugPrint('SupabaseService.init error: $e');
      _isInitialized = false;
    }
    notifyListeners();
  }


  Future<bool> updateCredentials(String newUrl, String newKey) async {
    _url = newUrl.trim();
    _anonKey = newKey.trim();
    if (_url.isEmpty || _anonKey.isEmpty || _url.contains('YOUR_SUPABASE') || _anonKey.contains('YOUR_SUPABASE')) {
      _isInitialized = false;
      notifyListeners();
      return false;
    }

    try {
      await Supabase.initialize(
        url: _url,
        // ignore: deprecated_member_use
        anonKey: _anonKey,
        debug: kDebugMode,
      );
      _isInitialized = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('SupabaseService.updateCredentials error: $e');
      _isInitialized = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Events ───────────────────────────────────────────────────────────────

  Future<List<EventModel>> fetchEvents() async {
    final c = client;
    if (c == null) return [];

    try {
      final res = await c
          .from('events')
          .select()
          .order('event_date', ascending: true);

      final List<EventModel> list = [];
      for (var row in res) {
        final dateStr = (row['event_date'] ?? '2026-10-24').toString();
        final parts = dateStr.split('-');
        String month = "OCT";
        String day = "24";
        if (parts.length >= 3) {
          final mInt = int.tryParse(parts[1]) ?? 10;
          const months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
          month = months[(mInt - 1).clamp(0, 11)];
          day = parts[2];
        }

        final maxCap = (row['max_capacity'] as num?)?.toInt() ?? 100;
        final regCount = (row['registered_count'] as num?)?.toInt() ?? 0;

        list.add(EventModel(
          id: row['id'].toString(),
          title: row['title'] ?? 'Department Event',
          description: row['description'] ?? '',
          category: row['event_type'] ?? 'Workshops',
          dateMonth: month,
          dateDay: day,
          time: '${row['start_time'] ?? '10:00 AM'} • ${row['venue'] ?? 'Auditorium'}',
          venue: row['venue'] ?? 'Campus Main Lab',
          speaker: row['faculty_coordinators'] ?? 'Department Faculty',
          seatsLeft: (maxCap - regCount).clamp(0, maxCap),
          totalSeats: maxCap,
          isRegistered: false,
        ));
      }
      return list;
    } catch (e) {
      debugPrint('Supabase fetchEvents error: $e');
      return [];
    }
  }

  Future<bool> registerEvent({
    required String eventId,
    required UserModel user,
  }) async {
    final c = client;
    if (c == null) return false;

    try {
      final regId = '${eventId}_${user.id}';
      await c.from('event_registrations').upsert({
        'id': regId,
        'event_id': eventId,
        'student_id': user.id,
        'student_roll': user.rollNumber,
        'student_name': user.name,
        'student_email': user.email,
        'student_year': user.academicDetails,
        'status': 'CONFIRMED',
        'registered_at': DateTime.now().toIso8601String(),
      });

      // Update registered count in events table
      try {
        final ev = await c.from('events').select('registered_count').eq('id', eventId).single();
        final cur = (ev['registered_count'] as num?)?.toInt() ?? 0;
        await c.from('events').update({'registered_count': cur + 1}).eq('id', eventId);
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('Supabase registerEvent error: $e');
      return false;
    }
  }

  Future<bool> cancelRegistration({
    required String eventId,
    required String userId,
  }) async {
    final c = client;
    if (c == null) return false;

    try {
      final regId = '${eventId}_$userId';
      await c.from('event_registrations').delete().eq('id', regId);

      // Decrement count
      try {
        final ev = await c.from('events').select('registered_count').eq('id', eventId).single();
        final cur = (ev['registered_count'] as num?)?.toInt() ?? 1;
        await c.from('events').update({'registered_count': (cur - 1).clamp(0, 9999)}).eq('id', eventId);
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('Supabase cancelRegistration error: $e');
      return false;
    }
  }

  Future<List<String>> fetchUserRegisteredEventIds(String userId) async {
    final c = client;
    if (c == null) return [];

    try {
      final res = await c
          .from('event_registrations')
          .select('event_id')
          .eq('student_id', userId);
      return res.map((r) => r['event_id'].toString()).toList();
    } catch (e) {
      debugPrint('Supabase fetchUserRegisteredEventIds error: $e');
      return [];
    }
  }

  // ─── Attendance ───────────────────────────────────────────────────────────

  Future<bool> logAttendance({
    required String subject,
    required String room,
    required UserModel user,
    String status = "Present",
  }) async {
    final c = client;
    if (c == null) return false;

    try {
      await c.from('event_attendance').insert({
        'id': 'ATT-${DateTime.now().millisecondsSinceEpoch}',
        'event_id': subject,
        'student_id': user.id,
        'student_roll': user.rollNumber,
        'student_name': user.name,
        'student_email': user.email,
        'scanned_by': 'Turnstile Gate #2',
        'status': status.toUpperCase(),
        'session': room,
        'scanned_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Supabase logAttendance error: $e');
      return false;
    }
  }

  // ─── Polls ─────────────────────────────────────────────────────────────────

  Future<List<PollModel>> fetchPolls({String? userId}) async {
    final c = client;
    if (c == null) return [];

    try {
      final pollsRes = await c
          .from('polls')
          .select()
          .eq('status', 'OPEN')
          .order('created_at', ascending: false);

      final List<PollModel> polls = [];
      for (final p in pollsRes) {
        final pollId = p['id'].toString();

        final optsRes = await c
            .from('poll_options')
            .select()
            .eq('poll_id', pollId);

        int? votedIndex;
        if (userId != null) {
          final voteRes = await c
              .from('poll_votes')
              .select('option_id')
              .eq('poll_id', pollId)
              .eq('student_id', userId)
              .maybeSingle();

          if (voteRes != null) {
            final optId = voteRes['option_id'].toString();
            for (int i = 0; i < optsRes.length; i++) {
              if (optsRes[i]['id'].toString() == optId) {
                votedIndex = i;
                break;
              }
            }
          }
        }

        final options = optsRes.map((o) => PollOption(
          id: o['id'].toString(),
          text: o['text'] ?? '',
          votes: (o['vote_count'] as num?)?.toInt() ?? 0,
        )).toList();

        polls.add(PollModel(
          id: pollId,
          question: p['question'] ?? '',
          description: p['description'] ?? '',
          category: p['category'] ?? 'Department',
          options: options,
          userVotedIndex: votedIndex,
          expiresText: 'Closes soon',
        ));
      }
      return polls;
    } catch (e) {
      debugPrint('Supabase fetchPolls error: $e');
      return [];
    }
  }

  Future<bool> castVote({
    required String pollId,
    required String optionId,
    required String userId,
  }) async {
    final c = client;
    if (c == null) return false;

    try {
      final voteId = '${pollId}_$userId';
      await c.from('poll_votes').upsert({
        'id': voteId,
        'poll_id': pollId,
        'option_id': optionId,
        'student_id': userId,
        'voted_at': DateTime.now().toIso8601String(),
      });

      // Increment vote count on option
      try {
        final opt = await c.from('poll_options').select('vote_count').eq('id', optionId).single();
        final current = (opt['vote_count'] as num?)?.toInt() ?? 0;
        await c.from('poll_options').update({'vote_count': current + 1}).eq('id', optionId);
      } catch (_) {}

      return true;
    } catch (e) {
      debugPrint('Supabase castVote error: $e');
      return false;
    }
  }

  // ─── Notifications & Broadcasts ──────────────────────────────────────────

  Future<List<AppNotification>> fetchNotifications({String? userId}) async {
    final c = client;
    if (c == null) return [];

    try {
      final notifsRes = await c
          .from('notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      Set<String> readIds = {};
      if (userId != null) {
        final readsRes = await c
            .from('notification_reads')
            .select('notification_id')
            .eq('user_id', userId);
        readIds = readsRes.map((r) => r['notification_id'].toString()).toSet();
      }

      final List<AppNotification> list = [];
      for (final n in notifsRes) {
        final nId = n['id'].toString();
        list.add(AppNotification(
          id: nId,
          title: n['title'] ?? 'Notice',
          message: n['message'] ?? '',
          timeAgo: 'Recent',
          category: n['category'] ?? 'System',
          isRead: readIds.contains(nId),
        ));
      }
      return list;
    } catch (e) {
      debugPrint('Supabase fetchNotifications error: $e');
      return [];
    }
  }

  Future<void> markNotificationRead(String notifId, String userId) async {
    final c = client;
    if (c == null) return;

    try {
      await c.from('notification_reads').upsert({
        'id': '${notifId}_$userId',
        'notification_id': notifId,
        'user_id': userId,
        'read_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Supabase markNotificationRead error: $e');
    }
  }

  Future<bool> broadcastNotification({
    required String title,
    required String message,
    String category = 'Urgent',
  }) async {
    final c = client;
    if (c == null) return false;

    try {
      await c.from('notifications').insert({
        'id': 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
        'title': title,
        'message': message,
        'category': category,
        'target_audience': 'ALL',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Supabase broadcastNotification error: $e');
      return false;
    }
  }

  // ─── Student Queries (Service Tickets) ───────────────────────────────────

  Future<List<ServiceTicket>> fetchTickets({String? rollNo}) async {
    final c = client;
    if (c == null) return [];

    try {
      final res = rollNo != null
          ? await c.from('student_queries').select().ilike('roll_no', rollNo).order('created_at', ascending: false)
          : await c.from('student_queries').select().order('created_at', ascending: false);
      return res.map((r) => ServiceTicket(
        id: r['id'].toString(),
        title: r['title'] ?? 'Department Ticket',
        description: r['description'] ?? '',
        status: (r['status'] ?? 'QUEUED').toString().toUpperCase(),
        updatedAt: 'Live Supabase',
        assignee: r['mentor'] ?? 'IT Helpdesk',
      )).toList();
    } catch (e) {
      debugPrint('Supabase fetchTickets error: $e');
      return [];
    }
  }

  Future<bool> submitTicket({
    required String title,
    required String description,
    required UserModel user,
  }) async {
    final c = client;
    if (c == null) return false;

    try {
      await c.from('student_queries').insert({
        'id': 'TICK-${DateTime.now().millisecondsSinceEpoch}',
        'student_name': user.name,
        'roll_no': user.rollNumber,
        'email': user.email,
        'year_level': user.academicDetails,
        'category': 'Lab Support',
        'mentor': 'IT Helpdesk',
        'title': title,
        'description': description,
        'status': 'QUEUED',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Supabase submitTicket error: $e');
      return false;
    }
  }

  // ─── User Profile Resolution ─────────────────────────────────────────────

  Future<UserModel?> fetchUserProfile(String identifier) async {
    final c = client;
    if (c == null) return null;

    final q = identifier.trim();
    if (q.isEmpty) return null;

    try {
      // 1. Check students table
      final studentRes = await c
          .from('students')
          .select()
          .or('roll_no.ilike.$q,email.ilike.$q,user_id.eq.$q')
          .maybeSingle();

      if (studentRes != null) {
        final roll = studentRes['roll_no']?.toString() ?? q;
        final name = studentRes['name']?.toString() ?? 'IT Student';
        final email = studentRes['email']?.toString() ?? '$roll@sasi.ac.in';
        final yr = studentRes['year_level']?.toString() ?? '3rd Year';
        final qr = studentRes['qr_token']?.toString() ?? 'ELITE_QR_$roll';

        return UserModel(
          id: studentRes['user_id']?.toString() ?? 'u_${roll.toLowerCase()}',
          name: name,
          email: email,
          rollNumber: roll,
          role: UserRole.student,
          department: studentRes['department']?.toString() ?? 'Information Technology',
          academicDetails: 'B.Tech IT • $yr',
          labPassId: qr,
          labPassRoom: 'IT Lab & Turnstile Gate #2',
          labPassExpiry: 'AY 2026-2027',
          cgpa: 9.15,
          attendancePercent: 92,
        );
      }

      // 2. Check staff table
      final staffRes = await c
          .from('staff')
          .select()
          .or('employee_id.ilike.$q,email.ilike.$q,user_id.eq.$q')
          .maybeSingle();

      if (staffRes != null) {
        return UserModel(
          id: staffRes['user_id']?.toString() ?? 'u_staff',
          name: staffRes['name']?.toString() ?? 'Department Faculty',
          email: staffRes['email']?.toString() ?? 'staff@elite.edu',
          rollNumber: staffRes['employee_id']?.toString() ?? 'EMP_IT',
          role: UserRole.staff,
          department: staffRes['department']?.toString() ?? 'Information Technology',
          academicDetails: staffRes['designation']?.toString() ?? 'Faculty Coordinator',
          labPassId: 'FAC-PASS-01',
          labPassRoom: staffRes['cabin']?.toString() ?? 'IT Department',
          labPassExpiry: 'Full Faculty Clearance',
          cgpa: 0,
          attendancePercent: 98,
        );
      }

      // 3. Check users table for SUPER_ADMIN
      final userRes = await c
          .from('users')
          .select()
          .or('username.ilike.$q,email.ilike.$q,id.eq.$q')
          .maybeSingle();

      if (userRes != null && userRes['role'] == 'SUPER_ADMIN') {
        return UserModel(
          id: userRes['id']?.toString() ?? 'u_admin',
          name: 'System Administrator',
          email: userRes['email']?.toString() ?? 'admin@elite.edu',
          rollNumber: 'ADMIN-IT',
          role: UserRole.admin,
          department: 'Information Technology',
          academicDetails: 'ELITE IT Department Super Admin',
          labPassId: 'ROOT-KEY-00',
          labPassRoom: 'Campus Data Center & Core Infrastructure',
          labPassExpiry: 'Permanent Admin Clearance',
          cgpa: 0,
          attendancePercent: 100,
        );
      }
    } catch (e) {
      debugPrint('SupabaseService.fetchUserProfile error: $e');
    }
    return null;
  }

  // ─── Live Attendance Logs ──────────────────────────────────────────────────

  Future<List<AttendanceLog>> fetchAttendanceLogs(String studentRoll) async {
    final c = client;
    if (c == null) return [];

    try {
      final res = await c
          .from('event_attendance')
          .select()
          .ilike('student_roll', studentRoll.trim())
          .order('scanned_at', ascending: false)
          .limit(30);

      return res.map((r) {
        final dateStr = (r['scanned_at'] ?? DateTime.now().toIso8601String()).toString();
        final dt = DateTime.tryParse(dateStr) ?? DateTime.now();
        final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        return AttendanceLog(
          id: r['id']?.toString() ?? 'log',
          date: '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
          time: timeStr,
          subject: r['event_id']?.toString() ?? 'Department Session',
          room: r['scanned_by']?.toString() ?? 'Turnstile Gate #2',
          status: (r['status']?.toString() ?? 'PRESENT').toUpperCase() == 'PRESENT' ? 'Present' : 'Late',
        );
      }).toList();
    } catch (e) {
      debugPrint('SupabaseService.fetchAttendanceLogs error: $e');
      return [];
    }
  }

}
