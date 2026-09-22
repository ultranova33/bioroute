# Bioroute 🧬🌱
> **Perishable Risk & Dynamic Rerouting Platform**  
> *VIT Chennai | University Enterprise Platform Project*

---

## 📌 Project Overview
**Bioroute** is an enterprise-grade cold-chain logistics platform that dynamically predicts perishable cargo spoilage risk using **Arrhenius decay kinetics**, **OpenCV Computer Vision surface degradation analysis**, and **PostGIS spatial network search**.

When environmental sensors (temperature, humidity, ethylene, ammonia) or camera frames detect thermal, gas, or visual degradation, Bioroute recalculates the **Remaining Shelf Life (RSL)**. If RSL falls below travel ETA to the primary destination, the platform automatically diverts cargo to secondary processing facilities, alerts drivers in their regional language via voice TTS, and dispatches dynamic **FEFO (First-Expired, First-Out)** discount webhooks, staff meal auto-earmarking, or food recovery NGO pick-up alerts.

---

## 👥 Team Information
- **Team Members:**
  - **Shree Hari K** — Reg No: `25BCE5135`
  - **Vedanth Sudarshan S** — Reg No: `25BCE5285`
  - **Vikram Krishna** — Reg No: `25BCE5055`
- **Degree Program:** B.Tech Computer Science & Engineering (2025–2029)
- **Institution:** VIT Chennai

---

## 🏗️ System Architecture & Platform Ecosystem
```
                                ┌──────────────────────────────────────┐
                                │   Environmental & Camera Telemetry   │
                                │ (Temp, RH, Ethylene, Ammonia, CV)    │
                                └──────────────────┬───────────────────┘
                                                   │
                                                   ▼
                                ┌──────────────────────────────────────┐
                                │ OpenCV Vision + Arrhenius Fusion     │
                                │    RSL_fused = Base_RSL / P_rot      │
                                └──────────────────┬───────────────────┘
                                                   │
                                                   ▼
                                ┌──────────────────────────────────────┐
                                │  FastAPI / PostGIS Microservice      │
                                │ ST_DWithin Highway Spatial Rerouting │
                                └──────────────────┬───────────────────┘
                                                   │
                ┌──────────────────────────────────┼──────────────────────────────────┐
                │                                  │                                  │
                ▼                                  ▼                                  ▼
┌───────────────────────────────┐  ┌───────────────────────────────┐  ┌───────────────────────────────┐
│ Dual-Dashboard Web Portal     │  │ Swiggy / Zomato FEFO Webhook  │  │ Localized Flutter Driver App  │
│ - Cloud Kitchen Admin         │  │ - 30% Dynamic FEFO Markdown   │  │ - Multi-Language (TN, KL, AP, │
│ - Staff Meals Auto-Earmark    │  │ - Staff Meals Auto-Allocation │  │   KA, HI, EN)                │
│ - Food Recovery NGO Dispatch  │  │ - Food Recovery NGO Alert     │  │ - Voice TTS Navigation        │
│ - Truck Fleet Telematics      │  │ - SHA-256 Audit Certificate   │  │ - Offline SQLite Darkzone     │
└───────────────────────────────┘  └───────────────────────────────┘  └───────────────────────────────┘
```

---

## 📂 Repository Structure
```
bioroute/
├── README.md                      # Documentation & System Architecture
├── requirements.txt                # Python backend & ML dependencies
├── app.py                          # Streamlit Master Review Prototype
├── engine/
│   ├── arrhenius.py               # Arrhenius decay kinetics calculations
│   └── routing.py                 # NetworkX spatial graph & A* rerouting
├── backend/                       # FastAPI & PostGIS Microservices
│   ├── main.py                    # Asynchronous FastAPI app & WebSockets
│   ├── database.py                # PostGIS spatial query logic
│   ├── models/telemetry.py        # Telematics & Chiller domain models
│   └── routes/                    # Spatial Routing & FEFO Webhook APIs
├── cv_engine/                     # Computer Vision Spoilage Inference
│   ├── detector.py                # OpenCV produce discoloration analysis
│   └── test_pipeline.py           # CV pipeline test bench
├── dashboard/                     # Executive Dual-Dashboard Web Portal
│   ├── index.html                 # Dark Forest Green Dual Portal Interface
│   ├── package.json               # Next.js dependencies
│   └── src/DualDashboard.jsx      # React dual-dashboard component
└── mobile_app/                    # Localized Flutter Driver Navigation App
    ├── pubspec.yaml               # Flutter package configuration
    ├── lib/main.dart              # Multi-language TTS & map navigation
    ├── lib/l10n/                  # Localizations (TN, KL, AP, KA, HI, EN)
    └── lib/services/              # SQLite offline darkzone storage
```

---

## 🚀 Execution & Deployment Guides

### 1. Backend Dependencies Installation
```bash
pip install -r requirements.txt
```

### 2. Launch FastAPI Microservice Server
```bash
python -m uvicorn backend.main:app --port 8000
```
* **API Documentation**: [http://localhost:8000/docs](http://localhost:8000/docs)
* **WebSocket Stream**: `ws://localhost:8000/ws/telemetry`

### 3. Launch Dual-Dashboard Web Portal
```bash
python -m http.server 8080 --directory dashboard
```
* **Web Portal URL**: [http://localhost:8080](http://localhost:8080)

### 4. Run Computer Vision Pipeline Test
```bash
python -m cv_engine.test_pipeline
```

### 5. Launch Localized Flutter Driver App
```bash
cd mobile_app
flutter run
```
