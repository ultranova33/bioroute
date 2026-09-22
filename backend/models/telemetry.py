from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

class TruckTelematics(BaseModel):
    """Domain Model (a): Transit Truck IoT Telematics Telemetry"""
    truck_id: str = Field(..., example="TN-01-BIO-9921")
    cargo_type: str = Field("Fresh Mangoes / Tomatoes", example="Fresh Mangoes")
    latitude: float = Field(..., example=12.9716)
    longitude: float = Field(..., example=79.1589)
    speed_kmh: float = Field(65.0, example=65.0)
    temperature_c: float = Field(..., example=18.5)
    humidity_percent: float = Field(..., example=82.0)
    ethylene_ppm: float = Field(..., example=8.5)
    ammonia_ppm: float = Field(..., example=4.2)
    timestamp: Optional[str] = Field(default_factory=lambda: datetime.utcnow().isoformat())

class ChillerInventory(BaseModel):
    """Domain Model (b): Cloud Kitchen Chiller Inventory Telemetry"""
    chiller_id: str = Field(..., example="CHILLER-ZONE-NORTH-04")
    kitchen_name: str = Field(..., example="Swiggy Cloud Kitchen Guindy")
    zone: str = Field("Cold Room 2", example="Cold Room 2")
    temperature_c: float = Field(..., example=6.2)
    humidity_percent: float = Field(..., example=88.0)
    ammonia_ppm: float = Field(..., example=12.4)
    batch_id: str = Field(..., example="BATCH-2025-VIT-BIO-8834")
    produce_type: str = Field(..., example="Cut Vegetables & Salad Prep")
    quantity_kg: float = Field(..., example=120.0)
    timestamp: Optional[str] = Field(default_factory=lambda: datetime.utcnow().isoformat())

class SpatialRerouteRequest(BaseModel):
    truck_id: str
    current_lat: float
    current_lon: float
    primary_destination_lat: float
    primary_destination_lon: float
    estimated_primary_eta_hours: float
    temperature_c: float
    humidity_percent: float
    ethylene_ppm: float
    ammonia_ppm: float

class GeoJSONFeature(BaseModel):
    type: str = "Feature"
    geometry: Dict[str, Any]
    properties: Dict[str, Any]

class GeoJSONFeatureCollection(BaseModel):
    type: str = "FeatureCollection"
    features: List[GeoJSONFeature]
