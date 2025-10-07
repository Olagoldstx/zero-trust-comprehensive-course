# 🧱 Lesson 8 — Dynamic Breach Containment

This lab demonstrates how **Zero Trust can respond autonomously** when telemetry indicates excessive risk or failed authentication attempts.

---

## 🕸️ System Overview

```mermaid
flowchart TD
    subgraph Telemetry_Plane["🧠 Telemetry + Policy Engine (OPA)"]
        OPA[OPA Decision Engine<br/>port 8181]
        Metrics[Prometheus Metrics<br/>/metrics endpoint]
        OPA --> Metrics
    end

    subgraph Enforcement_Loop["⚙️ Containment Logic"]
        Watcher[contain.sh<br/>Watcher Script]
        Attacker[attack.sh<br/>Simulated Adversary]
        Watcher -->|Sample Decisions| OPA
        Attacker -->|Risky Inputs| OPA
        Watcher -->|🚨 Trigger Action| Response[Auto Containment Action]
    end

    subgraph Network["🌐 Enterprise Environment"]
        Users[👥 Users / Clients]
        Apps[🎯 Protected Applications<br/>port 9000]
        Proxy[🔐 PEP Proxy<br/>port 8080]
        Users --> Proxy --> OPA --> Apps
    end

    Response --> Proxy
    Proxy -->|Block / Quarantine| Apps
⚡ Workflow Summary
Telemetry feeds real-time decision logs and Prometheus counters.

The contain.sh script continuously samples OPA decisions.

When the deny ratio > threshold (e.g., 0.6), containment triggers.

The system can automatically block sessions, quarantine devices, or alert SOC pipelines.

🧠 Reflection
How does automated containment improve your mean-time-to-respond (MTTR)?

Which additional telemetry sources (endpoint risk, cloud posture, UEBA) would make containment more accurate?

What safeguards should prevent false positives or self-DoS during automated response?

🧩 Next Step
In the next lesson, we’ll connect containment triggers to AWS Security Hub / SIEM event ingestion, completing the Zero Trust feedback loop.
