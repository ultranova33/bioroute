import networkx as nx

def build_spatial_network() -> nx.DiGraph:
    """
    Builds spatial network graph using NetworkX for Bioroute logistics network.
    
    Nodes:
    - Node A: "Chennai Cold Warehouse" (Origin)
    - Node B: "Sriperumbudur Transit Hub" (Waypoint 1)
    - Node C: "Ranipet Processing Plant" (Secondary Buyer / Diverted Outlet - 2 hrs ETA)
    - Node D: "Koyambedu Mandi Chennai" (Primary Destination - 6 hrs ETA)
    """
    G = nx.DiGraph()
    
    # Add nodes with metadata and spatial positions for visualization / A* heuristic
    nodes = {
        'A': {"name": "Chennai Cold Warehouse", "type": "Origin", "pos": (0.0, 1.0)},
        'B': {"name": "Sriperumbudur Transit Hub", "type": "Waypoint", "pos": (2.5, 1.8)},
        'C': {"name": "Ranipet Processing Plant", "type": "Diverted Outlet", "pos": (4.0, 3.0)},
        'D': {"name": "Koyambedu Mandi Chennai", "type": "Primary Destination", "pos": (5.5, 0.5)}
    }
    
    for node_id, data in nodes.items():
        G.add_node(node_id, **data)
        
    # Add edges with travel time weights (hours)
    # Primary Path: A -> B -> D (2.0 + 4.0 = 6.0 hours total travel time)
    # Diverted Path: A -> B -> C (2.0 + 2.0 = 4.0 hours total travel time)
    G.add_edge('A', 'B', weight=2.0, label="2 hrs")
    G.add_edge('B', 'D', weight=4.0, label="4 hrs")
    G.add_edge('B', 'C', weight=2.0, label="2 hrs")
    G.add_edge('A', 'C', weight=4.0, label="4 hrs")
    
    return G

def euclidean_heuristic(u, v):
    """Heuristic function for A* shortest path search based on node positions."""
    # Simple spatial distance metric for A* algorithm
    pos = {
        'A': (0.0, 1.0),
        'B': (2.5, 1.8),
        'C': (4.0, 3.0),
        'D': (5.5, 0.5)
    }
    x1, y1 = pos[u]
    x2, y2 = pos[v]
    return ((x1 - x2)**2 + (y1 - y2)**2) ** 0.5

def evaluate_reroute(rsl_hours: float) -> dict:
    """
    Evaluates dynamic rerouting based on dynamic RSL hours.
    
    Rule:
    - If rsl_hours >= 6.0: Maintain Primary Path to Koyambedu Mandi (Node D).
    - If rsl_hours < 6.0: Execute A* algorithm to Node C ("Ranipet Processing Plant").
    """
    G = build_spatial_network()
    
    if rsl_hours >= 6.0:
        path = ['A', 'B', 'D']
        dest_node = 'D'
        dest_name = G.nodes['D']['name']
        is_diverted = False
        alert_status = "SAFE_PRIMARY_PATH"
        alert_message = (
            f"✅ RSL of {rsl_hours:.2f} hrs exceeds travel ETA (6.0 hrs). "
            f"Maintaining Primary Path to {dest_name}."
        )
    else:
        # Execute A* Shortest Path algorithm to Node C (Ranipet Processing Plant)
        path = nx.astar_path(G, source='A', target='C', heuristic=euclidean_heuristic, weight='weight')
        dest_node = 'C'
        dest_name = G.nodes['C']['name']
        is_diverted = True
        alert_status = "CRITICAL_REROUTE_INITIATED"
        alert_message = (
            f"🚨 CRITICAL SPOILAGE RISK (RSL {rsl_hours:.2f} hrs < 6.0 hrs ETA)! "
            f"A* Dynamic Reroute Executed -> Diverting to Secondary Outlet: {dest_name} (ETA 2.0 hrs)."
        )
        
    path_names = [G.nodes[node]['name'] for node in path]
    
    return {
        "graph": G,
        "path": path,
        "path_names": path_names,
        "destination_node": dest_node,
        "destination_name": dest_name,
        "is_diverted": is_diverted,
        "alert_status": alert_status,
        "alert_message": alert_message
    }
