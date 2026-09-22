import math

def calculate_rsl(temp_c: float, rh_percent: float, ethylene_ppm: float, ammonia_ppm: float) -> dict:
    """
    Calculate Remaining Shelf Life (RSL) using Arrhenius Decay Kinetics.
    
    Parameters:
    - temp_c: Temperature in Celsius
    - rh_percent: Relative Humidity percentage
    - ethylene_ppm: Ethylene concentration in ppm
    - ammonia_ppm: Ammonia/VOC concentration in ppm
    
    Returns:
    - dict containing rsl_hours, decay_index, and risk status ("SAFE", "WARNING", "CRITICAL")
    """
    # Baseline constants
    baseline_shelf_life = 24.0  # Hours at 4°C reference temp
    ref_temp_k = 4.0 + 273.15   # 277.15 K
    curr_temp_k = max(temp_c, -10.0) + 273.15  # Temperature in Kelvin
    
    # Arrhenius Activation Energy for perishable food kinetics (J/mol)
    Ea = 52000.0
    R = 8.314  # Universal gas constant J/(mol K)
    
    # Thermal Stress: Arrhenius acceleration factor k_thermal / k_ref
    # k = A * exp(-Ea / (R * T)) => k_thermal / k_ref = exp( (Ea / R) * (1/T_ref - 1/T_curr) )
    if curr_temp_k > ref_temp_k:
        thermal_acceleration = math.exp((Ea / R) * ((1.0 / ref_temp_k) - (1.0 / curr_temp_k)))
    else:
        thermal_acceleration = 1.0

    # Gas Stress Acceleration
    # Ethylene (> 5.0 ppm) accelerates ripening & decay
    ethylene_factor = 1.0 + (max(0.0, ethylene_ppm - 5.0) * 0.12) if ethylene_ppm > 5.0 else 1.0
    
    # Ammonia (> 10.0 ppm) signals spoilage / VOC accumulation
    ammonia_factor = 1.0 + (max(0.0, ammonia_ppm - 10.0) * 0.08) if ammonia_ppm > 10.0 else 1.0
    
    # Relative Humidity Stress Factor (Optimal ~ 85%)
    rh_factor = 1.0 + (abs(rh_percent - 85.0) * 0.005)
    
    # Total Decay Rate Multiplier relative to baseline
    decay_index = thermal_acceleration * ethylene_factor * ammonia_factor * rh_factor
    
    # Dynamic RSL calculation (Hours)
    rsl_hours = round(baseline_shelf_life / decay_index, 2)
    decay_index_rounded = round(decay_index, 2)
    
    # Risk Status Determination
    if rsl_hours >= 12.0:
        status = "SAFE"
    elif rsl_hours >= 6.0:
        status = "WARNING"
    else:
        status = "CRITICAL"
        
    return {
        "rsl_hours": rsl_hours,
        "decay_index": decay_index_rounded,
        "status": status
    }
