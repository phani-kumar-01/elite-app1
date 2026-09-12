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
    yearLevel: "3rd Year",
    section: "B",
    labPassId: "ELITE_QR_24K61A1259",
    labPassRoom: "IT Lab & Turnstile Gate #2",
    labPassExpiry: "AY 2026-2027",
    cgpa: 9.15,
    attendancePercent: 92,
  );

  /// Real Staff Profile: Dr. AVN Chandra Sekhar (HoD IT)
  static final UserModel staffUser = UserModel(
    id: "u_staff01",
    name: "Dr. AVN Chandra Sekhar",
    email: "hod_it@sasi.ac.in",
    rollNumber: "EMP_IT_01",
    role: UserRole.staff,
    department: "Information Technology",
    academicDetails: "Head of Department (HoD) • Professor",
    yearLevel: "Faculty",
    section: "IT HOD Cabin",
    phoneNumber: "+91 98480 12345",
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
    email: "admin@sasi.ac.in",
    rollNumber: "ADMIN-IT",
    role: UserRole.admin,
    department: "Information Technology",
    academicDetails: "ELITE IT Department Super Admin",
    yearLevel: "Administration",
    section: "Campus Core Systems",
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
      title: "Vibe Coding Sprint",
      description: "Fast-paced competitive programming and agile problem-solving sprint in the departmental lab.",
      category: "Technical",
      dateMonth: "SEP",
      dateDay: "15",
      time: "10:00 AM - 11:30 AM",
      venue: "IT Lab 4, IT Department",
      speaker: "Dr. AVN Chandra Sekhar",
      seatsLeft: 42,
      totalSeats: 60,
      rules: "Individual participation only. Internet access restricted to documentation.",
      status: "OPEN",
      isTeamEvent: false,
      minTeamSize: 1,
      maxTeamSize: 1,
    ),
    EventModel(
      id: "ev_debugging",
      title: "Code Debugging Challenge",
      description: "Find subtle logic errors, memory leaks, and syntax flaws under high-stress time constraints.",
      category: "Technical",
      dateMonth: "SEP",
      dateDay: "15",
      time: "11:45 AM - 12:45 PM",
      venue: "IT Lab 1 & 2",
      speaker: "Faculty Coordinators",
      seatsLeft: 18,
      totalSeats: 50,
      rules: "Individual participation. Automated test suites determine accuracy.",
      status: "OPEN",
      isTeamEvent: false,
      minTeamSize: 1,
      maxTeamSize: 1,
    ),
    EventModel(
      id: "ev_tech_quiz",
      title: "National Technical Quiz",
      description: "Multi-round quiz tournament spanning algorithms, cloud architecture, cybersecurity, and OS internals.",
      category: "Technical",
      dateMonth: "SEP",
      dateDay: "17",
      time: "02:00 PM - 03:30 PM",
      venue: "AIML Seminar Hall",
      speaker: "K. Sarvagna, Student Lead",
      seatsLeft: 24,
      totalSeats: 80,
      rules: "Team of 2 to 4 students. Buzzer round in finals.",
      status: "OPEN",
      isTeamEvent: true,
      minTeamSize: 2,
      maxTeamSize: 4,
    ),
    EventModel(
      id: "ev_hackathon",
      title: "Campus AI & Cloud Hackathon",
      description: "36-hour intense product build sprint solving real campus automation challenges.",
      category: "Hackathons",
      dateMonth: "SEP",
      dateDay: "22",
      time: "09:00 AM - 06:00 PM",
      venue: "Innovation & Incubation Center",
      speaker: "ELITE Staff Committee",
      seatsLeft: 12,
      totalSeats: 40,
      rules: "Teams of 2 to 4 members. Hardware & Cloud credits provided.",
      status: "OPEN",
      isTeamEvent: true,
      minTeamSize: 2,
      maxTeamSize: 4,
    ),
  ];

  static List<SubjectAttendance> getSubjectAttendance() => [
    SubjectAttendance(code: "IT3101", title: "Machine Learning & AI", attended: 28, total: 30, faculty: "Dr. AVN Chandra Sekhar"),
    SubjectAttendance(code: "IT3102", title: "Cloud Native Computing", attended: 26, total: 30, faculty: "G. Nageswarao"),
    SubjectAttendance(code: "IT3103", title: "Cybersecurity & Cryptography", attended: 27, total: 30, faculty: "M. Tangamani"),
  ];

  static List<AttendanceLog> getAttendanceLogs() => [
    AttendanceLog(id: "log-1", date: "Today", time: "09:42 AM", subject: "Turnstile Gate #2", room: "Campus Main Gate", status: "Present"),
    AttendanceLog(id: "log-2", date: "Today", time: "10:02 AM", subject: "IT Lab 4 Entrance", room: "Lab Block B", status: "Present"),
  ];

  static List<PollModel> getInitialPolls() => [
    PollModel(
      id: "poll_tech_symposium",
      question: "Which emerging tech track should lead the next ELITE Winter Symposium?",
      description: "Vote for the primary keynote track of our upcoming department national symposium.",
      category: "Department",
      options: [
        PollOption(id: "opt_1", text: "Autonomous AI Agents & Multi-Modal LLMs", votes: 142),
        PollOption(id: "opt_2", text: "Zero-Knowledge Cryptography & Web3 Infra", votes: 88),
        PollOption(id: "opt_3", text: "Quantum Computing & Silicon Photonics", votes: 64),
      ],
      userVotedIndex: null,
      expiresText: "Active Poll",
      status: "OPEN",
    ),
  ];

  static List<AppNotification> getInitialNotifications() => [
    AppNotification(
      id: "notif_001",
      title: "Lab 4 Maintenance Window",
      message: "High Performance Cluster 4 will undergo scheduled firmware upgrades this Sunday 2:00 AM to 6:00 AM.",
      timeAgo: "10m ago",
      category: "Urgent",
      isRead: false,
    ),
    AppNotification(
      id: "notif_002",
      title: "ELITE Symposium Paper Submissions",
      message: "Abstract submission portal is now accepting IEEE-format research drafts.",
      timeAgo: "2h ago",
      category: "Academic",
      isRead: false,
    ),
    AppNotification(
      id: "notif_003",
      title: "Turnstile Pass Verification",
      message: "Ensure your digital student profile QR code is active for turnstile access at Gate 2.",
      timeAgo: "1d ago",
      category: "System",
      isRead: true,
    ),
  ];
}
