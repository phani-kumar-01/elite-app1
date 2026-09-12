import React from 'react';
import {
  GraduationCap,
  Users,
  CalendarDays,
  ScanLine,
  BarChart3,
  LifeBuoy,
  ArrowUpRight,
  ShieldCheck,
  Zap,
  Radio,
  Clock,
  CheckCircle2,
} from 'lucide-react';

export default function DashboardView({
  metrics,
  events,
  recentAttendance,
  onNavigate,
  onOpenNewEvent,
  onOpenBroadcast,
  onOpenCheckIn,
}) {
  return (
    <div className="page-container">
      {/* Top Welcome Banner */}
      <div
        className="glass-card"
        style={{
          background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.15) 0%, rgba(6, 182, 212, 0.08) 100%)',
          borderColor: 'rgba(99, 102, 241, 0.3)',
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          flexWrap: 'wrap',
          gap: '16px',
        }}
      >
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
            <span className="badge badge-indigo">
              <ShieldCheck size={12} /> Autonomous IT Ops
            </span>
            <span className="badge badge-emerald">
              <Zap size={12} /> Live Supabase Synced
            </span>
          </div>
          <h2 style={{ fontFamily: 'var(--font-heading)', fontSize: '22px', fontWeight: '800' }}>
            ELITE Department Executive Console
          </h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '13px', marginTop: '4px' }}>
            Single point of control for student identities, gate turnstile attendance, events registry, and faculty management.
          </p>
        </div>

        {/* Quick action buttons */}
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          <button onClick={onOpenNewEvent} className="btn btn-primary">
            <CalendarDays size={15} />
            <span>Create Event</span>
          </button>
          <button onClick={onOpenBroadcast} className="btn btn-secondary">
            <Radio size={15} />
            <span>Send Broadcast</span>
          </button>
          <button onClick={onOpenCheckIn} className="btn btn-secondary">
            <ScanLine size={15} />
            <span>Gate Check-In</span>
          </button>
        </div>
      </div>

      {/* KPI Cards Grid */}
      <div className="stats-grid">
        <div
          className="stat-card"
          style={{ '--card-accent': 'var(--cyan)', '--card-glow': 'var(--cyan-glow)' }}
          onClick={() => onNavigate('students')}
        >
          <div className="stat-icon-wrapper">
            <GraduationCap size={24} />
          </div>
          <div className="stat-content">
            <div className="stat-label">Enrolled Students</div>
            <div className="stat-value">{metrics.students}</div>
            <div className="stat-subtext">
              <span style={{ color: 'var(--emerald)' }}>● Active</span> All 381 IT batches loaded
            </div>
          </div>
        </div>

        <div
          className="stat-card"
          style={{ '--card-accent': 'var(--primary)', '--card-glow': 'var(--primary-glow)' }}
          onClick={() => onNavigate('faculty')}
        >
          <div className="stat-icon-wrapper">
            <Users size={24} />
          </div>
          <div className="stat-content">
            <div className="stat-label">Faculty & Coordinators</div>
            <div className="stat-value">{metrics.staff || 24}</div>
            <div className="stat-subtext">Professors & lab staff</div>
          </div>
        </div>

        <div
          className="stat-card"
          style={{ '--card-accent': 'var(--emerald)', '--card-glow': 'var(--emerald-glow)' }}
          onClick={() => onNavigate('events')}
        >
          <div className="stat-icon-wrapper">
            <CalendarDays size={24} />
          </div>
          <div className="stat-content">
            <div className="stat-label">Active Events</div>
            <div className="stat-value">{events.length}</div>
            <div className="stat-subtext">Technical & symposiums</div>
          </div>
        </div>

        <div
          className="stat-card"
          style={{ '--card-accent': 'var(--purple)', '--card-glow': 'rgba(168, 85, 247, 0.24)' }}
          onClick={() => onNavigate('attendance')}
        >
          <div className="stat-icon-wrapper">
            <ScanLine size={24} />
          </div>
          <div className="stat-content">
            <div className="stat-label">Turnstile Scans Logged</div>
            <div className="stat-value">{metrics.attendanceToday}</div>
            <div className="stat-subtext">Gate #2 & IT Labs</div>
          </div>
        </div>

        <div
          className="stat-card"
          style={{ '--card-accent': 'var(--amber)', '--card-glow': 'var(--amber-glow)' }}
          onClick={() => onNavigate('polls')}
        >
          <div className="stat-icon-wrapper">
            <BarChart3 size={24} />
          </div>
          <div className="stat-content">
            <div className="stat-label">Open Polls</div>
            <div className="stat-value">{metrics.openPolls}</div>
            <div className="stat-subtext">Live community voting</div>
          </div>
        </div>

        <div
          className="stat-card"
          style={{ '--card-accent': 'var(--rose)', '--card-glow': 'var(--rose-glow)' }}
          onClick={() => onNavigate('tickets')}
        >
          <div className="stat-icon-wrapper">
            <LifeBuoy size={24} />
          </div>
          <div className="stat-content">
            <div className="stat-label">Pending Helpdesk</div>
            <div className="stat-value">{metrics.openTickets}</div>
            <div className="stat-subtext">Awaiting resolution</div>
          </div>
        </div>
      </div>

      {/* Two-column layout for Event Registration Gauges + Live Turnstile Feed */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(400px, 1fr))', gap: '20px' }}>
        {/* Active Events & Capacity Progress */}
        <div className="glass-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '15px', fontWeight: '700' }}>
              Live Events Registration Capacity
            </h3>
            <button
              onClick={() => onNavigate('events')}
              className="btn-icon"
              title="View all events"
            >
              <ArrowUpRight size={16} />
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
            {events.slice(0, 4).map((ev) => {
              const cap = ev.max_capacity || 100;
              const reg = ev.registered_count || 0;
              const pct = Math.min(100, Math.round((reg / cap) * 100));

              return (
                <div key={ev.id} style={{ padding: '10px 12px', background: 'rgba(255,255,255,0.02)', borderRadius: '8px', border: '1px solid var(--border-subtle)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                    <span style={{ fontWeight: '600', color: '#ffffff' }}>{ev.title}</span>
                    <span className={`badge ${pct >= 90 ? 'badge-rose' : pct >= 60 ? 'badge-amber' : 'badge-cyan'}`}>
                      {reg} / {cap} Registered ({pct}%)
                    </span>
                  </div>
                  <div className="progress-bar-track">
                    <div className="progress-bar-fill" style={{ width: `${pct}%` }}></div>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '6px', fontSize: '11px', color: 'var(--text-dim)' }}>
                    <span>Venue: {ev.venue}</span>
                    <span>Date: {ev.event_date}</span>
                  </div>
                </div>
              );
            })}
            {events.length === 0 && (
              <p style={{ color: 'var(--text-dim)', textAlign: 'center', padding: '20px' }}>
                No active events found. Click 'Create Event' to launch one.
              </p>
            )}
          </div>
        </div>

        {/* Live Turnstile Stream */}
        <div className="glass-card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '15px', fontWeight: '700' }}>
                Recent Turnstile & Lab Scans
              </h3>
              <span className="pulse-dot" style={{ width: 6, height: 6 }}></span>
            </div>
            <button
              onClick={() => onNavigate('attendance')}
              className="btn-icon"
              title="Full attendance logs"
            >
              <ArrowUpRight size={16} />
            </button>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
            {recentAttendance.slice(0, 5).map((log, idx) => (
              <div key={log.id || idx} className="attendance-feed-item">
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div style={{ width: 34, height: 34, borderRadius: '8px', background: 'rgba(16, 185, 129, 0.15)', color: '#34d399', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <CheckCircle2 size={16} />
                  </div>
                  <div>
                    <div style={{ fontWeight: '600', fontSize: '13px' }}>
                      {log.student_roll || '22IT049'}
                      <span style={{ fontWeight: '400', color: 'var(--text-muted)', marginLeft: '6px' }}>
                        ({log.student_name || 'Student'})
                      </span>
                    </div>
                    <div style={{ fontSize: '11px', color: 'var(--text-dim)' }}>
                      {log.scanned_by || 'Turnstile Gate #2'} • {log.session || 'Main IT Entrance'}
                    </div>
                  </div>
                </div>

                <div style={{ textAlign: 'right' }}>
                  <span className="badge badge-emerald">{log.status || 'PRESENT'}</span>
                  <div style={{ fontSize: '10px', color: 'var(--text-dim)', marginTop: '4px' }}>
                    {log.scanned_at ? new Date(log.scanned_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : 'Recent'}
                  </div>
                </div>
              </div>
            ))}
            {recentAttendance.length === 0 && (
              <p style={{ color: 'var(--text-dim)', textAlign: 'center', padding: '20px' }}>
                No attendance scans recorded yet. Use 'Gate Check-In' to simulate or record a pass.
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
