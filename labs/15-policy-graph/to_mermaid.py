#!/usr/bin/env python3
import json

print("🔗 Generating Policy Graph Visualization")
G = json.load(open("labs/15-policy-graph/graph.json"))

def get_node_style(node):
    """Get Mermaid styling based on node type and sensitivity"""
    node_type = node.get("type")
    sensitivity = node.get("sensitivity", "low")
    
    base_styles = {
        "user": "U",
        "role": "R", 
        "policy": "POL",
        "pep": "PEP",
        "service": "SVC",
        "data": "DATA"
    }
    
    style_class = base_styles.get(node_type, "DEFAULT")
    
    # Add sensitivity styling
    if sensitivity in ["high", "critical"]:
        style_class += "_RISKY"
    
    return style_class

print("flowchart TB")
print("")

# Print nodes with styling
for n in G["nodes"]:
    label = n["id"].replace(":", "\\n")
    style_class = get_node_style(n)
    print(f'  {n["id"].replace(":", "_")}["{label}"]')
    print(f'  class {n["id"].replace(":", "_")} {style_class};')

print("")

# Print edges with risk styling
for e in G["edges"]:
    src_id = e["src"].replace(":", "_")
    dst_id = e["dst"].replace(":", "_")
    rel = e["rel"]
    
    if "risk" in e:
        risk_level = e["risk"]
        line_style = {
            "low": "---",
            "med": "-.->",
            "high": "==>",
            "critical": "==>>"
        }.get(risk_level, "-->")
        
        print(f'  {src_id} {line_style} |{risk_level.upper()}| {dst_id};')
    else:
        print(f'  {src_id} --> {dst_id};')

print("")

# Define comprehensive styling
print("""
classDef U fill:#e6f3ff,stroke:#6cb0f5,stroke-width:2px;
classDef R fill:#eef7ff,stroke:#4d94ff,stroke-width:2px;
classDef POL fill:#f0fff0,stroke:#66cc66,stroke-width:2px;
classDef PEP fill:#fff0f5,stroke:#ff69b4,stroke-width:2px;
classDef SVC fill:#fffbe6,stroke:#e6b800,stroke-width:2px;
classDef DATA fill:#ffecec,stroke:#ff4d4d,stroke-width:2px;

classDef U_RISKY fill:#ffebee,stroke:#f44336,stroke-width:3px;
classDef R_RISKY fill:#ffebee,stroke:#f44336,stroke-width:3px;
classDef POL_RISKY fill:#ffebee,stroke:#f44336,stroke-width:3px;
classDef PEP_RISKY fill:#ffebee,stroke:#f44336,stroke-width:3px;
classDef SVC_RISKY fill:#ffebee,stroke:#f44336,stroke-width:3px;
classDef DATA_RISKY fill:#ffebee,stroke:#f44336,stroke-width:3px;

classDef DEFAULT fill:#f5f5f5,stroke:#666,stroke-width:1px;
""")

print("""
%% Graph Legend
subgraph LEGEND[Graph Legend]
  direction LR
  L1[User]:::U
  L2[Role]:::R
  L3[Policy]:::POL
  L4[PEP]:::PEP
  L5[Service]:::SVC
  L6[Data]:::DATA
end
""")
