import React, { useState, useEffect } from 'react';
import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';
import { Snowflake, Tag, ShieldCheck, Activity, RefreshCw } from 'lucide-react';

export default function CloudKitchenDashboard() {
  const [telemetry, setTelemetry] = useState({
    temperature_c: 4.2,
    humidity_percent: 86.5,
    ethylene_ppm: 1.2,
    ammonia_ppm: 3.8,
    rsl_hours: 18.5,
    status: 'SAFE'
  });

  const [auditLogs, setAuditLogs] = useState([
    { batch_id: '#BIO-8834', action: '30% FEFO Markdown', discount: '30%', hash: 'a591a6d40bf420404a011733cfb7b190' },
    { batch_id: '#BIO-9912', action: '15% FEFO Markdown', discount: '15%', hash: 'f82e11c90a12001948ba1091a1829012' }
  ]);

  const chartData = [
    { time: '10:00', temp: 4.0, ammonia: 2.0 },
    { time: '10:05', temp: 4.2, ammonia: 2.1 },
    { time: '10:10', temp: 4.5, ammonia: 2.5 },
    { time: '10:15', temp: 5.1, ammonia: 3.2 },
    { time: '10:20', temp: 5.8, ammonia: 4.1 },
    { time: '10:25', temp: 6.2, ammonia: 5.0 }
  ];

  const triggerMarkdown = () => {
    const newLog = {
      batch_id: `#BIO-NEW-${Math.floor(Math.random() * 9000 + 1000)}`,
      action: 'Instant FEFO Sync',
      discount: '30%',
      hash: Math.random().toString(36).substring(2, 18)
    };
    setAuditLogs([newLog, ...auditLogs]);
  };

  return (
    <div style={{ backgroundColor: '#F6FAF4', minHeight: '100vh', fontFamily: "'Plus Jakarta Sans', sans-serif" }}>
      {/* Header */}
      <header style={{
        background: 'linear-gradient(135deg, #D0F0C0, #ACE1AF)',
        borderBottom: '2px solid #93C572',
        padding: '16px 32px',
        display: 'flex',
        justify-content: 'space-between',
        alignItems: 'center'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ width: '42px', height: '42px', backgroundColor: '#836953', borderRadius: '12px', color: '#FFF', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: '800' }}>🧬</div>
          <div>
            <h1 style={{ fontSize: '1.4rem', fontWeight: '800', color: '#3A2E2B' }}>BIOROUTE ENTERPRISE</h1>
            <p style={{ fontSize: '0.85rem', color: '#836953', fontWeight: '600' }}>Cloud Kitchen Operations & Aggregator Integration Portal</p>
          </div>
        </div>
        <div style={{ backgroundColor: 'rgba(255,255,255,0.85)', border: '1.5px solid #93C572', padding: '8px 18px', borderRadius: '30px', fontWeight: '700', fontSize: '0.85rem', display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Activity size={16} color="#93C572" />
          <span>LIVE CHILLER & AGGREGATOR SYNC</span>
        </div>
      </header>

      {/* Main Grid */}
      <main style={{ padding: '28px 32px', display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '24px', maxWidth: '1600px', margin: '0 auto' }}>
        
        {/* Panel 1: Chiller Tracker */}
        <div style={{ background: 'rgba(208, 240, 192, 0.45)', backdropFilter: 'blur(12px)', border: '1.5px solid rgba(147, 197, 114, 0.4)', borderRadius: '20px', padding: '24px' }}>
          <h2 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#3A2E2B', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Snowflake color="#836953" size={20} />
            Chiller Sensor Telemetry
          </h2>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '20px' }}>
            <div style={{ background: 'rgba(255,255,255,0.85)', border: '1px solid #ACE1AF', padding: '12px', borderRadius: '12px' }}>
              <span style={{ fontSize: '0.75rem', fontWeight: '700', color: '#836953' }}>TEMP</span>
              <div style={{ fontSize: '1.4rem', fontWeight: '800', color: '#3A2E2B' }}>{telemetry.temperature_c} °C</div>
            </div>
            <div style={{ background: 'rgba(255,255,255,0.85)', border: '1px solid #ACE1AF', padding: '12px', borderRadius: '12px' }}>
              <span style={{ fontSize: '0.75rem', fontWeight: '700', color: '#836953' }}>HUMIDITY</span>
              <div style={{ fontSize: '1.4rem', fontWeight: '800', color: '#3A2E2B' }}>{telemetry.humidity_percent} %</div>
            </div>
          </div>

          <div style={{ height: '200px' }}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(147, 197, 114, 0.2)" />
                <XAxis dataKey="time" stroke="#836953" />
                <YAxis stroke="#836953" />
                <Tooltip />
                <Line type="monotone" dataKey="temp" stroke="#836953" strokeWidth={3} />
                <Line type="monotone" dataKey="ammonia" stroke="#93C572" strokeWidth={3} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Panel 2: FEFO Markdown Engine */}
        <div style={{ background: 'rgba(208, 240, 192, 0.45)', backdropFilter: 'blur(12px)', border: '1.5px solid rgba(147, 197, 114, 0.4)', borderRadius: '20px', padding: '24px' }}>
          <h2 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#3A2E2B', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Tag color="#836953" size={20} />
            FEFO Dynamic Markdown Engine
          </h2>
          <div style={{ background: 'rgba(255,255,255,0.85)', borderLeft: '5px solid #93C572', padding: '16px', borderRadius: '12px', marginBottom: '12px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div>
              <div style={{ fontWeight: '800' }}>Batch #BIO-8834: Cut Veggies</div>
              <div style={{ fontSize: '0.8rem', color: '#836953' }}>RSL: 4.85 Hrs</div>
            </div>
            <span style={{ backgroundColor: '#836953', color: '#FFF', padding: '4px 12px', borderRadius: '20px', fontWeight: '800' }}>30% OFF</span>
          </div>

          <button onClick={triggerMarkdown} style={{ width: '100%', backgroundColor: '#93C572', color: '#3A2E2B', border: 'none', padding: '12px', borderRadius: '12px', fontWeight: '700', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', marginTop: '20px' }}>
            <RefreshCw size={18} />
            Trigger Swiggy/Zomato FEFO Sync
          </button>
        </div>

        {/* Panel 3: Cryptographic Audit Log */}
        <div style={{ background: 'rgba(208, 240, 192, 0.45)', backdropFilter: 'blur(12px)', border: '1.5px solid rgba(147, 197, 114, 0.4)', borderRadius: '20px', padding: '24px' }}>
          <h2 style={{ fontSize: '1.15rem', fontWeight: '800', color: '#3A2E2B', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <ShieldCheck color="#836953" size={20} />
            Cryptographic Freshness Audit Log
          </h2>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem' }}>
            <thead>
              <tr style={{ backgroundColor: 'rgba(131, 105, 83, 0.1)', color: '#836953' }}>
                <th style={{ padding: '8px', textAlign: 'left' }}>Batch</th>
                <th style={{ padding: '8px', textAlign: 'left' }}>Discount</th>
                <th style={{ padding: '8px', textAlign: 'left' }}>SHA-256 Hash</th>
              </tr>
            </thead>
            <tbody>
              {auditLogs.map((log, index) => (
                <tr key={index} style={{ borderBottom: '1px solid rgba(147, 197, 114, 0.3)' }}>
                  <td style={{ padding: '8px', fontWeight: '700' }}>{log.batch_id}</td>
                  <td style={{ padding: '8px' }}>{log.discount}</td>
                  <td style={{ padding: '8px', fontFamily: 'monospace', fontSize: '0.75rem', color: '#836953' }}>{log.hash.substring(0, 10)}...</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

      </main>
    </div>
  );
}
