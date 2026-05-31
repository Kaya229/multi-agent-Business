'use client';
import { useState, useEffect } from 'react';
import StatusCard from './components/StatusCard';
import CommandInput from './components/CommandInput';
import AgentGrid from './components/AgentGrid';

export default function Home() {
  const [data, setData] = useState(null);
  const [activity, setActivity] = useState([]);
  const [agents, setAgents] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch Dashboard Data
        const res = await fetch('/api/dashboard');
        const json = await res.json();
        setData(json);

        // Parse completed tasks for activity feed
        if (json.raw) {
          const completedSection = json.raw.split('## ✅ 本日の戦果')[1]?.split('##')[0];
          if (completedSection) {
            const rows = completedSection.trim().split('\n')
              .filter(line => line.startsWith('|') && !line.includes('---') && !line.includes('時刻'));
            const items = rows.map(row => {
              const cols = row.split('|').map(c => c.trim()).filter(c => c);
              return { time: cols[0], agent: cols[1], task: cols[2], result: cols[3] };
            }).filter(item => item.task);
            setActivity(items.slice(0, 5));
          }
        }

        // Fetch Agent Status & Logs
        const resAgents = await fetch('/api/agents');
        const jsonAgents = await resAgents.json();
        if (jsonAgents.agents) {
          setAgents(jsonAgents.agents);
        }

      } catch (e) {
        console.error(e);
      }
    };
    fetchData();
    const interval = setInterval(fetchData, 2000); // Poll every 2 seconds for real-time feel
    return () => clearInterval(interval);
  }, []);

  const agentsOnline = agents.length > 0 ? agents.length : 10;
  const activeTasks = agents.filter(a => a.status === 'active').length + (data?.inProgress?.length || 0);
  const completedToday = activity.length;
  const phase = data?.phase || 'Planning';

  return (
    <div className="container" style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', gap: '2rem' }}>

      {/* Header */}
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingTop: '1rem' }}>
        <h1 style={{ fontSize: '1.5rem', fontWeight: '600', letterSpacing: '-0.01em' }}>
          AI Command Center
        </h1>
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
          <span style={{
            width: '10px',
            height: '10px',
            borderRadius: '50%',
            background: 'var(--success)',
            boxShadow: '0 0 8px var(--success)'
          }}></span>
          <span className="text-muted" style={{ fontSize: '0.875rem' }}>SYSTEM ONLINE</span>
        </div>
      </header>

      {/* Metrics */}
      <section style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '1rem' }}>
        <StatusCard value={agentsOnline} label="Agents Monitor" />
        <StatusCard value={activeTasks} label="Active Processes" accent={activeTasks > 0} />
        <StatusCard value={completedToday} label="Completed Today" />
      </section>

      {/* Agent Grid (Real-time Logs) */}
      <section>
        <h2 style={{ fontSize: '1.1rem', fontWeight: '500', marginBottom: '1rem', color: 'var(--text-primary)' }}>
          Live Agent Grid
        </h2>
        <AgentGrid agents={agents} />
      </section>

      {/* Progress */}
      <section className="card">
        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '0.75rem' }}>
          <span style={{ fontWeight: '500' }}>Current Phase: {phase}</span>
          <span className="text-muted">25%</span>
        </div>
        <div className="progress-bar">
          <div className="progress-fill" style={{ width: '25%' }}></div>
        </div>
      </section>

      {/* Command Input */}
      <section className="card">
        <CommandInput />
      </section>

      {/* Activity Feed */}
      <section className="card" style={{ flex: 1, paddingBottom: '2rem' }}>
        <h2 style={{ fontSize: '1rem', fontWeight: '500', marginBottom: '1rem', color: 'var(--text-secondary)' }}>
          Recent Activity (Confirmed)
        </h2>
        {activity.length === 0 ? (
          <p className="text-muted">No completed tasks yet today.</p>
        ) : (
          <div>
            {activity.map((item, i) => (
              <div key={i} className="activity-item">
                <span className="activity-icon">✓</span>
                <span>{item.task}</span>
                <span className="activity-time">{item.time}</span>
              </div>
            ))}
          </div>
        )}
      </section>

    </div>
  );
}

