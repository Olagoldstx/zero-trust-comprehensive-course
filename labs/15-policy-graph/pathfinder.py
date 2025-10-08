#!/usr/bin/env python3
import json, sys
from collections import defaultdict, deque

print("🔍 Zero Trust Attack Path Analyzer")
print("==================================")

with open("labs/15-policy-graph/graph.json") as f:
    G = json.load(f)

# Build adjacency + node lookup
adj = defaultdict(list)
risk_edge = {}
node_details = {}

for e in G["edges"]:
    src, dst = e["src"], e["dst"]
    adj[src].append(dst)
    if "risk" in e:
        risk_edge[(src,dst)] = e["risk"]

for n in G["nodes"]:
    node_details[n["id"]] = n

def bfs_paths(src, dst_max_types=("data","service"), max_depth=8):
    paths = []
    q = deque([ [src] ])
    seen_depth = {src:0}
    
    while q:
        path = q.popleft()
        u = path[-1]
        
        if len(path) > max_depth: 
            continue
            
        # If endpoint is a target node type, collect
        node_type = node_details.get(u,{}).get("type")
        if node_type in dst_max_types and len(path) > 1:
            paths.append(path)
            
        for v in adj.get(u,[]):
            if seen_depth.get(v, 1e9) > len(path):
                seen_depth[v] = len(path)
                q.append(path + [v])
                
    return paths

def score_path(path):
    """Calculate risk score for attack path"""
    # Base score by length (shorter = riskier)
    base = max(1, 8 - len(path))  # len 2 => 6 pts, len 3 => 5 pts...
    
    # Risk edges add weight
    bonus = 0
    for i in range(len(path)-1):
        risk_level = risk_edge.get((path[i], path[i+1]), "")
        bonus += {"critical":5, "high":3, "med":2, "low":1}.get(risk_level, 0)
    
    # Target sensitivity
    tail = node_details.get(path[-1],{})
    tier = tail.get("tier","internal")
    tier_weight = {"public":0, "internal":1, "confidential":3, "restricted":5}.get(tier, 1)
    
    # Source threat level
    head = node_details.get(path[0],{})
    source_risk = 1
    if head.get("type") == "user" and "attacker" in head.get("id",""):
        source_risk = 3
    
    return (base + bonus) * tier_weight * source_risk

def explain_path(path):
    """Generate human-readable path explanation"""
    parts = []
    total_risk = 0
    
    for i in range(len(path)-1):
        edge_data = next((e for e in G["edges"] if e["src"]==path[i] and e["dst"]==path[i+1]), {})
        rel = edge_data.get("rel", "?")
        risk = edge_data.get("risk", "")
        
        risk_score = {"critical":5, "high":3, "med":2, "low":1}.get(risk, 0)
        total_risk += risk_score
        
        risk_display = f" ⚠️{risk.upper()}" if risk else ""
        parts.append(f"{path[i]} --[{rel}{risk_display}]-->")
    
    parts.append(path[-1])
    explanation = " ".join(parts)
    
    # Add target sensitivity info
    target = node_details.get(path[-1],{})
    target_info = f" | Target: {target.get('tier','unknown')} tier"
    
    return explanation + target_info, total_risk

def analyze_attack_paths(src_user="user:ola"):
    print(f"\n🎯 Analyzing attack paths from: {src_user}")
    print("=" * 60)
    
    paths = bfs_paths(src_user)
    
    if not paths:
        print("❌ No attack paths found from this source.")
        return
    
    # Score and rank paths
    ranked_paths = []
    for path in paths:
        score = score_path(path)
        explanation, path_risk = explain_path(path)
        ranked_paths.append((score, path, explanation, path_risk))
    
    # Sort by risk score (descending)
    ranked_paths.sort(key=lambda x: -x[0])
    
    print(f"📊 Found {len(ranked_paths)} potential attack paths")
    print(f"🚨 Top 10 highest risk paths:\n")
    
    for i, (score, path, explanation, path_risk) in enumerate(ranked_paths[:10], 1):
        print(f"{i:2d}. Risk Score: {score:>2} | Hops: {len(path)-1:>2}")
        print(f"    Path: {explanation}")
        print(f"    Details: {node_details[path[0]]['type']} → {node_details[path[-1]]['type']}")
        print()
    
    # Summary statistics
    high_risk_paths = [p for p in ranked_paths if p[0] >= 15]
    critical_paths = [p for p in ranked_paths if p[0] >= 25]
    
    print("📈 RISK SUMMARY:")
    print(f"   Total paths: {len(ranked_paths)}")
    print(f"   High risk (≥15): {len(high_risk_paths)}")
    print(f"   Critical risk (≥25): {len(critical_paths)}")
    
    return ranked_paths

if __name__ == "__main__":
    source_user = sys.argv[1] if len(sys.argv) > 1 else "user:ola"
    analyze_attack_paths(source_user)
    
    # Also analyze from attacker perspective
    if source_user != "user:attacker":
        print("\n" + "="*60)
        analyze_attack_paths("user:attacker")
