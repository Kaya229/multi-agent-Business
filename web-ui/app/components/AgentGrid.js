import AgentCard from './AgentCard';

export default function AgentGrid({ agents }) {
    // Define order of agents
    const order = [
        'orchestrator',
        'strategy_consultant', 'product_owner',
        'tech_lead',
        'frontend', 'backend', 'db_infra', 'ui_ux',
        'qa_reviewer', 'archivist'
    ];

    const sortedAgents = [...agents].sort((a, b) => {
        return order.indexOf(a.name) - order.indexOf(b.name);
    });

    return (
        <div className="agent-grid">
            {sortedAgents.map(agent => (
                <AgentCard key={agent.name} agent={agent} />
            ))}
        </div>
    );
}
