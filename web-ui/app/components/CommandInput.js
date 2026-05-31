'use client';
import { useState } from 'react';

export default function CommandInput() {
    const [input, setInput] = useState('');
    const [sending, setSending] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!input.trim()) return;

        setSending(true);
        try {
            await fetch('/api/command', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command: input })
            });
            setInput('');
        } catch (err) {
            console.error(err);
        }
        setSending(false);
    };

    return (
        <form onSubmit={handleSubmit} style={{ display: 'flex', gap: '1rem' }}>
            <input
                type="text"
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="What would you like me to do?"
                disabled={sending}
            />
            <button type="submit" className="btn-primary" disabled={sending}>
                {sending ? 'Sending...' : 'Send'}
            </button>
        </form>
    );
}
