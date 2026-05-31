import { NextResponse } from 'next/server';
import { exec } from 'child_process';
import util from 'util';

const execPromise = util.promisify(exec);

export async function POST(request) {
    try {
        const body = await request.json();
        const { command, target = 'shogun:main' } = body;

        if (!command) {
            return NextResponse.json({ error: 'Command is required' }, { status: 400 });
        }

        // Safety check: Basic injection prevention or validation could go here.
        // Since this is a local tool for the user, we assume some trust,
        // but avoiding executing purely arbitrary shell commands if possible.
        // However, the goal IS to send arbitrary commands to the agent.

        // We escape the command for the shell to ensure it builds a valid tmux command string
        // But tmux send-keys treats arguments as keystrokes.
        // "tmux send-keys -t target 'command' Enter"

        // We must be careful with quotes.
        // A simple approach is passing the string as an argument.

        // Using JSON.stringify ensures it is properly escaped as a string literal
        const safeCommand = JSON.stringify(command);

        // Fix: JSON.stringify adds quotes "cmd", so we don't need extra quotes around it if we use it directly?
        // Actually tmux send-keys needs the raw keys.
        // If I send "ls -la", I want tmux to receive l, s, space, -, l, a.
        // best way is to wrap in single quotes: 'ls -la'

        const tmuxCommand = `tmux send-keys -t ${target} '${command.replace(/'/g, "'\\''")}' Enter`;

        console.log('Function: Executing', tmuxCommand);

        await execPromise(tmuxCommand);

        return NextResponse.json({ success: true, command: tmuxCommand });

    } catch (error) {
        console.error('API Error:', error);
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
