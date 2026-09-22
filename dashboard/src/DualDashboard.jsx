import React, { useState } from 'react';

export default function DualDashboardPortal() {
  const [activeTab, setActiveTab] = useState('home');
  const [temp, setTemp] = useState(4.0);
  const [rh, setRh] = useState(85.0);
  const [eth, setEth] = useState(0.5);
  const [amm, setAmm] = useState(2.0);

  const Ea = 52000.0, R = 8.314;
  const refT = 277.15, currT = temp + 273.15;
  const k_thermal = currT > refT ? Math.exp((Ea / R) * ((1.0 / refT) - (1.0 / currT))) : 1.0;
  const k_eth = eth > 5.0 ? 1.0 + (eth - 5.0) * 0.12 : 1.0;
  const k_amm = amm > 10.0 ? 1.0 + (amm - 10.0) * 0.08 : 1.0;
  const k_rh = 1.0 + (Math.abs(rh - 85.0) * 0.005);

  const decayIndex = k_thermal * k_eth * k_amm * k_rh;
  const rslHours = (24.0 / decayIndex).toFixed(2);
  const isDiverted = rslHours < 6.0;

  const getStatus = () => {
    if (rslHours >= 12.0) return { label: 'STATUS: SAFE', color: '#81C784' };
    if (rslHours >= 6.0) return { label: 'STATUS: WARNING', color: '#FFB74D' };
    return { label: 'STATUS: CRITICAL', color: '#E57373' };
  };

  const statusInfo = getStatus();

  return (
    <div style={{ backgroundColor: '#14281D', minHeight: '100vh', fontFamily: "'Plus Jakarta Sans', sans-serif", color: '#F2F9F1' }}>
      {/* Header */}
      <header style={{
        background: '#1C3829',
        borderBottom: '2px solid rgba(147, 197, 114, 0.3)',
        padding: '16px 32px',
        display: 'flex',
        justify-content: 'space-between',
        alignItems: 'center'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', cursor: 'pointer' }} onClick={() => setActiveTab('home')}>
          <div style={{ width: '44px', height: '44px', backgroundColor: '#93C572', borderRadius: '12px', color: '#14281D', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: '800', fontSize: '24px' }}>🌱</div>
          <div>
            <h1 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", fontSize: '1.9rem', fontWeight: '800', color: '#FFFFFF' }}>Bioroute</h1>
          </div>
        </div>

        <nav style={{ display: 'flex', gap: '8px', background: 'rgba(20, 40, 29, 0.8)', padding: '6px', borderRadius: '30px', border: '1px solid rgba(147, 197, 114, 0.25)' }}>
          <button onClick={() => setActiveTab('home')} style={{ padding: '8px 22px', borderRadius: '20px', border: 'none', fontWeight: '700', cursor: 'pointer', backgroundColor: activeTab === 'home' ? '#93C572' : 'transparent', color: activeTab === 'home' ? '#14281D' : '#ACE1AF' }}>Home</button>
          <button onClick={() => setActiveTab('kitchen')} style={{ padding: '8px 22px', borderRadius: '20px', border: 'none', fontWeight: '700', cursor: 'pointer', backgroundColor: activeTab === 'kitchen' ? '#93C572' : 'transparent', color: activeTab === 'kitchen' ? '#14281D' : '#ACE1AF' }}>Cloud Kitchen Admin</button>
          <button onClick={() => setActiveTab('truck')} style={{ padding: '8px 22px', borderRadius: '20px', border: 'none', fontWeight: '700', cursor: 'pointer', backgroundColor: activeTab === 'truck' ? '#93C572' : 'transparent', color: activeTab === 'truck' ? '#14281D' : '#ACE1AF' }}>Truck Fleet Logistics</button>
        </nav>
      </header>

      {/* Sliders (Hidden on Home View) */}
      {activeTab !== 'home' && (
        <div style={{ background: 'rgba(20, 40, 29, 0.95)', borderBottom: '1.5px solid rgba(147, 197, 114, 0.25)', padding: '16px 32px', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr) auto', gap: '20px', alignItems: 'center' }}>
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', fontWeight: '800', color: '#ACE1AF' }}>
              <span>TEMPERATURE</span>
              <span style={{ color: '#BAED91' }}>{temp.toFixed(1)} °C</span>
            </div>
            <input type="range" min="2.0" max="40.0" step="0.5" value={temp} onChange={(e) => setTemp(parseFloat(e.target.value))} style={{ width: '100%', accentColor: '#93C572' }} />
          </div>

          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', fontWeight: '800', color: '#ACE1AF' }}>
              <span>HUMIDITY</span>
              <span style={{ color: '#BAED91' }}>{rh.toFixed(1)} %</span>
            </div>
            <input type="range" min="30.0" max="95.0" step="1.0" value={rh} onChange={(e) => setRh(parseFloat(e.target.value))} style={{ width: '100%', accentColor: '#93C572' }} />
          </div>

          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', fontWeight: '800', color: '#ACE1AF' }}>
              <span>ETHYLENE GAS</span>
              <span style={{ color: '#BAED91' }}>{eth.toFixed(1)} ppm</span>
            </div>
            <input type="range" min="0.0" max="50.0" step="0.5" value={eth} onChange={(e) => setEth(parseFloat(e.target.value))} style={{ width: '100%', accentColor: '#93C572' }} />
          </div>

          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.75rem', fontWeight: '800', color: '#ACE1AF' }}>
              <span>AMMONIA / VOC</span>
              <span style={{ color: '#BAED91' }}>{amm.toFixed(1)} ppm</span>
            </div>
            <input type="range" min="0.0" max="100.0" step="1.0" value={amm} onChange={(e) => setAmm(parseFloat(e.target.value))} style={{ width: '100%', accentColor: '#93C572' }} />
          </div>

          <div style={{ background: 'rgba(28, 56, 41, 0.75)', border: '1.5px solid #93C572', padding: '10px 20px', borderRadius: '16px', textAlign: 'center' }}>
            <div style={{ fontSize: '0.7rem', color: '#ACE1AF', fontWeight: '700' }}>DYNAMIC RSL</div>
            <div style={{ fontSize: '1.4rem', fontWeight: '800', color: '#BAED91' }}>{rslHours} HRS</div>
            <div style={{ fontWeight: '800', fontSize: '0.8rem', color: statusInfo.color }}>{statusInfo.label}</div>
          </div>
        </div>
      )}

      {/* Main Content Area */}
      <main style={{ padding: '28px 32px', maxWidth: '1600px', margin: '0 auto' }}>
        {activeTab === 'home' && (
          <div>
            <div style={{ textAlign: 'center', maxWidth: '920px', margin: '16px auto 32px auto' }}>
              <h1 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", fontSize: '3.5rem', fontWeight: '900', color: '#FFFFFF', lineHeight: '1.12', marginBottom: '14px' }}>
                Welcome to Bioroute.
              </h1>
              <div style={{ fontSize: '1.15rem', color: '#ACE1AF', fontWeight: '500', lineHeight: '1.6', marginBottom: '16px' }}>
                Choose an operational portal to manage inventory, staff meals, food recovery NGOs, or highway fleet logistics:
              </div>
              <div style={{ fontSize: '0.95rem', color: '#BAED91', fontWeight: '800', textTransform: 'uppercase', letterSpacing: '1.5px' }}>
                Select Operational Domain
              </div>
            </div>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '32px' }}>
              <div onClick={() => setActiveTab('kitchen')} style={{ background: 'rgba(28, 56, 41, 0.75)', border: '2px solid rgba(147, 197, 114, 0.25)', borderRadius: '24px', padding: '36px', cursor: 'pointer' }}>
                <div style={{ fontSize: '56px', marginBottom: '16px' }}>🍳</div>
                <h3 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", fontSize: '1.85rem', fontWeight: '800', color: '#FFFFFF' }}>Cloud Kitchen Operations</h3>
                <p style={{ color: '#ACE1AF', fontWeight: '500', marginTop: '12px', lineHeight: '1.6' }}>Multi-zone chiller telemetry, Swiggy/Zomato FEFO discount webhooks, <strong>Staff Meals Auto-Earmarking</strong>, and food recovery <strong>NGO Dispatches (Robin Hood Army)</strong>.</p>
              </div>

              <div onClick={() => setActiveTab('truck')} style={{ background: 'rgba(28, 56, 41, 0.75)', border: '2px solid rgba(147, 197, 114, 0.25)', borderRadius: '24px', padding: '36px', cursor: 'pointer' }}>
                <div style={{ fontSize: '56px', marginBottom: '16px' }}>🚚</div>
                <h3 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", fontSize: '1.85rem', fontWeight: '800', color: '#FFFFFF' }}>Truck Fleet Logistics</h3>
                <p style={{ color: '#ACE1AF', fontWeight: '500', marginTop: '12px', lineHeight: '1.6' }}>Pure B2B highway corridor telematics, dynamic spatial A* rerouting visualizer, and automated secondary outlet diversion.</p>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'kitchen' && (
          <div>
            <h2 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", fontSize: '2.1rem', fontWeight: '800', color: '#FFFFFF', marginBottom: '20px' }}>🍳 Cloud Kitchen Operations Portal</h2>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '24px' }}>
              <div style={{ background: 'rgba(28, 56, 41, 0.75)', borderRadius: '20px', padding: '24px', border: '1.5px solid rgba(147, 197, 114, 0.25)' }}>
                <h3 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", color: '#FFFFFF' }}>❄️ Multi-Zone Chiller Telemetry</h3>
                <p style={{ marginTop: '12px', fontWeight: '700', color: '#BAED91' }}>Zone 1 Temp: {temp.toFixed(1)} °C</p>
                <p style={{ fontWeight: '700', color: '#BAED91' }}>Ammonia/VOC: {amm.toFixed(1)} ppm</p>
              </div>
              <div style={{ background: 'rgba(28, 56, 41, 0.75)', borderRadius: '20px', padding: '24px', border: '1.5px solid rgba(147, 197, 114, 0.25)' }}>
                <h3 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", color: '#FFFFFF' }}>🏷️ Dynamic FEFO & Recovery Actions</h3>
                <p style={{ marginTop: '12px', fontWeight: '700' }}>🏷️ Swiggy/Zomato Markdown (30% OFF)</p>
                <p style={{ marginTop: '8px', fontWeight: '700', color: '#BAED91' }}>🍲 Staff Meals Auto-Earmark Active</p>
                <p style={{ marginTop: '8px', fontWeight: '700', color: '#81C784' }}>🤝 Food Recovery NGO (Robin Hood Army)</p>
              </div>
              <div style={{ background: 'rgba(28, 56, 41, 0.75)', borderRadius: '20px', padding: '24px', border: '1.5px solid rgba(147, 197, 114, 0.25)' }}>
                <h3 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", color: '#FFFFFF' }}>🛡️ Cryptographic Audit Log</h3>
                <p style={{ marginTop: '12px', fontFamily: 'monospace', color: '#D4B296' }}>SHA-256: a591a6d40bf420404a01...</p>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'truck' && (
          <div>
            <h2 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", fontSize: '2.1rem', fontWeight: '800', color: '#FFFFFF', marginBottom: '20px' }}>🚚 Truck Fleet Logistics & Highway Telematics</h2>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '24px' }}>
              <div style={{ background: 'rgba(28, 56, 41, 0.75)', borderRadius: '20px', padding: '24px', border: '1.5px solid rgba(147, 197, 114, 0.25)' }}>
                <h3 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", color: '#FFFFFF' }}>📡 Vehicle Telematics</h3>
                <p style={{ marginTop: '12px', fontWeight: '700' }}>Vehicle ID: TN-01-BIO-9921</p>
                <p style={{ fontWeight: '700', color: '#BAED91' }}>Cargo Temp: {temp.toFixed(1)} °C</p>
                <p style={{ fontWeight: '700', color: '#BAED91' }}>Calculated RSL: {rslHours} Hrs</p>
              </div>
              <div style={{ background: 'rgba(28, 56, 41, 0.75)', borderRadius: '20px', padding: '24px', border: '1.5px solid rgba(147, 197, 114, 0.25)' }}>
                <h3 style={{ fontFamily: "'Outfit', 'Syne', sans-serif", color: '#FFFFFF' }}>🗺️ Spatial Reroute Visualizer (A* Search)</h3>
                <div style={{ padding: '16px', borderRadius: '12px', marginTop: '16px', fontWeight: '800', backgroundColor: isDiverted ? 'rgba(229,115,115,0.2)' : 'rgba(129,199,132,0.2)', color: isDiverted ? '#E57373' : '#81C784' }}>
                  {isDiverted ? `🚨 CRITICAL SPOILAGE RISK (RSL ${rslHours} hrs < 6.0 hrs ETA)! Dynamic A* Reroute -> Diverting to Ranipet Processing Plant (ETA 2.0 hrs)` : `✅ MAINTAINING PRIMARY ROUTE to Koyambedu Mandi Chennai (ETA 6.0 hrs)`}
                </div>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
