enum UserRole { student, staff, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String rollNumber;
  final UserRole role;
  final String department;
  final String academicDetails; // e.g. "B.Tech IT • Sem 6" or "Associate Professor"
  final String labPassId;
  final String labPassRoom;
  final String labPassExpiry;
  final double cgpa;
  final int attendancePercent;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.rollNumber,
    required this.role,
    required this.department,
    required this.academicDetails,
    this.labPassId = "IT-9942",
    this.labPassRoom = "Advanced AI & Systems Lab 402",
    this.labPassExpiry = "6:00 PM Today",
    this.cgpa = 8.94,
    this.attendancePercent = 88,
  });
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String category; // Workshop, Hackathon, Seminar, Tech Talk
  final String dateMonth; // "OCT"
  final String dateDay; // "24"
  final String time;
  final String venue;
  final String speaker;
  int seatsLeft;
  final int totalSeats;
  bool isRegistered;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateMonth,
    required this.dateDay,
    required this.time,
    required this.venue,
    required this.speaker,
    required this.seatsLeft,
    required this.totalSeats,
    this.isRegistered = false,
  });
}

class SubjectAttendance {
  final String code;
  final String title;
  final int attended;
  final int total;
  final String faculty;

  SubjectAttendance({
    required this.code,
    required this.title,
    required this.attended,
    required this.total,
    required this.faculty,
  });

  double get percentage => total == 0 ? 0 : (attended / total) * 100;
}

class AttendanceLog {
  final String id;
  final String date;
  final String time;
  final String subject;
  final String room;
  final String status; // Present, Late, Excused

  AttendanceLog({
    required this.id,
    required this.date,
    required this.time,
    required this.subject,
    required this.room,
    required this.status,
  });
}

class PollOption {
  final String id;
  final String text;
  int votes;

  PollOption({
    required this.id,
    required this.text,
    required this.votes,
  });
}

class PollModel {
  final String id;
  final String question;
  final String description;
  final String category;
  final List<PollOption> options;
  int? userVotedIndex;
  final String expiresText;

  PollModel({
    required this.id,
    required this.question,
    required this.description,
    required this.category,
    required this.options,
    this.userVotedIndex,
    required this.expiresText,
  });

  int get totalVotes => options.fold(0, (sum, opt) => sum + opt.votes);
}

class ServiceTicket {
  final String id;
  final String title;
  final String description;
  final String status; // IN PROGRESS, QUEUED, RESOLVED
  final String updatedAt;
  final String assignee;

  ServiceTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.updatedAt,
    required this.assignee,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String category; // Urgent, Academic, System, Event
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    this.isRead = false,
  });
}

