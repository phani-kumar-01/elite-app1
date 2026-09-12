import React, { useState, useEffect } from 'react';
import { Database, Key, CheckCircle2, AlertCircle, RefreshCw, Server, ShieldCheck } from 'lucide-react';
import supabaseAdmin from '../services/supabase';

export default function SettingsView({ onCredentialsUpdated }) {
  const [url, setUrl] = useState(supabaseAdmin.url);
  const [key, setKey] = useState(supabaseAdmin.key);
  const [testResult, setTestResult] = useState(null);
  const [isTesting, setIsTesting] = useState(false);
  const [savedMessage, setSavedMessage] = useState('');

  const handleTestConnection = async () => {
    setIsTesting(true);
    setTestResult(null);
    try {
      const res = await supabaseAdmin.testConnection();
      setTestResult(res);
    } catch (e) {
      setTestResult({ ok: false, error: e.message });
    } finally {
      setIsTesting(false);
    }
  };

  useEffect(() => {
    handleTestConnection();
  }, []);

  const handleSave = (e) => {
    e.preventDefault();
    supabaseAdmin.updateCredentials(url, key);
    setSavedMessage('Supabase credentials successfully updated and active!');
    if (onCredentialsUpdated) onCredentialsUpdated();
    setTimeout(() => setSavedMessage(''), 4000);
    handleTestConnection();
  };

  const handleReset = () => {
    supabaseAdmin.resetCredentials();
    setUrl(supabaseAdmin.url);
    setKey(supabaseAdmin.key);
    setSavedMessage('Reset to default project credentials.');
    if (onCredentialsUpdated) onCredentialsUpdated();
    setTimeout(() => setSavedMessage(''), 4000);
    handleTestConnection();
  };

  return (
    <div className="page-container">
      {/* Top Banner */}
      <div className="glass-card">
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
          <span className="badge badge-indigo">
            <Server size={12} /> Backend Gateway
          </span>
          <span className="badge badge-emerald">
            <ShieldCheck size={12} /> 100% Supabase Powered
          </span>
        </div>
        <h2 style={{ fontFamily: 'var(--font-heading)', fontSize: '20px', fontWeight: '800' }}>
          Supabase PostgreSQL Connection & Security Keys
        </h2>
        <p style={{ color: 'var(--text-muted)', fontSize: '13px', marginTop: '4px' }}>
          Manage your live Supabase endpoint and switch between Anon Public key and Service Role key.
        </p>
      </div>

      {/* Connection Status Card */}
      <div className="glass-card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
          <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '16px', fontWeight: '700' }}>
            Live Supabase Diagnostics
          </h3>
          <button
            onClick={handleTestConnection}
            className="btn btn-secondary"
            disabled={isTesting}
            style={{ padding: '6px 12px', fontSize: '12px' }}
          >
            <RefreshCw size={13} className={isTesting ? 'animate-spin' : ''} />
            <span>Run Health Check</span>
          </button>
        </div>

        {testResult && (
          <div
            style={{
              padding: '12px 16px',
              borderRadius: '8px',
              background: testResult.ok ? 'rgba(16, 185, 129, 0.1)' : 'rgba(244, 63, 94, 0.1)',
              border: `1px solid ${testResult.ok ? 'rgba(16, 185, 129, 0.3)' : 'rgba(244, 63, 94, 0.3)'}`,
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
            }}
          >
            {testResult.ok ? (
              <CheckCircle2 size={20} color="var(--emerald)" />
            ) : (
              <AlertCircle size={20} color="var(--rose)" />
            )}
            <div>
              <div style={{ fontWeight: '700', color: testResult.ok ? '#34d399' : '#fb7185' }}>
                {testResult.ok ? 'Database Connected & Operational' : 'Connection Failure'}
              </div>
              <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                {testResult.ok
                  ? `Successfully authenticated to ${supabaseAdmin.url} via PostgreSQL client.`
                  : testResult.error}
              </div>
            </div>
          </div>
        )}

        <div style={{ marginTop: '16px', display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '12px' }}>
          {[
            { name: 'students', label: 'Student Enrolment (381)' },
            { name: 'staff', label: 'Faculty Coordinators' },
            { name: 'events', label: 'Events & Lineup' },
            { name: 'event_attendance', label: 'Turnstile Scans' },
            { name: 'polls', label: 'Ballots & Polls' },
            { name: 'notifications', label: 'System Broadcasts' },
            { name: 'student_queries', label: 'Helpdesk Tickets' },
          ].map((t) => (
            <div
              key={t.name}
              style={{
                padding: '10px 12px',
                background: 'rgba(255, 255, 255, 0.02)',
                borderRadius: '8px',
                border: '1px solid var(--border-subtle)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
              }}
            >
              <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{t.label}</span>
              <span className="badge badge-emerald">Ready</span>
            </div>
          ))}
        </div>
      </div>

      {/* Credential Form */}
      <div className="glass-card">
        <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '16px', fontWeight: '700', marginBottom: '14px' }}>
          API Endpoint & Security Credentials
        </h3>

        {savedMessage && (
          <div
            style={{
              padding: '10px 14px',
              borderRadius: '8px',
              background: 'rgba(16, 185, 129, 0.15)',
              border: '1px solid rgba(16, 185, 129, 0.3)',
              color: '#34d399',
              fontSize: '13px',
              fontWeight: '600',
              marginBottom: '14px',
            }}
          >
            {savedMessage}
          </div>
        )}

        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div className="form-group">
            <label>Supabase Project URL</label>
            <input
              type="text"
              className="form-control"
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label>Supabase API Key (Anon Public Key or Service Role Key)</label>
            <textarea
              className="form-control"
              value={key}
              onChange={(e) => setKey(e.target.value)}
              rows={3}
              required
            />
            <span style={{ fontSize: '11px', color: 'var(--text-dim)' }}>
              * You can paste a <strong>service_role</strong> secret key here to bypass Row Level Security (RLS) for complete admin overrides.
            </span>
          </div>

          <div style={{ display: 'flex', gap: '10px', marginTop: '6px' }}>
            <button type="submit" className="btn btn-primary">
              <Key size={14} />
              <span>Apply & Activate Credentials</span>
            </button>
            <button type="button" onClick={handleReset} className="btn btn-secondary">
              Reset to Project Defaults
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
