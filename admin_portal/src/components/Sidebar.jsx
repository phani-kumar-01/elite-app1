import React from 'react';
import {
  LayoutDashboard,
  GraduationCap,
  Users,
  CalendarDays,
  ScanLine,
  BarChart3,
  Radio,
  LifeBuoy,
  Database,
  Cpu,
} from 'lucide-react';

export default function Sidebar({ activeTab, setActiveTab, metrics }) {
  const navItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard, badge: null },
    { id: 'students', label: 'Students Directory', icon: GraduationCap, badge: metrics?.students || '381' },
    { id: 'faculty', label: 'Faculty & Staff', icon: Users, badge: metrics?.staff || null },
    { id: 'events', label: 'Events & Lineup', icon: CalendarDays, badge: metrics?.events || null },
    { id: 'attendance', label: 'Turnstile & Labs', icon: ScanLine, badge: 'Live' },
    { id: 'polls', label: 'Department Polls', icon: BarChart3, badge: metrics?.openPolls ? `${metrics.openPolls} Open` : null },
    { id: 'broadcasts', label: 'Broadcast Notices', icon: Radio, badge: null },
    { id: 'tickets', label: 'Service Helpdesk', icon: LifeBuoy, badge: metrics?.openTickets ? `${metrics.openTickets}` : null },
    { id: 'database', label: 'Database & Keys', icon: Database, badge: null },
  ];

  return (
    <aside className="sidebar">
      {/* Brand Header */}
      <div className="sidebar-header">
        <div className="brand-icon-box">
          <Cpu size={22} />
        </div>
        <div className="brand-info">
          <h1>ELITE ADMIN</h1>
          <p>Autonomous IT Ops</p>
        </div>
      </div>

      {/* Navigation list */}
      <nav className="sidebar-nav">
        <span className="nav-section-label">Command Modules</span>
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              className={`nav-btn ${isActive ? 'active' : ''}`}
            >
              <Icon className="nav-icon" />
              <span>{item.label}</span>
              {item.badge && (
                <span className={`nav-badge ${isActive ? 'active-badge' : ''}`}>
                  {item.badge}
                </span>
              )}
            </button>
          );
        })}
      </nav>

      {/* Admin Profile Footer */}
      <div className="sidebar-footer">
        <div className="user-snippet">
          <div className="avatar">AD</div>
          <div className="user-info">
            <div className="name">IT Super Administrator</div>
            <div className="role">
              <span className="pulse-dot" style={{ width: 6, height: 6 }}></span>
              Full Database Clearance
            </div>
          </div>
        </div>
      </div>
    </aside>
  );
}
