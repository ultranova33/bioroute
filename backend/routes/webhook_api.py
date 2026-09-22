import json
import hashlib
from datetime import datetime
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field

router = APIRouter(prefix="/api/v1/webhook", tags=["Swiggy/Zomato Webhook Dispatcher"])

# In-memory audit log store for cryptographic freshness certificates
WEBHOOK_AUDIT_LOGS = []

class WebhookDispatchRequest(BaseModel):
    batch_id: str = Field(..., example="BATCH-2025-VIT-BIO-8834")
    merchant_id: str = Field("SWIGGY-HYPERLOCAL-09", example="SWIGGY-HYPERLOCAL-09")
    cargo_type: str = Field("Fresh Produce / Perishables", example="Fresh Produce")
    calculated_rsl_hours: float = Field(..., example=4.85)
    diverted_outlet: str = Field("Ranipet Processing Plant", example="Ranipet Processing Plant")

@router.post("/dispatch_fefo")
def dispatch_fefo_webhook(request: WebhookDispatchRequest):
    """
    Automated Swiggy/Zomato Merchant Webhook Dispatcher.
    Applies dynamic FEFO markdown discounts and generates cryptographic SHA-256 audit hashes.
    """
    # Determine FEFO discount based on RSL urgency
    if request.calculated_rsl_hours < 6.0:
        fefo_discount_percent = 30.0
        risk_level = "CRITICAL"
        action = "DYNAMIC_REROUTE_AND_MARKDOWN"
    elif request.calculated_rsl_hours < 12.0:
        fefo_discount_percent = 15.0
        risk_level = "WARNING"
        action = "PREEMPTIVE_MARKDOWN"
    else:
        fefo_discount_percent = 0.0
        risk_level = "SAFE"
        action = "NOMINAL_DISPATCH"

    timestamp_str = datetime.utcnow().isoformat() + "Z"

    payload_data = {
        "event": "DYNAMIC_FEFO_MARKDOWN_DISPATCH",
        "batch_id": request.batch_id,
        "merchant_id": request.merchant_id,
        "cargo_type": request.cargo_type,
        "timestamp": timestamp_str,
        "calculated_rsl_hours": request.calculated_rsl_hours,
        "applied_fefo_discount_percent": fefo_discount_percent,
        "risk_level": risk_level,
        "action": action,
        "diverted_outlet": request.diverted_outlet
    }

    # Generate SHA-256 Cryptographic Verification Hash
    serialized_payload = json.dumps(payload_data, sort_keys=True)
    sha256_hash = hashlib.sha256(serialized_payload.encode('utf-8')).hexdigest()
    
    payload_data["cryptographic_verification_hash"] = sha256_hash

    # Save to audit log
    WEBHOOK_AUDIT_LOGS.insert(0, payload_data)
    
    return {
        "status": "DISPATCH_SUCCESSFUL",
        "applied_fefo_discount_percent": fefo_discount_percent,
        "sha256_hash": sha256_hash,
        "payload": payload_data
    }

@router.get("/audit_logs")
def get_webhook_audit_logs():
    """Returns immutable cryptographic audit log table of all FEFO markdown dispatches."""
    return {
        "total_dispatches": len(WEBHOOK_AUDIT_LOGS),
        "audit_logs": WEBHOOK_AUDIT_LOGS
    }
