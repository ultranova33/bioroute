# Bioroute Engine 🧬
> **Perishable Risk & Dynamic Rerouting Engine**  
> *VIT Chennai | Review II Functional Prototype (35%+ Completion)*

---

## 📌 Project Overview
**Bioroute** is an intelligent cold-chain logistics system that dynamically monitors perishable cargo spoilage risk using **Arrhenius decay kinetics** and executes real-time spatial graph rerouting using the **A* Shortest Path algorithm**. 

When environmental sensors (temperature, humidity, ethylene, ammonia) detect thermal or gas stress, Bioroute recalculates the **Remaining Shelf Life (RSL)**. If RSL drops below the transit time required for the primary destination, the engine automatically diverts cargo to secondary processing outlets and emits dynamic **FEFO (First-Expired, First-Out)** discount webhooks for integration with platforms like Swiggy and Zomato.

---

## 👥 Team Information
- **Team Members:**
  - **Shree Hari K** — Reg No: `25BCE5135`
  - **Vedanth Sudarshan S** — Reg No: `25BCE5285`
  - **Vikram Krishna** — Reg No: `25BCE5055`
- **Degree Program:** B.Tech Computer Science & Engineering (2025–2029)
- **Institution:** VIT Chennai

---

## 🏗️ System Architecture
```
                                ┌────────────────────────────────┐
                                │   Live Environmental Sensors   │
                                │ (Temp, RH, Ethylene, Ammonia)  │
                                └───────────────┬────────────────┘
                                                │
                                                ▼
                                ┌────────────────────────────────┐
                                │    Arrhenius Kinetics Engine   │
                                │   k = A * exp(-Ea / (R * T))   │
                                └───────────────┬────────────────┘
                                                │
                                                ▼
                                ┌────────────────────────────────┐
                                │ Dynamic RSL Calculation (Hrs)  │
                                └───────────────┬────────────────┘
                                                │
                    ┌───────────────────────────┴───────────────────────────┐
                    │                                                       │
           RSL >= 6.0 Hours                                        RSL < 6.0 Hours
                    │                                                       │
                    ▼                                                       ▼
  ┌───────────────────────────────────┐                  ┌───────────────────────────────────┐
  │      Maintain Primary Path        │                  │   Execute A* Rerouting Engine     │
  │     (Koyambedu Mandi Chennai)     │                  │    (Ranipet Processing Plant)     │
  └───────────────────────────────────┘                  └──────────────────┬────────────────┘
                                                                            │
                                                                            ▼
                                                         ┌───────────────────────────────────┐
                                                         │   Swiggy/Zomato Webhook Dispatch  │
                                                         │    (30% Dynamic FEFO Discount)    │
                                                         │     SHA-256 Crypto Verification   │
                                                         └───────────────────────────────────┘
```

---

## 🧪 Arrhenius Decay Kinetics Equation
The reaction rate constant $k$ for chemical and biological degradation is modeled via:
$$k = A \cdot \exp\left( -\frac{E_a}{R \cdot T} \right)$$

Relative decay acceleration relative to reference baseline temperature $T_{\text{ref}} = 4.0^\circ\text{C}$ (277.15 K):
$$\text{Thermal Acceleration} = \exp\left( \frac{E_a}{R} \left( \frac{1}{T_{\text{ref}}} - \frac{1}{T} \right) \right)$$

- $E_a = 52,000\text{ J/mol}$ (Activation Energy for perishable produce)
- $R = 8.314\text{ J/(mol}\cdot\text{K)}$ (Universal Gas Constant)
- Gas Stress Multipliers: Ethylene ($>5\text{ ppm}$) and Ammonia ($>10\text{ ppm}$) accelerate $k$.
- Dynamic RSL equation:
$$\text{RSL (Hours)} = \frac{\text{Baseline Shelf Life (24.0 Hours)}}{\text{Decay Index}}$$

---

## 🚀 Getting Started & Execution

### 1. Prerequisites Installation
Install dependencies via `requirements.txt`:
```bash
pip install -r requirements.txt
```
*(Or `pip install streamlit pandas numpy networkx matplotlib requests pydantic`)*

### 2. Launch Streamlit Master Review Interface
Run the application locally:
```bash
streamlit run app.py
```

---

## 📁 Repository Structure
```
bioroute/
├── README.md                 # Documentation & System Architecture
├── requirements.txt           # Dependency requirements
├── app.py                     # Streamlit Master Review Dashboard Interface
├── engine/
│   ├── __init__.py            # Engine module package marker
│   ├── arrhenius.py           # Arrhenius decay kinetics calculations
│   └── routing.py             # NetworkX spatial graph & A* rerouting
└── assets/
    └── sample_payload.json    # Sample Swiggy/Zomato webhook JSON payload
```
