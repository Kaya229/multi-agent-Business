import { NextResponse } from 'next/server';
import fs from 'fs';
import path from 'path';

export const dynamic = 'force-dynamic';

export async function GET() {
    try {
        const projectRoot = path.resolve(process.cwd(), '..'); // Assuming web-ui is in project root/web-ui
        const logsDir = path.join(projectRoot, 'logs');

        const agentNames = [
            'orchestrator', 'strategy_consultant', 'product_owner',
            'tech_lead', 'frontend', 'backend', 'db_infra', 'ui_ux',
            'qa_reviewer', 'archivist'
        ];

        // Map slightly different log naming conventions if necessary
        // Logs are typically: YYYYMMDD_HHMMSS_{Name}.log

        // Mapping from internal agent ID to log name fragment
        const logNameMapping = {
            'orchestrator': 'orchestrator', // e.g. ..._orchestrator.log
            'strategy_consultant': 'Strategy', // e.g. ..._Strategy.log
            'product_owner': 'ProductOwner',
            'tech_lead': 'TechLead',
            'frontend': 'Frontend',
            'backend': 'Backend',
            'db_infra': 'DBInfra',
            'ui_ux': 'UIUX',
            'qa_reviewer': 'QA',
            'archivist': 'Archivist'
        };

        const agents = [];

        // Check if logs directory exists
        if (fs.existsSync(logsDir)) {
            const allFiles = fs.readdirSync(logsDir);

            for (const agentId of agentNames) {
                const logFragment = logNameMapping[agentId];

                // Find latest log file for this agent
                const agentFiles = allFiles
                    .filter(f => f.includes(logFragment) && f.endsWith('.log'))
                    .sort()
                    .reverse(); // Latest first

                let status = 'idle';
                let logs = [];

                if (agentFiles.length > 0) {
                    const latestFile = agentFiles[0];
                    const fullPath = path.join(logsDir, latestFile);

                    // Check modification time
                    const stats = fs.statSync(fullPath);
                    const now = new Date();
                    const diffMs = now - stats.mtime;

                    // If modified in last 10 seconds, consider active
                    if (diffMs < 10000) {
                        status = 'active';
                    }

                    // Read last 5 lines
                    try {
                        const content = fs.readFileSync(fullPath, 'utf8');
                        const lines = content.trim().split('\n');
                        logs = lines.slice(-5);
                    } catch (e) {
                        logs = ['Error reading log'];
                    }
                }

                agents.push({
                    name: agentId,
                    status: status,
                    logs: logs
                });
            }
        } else {
            // Mock data if logs not found (e.g. dev environment without main system running)
            return NextResponse.json({ error: 'Logs directory not found', path: logsDir });
        }

        return NextResponse.json({ agents });

    } catch (error) {
        console.error('API Error:', error);
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
