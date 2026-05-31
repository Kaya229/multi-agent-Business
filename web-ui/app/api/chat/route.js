import { NextResponse } from 'next/server';
import { exec } from 'child_process';
import util from 'util';

const execPromise = util.promisify(exec);

export async function GET() {
    try {
        // Capture the last 200 lines of the shogun session
        // -p = print to stdout (don't fill buffer)
        // -S -200 = start -200 lines from end (history)
        // We add "-e" to include escape sequences (for colors) if we handle them on frontend,
        // or we strip them. For MVP simplicity, let's strip them or just capture generic text.
        // Standard capture-pane output does not include colors unless -e is used.
        // Let's capture plain text for now for easier rendering.

        const { stdout } = await execPromise('tmux capture-pane -t shogun:main -p -S -200');

        const lines = stdout.split('\n');

        return NextResponse.json({ history: lines });

    } catch (error) {
        console.error('API Error:', error);
        // If session doesn't exist, return empty
        if (error.message && error.message.includes('sessions not found')) {
            return NextResponse.json({ history: ['Waiting for session...'] });
        }
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
