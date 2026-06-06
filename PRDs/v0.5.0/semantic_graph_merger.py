import yaml
import sys
import os

def load_yaml(filepath):
    """Loads a YAML file safely."""
    try:
        with open(filepath, 'r') as f:
            return yaml.safe_load(f) or {}
    except Exception as e:
        print(f"[!] Error loading {filepath}: {e}")
        return None

def save_yaml(data, filepath):
    """Saves data to a YAML file, maintaining formatting."""
    with open(filepath, 'w') as f:
        yaml.safe_dump(data, f, default_flow_style=False, sort_keys=False)

def merge_hypergraphs(main_graph, branch_graph):
    """
    Deterministically merges two hypergraphs.
    Rules:
    1. Nodes are merged by ID. Branch data overwrites Main data for existing fields.
    2. Edges are unioned to prevent duplication.
    """
    merged = {"nodes": {}, "edges": []}

    # 1. Merge Nodes (Dict based on Node ID)
    main_nodes = main_graph.get("nodes", {})
    branch_nodes = branch_graph.get("nodes", {})
    
    all_node_ids = set(main_nodes.keys()).union(set(branch_nodes.keys()))
    
    for node_id in all_node_ids:
        if node_id in branch_nodes and node_id in main_nodes:
            # Branch overwrites/updates Main
            merged_node = {**main_nodes[node_id], **branch_nodes[node_id]}
            merged["nodes"][node_id] = merged_node
        elif node_id in branch_nodes:
            merged["nodes"][node_id] = branch_nodes[node_id]
        else:
            merged["nodes"][node_id] = main_nodes[node_id]

    # 2. Merge Edges (List of dicts)
    # Convert edge dicts to frozensets/tuples for hashability to enforce unique edges
    def hashable_edge(edge):
        return tuple(sorted(edge.items()))

    seen_edges = set()
    merged_edges = []
    
    for edge in main_graph.get("edges", []) + branch_graph.get("edges", []):
        h_edge = hashable_edge(edge)
        if h_edge not in seen_edges:
            seen_edges.add(h_edge)
            merged_edges.append(edge)
            
    merged["edges"] = merged_edges

    # 3. Preserve metadata if it exists
    if "metadata" in main_graph or "metadata" in branch_graph:
        merged["metadata"] = {**main_graph.get("metadata", {}), **branch_graph.get("metadata", {})}

    return merged

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python hypergraph_merger.py <main_yaml> <branch_yaml> <output_yaml>")
        sys.exit(1)
        
    main_file = sys.argv[1]
    branch_file = sys.argv[2]
    output_file = sys.argv[3]
    
    print(f"[*] Semantic Merge Initiated: {main_file} + {branch_file}")
    
    main_graph = load_yaml(main_file)
    branch_graph = load_yaml(branch_file)
    
    if main_graph is None or branch_graph is None:
        print("[!] Aborting merge due to missing files.")
        sys.exit(1)
        
    merged_graph = merge_hypergraphs(main_graph, branch_graph)
    save_yaml(merged_graph, output_file)
    print(f"[+] Semantic Merge Complete. Saved to {output_file}")
