import cv2
import numpy as np
from cv_engine.detector import analyze_produce_spoilage, calculate_fused_rsl

def generate_mock_produce_frame(rot_severity: str = "FRESH") -> bytes:
    """Generates synthetic produce camera frames representing FRESH, EARLY_DECAY, and ROTTEN states."""
    img = np.zeros((224, 224, 3), dtype=np.uint8)
    
    if rot_severity == "FRESH":
        # Vibrant green produce frame
        img[:, :] = (34, 139, 34)
    elif rot_severity == "EARLY_DECAY":
        # Green frame with early brown discoloration patches
        img[:, :] = (34, 139, 34)
        cv2.circle(img, (112, 112), 45, (30, 65, 120), -1)
    else:  # ROTTEN
        # Heavily decayed dark brown / black frame
        img[:, :] = (20, 45, 90)
        cv2.circle(img, (112, 112), 80, (10, 20, 40), -1)
        
    _, encoded = cv2.imencode('.jpg', img)
    return encoded.tobytes()

def run_pipeline_test():
    print("=========================================================")
    print("   BIOROUTE CV SPOILAGE INFERENCE PIPELINE TEST BENCH   ")
    print("=========================================================\n")
    
    scenarios = [
        ("Nominal Fresh Cargo", "FRESH", 6.0, 85.0, 0.5, 2.0),
        ("Early Discoloration (Pre-gas spike)", "EARLY_DECAY", 14.0, 85.0, 2.0, 4.0),
        ("Advanced Rot & Thermal Acceleration", "ROTTEN", 26.0, 90.0, 12.0, 18.0)
    ]
    
    for title, severity, temp, rh, eth, amm in scenarios:
        frame_bytes = generate_mock_produce_frame(severity)
        cv_result = analyze_produce_spoilage(frame_bytes)
        fused_result = calculate_fused_rsl(temp, rh, eth, amm, image_bytes=frame_bytes)
        
        print(f"--- SCENARIO: {title} ---")
        print(f"Inputs: Temp={temp}°C | Ethylene={eth}ppm | Visual Frame State={severity}")
        print(f"CV Classification    : {cv_result['classification']} (rot probability P_rot = {cv_result['p_rot']})")
        print(f"Base Arrhenius RSL   : {fused_result['base_arrhenius_rsl']} hours")
        print(f"Visual Penalty Factor: {fused_result['visual_penalty_factor']}x")
        print(f"Fused Final RSL      : {fused_result['fused_rsl_hours']} hours -> Status: [{fused_result['fused_status']}]\n")

if __name__ == "__main__":
    run_pipeline_test()
