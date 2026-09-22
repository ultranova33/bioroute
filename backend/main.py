import asyncio
import json
import random
import time
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from backend.routes.routing_api import router as routing_router
from backend.routes.webhook_api import router as webhook_router
from engine.arrhenius import calculate_rsl

app = FastAPI(
    title="Bioroute Enterprise Microservices API",
    description="Spatial PostGIS Routing & Dynamic FEFO Risk Engine API for Swiggy/Zomato Hyperlocal Logistics",
    version="2.0.0"
)

# CORS configuration for enterprise frontend integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API Routers
app.include_router(routing_router)
app.include_router(webhook_router)

@app.get("/")
def read_root():
    return {
        "system": "Bioroute Enterprise Engine",
        "status": "ONLINE",
        "version": "2.0.0",
        "calibration_sources": [
            "Roboflow Produce Ripeness / Fruits 360 CV Dataset",
            "OpenStreetMap (OSM) Highway Geometries (TN, KA, AP, KL)",
            "USDA Handbook No. 66 Arrhenius Kinetic Constants"
        ]
    }

@app.get("/health")
def health_check():
    return {"status": "HEALTHY", "timestamp": time.time()}

# WebSocket Connection Manager for Real-Time Telemetry Streaming
class TelemetryConnectionManager:
    def __init__(self):
        self.active_connections: list[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)

    async def broadcast(self, message: str):
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except Exception:
                pass

manager = TelemetryConnectionManager()

@app.websocket("/ws/telemetry")
async def websocket_telemetry_endpoint(websocket: WebSocket):
    """
    WebSocket endpoint for real-time truck telematics & kitchen chiller telemetry streaming.
    Pushes live simulated sensor ticks (Temp, RH, Ethylene, Ammonia) to dashboards & mobile apps.
    """
    await manager.connect(websocket)
    try:
        base_temp = 4.0
        base_eth = 0.5
        base_amm = 2.0
        step = 0
        
        while True:
            step += 1
            # Simulate gradual thermal drift & gas spikes for demo lifecycle
            sim_temp = round(base_temp + (step * 0.4) % 32.0, 1)
            sim_rh = round(85.0 - (step * 0.2) % 30.0, 1)
            sim_eth = round(base_eth + (step * 0.3) if sim_temp > 18.0 else base_eth, 1)
            sim_amm = round(base_amm + (step * 0.5) if sim_temp > 24.0 else base_amm, 1)

            # Calculate Arrhenius kinetics on the fly
            rsl_data = calculate_rsl(sim_temp, sim_rh, sim_eth, sim_amm)

            telemetry_payload = {
                "type": "TELEMETRY_STREAM_TICK",
                "truck_id": "TN-01-BIO-9921",
                "cargo_type": "Fresh Produce / Perishable Biologics",
                "location": {"lat": 12.9716, "lon": 79.1589, "node": "Sriperumbudur Hub"},
                "sensor_data": {
                    "temperature_c": sim_temp,
                    "humidity_percent": sim_rh,
                    "ethylene_ppm": sim_eth,
                    "ammonia_ppm": sim_amm
                },
                "kinetics": {
                    "rsl_hours": rsl_data["rsl_hours"],
                    "decay_index": rsl_data["decay_index"],
                    "risk_status": rsl_data["status"]
                },
                "timestamp": time.time()
            }

            await websocket.send_text(json.dumps(telemetry_payload))
            await asyncio.sleep(2.0)
    except WebSocketDisconnect:
        manager.disconnect(websocket)
    except Exception:
        manager.disconnect(websocket)
