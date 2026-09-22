import streamlit as st
import matplotlib.pyplot as plt
import networkx as nx
import json
import hashlib
import time
from engine.arrhenius import calculate_rsl
from engine.routing import evaluate_reroute

# Page configuration
st.set_page_config(
    page_title="Bioroute Engine",
    page_icon="🧬",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for high-end aesthetic dashboard
st.markdown("""
    <style>
    /* Dark glassmorphic container styling */
    .stApp {
        background-color: #0E1117;
        color: #FAFAFA;
    }
    .metric-card {
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        padding: 16px;
        margin-bottom: 12px;
        backdrop-filter: blur(10px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    }
    .metric-value {
        font-size: 26px;
        font-weight: 700;
        margin-top: 4px;
    }
    .status-badge {
        display: inline-block;
        padding: 6px 14px;
        border-radius: 20px;
        font-weight: 700;
        font-size: 14px;
        text-transform: uppercase;
        letter-spacing: 0.8px;
    }
    .status-safe {
        background-color: rgba(16, 185, 129, 0.2);
        color: #10B981;
        border: 1px solid #10B981;
    }
    .status-warning {
        background-color: rgba(245, 158, 11, 0.2);
        color: #F59E0B;
        border: 1px solid #F59E0B;
    }
    .status-critical {
        background-color: rgba(239, 68, 68, 0.2);
        color: #EF4444;
        border: 1px solid #EF4444;
    }
    .main-header {
        background: linear-gradient(90deg, #10B981, #3B82F6);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-size: 2.4rem;
        font-weight: 800;
        margin-bottom: 0px;
    }
    .sub-header {
        color: #9CA3AF;
        font-size: 1.0rem;
        margin-bottom: 24px;
    }
    </style>
""", unsafe_allow_html=True)

# Main Title Header
st.markdown('<div class="main-header">BIOROUTE ENGINE</div>', unsafe_allow_html=True)
st.markdown('<div class="sub-header">Perishable Risk & Dynamic Rerouting Engine | VIT Chennai Review II Prototype</div>', unsafe_allow_html=True)

# Sidebar Controls
st.sidebar.header("🎛️ Live Sensor Simulation")
st.sidebar.markdown("Adjust environmental sensor telemetry to test real-time Arrhenius kinetics and dynamic rerouting.")

temp_c = st.sidebar.slider(
    "🌡️ Cargo Temperature (°C)",
    min_value=2.0,
    max_value=40.0,
    value=4.0,
    step=0.5,
    help="Reference baseline is 4.0°C. Higher temperatures exponentially accelerate decay kinetics."
)

rh_percent = st.sidebar.slider(
    "💧 Relative Humidity (%)",
    min_value=30.0,
    max_value=95.0,
    value=85.0,
    step=1.0,
    help="Optimal humidity for cold-chain produce is ~85%."
)

ethylene_ppm = st.sidebar.slider(
    "🍇 Ethylene Gas (ppm)",
    min_value=0.0,
    max_value=50.0,
    value=0.5,
    step=0.5,
    help="Concentrations > 5.0 ppm trigger rapid ripening & decay acceleration."
)

ammonia_ppm = st.sidebar.slider(
    "☣️ Ammonia / VOC (ppm)",
    min_value=0.0,
    max_value=100.0,
    value=2.0,
    step=1.0,
    help="Concentrations > 10.0 ppm signal organic spoilage gas build-up."
)

st.sidebar.divider()
st.sidebar.info("💡 **Demo Preset Scenarios:**\n\n- **Nominal (4°C, 85% RH):** Safe Path\n- **Heat Stress (28°C):** Triggers Dynamic Reroute\n- **Gas Leak (12 ppm Ethylene):** Triggers Dynamic Reroute")

# Calculate Kinetics and Routing Evaluation
arrhenius_result = calculate_rsl(temp_c, rh_percent, ethylene_ppm, ammonia_ppm)
rsl_hours = arrhenius_result["rsl_hours"]
decay_index = arrhenius_result["decay_index"]
status = arrhenius_result["status"]

reroute_result = evaluate_reroute(rsl_hours)
is_diverted = reroute_result["is_diverted"]

# 3-Column Dashboard Layout
col1, col2, col3 = st.columns([1, 1, 1.2])

# ==========================================
# COLUMN 1: LIVE SENSOR TELEMETRY
# ==========================================
with col1:
    st.subheader("📡 Live Sensor Telemetry")
    
    # Temp Metric Card
    temp_color = "#10B981" if temp_c <= 8.0 else ("#F59E0B" if temp_c <= 15.0 else "#EF4444")
    st.markdown(f"""
        <div class="metric-card" style="border-left: 5px solid {temp_color};">
            <span style="color: #9CA3AF; font-size: 13px;">CARGO TEMPERATURE</span>
            <div class="metric-value" style="color: {temp_color};">{temp_c:.1f} °C</div>
            <span style="font-size: 12px; color: #6B7280;">Baseline: 4.0°C | Threshold: 8.0°C</span>
        </div>
    """, unsafe_allow_html=True)

    # Humidity Metric Card
    rh_color = "#10B981" if 75.0 <= rh_percent <= 90.0 else "#F59E0B"
    st.markdown(f"""
        <div class="metric-card" style="border-left: 5px solid {rh_color};">
            <span style="color: #9CA3AF; font-size: 13px;">RELATIVE HUMIDITY</span>
            <div class="metric-value" style="color: {rh_color};">{rh_percent:.1f} %</div>
            <span style="font-size: 12px; color: #6B7280;">Target range: 75% - 90%</span>
        </div>
    """, unsafe_allow_html=True)

    # Ethylene Metric Card
    eth_color = "#10B981" if ethylene_ppm <= 5.0 else "#EF4444"
    st.markdown(f"""
        <div class="metric-card" style="border-left: 5px solid {eth_color};">
            <span style="color: #9CA3AF; font-size: 13px;">ETHYLENE CONCENTRATION</span>
            <div class="metric-value" style="color: {eth_color};">{ethylene_ppm:.1f} ppm</div>
            <span style="font-size: 12px; color: #6B7280;">Ripening stress threshold: 5.0 ppm</span>
        </div>
    """, unsafe_allow_html=True)

    # Ammonia Metric Card
    amm_color = "#10B981" if ammonia_ppm <= 10.0 else "#EF4444"
    st.markdown(f"""
        <div class="metric-card" style="border-left: 5px solid {amm_color};">
            <span style="color: #9CA3AF; font-size: 13px;">AMMONIA / VOC SPOILAGE GAS</span>
            <div class="metric-value" style="color: {amm_color};">{ammonia_ppm:.1f} ppm</div>
            <span style="font-size: 12px; color: #6B7280;">Organic spoilage threshold: 10.0 ppm</span>
        </div>
    """, unsafe_allow_html=True)

# ==========================================
# COLUMN 2: BIOCHEMICAL DECAY KINETICS
# ==========================================
with col2:
    st.subheader("🧪 Arrhenius Kinetics & RSL")
    
    # Status Badge
    badge_class = "status-safe" if status == "SAFE" else ("status-warning" if status == "WARNING" else "status-critical")
    st.markdown(f'<span class="status-badge {badge_class}">RISK STATUS: {status}</span>', unsafe_allow_html=True)
    st.write("")

    # RSL Large Display
    st.markdown(f"""
        <div class="metric-card" style="text-align: center; padding: 24px;">
            <span style="color: #9CA3AF; font-size: 14px; text-transform: uppercase; letter-spacing: 1px;">DYNAMIC REMAINING SHELF LIFE</span>
            <div style="font-size: 54px; font-weight: 800; color: {'#10B981' if rsl_hours >= 12.0 else ('#F59E0B' if rsl_hours >= 6.0 else '#EF4444')}; font-family: monospace;">
                {rsl_hours:.2f} <span style="font-size: 22px;">HRS</span>
            </div>
            <span style="color: #6B7280; font-size: 13px;">Baseline: 24.00 Hours @ 4.0°C</span>
        </div>
    """, unsafe_allow_html=True)

    # Decay Index Metric
    st.metric("Decay Acceleration Index (k / k₀)", f"{decay_index:.2f}x", delta=f"{(decay_index - 1.0)*100:+.1f}% vs baseline", delta_color="inverse")

    # Quality Index Progress Bar
    quality_pct = min(100.0, max(0.0, (rsl_hours / 24.0) * 100.0))
    st.write(f"**Cargo Quality Retention:** {quality_pct:.1f}%")
    st.progress(quality_pct / 100.0)

    # Alert Box
    if is_diverted:
        st.error(f"🚨 **REROUTE INITIATED**\n\n{reroute_result['alert_message']}")
    else:
        st.success(f"✅ **NORMAL ROUTE ACTIVE**\n\n{reroute_result['alert_message']}")

# ==========================================
# COLUMN 3: SPATIAL MAP & WEBHOOK INTEGRATION
# ==========================================
with col3:
    st.subheader("🗺️ Spatial Network Graph & Webhook")

    # Plot NetworkX Graph using Matplotlib
    fig, ax = plt.subplots(figsize=(6, 4.2), facecolor="#0E1117")
    ax.set_facecolor("#0E1117")

    G = reroute_result["graph"]
    pos = {
        'A': (0.0, 1.0),
        'B': (2.5, 1.8),
        'C': (4.0, 3.0),
        'D': (5.5, 0.5)
    }
    
    # Draw all edges in grey background
    nx.draw_networkx_edges(G, pos, ax=ax, edge_color="#4B5563", width=1.5, style="dashed", arrowsize=12)
    
    # Highlight active path
    active_path = reroute_result["path"]
    active_edges = [(active_path[i], active_path[i+1]) for i in range(len(active_path)-1)]
    path_color = "#EF4444" if is_diverted else "#10B981"
    
    nx.draw_networkx_edges(
        G, pos, edgelist=active_edges, ax=ax,
        edge_color=path_color, width=3.5, arrowsize=18
    )

    # Node color mapping
    node_colors = []
    for node in G.nodes():
        if node == 'A':
            node_colors.append("#3B82F6")  # Blue Origin
        elif node == active_path[-1]:
            node_colors.append(path_color) # Destination Color
        else:
            node_colors.append("#6B7280")  # Grey intermediate

    nx.draw_networkx_nodes(G, pos, ax=ax, node_color=node_colors, node_size=700)

    # Custom Node Labels
    labels = {
        'A': 'A: Origin\n(Chennai Warehouse)',
        'B': 'B: Transit Hub\n(Sriperumbudur)',
        'C': 'C: Diverted Buyer\n(Ranipet Plant)',
        'D': 'D: Primary Dest.\n(Koyambedu Mandi)'
    }
    
    for k, (x, y) in pos.items():
        ax.text(x, y + 0.35, labels[k], fontsize=8, color="#FAFAFA", fontweight="bold", ha="center")

    # Edge weight labels
    edge_labels = {
        ('A', 'B'): '2h',
        ('B', 'D'): '4h',
        ('B', 'C'): '2h',
        ('A', 'C'): '4h'
    }
    nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels, ax=ax, font_color="#9CA3AF", font_size=8, bbox=dict(boxstyle='round,pad=0.2', fc='#0E1117', ec='none'))

    ax.set_xlim(-0.8, 6.5)
    ax.set_ylim(-0.2, 4.0)
    ax.axis("off")
    plt.tight_layout()
    st.pyplot(fig)

    # Webhook Payload Section (for WARNING or CRITICAL)
    if status in ["WARNING", "CRITICAL"] or is_diverted:
        st.markdown("### ⚡ Swiggy / Zomato Merchant Webhook")
        fefo_discount = 30.0 if rsl_hours < 6.0 else 15.0
        
        raw_payload_data = {
            "event": "DYNAMIC_FEFO_REROUTE_DISCOUNT",
            "batch_id": "BATCH-2025-VIT-BIO-8834",
            "merchant_integration": "Swiggy / Zomato Hyperlocal Perishable API",
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "calculated_rsl_hours": rsl_hours,
            "applied_fefo_discount_percent": fefo_discount,
            "diverted_outlet": reroute_result["destination_name"],
            "risk_status": status
        }
        
        # SHA-256 Hash Verification
        payload_str = json.dumps(raw_payload_data, sort_keys=True)
        sha256_hash = hashlib.sha256(payload_str.encode('utf-8')).hexdigest()
        
        raw_payload_data["cryptographic_verification_hash"] = sha256_hash

        with st.expander("📦 JSON Webhook Payload & SHA-256 Hash", expanded=True):
            st.json(raw_payload_data)
            st.code(f"SHA-256 Verification: {sha256_hash}", language="text")
