import React, { useState, useEffect } from 'react';
import {
  Calendar,
  Clock,
  MapPin,
  Users,
  Plus,
  Edit,
  Trash2,
  ListOrdered,
  Download,
  CheckCircle,
  Tag,
  AlertCircle,
} from 'lucide-react';
import supabaseAdmin from '../services/supabase';
import Modal from '../components/Modal';

export default function EventsView({ isCreateOpen, setIsCreateOpen }) {
  const [events, setEvents] = useState([]);
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [isLoading, setIsLoading] = useState(false);

  // Roster Modal
  const [isRosterOpen, setIsRosterOpen] = useState(false);
  const [selectedEvent, setSelectedEvent] = useState(null);
  const [registrations, setRegistrations] = useState([]);
  const [rosterLoading, setRosterLoading] = useState(false);

  // Edit/Create Event Form
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    event_type: 'Technical',
    venue: 'Campus Auditorium',
    event_date: new Date().toISOString().split('T')[0],
    start_time: '10:00 AM',
    end_time: '04:00 PM',
    max_capacity: 100,
    faculty_coordinators: 'Dr. AVN Chandra Sekhar',
    student_coordinators: '',
    participation_type: 'Individual',
    rules: '',
  });

  const fetchEvents = async () => {
    setIsLoading(true);
    try {
      const data = await supabaseAdmin.getEvents();
      setEvents(data);
    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchEvents();
  }, []);

  const handleSaveEvent = async (e) => {
    e.preventDefault();
    if (!formData.title) return;

    try {
      if (editingId) {
        await supabaseAdmin.updateEvent(editingId, formData);
      } else {
        await supabaseAdmin.createEvent(formData);
      }
      setIsCreateOpen(false);
      setEditingId(null);
      setFormData({
        title: '',
        description: '',
        event_type: 'Technical',
        venue: 'Campus Auditorium',
        event_date: new Date().toISOString().split('T')[0],
        start_time: '10:00 AM',
        end_time: '04:00 PM',
        max_capacity: 100,
        faculty_coordinators: 'Dr. AVN Chandra Sekhar',
        student_coordinators: '',
        participation_type: 'Individual',
        rules: '',
      });
      fetchEvents();
    } catch (err) {
      alert('Error saving event: ' + err.message);
    }
  };

  const handleDeleteEvent = async (id) => {
    if (!window.confirm('Are you sure you want to cancel and delete this event?')) return;
    try {
      await supabaseAdmin.deleteEvent(id);
      fetchEvents();
    } catch (err) {
      alert('Error deleting event: ' + err.message);
    }
  };

  const openRoster = async (ev) => {
    setSelectedEvent(ev);
    setIsRosterOpen(true);
    setRosterLoading(true);
    try {
      const regs = await supabaseAdmin.getEventRegistrations(ev.id);
      setRegistrations(regs);
    } catch (e) {
      console.error(e);
    } finally {
      setRosterLoading(false);
    }
  };

  const exportRosterCSV = () => {
    if (!selectedEvent || registrations.length === 0) return;
    const headers = ['Student ID', 'Roll Number', 'Name', 'Email', 'Year', 'Status', 'Registered At'];
    const rows = registrations.map((r) => [
      r.student_id || '',
      r.student_roll || '',
      `"${r.student_name || ''}"`,
      r.student_email || '',
      `"${r.student_year || ''}"`,
      r.status || 'CONFIRMED',
      r.registered_at || '',
    ]);
    const csv = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map((e) => e.join(','))].join('\n');
    const link = document.createElement('a');
    link.href = encodeURI(csv);
    link.download = `event_roster_${selectedEvent.id}.csv`;
    link.click();
  };

  const filtered = events.filter((ev) => {
    if (categoryFilter === 'All') return true;
    return ev.event_type?.toLowerCase() === categoryFilter.toLowerCase();
  });

  return (
    <div className="page-container">
      {/* Toolbar */}
      <div className="toolbar">
        <div className="filter-group">
          {['All', 'Technical', 'Creative', 'Cultural'].map((cat) => (
            <button
              key={cat}
              className={`filter-btn ${categoryFilter === cat ? 'active' : ''}`}
              onClick={() => setCategoryFilter(cat)}
            >
              {cat}
            </button>
          ))}
        </div>

        <button
          onClick={() => {
            setEditingId(null);
            setIsCreateOpen(true);
          }}
          className="btn btn-primary"
        >
          <Plus size={15} />
          <span>Launch New Event</span>
        </button>
      </div>

      {/* Events Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(360px, 1fr))', gap: '20px' }}>
        {filtered.map((ev) => {
          const cap = ev.max_capacity || 100;
          const reg = ev.registered_count || 0;
          const pct = Math.min(100, Math.round((reg / cap) * 100));

          return (
            <div key={ev.id} className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <span className="badge badge-indigo">{ev.event_type || 'Technical'}</span>
                <span className={`badge ${ev.status === 'OPEN' ? 'badge-emerald' : 'badge-amber'}`}>
                  {ev.status || 'OPEN'}
                </span>
              </div>

              <div>
                <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '17px', fontWeight: '800', color: '#ffffff' }}>
                  {ev.title}
                </h3>
                <p style={{ color: 'var(--text-muted)', fontSize: '12px', marginTop: '6px', lineClamp: 2, display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical', overflow: 'hidden' }}>
                  {ev.description}
                </p>
              </div>

              {/* Progress gauge */}
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '11px', marginBottom: '6px' }}>
                  <span style={{ color: 'var(--text-dim)' }}>Confirmed Slots</span>
                  <span style={{ fontWeight: '700', color: '#ffffff' }}>
                    {reg} / {cap} ({pct}%)
                  </span>
                </div>
                <div className="progress-bar-track">
                  <div className="progress-bar-fill" style={{ width: `${pct}%` }}></div>
                </div>
              </div>

              {/* Event Metadata */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '6px', fontSize: '12px', color: 'var(--text-dim)', borderTop: '1px solid var(--border-subtle)', paddingTop: '12px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Calendar size={13} style={{ color: 'var(--cyan)' }} />
                  <span>{ev.event_date} • {ev.start_time} - {ev.end_time}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <MapPin size={13} style={{ color: 'var(--emerald)' }} />
                  <span>{ev.venue}</span>
                </div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Users size={13} style={{ color: 'var(--primary)' }} />
                  <span>Coordinators: {ev.faculty_coordinators || 'IT Faculty'}</span>
                </div>
              </div>

              {/* Action Buttons */}
              <div style={{ display: 'flex', gap: '8px', borderTop: '1px solid var(--border-subtle)', paddingTop: '12px' }}>
                <button
                  onClick={() => openRoster(ev)}
                  className="btn btn-secondary"
                  style={{ flex: 1, padding: '6px 10px', fontSize: '12px' }}
                >
                  <ListOrdered size={14} />
                  <span>Roster ({reg})</span>
                </button>
                <button
                  onClick={() => {
                    setEditingId(ev.id);
                    setFormData({
                      title: ev.title,
                      description: ev.description || '',
                      event_type: ev.event_type || 'Technical',
                      venue: ev.venue || 'Campus Auditorium',
                      event_date: ev.event_date || '',
                      start_time: ev.start_time || '10:00 AM',
                      end_time: ev.end_time || '04:00 PM',
                      max_capacity: ev.max_capacity || 100,
                      faculty_coordinators: ev.faculty_coordinators || '',
                      student_coordinators: ev.student_coordinators || '',
                      participation_type: ev.participation_type || 'Individual',
                      rules: typeof ev.rules === 'string' ? ev.rules : '',
                    });
                    setIsCreateOpen(true);
                  }}
                  className="btn-icon"
                  title="Edit Event"
                >
                  <Edit size={14} />
                </button>
                <button
                  onClick={() => handleDeleteEvent(ev.id)}
                  className="btn-icon"
                  style={{ color: 'var(--rose)' }}
                  title="Cancel Event"
                >
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {/* Create / Edit Event Modal */}
      <Modal
        isOpen={isCreateOpen}
        onClose={() => setIsCreateOpen(false)}
        title={editingId ? 'Modify Department Event' : 'Launch New Department Event'}
        maxWidth="680px"
        footer={
          <>
            <button onClick={() => setIsCreateOpen(false)} className="btn btn-secondary">
              Cancel
            </button>
            <button onClick={handleSaveEvent} className="btn btn-primary">
              {editingId ? 'Save Changes' : 'Publish to Students'}
            </button>
          </>
        }
      >
        <form onSubmit={handleSaveEvent} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div className="form-group">
            <label>Event Title *</label>
            <input
              type="text"
              className="form-control"
              placeholder="e.g. AI & Cloud Hackathon 2026"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              required
            />
          </div>

          <div className="form-group">
            <label>Description & Objectives</label>
            <textarea
              className="form-control"
              placeholder="Detailed schedule and requirements..."
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Event Category</label>
              <select
                className="form-control"
                value={formData.event_type}
                onChange={(e) => setFormData({ ...formData, event_type: e.target.value })}
              >
                <option value="Technical">Technical</option>
                <option value="Creative">Creative</option>
                <option value="Cultural">Cultural</option>
                <option value="Workshops">Workshops</option>
              </select>
            </div>
            <div className="form-group">
              <label>Venue / Hall</label>
              <input
                type="text"
                className="form-control"
                placeholder="e.g. IT Lab 4 & Auditorium"
                value={formData.venue}
                onChange={(e) => setFormData({ ...formData, venue: e.target.value })}
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Date</label>
              <input
                type="date"
                className="form-control"
                value={formData.event_date}
                onChange={(e) => setFormData({ ...formData, event_date: e.target.value })}
              />
            </div>
            <div className="form-group">
              <label>Capacity (Max Seats)</label>
              <input
                type="number"
                className="form-control"
                value={formData.max_capacity}
                onChange={(e) => setFormData({ ...formData, max_capacity: e.target.value })}
              />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Start Time</label>
              <input
                type="text"
                className="form-control"
                placeholder="10:00 AM"
                value={formData.start_time}
                onChange={(e) => setFormData({ ...formData, start_time: e.target.value })}
              />
            </div>
            <div className="form-group">
              <label>End Time</label>
              <input
                type="text"
                className="form-control"
                placeholder="04:00 PM"
                value={formData.end_time}
                onChange={(e) => setFormData({ ...formData, end_time: e.target.value })}
              />
            </div>
          </div>

          <div className="form-group">
            <label>Faculty Coordinators</label>
            <input
              type="text"
              className="form-control"
              placeholder="e.g. Dr. AVN Chandra Sekhar, G. Nageswarao"
              value={formData.faculty_coordinators}
              onChange={(e) => setFormData({ ...formData, faculty_coordinators: e.target.value })}
            />
          </div>
        </form>
      </Modal>

      {/* Roster & Registrations Modal */}
      <Modal
        isOpen={isRosterOpen}
        onClose={() => setIsRosterOpen(false)}
        title={selectedEvent ? `Registered Students: ${selectedEvent.title}` : 'Registered Students'}
        maxWidth="750px"
        footer={
          <>
            <button onClick={exportRosterCSV} className="btn btn-secondary">
              <Download size={14} />
              <span>Export CSV Roster</span>
            </button>
            <button onClick={() => setIsRosterOpen(false)} className="btn btn-primary">
              Done
            </button>
          </>
        }
      >
        <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span style={{ color: 'var(--text-muted)', fontSize: '13px' }}>
              Total confirmed registrations: <strong style={{ color: '#ffffff' }}>{registrations.length}</strong>
            </span>
          </div>

          <div className="table-wrapper" style={{ maxHeight: '350px' }}>
            <table className="admin-table">
              <thead>
                <tr>
                  <th>Roll No</th>
                  <th>Student Name</th>
                  <th>Email</th>
                  <th>Status</th>
                  <th>Registered At</th>
                </tr>
              </thead>
              <tbody>
                {registrations.map((r) => (
                  <tr key={r.id || r.student_roll}>
                    <td style={{ fontFamily: 'var(--font-mono)', fontWeight: '600', color: 'var(--cyan)' }}>
                      {r.student_roll || r.student_id}
                    </td>
                    <td style={{ fontWeight: '600' }}>{r.student_name || 'Student'}</td>
                    <td style={{ color: 'var(--text-muted)', fontSize: '12px' }}>{r.student_email || '—'}</td>
                    <td>
                      <span className="badge badge-emerald">{r.status || 'CONFIRMED'}</span>
                    </td>
                    <td style={{ color: 'var(--text-dim)', fontSize: '11px' }}>
                      {r.registered_at ? new Date(r.registered_at).toLocaleDateString() : 'Recent'}
                    </td>
                  </tr>
                ))}
                {registrations.length === 0 && !rosterLoading && (
                  <tr>
                    <td colSpan={5} style={{ textAlign: 'center', padding: '30px', color: 'var(--text-dim)' }}>
                      No students registered for this event yet.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </Modal>
    </div>
  );
}
