import os
import json
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, declarative_base

# Database URL configuration (defaults to SQLite memory or PostgreSQL with PostGIS extension)
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./bioroute_spatial.db")

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False} if "sqlite" in DATABASE_URL else {}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Regional Processing Outlets (South India OSM Highway Corridor: TN, KA, AP, KL)
REGIONAL_PROCESSING_OUTLETS = [
    {
        "id": "OUTLET-TN-RANIPET-01",
        "name": "Ranipet Processing Plant",
        "state": "Tamil Nadu",
        "lat": 12.9298,
        "lon": 79.3333,
        "capacity_tons": 45.0,
        "fefo_discount_eligible": True
    },
    {
        "id": "OUTLET-TN-HOSUR-02",
        "name": "Hosur Cold Processing Hub",
        "state": "Tamil Nadu",
        "lat": 12.7409,
        "lon": 77.8253,
        "capacity_tons": 60.0,
        "fefo_discount_eligible": True
    },
    {
        "id": "OUTLET-KA-BANGALORE-03",
        "name": "Electronic City Dairy & Pulp Outlet",
        "state": "Karnataka",
        "lat": 12.8399,
        "lon": 77.6770,
        "capacity_tons": 80.0,
        "fefo_discount_eligible": True
    },
    {
        "id": "OUTLET-AP-CHITTOOR-04",
        "name": "Chittoor Agro Processing Facility",
        "state": "Andhra Pradesh",
        "lat": 13.2172,
        "lon": 79.1003,
        "capacity_tons": 35.0,
        "fefo_discount_eligible": True
    },
    {
        "id": "OUTLET-KL-PALAKKAD-05",
        "name": "Palakkad Spoilage Recovery Center",
        "state": "Kerala",
        "lat": 10.7867,
        "lon": 76.6548,
        "capacity_tons": 50.0,
        "fefo_discount_eligible": True
    }
]

def query_nearby_processing_plants(lat: float, lon: float, radius_km: float = 100.0) -> list:
    """
    Executes PostGIS ST_DWithin spatial query to locate active secondary processing outlets
    within the radius of current cargo location. Falls back to Haversine distance if PostGIS is offline.
    """
    db = SessionLocal()
    try:
        # Check if PostGIS extension exists
        if "postgresql" in DATABASE_URL:
            query = text("""
                SELECT id, name, state, 
                       ST_Y(geom) as lat, ST_X(geom) as lon,
                       ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography)/1000.0 AS distance_km
                FROM processing_outlets
                WHERE ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(:lon, :lat), 4326)::geography, :radius_meters)
                ORDER BY distance_km ASC;
            """)
            result = db.execute(query, {"lat": lat, "lon": lon, "radius_meters": radius_km * 1000.0})
            rows = result.fetchall()
            return [dict(row._mapping) for row in rows]
    except Exception:
        pass
    finally:
        db.close()

    # Spatial Haversine fallback calculation for standalone deployment
    import math
    def haversine(lat1, lon1, lat2, lon2):
        R = 6371.0 # Radius of earth in km
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = math.sin(dlat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon/2)**2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
        return R * c

    nearby = []
    for outlet in REGIONAL_PROCESSING_OUTLETS:
        dist = haversine(lat, lon, outlet["lat"], outlet["lon"])
        if dist <= radius_km:
            outlet_copy = dict(outlet)
            outlet_copy["distance_km"] = round(dist, 2)
            nearby.append(outlet_copy)
            
    nearby.sort(key=lambda x: x["distance_km"])
    return nearby
