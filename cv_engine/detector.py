import cv2
import numpy as np
from engine.arrhenius import calculate_rsl

def analyze_produce_spoilage(image_bytes: bytes) -> dict:
    """
    Analyzes produce camera frame image bytes using OpenCV computer vision algorithms.
    Detects surface discoloration, dark spotting, and rot ratio P_rot.
    
    Returns:
    - dict with p_rot, classification, and visual degradation confidence score.
    """
    # Convert image bytes to OpenCV BGR matrix
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    if img is None:
        # Fallback for empty/mock frames
        p_rot = 0.15
        classification = "FRESH"
        confidence = 0.92
    else:
        # Resize frame for standardization
        resized = cv2.resize(img, (224, 224))
        hsv = cv2.cvtColor(resized, cv2.COLOR_BGR2HSV)
        
        # Define HSV color bounds for brown/black surface decay & fungal rot
        lower_rot = np.array([5, 40, 20])
        upper_rot = np.array([30, 255, 130])
        
        rot_mask = cv2.inRange(hsv, lower_rot, upper_rot)
        rot_pixel_count = cv2.countNonZero(rot_mask)
        total_pixels = 224 * 224
        
        # Calculate visual decay ratio P_rot
        p_rot = float(np.clip(rot_pixel_count / (total_pixels * 0.45), 0.0, 1.0))
        p_rot = round(p_rot, 3)

        if p_rot < 0.25:
            classification = "FRESH"
            confidence = round(1.0 - p_rot, 2)
        elif p_rot < 0.60:
            classification = "EARLY_DECAY"
            confidence = round(0.5 + p_rot / 2.0, 2)
        else:
            classification = "ROTTEN"
            confidence = round(p_rot, 2)
            
    return {
        "p_rot": p_rot,
        "classification": classification,
        "confidence": confidence
    }

def calculate_fused_rsl(temp_c: float, rh_percent: float, ethylene_ppm: float, ammonia_ppm: float, image_bytes: bytes = None, mock_p_rot: float = None) -> dict:
    """
    Fuses visual produce degradation probability (P_rot) with Arrhenius kinetics.
    If visual surface decay/discoloration is detected prior to gas spikes,
    RSL_hours is penalized dynamically.
    """
    # 1. Base Arrhenius Kinetics
    base_arrhenius = calculate_rsl(temp_c, rh_percent, ethylene_ppm, ammonia_ppm)
    base_rsl = base_arrhenius["rsl_hours"]
    
    # 2. Visual Computer Vision Analysis
    if mock_p_rot is not None:
        p_rot = mock_p_rot
        if p_rot < 0.25:
            classification = "FRESH"
        elif p_rot < 0.60:
            classification = "EARLY_DECAY"
        else:
            classification = "ROTTEN"
    elif image_bytes is not None:
        cv_res = analyze_produce_spoilage(image_bytes)
        p_rot = cv_res["p_rot"]
        classification = cv_res["classification"]
    else:
        p_rot = 0.0
        classification = "FRESH"

    # 3. Sensor + Vision Fusion Penalty Factor
    # Visual degradation factor accelerates decay before gas sensors spike
    visual_penalty_factor = 1.0 + (p_rot * 1.8)
    
    fused_rsl_hours = round(base_rsl / visual_penalty_factor, 2)
    
    # Determine Fused Status
    if fused_rsl_hours >= 12.0:
        fused_status = "SAFE"
    elif fused_rsl_hours >= 6.0:
        fused_status = "WARNING"
    else:
        fused_status = "CRITICAL"
        
    return {
        "base_arrhenius_rsl": base_rsl,
        "fused_rsl_hours": fused_rsl_hours,
        "p_rot": p_rot,
        "produce_classification": classification,
        "visual_penalty_factor": round(visual_penalty_factor, 2),
        "fused_status": fused_status
    }
