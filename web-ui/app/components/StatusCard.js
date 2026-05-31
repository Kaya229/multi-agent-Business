'use client';

export default function StatusCard({ value, label, accent = false }) {
    return (
        <div className="card" style={{ textAlign: 'center' }}>
            <div
                className="metric-value"
                style={{ color: accent ? 'var(--accent)' : 'var(--text-primary)' }}
            >
                {value}
            </div>
            <div className="metric-label">{label}</div>
        </div>
    );
}
