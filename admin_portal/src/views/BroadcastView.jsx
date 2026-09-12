import React, { useState, useEffect } from 'react';
import { Radio, Bell, Send, AlertTriangle, Info, CheckCircle2, ShieldAlert } from 'lucide-react';
import supabaseAdmin from '../services/supabase';
import Modal from '../components/Modal';

export default function BroadcastView({ isBroadcastOpen, setIsBroadcastOpen }) {
  const [notifications, setNotifications] = useState([]);
  const [isLoading, setIsLoading] = useState(false);

  // Broadcast Form
  const [title, setTitle] = useState('');
  const [message, setMessage] = useState('');
  const [category, setCategory] = useState('Urgent');
  const [targetAudience, setTargetAudience] = useState('ALL');
  const [isSending, setIsSending] = useState(false);

  const fetchNotifs = async () => {
    setIsLoading(true);
    try {
      const data = await supabaseAdmin.getNotifications({ limit: 50 });
      setNotifications(data);
    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchNotifs();
  }, []);

  const handleSendBroadcast = async (e) => {
    e.preventDefault();
    if (!title.trim() || !message.trim()) return;

    setIsSending(true);
    try {
      await supabaseAdmin.broadcastNotification({
        title,
        message,
        category,
        target_audience: targetAudience,
      });
      setIsBroadcastOpen(false);
      setTitle('');
      setMessage('');
      fetchNotifs();
    } catch (err) {
      alert('Error broadcasting notice: ' + err.message);
    } finally {
      setIsSending(false);
    }
  };

  return (
    <div className="page-container">
      {/* Top Banner */}
      <div className="glass-card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
            <span className="badge badge-rose">
              <ShieldAlert size={12} /> Emergency & Dispatch Console
            </span>
          </div>
          <h2 style={{ fontFamily: 'var(--font-heading)', fontSize: '20px', fontWeight: '800' }}>
            Department Notification Broadcasting
          </h2>
          <p style={{ color: 'var(--text-muted)', fontSize: '13px' }}>
            Instantly push critical notices, lab maintenance alerts, and symposium deadlines to student mobile apps.
          </p>
        </div>

        <button onClick={() => setIsBroadcastOpen(true)} className="btn btn-primary">
          <Radio size={15} />
          <span>Dispatch New Notice</span>
        </button>
      </div>

      {/* Broadcasts Feed */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
        <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '16px', fontWeight: '700' }}>
          Recent Dispatched Broadcasts
        </h3>

        {notifications.map((notif) => {
          const isUrgent = notif.category?.toLowerCase() === 'urgent';
          const isAcademic = notif.category?.toLowerCase() === 'academic';

          return (
            <div
              key={notif.id}
              className="glass-card"
              style={{
                borderLeft: `4px solid ${
                  isUrgent ? 'var(--rose)' : isAcademic ? 'var(--cyan)' : 'var(--primary)'
                }`,
              }}
            >
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '8px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span className={`badge ${isUrgent ? 'badge-rose' : isAcademic ? 'badge-cyan' : 'badge-indigo'}`}>
                    {notif.category || 'System'}
                  </span>
                  <span className="badge badge-amber">
                    Audience: {notif.target_audience || 'ALL'}
                  </span>
                </div>
                <span style={{ fontSize: '11px', color: 'var(--text-dim)', fontFamily: 'var(--font-mono)' }}>
                  {notif.created_at ? new Date(notif.created_at).toLocaleString() : 'Recent'}
                </span>
              </div>

              <h4 style={{ fontSize: '15px', fontWeight: '700', color: '#ffffff', marginBottom: '4px' }}>
                {notif.title}
              </h4>
              <p style={{ color: 'var(--text-muted)', fontSize: '13px' }}>
                {notif.message}
              </p>
            </div>
          );
        })}

        {notifications.length === 0 && !isLoading && (
          <div className="glass-card" style={{ textAlign: 'center', padding: '36px', color: 'var(--text-dim)' }}>
            No past broadcast notifications recorded. Click 'Dispatch New Notice' to publish one.
          </div>
        )}
      </div>

      {/* Broadcast Modal */}
      <Modal
        isOpen={isBroadcastOpen}
        onClose={() => setIsBroadcastOpen(false)}
        title="Compose Department Broadcast Notice"
        maxWidth="600px"
        footer={
          <>
            <button onClick={() => setIsBroadcastOpen(false)} className="btn btn-secondary">
              Cancel
            </button>
            <button onClick={handleSendBroadcast} className="btn btn-primary" disabled={isSending}>
              <Send size={14} />
              <span>{isSending ? 'Transmitting...' : 'Dispatch Broadcast'}</span>
            </button>
          </>
        }
      >
        <form onSubmit={handleSendBroadcast} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div className="form-group">
            <label>Notice Headline *</label>
            <input
              type="text"
              className="form-control"
              placeholder="e.g. High Performance Cluster 4 Maintenance Window"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label>Detailed Message *</label>
            <textarea
              className="form-control"
              placeholder="Enter full notice instructions for students..."
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              required
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Urgency Level / Category</label>
              <select
                className="form-control"
                value={category}
                onChange={(e) => setCategory(e.target.value)}
              >
                <option value="Urgent">Urgent / Alert</option>
                <option value="Academic">Academic</option>
                <option value="System">System Notice</option>
                <option value="Events">Events & Hackathons</option>
              </select>
            </div>

            <div className="form-group">
              <label>Target Audience</label>
              <select
                className="form-control"
                value={targetAudience}
                onChange={(e) => setTargetAudience(e.target.value)}
              >
                <option value="ALL">All Students & Faculty</option>
                <option value="STUDENTS">Students Only</option>
                <option value="STAFF">Faculty Only</option>
                <option value="3rd Year">3rd Year Batches Only</option>
                <option value="4th Year">4th Year Batches Only</option>
              </select>
            </div>
          </div>
        </form>
      </Modal>
    </div>
  );
}
