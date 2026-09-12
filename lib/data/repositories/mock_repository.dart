import '../models/app_models.dart';

class MockRepository {
  /// Real Student Profile: Phani Kumar Koppisetti (24K61A1259)
  static final UserModel studentUser = UserModel(
    id: "u_24k61a1259",
    name: "Phani Kumar Koppisetti",
    email: "phanikumar.koppisetti24@sasi.ac.in",
    rollNumber: "24K61A1259",
    role: UserRole.student,
    department: "Information Technology",
    academicDetails: "B.Tech IT • 3rd Year Section B",
    labPassId: "ELITE_QR_24K61A1259",
    labPassRoom: "IT Lab & Turnstile Gate #2",
    labPassExpiry: "AY 2026-2027",
    cgpa: 9.15,
    attendancePercent: 92,
  );

  /// Real Staff Profile: Dr. Ramesh Kumar (HoD IT)
  static final UserModel staffUser = UserModel(
    id: "u_staff01",
    name: "Dr. Ramesh Kumar",
    email: "ramesh@elite.edu",
    rollNumber: "EMP_IT_01",
    role: UserRole.staff,
    department: "Information Technology",
    academicDetails: "Head of Department (HoD) • IT Department",
    labPassId: "FAC-IT-01",
    labPassRoom: "All IT Facilities & Server Rooms",
    labPassExpiry: "Full Faculty Clearance",
    cgpa: 0,
    attendancePercent: 98,
  );

  /// Real Super Admin Profile
  static final UserModel adminUser = UserModel(
    id: "u_admin",
    name: "System Administrator",
    email: "admin@elite.edu",
    rollNumber: "ADMIN-IT",
    role: UserRole.admin,
    department: "Information Technology",
    academicDetails: "ELITE IT Department Super Admin",
    labPassId: "ROOT-KEY-00",
    labPassRoom: "Campus Data Center & Core Infrastructure",
    labPassExpiry: "Permanent Admin Clearance",
    cgpa: 0,
    attendancePercent: 100,
  );

  /// Real Department Events
  static List<EventModel> getInitialEvents() => [
    EventModel(
      id: "ev_vibe_coding",
      title: "Vibe Coding",
      description: "Fast-paced competitive programming and agile problem-solving sprint in the departmental lab.",
      category: "Technical",
      dateMonth: "SEP",
      dateDay: "15",
      time: "10:00 AM • IT Lab",
      venue: "IT Lab, IT Department",
      speaker: "Faculty: K. Rammohana Rao",
      seatsLeft: 32,
      totalSeats: 80,
      isRegistered: false,
    ),
    EventModel(
      id: "ev_debugging",
      title: "Debugging Challenge",
      description: "Error-identification and code-correction competition testing logical thinking and C programming skills.",
      category: "Technical",
      dateMonth: "SEP",
      dateDay: "15",
      time: "10:45 AM • IT Lab",
      venue: "IT Lab, IT Department",
      speaker: "Faculty: T. Vinay",
      seatsLeft: 18,
      totalSeats: 80,
      isRegistered: false,
    ),
    EventModel(
      id: "ev_tech_quiz",
      title: "Tech Quiz 2026",
      description: "Individual technical knowledge competition across two rounds testing CS/IT concepts and emerging tech.",
      category: "Technical",
      dateMonth: "SEP",
      dateDay: "15",
      time: "11:55 AM • IT Lab",
      venue: "IT Lab, IT Department",
      speaker: "Faculty: K. Rammohana Rao",
      seatsLeft: 24,
      totalSeats: 100,
      isRegistered: true,
    ),
    EventModel(
      id: "ev_idea_pitch",
      title: "Idea Pitch & Innovation",
      description: "Department innovation summit presenting disruptive software architectures and research prototypes.",
      category: "Seminars",
      dateMonth: "SEP",
      dateDay: "15",
      time: "02:00 PM • Seminar Hall",
      venue: "Seminar Hall & Innovation Hub",
      speaker: "Dr. Ramesh Kumar, HoD IT",
      seatsLeft: 45,
      totalSeats: 100,
      isRegistered: false,
    ),
  ];

  static List<ServiceTicket> getInitialTickets() => [];

  static List<SubjectAttendance> getSubjectAttendance() => [
    SubjectAttendance(
      code: "IT301",
      title: "Full Stack & Cloud Systems",
      attended: 24,
      total: 26,
      faculty: "Er. Vignesh Babu",
    ),
    SubjectAttendance(
      code: "IT302",
      title: "Database Engineering & PostgreSQL",
      attended: 21,
      total: 22,
      faculty: "Dr. Ramesh Kumar",
    ),
    SubjectAttendance(
      code: "IT303",
      title: "Artificial Intelligence & Edge ML",
      attended: 19,
      total: 20,
      faculty: "Prof. Sunita Reddy",
    ),
  ];

  static List<AttendanceLog> getAttendanceLogs() => [
    AttendanceLog(
      id: "att-1",
      date: "Today",
      time: "09:05 AM",
      subject: "IT301 Full Stack Systems",
      room: "Turnstile Gate #2 Check-in",
      status: "Present",
    ),
    AttendanceLog(
      id: "att-2",
      date: "Yesterday",
      time: "10:00 AM",
      subject: "IT302 Database Engineering",
      room: "IT Lab 401 Turnstile",
      status: "Present",
    ),
  ];

  static List<PollModel> getInitialPolls() => [
    PollModel(
      id: "poll_tech_symposium",
      question: "Which emerging tech track should lead the next ELITE Winter Symposium?",
      description: "Vote for the primary technology track of our upcoming department national symposium.",
      category: "Department",
      options: [
        PollOption(id: "opt_ai_agents", text: "Autonomous AI Agents & Multi-Modal LLMs", votes: 142),
        PollOption(id: "opt_crypto", text: "Zero-Knowledge Cryptography & Web3 Infra", votes: 88),
        PollOption(id: "opt_quantum", text: "Quantum Computing & Silicon Photonics", votes: 64),
        PollOption(id: "opt_robotics", text: "Embedded Robotics & ROS2 Real-Time Control", votes: 115),
      ],
      userVotedIndex: 0,
      expiresText: "Closes soon",
    ),
  ];

  static List<AppNotification> getInitialNotifications() => [
    AppNotification(
      id: "notif_001",
      title: "Lab 4 Maintenance Window",
      message: "High Performance Cluster 4 will undergo scheduled firmware upgrades this Sunday 2:00 AM to 6:00 AM.",
      timeAgo: "15m ago",
      category: "Urgent",
      isRead: false,
    ),
    AppNotification(
      id: "notif_002",
      title: "ELITE Symposium Paper Submissions Open",
      message: "Abstract submission portal is now accepting IEEE-format research drafts until Nov 1st.",
      timeAgo: "2h ago",
      category: "Academic",
      isRead: false,
    ),
    AppNotification(
      id: "notif_003",
      title: "Campus Turnstile Pass Generation",
      message: "Ensure your digital student profile QR code is active for turnstile access at Gate 2.",
      timeAgo: "1d ago",
      category: "System",
      isRead: true,
    ),
  ];
}
