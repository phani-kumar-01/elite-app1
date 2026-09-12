import React, { useState, useEffect } from 'react';
import {
  ScanLine,
  CheckCircle2,
  Clock,
  Download,
  Filter,
  UserCheck,
  Building,
  Zap,
  RotateCw,
} from 'lucide-react';
import supabaseAdmin from '../services/supabase';
import Modal from '../components/Modal';

export default function AttendanceView({ isCheckInOpen, setIsCheckInOpen }) {
  const [logs, setLogs] = useState([]);
  const [filterGate, setFilterGate] = useState('All');
  const [isLoading, setIsLoading] = useState(false);

  // Manual Check-In Form
  const [checkInRoll, setCheckInRoll] = useState('');
  const [checkInName, setCheckInName] = useState('');
  const [checkInGate, setCheckInGate] = useState('Turnstile Gate #2');
  const [checkInStatus, setCheckInStatus] = useState('PRESENT');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchLogs = async () => {
    setIsLoading(true);
    try {
      const data = await supabaseAdmin.getAttendanceLogs({ limit: 100 });
      setLogs(data);
    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs();
    const interval = setInterval(fetchLogs, 15000); // 15s live polling
    return () => clearInterval(interval);
  }, []);

  const handleManualCheckIn = async (e) => {
    e.preventDefault();
    if (!checkInRoll.trim()) return;

    setIsSubmitting(true);
    try {
      await supabaseAdmin.logAttendance({
        studentRoll: checkInRoll,
        studentName: checkInName || 'Student Verified',
        room: checkInGate,
        status: checkInStatus,
      });
      setIsCheckInOpen(false);
      setCheckInRoll('');
      setCheckInName('');
      fetchLogs();
    } catch (err) {
      alert('Error logging attendance: ' + err.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  const exportAttendanceCSV = () => {
    if (logs.length === 0) return;
    const headers = ['Log ID', 'Roll No', 'Student Name', 'Gate / Room', 'Status', 'Timestamp'];
    const rows = logs.map((l) => [
      l.id,
      l.student_roll || '',
      `"${l.student_name || ''}"`,
      `"${l.scanned_by || l.session || ''}"`,
      l.status || 'PRESENT',
      l.scanned_at || '',
    ]);
    const csv = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map((r) => r.join(','))].join('\n');
    const link = document.createElement('a');
    link.href = encodeURI(csv);
    link.download = `elite_attendance_log_${Date.now()}.csv`;
    link.click();
  };

  const filteredLogs = logs.filter((l) => {
    if (filterGate === 'All') return true;
    return (l.scanned_by || l.session || '').toLowerCase().includes(filterGate.toLowerCase());
  });

  return (
    <div className="page-container">
      {/* Top Banner */}
      <div className="glass-card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
            <span className="pulse-dot"></span>
            <span style={{ fontWeight: '700', color: 'var(--emerald)', fontSize: '13px' }}>
              Real-time Hardware Turnstile Bus Active
            </span>
          </div>
          <h2 style={{ fontFamily: 'var(--font-heading)', fontSize: '20px', fontWeight: '800' }}>
            Turnstile Gates & Department Labs Access Feed
          </h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '12px' }}>
            Monitoring NFC passes, QR tokens, and RFID student verification in real-time.
          </p>
        </div>

        <div style={{ display: 'flex', gap: '10px' }}>
          <button onClick={fetchLogs} className="btn btn-secondary">
            <RotateCw size={14} className={isLoading ? 'animate-spin' : ''} />
            <span>Poll Now</span>
          </button>
          <button onClick={exportAttendanceCSV} className="btn btn-secondary">
            <Download size={14} />
            <span>Export Logs</span>
          </button>
          <button onClick={() => setIsCheckInOpen(true)} className="btn btn-primary">
            <ScanLine size={14} />
            <span>Manual Gate Entry</span>
          </button>
        </div>
      </div>

      {/* Filter Bar */}
      <div className="toolbar">
        <div className="filter-group">
          {['All', 'Turnstile Gate #2', 'IT Lab', 'AIML Hall', 'HPC Cluster'].map((g) => (
            <button
              key={g}
              className={`filter-btn ${filterGate === g ? 'active' : ''}`}
              onClick={() => setFilterGate(g)}
            >
              {g}
            </button>
          ))}
        </div>

        <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
          Showing <strong>{filteredLogs.length}</strong> recent scan entries
        </span>
      </div>

      {/* Attendance Table */}
      <div className="table-wrapper">
        <table className="admin-table">
          <thead>
            <tr>
              <th>Scan Timestamp</th>
              <th>Roll Number</th>
              <th>Student Name</th>
              <th>Terminal / Gate</th>
              <th>Event / Session</th>
              <th>Gate Clearance</th>
            </tr>
          </thead>
          <tbody>
            {filteredLogs.map((log) => {
              const dt = log.scanned_at ? new Date(log.scanned_at) : new Date();
              const isPresent = (log.status || 'PRESENT').toUpperCase() === 'PRESENT';

              return (
                <tr key={log.id}>
                  <td style={{ color: 'var(--text-dim)', fontSize: '12px', fontFamily: 'var(--font-mono)' }}>
                    {dt.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' })}{' '}
                    • {dt.toLocaleDateString([], { month: 'short', day: 'numeric' })}
                  </td>
                  <td>
                    <span style={{ fontFamily: 'var(--font-mono)', fontWeight: '700', color: 'var(--cyan)' }}>
                      {log.student_roll || '—'}
                    </span>
                  </td>
                  <td style={{ fontWeight: '600' }}>{log.student_name || 'Verified Student'}</td>
                  <td>
                    <span className="badge badge-indigo">
                      {log.scanned_by || 'Turnstile Gate #2'}
                    </span>
                  </td>
                  <td style={{ color: 'var(--text-muted)', fontSize: '12px' }}>
                    {log.event_id || log.session || 'General Access'}
                  </td>
                  <td>
                    <span className={`badge ${isPresent ? 'badge-emerald' : 'badge-rose'}`}>
                      {isPresent ? <CheckCircle2 size={11} /> : <Clock size={11} />}
                      {log.status || 'PRESENT'}
                    </span>
                  </td>
                </tr>
              );
            })}
            {filteredLogs.length === 0 && !isLoading && (
              <tr>
                <td colSpan={6} style={{ textAlign: 'center', padding: '36px', color: 'var(--text-dim)' }}>
                  No attendance records logged for the selected terminal.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Manual Check-in Modal */}
      <Modal
        isOpen={isCheckInOpen}
        onClose={() => setIsCheckInOpen(false)}
        title="Record Gate / Lab Attendance Scan"
        footer={
          <>
            <button onClick={() => setIsCheckInOpen(false)} className="btn btn-secondary">
              Cancel
            </button>
            <button onClick={handleManualCheckIn} className="btn btn-primary" disabled={isSubmitting}>
              {isSubmitting ? 'Logging to Supabase...' : 'Confirm Access Scan'}
            </button>
          </>
        }
      >
        <form onSubmit={handleManualCheckIn} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div className="form-group">
            <label>Student Roll Number *</label>
            <input
              type="text"
              className="form-control"
              placeholder="e.g. 22IT049"
              value={checkInRoll}
              onChange={(e) => setCheckInRoll(e.target.value.toUpperCase())}
              required
            />
          </div>

          <div className="form-group">
            <label>Student Name (Optional)</label>
            <input
              type="text"
              className="form-control"
              placeholder="e.g. K. Vamsi Krishna"
              value={checkInName}
              onChange={(e) => setCheckInName(e.target.value)}
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Gate / Terminal Location</label>
              <select
                className="form-control"
                value={checkInGate}
                onChange={(e) => setCheckInGate(e.target.value)}
              >
                <option value="Turnstile Gate #2">Turnstile Gate #2 (Main)</option>
                <option value="IT Lab 4 Entrance">IT Lab 4 Entrance</option>
                <option value="AIML Seminar Hall">AIML Seminar Hall</option>
                <option value="HPC Cluster Room">HPC Cluster Room</option>
              </select>
            </div>
            <div className="form-group">
              <label>Status</label>
              <select
                className="form-control"
                value={checkInStatus}
                onChange={(e) => setCheckInStatus(e.target.value)}
              >
                <option value="PRESENT">PRESENT</option>
                <option value="LATE">LATE</option>
              </select>
            </div>
          </div>
        </form>
      </Modal>
    </div>
  );
}
