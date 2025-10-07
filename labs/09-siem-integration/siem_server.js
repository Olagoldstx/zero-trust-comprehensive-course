#!/usr/bin/env node
import express from "express";
const app = express();
app.use(express.json());

// Store events in memory (in real SIEM, this would be a database)
const securityEvents = [];
let alertCount = 0;

// Receive logs from OPA or watcher
app.post("/ingest", (req, res) => {
  const event = {
    ...req.body,
    id: securityEvents.length + 1,
    received_at: new Date().toISOString()
  };
  
  securityEvents.push(event);
  
  console.log("📥 SIEM received event #" + event.id);
  console.log("   Type:", event.event_type || "unknown");
  console.log("   Source:", event.source || "unknown");
  
  // Detect high-risk events and create alerts
  if (event.severity === "HIGH" || event.event?.result === false) {
    alertCount++;
    console.log("🚨 SECURITY ALERT #" + alertCount + ": Access denied or high risk detected");
    console.log("   User:", event.user || "unknown");
    console.log("   Risk Score:", event.risk_score || "unknown");
  }
  
  res.status(200).send({ 
    status: "ok", 
    event_id: event.id,
    total_events: securityEvents.length 
  });
});

// View all collected events
app.get("/events", (req, res) => {
  res.json({
    total_events: securityEvents.length,
    total_alerts: alertCount,
    events: securityEvents
  });
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({ 
    status: "healthy", 
    timestamp: new Date().toISOString(),
    events_received: securityEvents.length,
    alerts_triggered: alertCount
  });
});

// Get statistics
app.get("/stats", (req, res) => {
  const highRiskEvents = securityEvents.filter(e => e.severity === "HIGH").length;
  const deniedAccess = securityEvents.filter(e => e.event?.result === false).length;
  
  res.json({
    total_events: securityEvents.length,
    high_risk_events: highRiskEvents,
    denied_accesses: deniedAccess,
    alerts_triggered: alertCount
  });
});

app.listen(9200, () => {
  console.log("🛰️  SIEM endpoint running on http://127.0.0.1:9200");
  console.log("📊 Available endpoints:");
  console.log("   POST /ingest    - Receive security events");
  console.log("   GET  /events    - View all collected events");
  console.log("   GET  /health    - Health check");
  console.log("   GET  /stats     - Security statistics");
});
