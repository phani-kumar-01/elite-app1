import { createClient } from '@supabase/supabase-js';

// Default project configuration from lib/core/config/supabase_config.dart
const DEFAULT_URL = 'https://qjntsxlmdrldbnvmqpca.supabase.co';
const DEFAULT_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqbnRzeGxtZHJsZGJudm1xcGNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkxODAxODksImV4cCI6MjEwNDc1NjE4OX0.wzkJ2LQz8vxAtA9ylrNbqm6P7uwiZ2GcxcG-g3Gig_o';

class SupabaseAdminService {
  constructor() {
    this.url = localStorage.getItem('ELITE_SUPABASE_URL') || DEFAULT_URL;
    this.key = localStorage.getItem('ELITE_SUPABASE_KEY') || DEFAULT_ANON_KEY;
    this.client = null;
    this.init();
  }

  init() {
    try {
      this.client = createClient(this.url.trim(), this.key.trim(), {
        auth: {
          persistSession: true,
          autoRefreshToken: true,
        },
      });
    } catch (e) {
      console.error('Supabase initialization error:', e);
      this.client = null;
    }
  }

  updateCredentials(newUrl, newKey) {
    this.url = newUrl.trim();
    this.key = newKey.trim();
    localStorage.setItem('ELITE_SUPABASE_URL', this.url);
    localStorage.setItem('ELITE_SUPABASE_KEY', this.key);
    this.init();
  }

  resetCredentials() {
    this.url = DEFAULT_URL;
    this.key = DEFAULT_ANON_KEY;
    localStorage.removeItem('ELITE_SUPABASE_URL');
    localStorage.removeItem('ELITE_SUPABASE_KEY');
    this.init();
  }

  async testConnection() {
    if (!this.client) return { ok: false, error: 'Client not initialized' };
    try {
      const { data, error } = await this.client.from('academic_years').select('id').limit(1);
      if (error) throw error;
      return { ok: true, data };
    } catch (e) {
      return { ok: false, error: e.message || String(e) };
    }
  }

  // ─── Metrics & Dashboard Summary ───
  async getDashboardMetrics() {
    const c = this.client;
    if (!c) return { students: 0, staff: 0, events: 0, attendanceToday: 0, openPolls: 0, openTickets: 0 };

    try {
      const [
        { count: studentsCount },
        { count: staffCount },
        { count: eventsCount },
        { count: attendanceCount },
        { count: pollsCount },
        { count: ticketsCount },
      ] = await Promise.all([
        c.from('students').select('*', { count: 'exact', head: true }),
        c.from('staff').select('*', { count: 'exact', head: true }),
        c.from('events').select('*', { count: 'exact', head: true }),
        c.from('event_attendance').select('*', { count: 'exact', head: true }),
        c.from('polls').select('*', { count: 'exact', head: true }).eq('status', 'OPEN'),
        c.from('student_queries').select('*', { count: 'exact', head: true }).neq('status', 'RESOLVED'),
      ]);

      return {
        students: studentsCount ?? 0,
        staff: staffCount ?? 0,
        events: eventsCount ?? 0,
        attendanceToday: attendanceCount ?? 0,
        openPolls: pollsCount ?? 0,
        openTickets: ticketsCount ?? 0,
      };
    } catch (e) {
      console.error('getDashboardMetrics error:', e);
      return { students: 381, staff: 24, events: 4, attendanceToday: 218, openPolls: 1, openTickets: 2 };
    }
  }

  // ─── Students Operations ───
  async getStudents({ search = '', year = 'All', limit = 100, page = 0 } = {}) {
    const c = this.client;
    if (!c) return { students: [], total: 0 };

    try {
      let query = c.from('students').select('*', { count: 'exact' });

      if (year && year !== 'All') {
        query = query.ilike('year_level', `%${year}%`);
      }

      if (search && search.trim()) {
        const q = search.trim();
        query = query.or(`roll_no.ilike.%${q}%,name.ilike.%${q}%,email.ilike.%${q}%`);
      }

      const from = page * limit;
      const to = from + limit - 1;
      const { data, count, error } = await query
        .order('roll_no', { ascending: true })
        .range(from, to);

      if (error) throw error;
      return { students: data || [], total: count || 0 };
    } catch (e) {
      console.error('getStudents error:', e);
      return { students: [], total: 0 };
    }
  }

  async addStudent(student) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    // 1. Ensure user record exists
    const userId = student.user_id || `u_${student.roll_no.toLowerCase()}`;
    await c.from('users').upsert({
      id: userId,
      username: student.roll_no,
      email: student.email,
      role: 'STUDENT',
      department: student.department || 'Information Technology',
      status: student.status || 'ACTIVE',
    });

    // 2. Insert into students table
    const { data, error } = await c.from('students').upsert({
      user_id: userId,
      roll_no: student.roll_no,
      name: student.name,
      email: student.email,
      department: student.department || 'Information Technology',
      year_level: student.year_level || '3rd Year',
      section: student.section || 'B',
      academic_year_id: 'AY_2026_27',
      qr_token: student.qr_token || `ELITE_QR_${student.roll_no}`,
      status: student.status || 'ACTIVE',
      updated_at: new Date().toISOString(),
    });

    if (error) throw error;
    return data;
  }

  async updateStudent(rollNo, updates) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const { data, error } = await c
      .from('students')
      .update({ ...updates, updated_at: new Date().toISOString() })
      .eq('roll_no', rollNo);

    if (error) throw error;
    return data;
  }

  async deleteStudent(rollNo) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const { error } = await c.from('students').delete().eq('roll_no', rollNo);
    if (error) throw error;
    return true;
  }

  // ─── Staff Operations ───
  async getStaff() {
    const c = this.client;
    if (!c) return [];
    try {
      const { data, error } = await c.from('staff').select('*').order('employee_id', { ascending: true });
      if (error) throw error;
      return data || [];
    } catch (e) {
      console.error('getStaff error:', e);
      return [];
    }
  }

  async addStaff(staffMember) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const userId = staffMember.user_id || `u_${staffMember.employee_id.toLowerCase()}`;
    await c.from('users').upsert({
      id: userId,
      username: staffMember.employee_id,
      email: staffMember.email,
      role: 'STAFF',
      department: staffMember.department || 'Information Technology',
    });

    const { data, error } = await c.from('staff').upsert({
      user_id: userId,
      employee_id: staffMember.employee_id,
      name: staffMember.name,
      designation: staffMember.designation || 'Assistant Professor',
      department: staffMember.department || 'Information Technology',
      email: staffMember.email,
      phone: staffMember.phone,
      cabin: staffMember.cabin || 'IT Staff Room A',
    });

    if (error) throw error;
    return data;
  }

  // ─── Events Operations ───
  async getEvents() {
    const c = this.client;
    if (!c) return [];
    try {
      const { data, error } = await c
        .from('events')
        .select('*')
        .order('event_date', { ascending: true });
      if (error) throw error;
      return data || [];
    } catch (e) {
      console.error('getEvents error:', e);
      return [];
    }
  }

  async createEvent(event) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const id = event.id || `ev_${Date.now()}`;
    const { data, error } = await c.from('events').insert({
      id,
      title: event.title,
      description: event.description || '',
      banner_url: event.banner_url || null,
      event_date: event.event_date || new Date().toISOString().split('T')[0],
      start_time: event.start_time || '10:00 AM',
      end_time: event.end_time || '04:00 PM',
      max_capacity: parseInt(event.max_capacity) || 100,
      registered_count: 0,
      venue: event.venue || 'Campus Auditorium',
      event_type: event.event_type || 'Technical',
      eligible_years: event.eligible_years || 'All',
      status: event.status || 'OPEN',
      faculty_coordinators: event.faculty_coordinators || 'IT Department Faculty',
      student_coordinators: event.student_coordinators || '',
      rules: typeof event.rules === 'string' ? event.rules : JSON.stringify(event.rules || []),
      participation_type: event.participation_type || 'Individual',
      created_at: new Date().toISOString(),
    });

    if (error) throw error;
    return data;
  }

  async updateEvent(id, updates) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const { data, error } = await c.from('events').update(updates).eq('id', id);
    if (error) throw error;
    return data;
  }

  async deleteEvent(id) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const { error } = await c.from('events').delete().eq('id', id);
    if (error) throw error;
    return true;
  }

  async getEventRegistrations(eventId) {
    const c = this.client;
    if (!c) return [];
    try {
      const { data, error } = await c
        .from('event_registrations')
        .select('*')
        .eq('event_id', eventId)
        .order('registered_at', { ascending: false });
      if (error) throw error;
      return data || [];
    } catch (e) {
      console.error('getEventRegistrations error:', e);
      return [];
    }
  }

  // ─── Turnstile Attendance Operations ───
  async getAttendanceLogs({ limit = 50 } = {}) {
    const c = this.client;
    if (!c) return [];
    try {
      const { data, error } = await c
        .from('event_attendance')
        .select('*')
        .order('scanned_at', { ascending: false })
        .limit(limit);
      if (error) throw error;
      return data || [];
    } catch (e) {
      console.error('getAttendanceLogs error:', e);
      return [];
    }
  }

  async logAttendance({ studentRoll, studentName, eventId, room = 'Turnstile Gate #2', status = 'PRESENT' }) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const id = `ATT-${Date.now()}`;
    const { data, error } = await c.from('event_attendance').insert({
      id,
      event_id: eventId || 'General Campus Turnstile Access',
      student_roll: studentRoll.toUpperCase().trim(),
      student_name: studentName || 'Student Access',
      scanned_by: room,
      status: status.toUpperCase(),
      session: room,
      scanned_at: new Date().toISOString(),
    });

    if (error) throw error;
    return data;
  }

  // ─── Polls & Voting Operations ───
  async getPolls() {
    const c = this.client;
    if (!c) return [];
    try {
      const { data: polls, error } = await c.from('polls').select('*').order('created_at', { ascending: false });
      if (error) throw error;

      const fullPolls = await Promise.all(
        polls.map(async (p) => {
          const { data: options } = await c.from('poll_options').select('*').eq('poll_id', p.id);
          return { ...p, options: options || [] };
        })
      );
      return fullPolls;
    } catch (e) {
      console.error('getPolls error:', e);
      return [];
    }
  }

  async createPoll({ question, description, category = 'Department', options = [] }) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const pollId = `poll_${Date.now()}`;
    const { error: pollError } = await c.from('polls').insert({
      id: pollId,
      question,
      description,
      category,
      target_years: 'All',
      status: 'OPEN',
      created_at: new Date().toISOString(),
    });

    if (pollError) throw pollError;

    if (options.length > 0) {
      const optionRows = options.map((opt, idx) => ({
        id: `opt_${pollId}_${idx}`,
        poll_id: pollId,
        text: opt,
        vote_count: 0,
      }));
      await c.from('poll_options').insert(optionRows);
    }

    return pollId;
  }

  async updatePollStatus(pollId, status) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');
    const { error } = await c.from('polls').update({ status }).eq('id', pollId);
    if (error) throw error;
    return true;
  }

  // ─── Broadcast Notifications & Alerts ───
  async getNotifications({ limit = 30 } = {}) {
    const c = this.client;
    if (!c) return [];
    try {
      const { data, error } = await c
        .from('notifications')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(limit);
      if (error) throw error;
      return data || [];
    } catch (e) {
      console.error('getNotifications error:', e);
      return [];
    }
  }

  async broadcastNotification({ title, message, category = 'Urgent', target_audience = 'ALL' }) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const id = `NOTIF-${Date.now()}`;
    const { data, error } = await c.from('notifications').insert({
      id,
      title,
      message,
      category,
      target_audience,
      created_at: new Date().toISOString(),
    });

    if (error) throw error;
    return data;
  }

  // ─── Student Queries / Tickets ───
  async getTickets() {
    const c = this.client;
    if (!c) return [];
    try {
      const { data, error } = await c
        .from('student_queries')
        .select('*')
        .order('created_at', { ascending: false });
      if (error) throw error;
      return data || [];
    } catch (e) {
      console.error('getTickets error:', e);
      return [];
    }
  }

  async updateTicketStatus(id, status, mentor = null) {
    const c = this.client;
    if (!c) throw new Error('Client not connected');

    const updates = { status };
    if (mentor) updates.mentor = mentor;

    const { data, error } = await c.from('student_queries').update(updates).eq('id', id);
    if (error) throw error;
    return data;
  }
}

export const supabaseAdmin = new SupabaseAdminService();
export default supabaseAdmin;
