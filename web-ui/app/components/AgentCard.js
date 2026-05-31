export default function AgentCard({ agent }) {
    const isActive = agent.status === 'active';

    // Format role for display
    const formatName = (name) => {
        return name.replace('_', ' ').replace(/\b\w/g, l => l.toUpperCase());
    };

    // Get icon based on name
    const getIcon = (name) => {
        if (name.includes('orchestrator')) return '👑';
        if (name.includes('strategy')) return '📊';
        if (name.includes('product')) return '📋';
        if (name.includes('tech')) return '🔧';
        if (name.includes('front')) return '💻';
        if (name.includes('back')) return '🖥️';
        if (name.includes('db')) return '🗄️';
        if (name.includes('ui')) return '🎨';
        if (name.includes('qa')) return '🔍';
        if (name.includes('archivist')) return '📚';
        return '🤖';
    };

    return (
        <div className="card" style={{ display: 'flex', flexDirection: 'column' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.5rem' }}>
                <div style={{ display: 'flex', alignItems: 'center' }}>
                    <span className="agent-role-icon">{getIcon(agent.name)}</span>
                    <span style={{ fontWeight: '600', fontSize: '0.9rem' }}>{formatName(agent.name)}</span>
                </div>
                <div className={`status-dot ${isActive ? 'active' : ''}`} title={isActive ? "Active" : "Idle"}></div>
            </div>

            <div className="terminal-window">
                {agent.logs && agent.logs.length > 0 ? (
                    agent.logs.map((line, i) => (
                        <div key={i}>{line}</div>
                    ))
                ) : (
                    <div style={{ color: '#555' }}>Waiting for output...</div>
                )}
            </div>
        </div>
    );
}
