import { NextResponse } from 'next/server';
import fs from 'fs';
import path from 'path';

export async function GET() {
    try {
        // Go up from app/api/dashboard/route.js -> web-ui -> multi-agent-Business
        const dashboardPath = path.join(process.cwd(), '..', 'dashboard.md');

        if (!fs.existsSync(dashboardPath)) {
            return NextResponse.json({ error: 'Dashboard file not found' }, { status: 404 });
        }

        const content = fs.readFileSync(dashboardPath, 'utf-8');
        const lines = content.split('\n');

        const data = {
            lastUpdated: '',
            phase: '',
            inProgress: [],
            completed: [],
            raw: content, // Send raw for fallback
        };

        // Simple Parsing Logic
        let currentSection = '';

        // Parse Phase
        const phaseMatch = content.match(/Current Phase: (.*)/) || content.match(/現在のフェーズ\s*\n\*\*(.*)\*\*/);
        if (phaseMatch) data.phase = phaseMatch[1];

        // Parse Last Updated
        const updatedMatch = content.match(/最終更新: (.*)/);
        if (updatedMatch) data.lastUpdated = updatedMatch[1];

        // Parse Tables (simplified)
        // We will do more robust parsing on frontend or refine here if needed.
        // For now, let's just pass the raw content so Frontend allows "View Raw" 
        // AND extract list of active agents if possible.

        // Extracting "In Progress" table rows
        const inProgressSection = content.split('## 🔄 進行中')[1]?.split('##')[0];
        if (inProgressSection) {
            const rows = inProgressSection.trim().split('\n').filter(line => line.startsWith('|') && !line.includes('---'));
            // Remove header row
            rows.shift();
            rows.forEach(row => {
                const cols = row.split('|').map(c => c.trim()).filter(c => c);
                if (cols.length >= 2) {
                    data.inProgress.push({
                        agent: cols[0],
                        task: cols[1],
                        started: cols[2] || ''
                    });
                }
            });
        }

        return NextResponse.json(data);
    } catch (error) {
        console.error('API Error:', error);
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
