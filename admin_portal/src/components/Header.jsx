import React, { useState } from 'react';
import { RefreshCw, Key, ExternalLink, CheckCircle2, AlertCircle } from 'lucide-react';
import supabaseAdmin from '../services/supabase';

export default function Header({ activeTab, isConnected, onRefresh, isRefreshing, onOpenSettings }) {
  const titles = {
    dashboard: 'System Overview & Live Telemetry',
    students: 'Student Records & Turnstile Passes',
    faculty: 'Faculty & Department Staff',
    events: 'Events, Hackathons & Competitions',
    attendance: 'Live Turnstile & Lab Gate Monitor',
    polls: 'Department Voting & Live Opinion Tally',
    broadcasts: 'Emergency & Department Broadcasts',
    tickets: 'Student Queries & Helpdesk Tickets',
    database: 'Supabase PostgreSQL Configuration & Health',
  };

  return (
    <header className="top-header">
      <div className="header-left">
        <div className="page-title-badge">
          <h2 className="page-title">{titles[activeTab] || 'Department Administration'}</h2>
        </div>
      </div>

      <div className="header-right">
        {/* Supabase Status Indicator */}
        <div className={`supabase-pill ${isConnected ? '' : 'offline'}`}>
          <span className={`pulse-dot ${isConnected ? '' : 'offline'}`}></span>
          <span>{isConnected ? 'Supabase Live' : 'Supabase Offline'}</span>
        </div>

        {/* Sync Button */}
        <button
          onClick={onRefresh}
          className="btn-icon"
          title="Refresh Supabase Data"
          disabled={isRefreshing}
        >
          <RefreshCw size={16} className={isRefreshing ? 'animate-spin' : ''} style={{ animation: isRefreshing ? 'spin 1s linear infinite' : 'none' }} />
        </button>

        {/* Settings / API Key Button */}
        <button
          onClick={onOpenSettings}
          className="btn btn-secondary"
          style={{ padding: '6px 12px', fontSize: '12px' }}
        >
          <Key size={14} />
          <span>API Keys</span>
        </button>

        <style>{`
          @keyframes spin {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
          }
        `}</style>
      </div>
    </header>
  );
}
