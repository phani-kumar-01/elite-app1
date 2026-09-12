import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import DashboardView from './views/DashboardView';
import StudentsView from './views/StudentsView';
import FacultyView from './views/FacultyView';
import EventsView from './views/EventsView';
import AttendanceView from './views/AttendanceView';
import PollsView from './views/PollsView';
import BroadcastView from './views/BroadcastView';
import TicketsView from './views/TicketsView';
import SettingsView from './views/SettingsView';
import supabaseAdmin from './services/supabase';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [isConnected, setIsConnected] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // Global telemetry states
  const [metrics, setMetrics] = useState({
    students: 381,
    staff: 24,
    events: 4,
    attendanceToday: 0,
    openPolls: 1,
    openTickets: 0,
  });
  const [events, setEvents] = useState([]);
  const [recentAttendance, setRecentAttendance] = useState([]);

  // Quick modals triggers from dashboard / header
  const [isNewEventOpen, setIsNewEventOpen] = useState(false);
  const [isBroadcastOpen, setIsBroadcastOpen] = useState(false);
  const [isCheckInOpen, setIsCheckInOpen] = useState(false);

  const fetchGlobalData = async () => {
    setIsRefreshing(true);
    try {
      // 1. Connection check
      const ping = await supabaseAdmin.testConnection();
      setIsConnected(ping.ok);

      // 2. Metrics
      const m = await supabaseAdmin.getDashboardMetrics();
      setMetrics(m);

      // 3. Events
      const evs = await supabaseAdmin.getEvents();
      setEvents(evs);

      // 4. Attendance
      const att = await supabaseAdmin.getAttendanceLogs({ limit: 10 });
      setRecentAttendance(att);
    } catch (e) {
      console.error('Data fetch error:', e);
      setIsConnected(false);
    } finally {
      setIsRefreshing(false);
    }
  };

  useEffect(() => {
    fetchGlobalData();
  }, []);

  return (
    <div className="app-layout">
      {/* Navigation Sidebar */}
      <Sidebar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        metrics={metrics}
      />

      {/* Main Content Area */}
      <div className="main-wrapper">
        <Header
          activeTab={activeTab}
          isConnected={isConnected}
          onRefresh={fetchGlobalData}
          isRefreshing={isRefreshing}
          onOpenSettings={() => setActiveTab('database')}
        />

        <main style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
          {activeTab === 'dashboard' && (
            <DashboardView
              metrics={metrics}
              events={events}
              recentAttendance={recentAttendance}
              onNavigate={setActiveTab}
              onOpenNewEvent={() => {
                setActiveTab('events');
                setIsNewEventOpen(true);
              }}
              onOpenBroadcast={() => {
                setActiveTab('broadcasts');
                setIsBroadcastOpen(true);
              }}
              onOpenCheckIn={() => {
                setActiveTab('attendance');
                setIsCheckInOpen(true);
              }}
            />
          )}

          {activeTab === 'students' && <StudentsView />}

          {activeTab === 'faculty' && <FacultyView />}

          {activeTab === 'events' && (
            <EventsView
              isCreateOpen={isNewEventOpen}
              setIsCreateOpen={setIsNewEventOpen}
            />
          )}

          {activeTab === 'attendance' && (
            <AttendanceView
              isCheckInOpen={isCheckInOpen}
              setIsCheckInOpen={setIsCheckInOpen}
            />
          )}

          {activeTab === 'polls' && <PollsView />}

          {activeTab === 'broadcasts' && (
            <BroadcastView
              isBroadcastOpen={isBroadcastOpen}
              setIsBroadcastOpen={setIsBroadcastOpen}
            />
          )}

          {activeTab === 'tickets' && <TicketsView />}

          {activeTab === 'database' && (
            <SettingsView onCredentialsUpdated={fetchGlobalData} />
          )}
        </main>
      </div>
    </div>
  );
}
