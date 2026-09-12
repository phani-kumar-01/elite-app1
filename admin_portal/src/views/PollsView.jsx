import React, { useState, useEffect } from 'react';
import { Plus, BarChart3, CheckCircle2, XCircle, Users, Lock, Unlock } from 'lucide-react';
import supabaseAdmin from '../services/supabase';
import Modal from '../components/Modal';

export default function PollsView() {
  const [polls, setPolls] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [isAddOpen, setIsAddOpen] = useState(false);

  // New Poll form
  const [question, setQuestion] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('Department');
  const [options, setOptions] = useState(['', '', '']);

  const fetchPolls = async () => {
    setIsLoading(true);
    try {
      const data = await supabaseAdmin.getPolls();
      setPolls(data);
    } catch (e) {
      console.error(e);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchPolls();
  }, []);

  const handleCreatePoll = async (e) => {
    e.preventDefault();
    const validOptions = options.filter((o) => o.trim().length > 0);
    if (!question.trim() || validOptions.length < 2) {
      alert('Please provide a question and at least 2 options.');
      return;
    }

    try {
      await supabaseAdmin.createPoll({
        question,
        description,
        category,
        options: validOptions,
      });
      setIsAddOpen(false);
      setQuestion('');
      setDescription('');
      setOptions(['', '', '']);
      fetchPolls();
    } catch (err) {
      alert('Error creating poll: ' + err.message);
    }
  };

  const handleToggleStatus = async (poll) => {
    const newStatus = poll.status === 'OPEN' ? 'CLOSED' : 'OPEN';
    try {
      await supabaseAdmin.updatePollStatus(poll.id, newStatus);
      fetchPolls();
    } catch (err) {
      alert('Error toggling status: ' + err.message);
    }
  };

  return (
    <div className="page-container">
      {/* Toolbar */}
      <div className="toolbar">
        <div>
          <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '18px', fontWeight: '700' }}>
            Department Voting & Decision Polls
          </h3>
          <p style={{ color: 'var(--text-muted)', fontSize: '12px' }}>
            Direct democratic participation for students and faculty.
          </p>
        </div>

        <button onClick={() => setIsAddOpen(true)} className="btn btn-primary">
          <Plus size={15} />
          <span>Create Department Poll</span>
        </button>
      </div>

      {/* Poll Cards Grid */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
        {polls.map((poll) => {
          const totalVotes = (poll.options || []).reduce(
            (sum, opt) => sum + (parseInt(opt.vote_count) || 0),
            0
          );
          const isOpen = poll.status === 'OPEN';

          return (
            <div key={poll.id} className="glass-card" style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', flexWrap: 'wrap', gap: '10px' }}>
                <div>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                    <span className="badge badge-indigo">{poll.category || 'Department'}</span>
                    <span className={`badge ${isOpen ? 'badge-emerald' : 'badge-rose'}`}>
                      {poll.status || 'OPEN'}
                    </span>
                  </div>
                  <h3 style={{ fontFamily: 'var(--font-heading)', fontSize: '17px', fontWeight: '800', color: '#ffffff' }}>
                    {poll.question}
                  </h3>
                  {poll.description && (
                    <p style={{ color: 'var(--text-muted)', fontSize: '13px', marginTop: '4px' }}>
                      {poll.description}
                    </p>
                  )}
                </div>

                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <span style={{ fontSize: '13px', fontWeight: '700', color: 'var(--cyan)' }}>
                    {totalVotes} total votes
                  </span>
                  <button
                    onClick={() => handleToggleStatus(poll)}
                    className="btn btn-secondary"
                    style={{ padding: '6px 12px', fontSize: '12px' }}
                  >
                    {isOpen ? <Lock size={13} /> : <Unlock size={13} />}
                    <span>{isOpen ? 'Close Poll' : 'Re-Open'}</span>
                  </button>
                </div>
              </div>

              {/* Options & Votes Bars */}
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginTop: '8px' }}>
                {(poll.options || []).map((opt) => {
                  const votes = parseInt(opt.vote_count) || 0;
                  const pct = totalVotes > 0 ? Math.round((votes / totalVotes) * 100) : 0;

                  return (
                    <div key={opt.id} className="poll-option-box">
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px' }}>
                        <span style={{ fontWeight: '600', color: '#ffffff' }}>{opt.text}</span>
                        <span style={{ fontWeight: '700', color: 'var(--text-muted)' }}>
                          {votes} votes ({pct}%)
                        </span>
                      </div>
                      <div className="progress-bar-track">
                        <div className="progress-bar-fill" style={{ width: `${pct}%` }}></div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          );
        })}

        {polls.length === 0 && !isLoading && (
          <div className="glass-card" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-dim)' }}>
            No active polls found. Click 'Create Department Poll' to initiate a community vote.
          </div>
        )}
      </div>

      {/* Create Poll Modal */}
      <Modal
        isOpen={isAddOpen}
        onClose={() => setIsAddOpen(false)}
        title="Initiate Department Poll"
        maxWidth="600px"
        footer={
          <>
            <button onClick={() => setIsAddOpen(false)} className="btn btn-secondary">
              Cancel
            </button>
            <button onClick={handleCreatePoll} className="btn btn-primary">
              Publish Poll
            </button>
          </>
        }
      >
        <form onSubmit={handleCreatePoll} style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
          <div className="form-group">
            <label>Question / Ballot Prompt *</label>
            <input
              type="text"
              className="form-control"
              placeholder="e.g. Which track should lead the upcoming Symposium?"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
              required
            />
          </div>

          <div className="form-group">
            <label>Description (Context)</label>
            <textarea
              className="form-control"
              placeholder="Provide background context for students & faculty..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
            />
          </div>

          <div className="form-group">
            <label>Category</label>
            <select
              className="form-control"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            >
              <option value="Department">Department</option>
              <option value="Curriculum">Curriculum</option>
              <option value="Hackathon">Hackathon</option>
              <option value="Student Life">Student Life</option>
            </select>
          </div>

          <div className="form-group">
            <label>Ballot Options (Minimum 2)</label>
            {options.map((opt, idx) => (
              <div key={idx} style={{ marginBottom: '8px' }}>
                <input
                  type="text"
                  className="form-control"
                  placeholder={`Option ${idx + 1}`}
                  value={opt}
                  onChange={(e) => {
                    const newOpts = [...options];
                    newOpts[idx] = e.target.value;
                    setOptions(newOpts);
                  }}
                />
              </div>
            ))}
            <button
              type="button"
              onClick={() => setOptions([...options, ''])}
              className="btn btn-secondary"
              style={{ alignSelf: 'flex-start', padding: '4px 10px', fontSize: '12px' }}
            >
              + Add Another Option
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
