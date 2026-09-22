from fastapi import APIRouter, HTTPException
from backend.models.telemetry import SpatialRerouteRequest, GeoJSONFeatureCollection
from engine.arrhenius import calculate_rsl
from engine.routing import evaluate_reroute
from backend.database import query_nearby_processing_plants

router = APIRouter(prefix="/api/v1/routing", tags=["Spatial Routing"])

@router.post("/evaluate", response_model=dict)
def evaluate_spatial_reroute(request: SpatialRerouteRequest):
    """
    Evaluates cargo remaining shelf life against primary destination ETA.
    Returns GeoJSON dynamic path and reroute decision.
    """
    # Calculate Arrhenius decay kinetics
    rsl_data = calculate_rsl(
        temp_c=request.temperature_c,
        rh_percent=request.humidity_percent,
        ethylene_ppm=request.ethylene_ppm,
        ammonia_ppm=request.ammonia_ppm
    )
    
    rsl_hours = rsl_data["rsl_hours"]
    is_spoilage_critical = rsl_hours < request.estimated_primary_eta_hours
    
    # Query nearby processing plants using PostGIS spatial logic
    nearby_plants = query_nearby_processing_plants(
        lat=request.current_lat,
        lon=request.current_lon,
        radius_km=150.0
    )
    
    if is_spoilage_critical and nearby_plants:
        target_plant = nearby_plants[0] # Closest processing outlet
        reroute_status = "DIVERTED_TO_SECONDARY_PROCESSING"
        dest_name = target_plant["name"]
        
        # Build GeoJSON feature collection for diverted path
        geojson = {
            "type": "FeatureCollection",
            "features": [
                {
                    "type": "Feature",
                    "geometry": {
                        "type": "LineString",
                        "coordinates": [
                            [request.current_lon, request.current_lat],
                            [target_plant["lon"], target_plant["lat"]]
                        ]
                    },
                    "properties": {
                        "path_type": "DIVERTED_PATH",
                        "stroke": "#EF4444",
                        "distance_km": target_plant["distance_km"],
                        "destination": dest_name
                    }
                },
                {
                    "type": "Feature",
                    "geometry": {
                        "type": "Point",
                        "coordinates": [target_plant["lon"], target_plant["lat"]]
                    },
                    "properties": {
                        "name": dest_name,
                        "type": "Processing Plant",
                        "state": target_plant["state"]
                    }
                }
            ]
        }
    else:
        reroute_status = "MAINTAINING_PRIMARY_PATH"
        dest_name = "Koyambedu Mandi Chennai"
        geojson = {
            "type": "FeatureCollection",
            "features": [
                {
                    "type": "Feature",
                    "geometry": {
                        "type": "LineString",
                        "coordinates": [
                            [request.current_lon, request.current_lat],
                            [request.primary_destination_lon, request.primary_destination_lat]
                        ]
                    },
                    "properties": {
                        "path_type": "PRIMARY_PATH",
                        "stroke": "#10B981",
                        "destination": dest_name
                    }
                }
            ]
        }

    return {
        "truck_id": request.truck_id,
        "calculated_rsl_hours": rsl_hours,
        "primary_eta_hours": request.estimated_primary_eta_hours,
        "risk_status": rsl_data["status"],
        "reroute_decision": reroute_status,
        "target_destination": dest_name,
        "geojson": geojson,
        "nearby_outlets": nearby_plants
    }
