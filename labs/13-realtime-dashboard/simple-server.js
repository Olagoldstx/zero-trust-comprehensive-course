const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 5050;

// Serve static files
app.use(express.static('public'));

// Simple health check
app.get('/health', (req, res) => {
    res.json({ 
        status: 'ok', 
        message: 'Dashboard server is running',
        timestamp: new Date().toISOString()
    });
});

// Simple events endpoint
app.get('/api/events', (req, res) => {
    try {
        const eventsFile = path.join(__dirname, '../12-cross-cloud-correlation/multicloud_events.jsonl');
        if (!fs.existsSync(eventsFile)) {
            return res.json([]);
        }
        
        const data = fs.readFileSync(eventsFile, 'utf8');
        const events = data.split('\n')
            .filter(line => line.trim())
            .map(line => {
                try { return JSON.parse(line); } 
                catch { return null; }
            })
            .filter(event => event !== null)
            .slice(-50);
            
        res.json(events);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Correlation analysis endpoint
app.get('/api/correlations', (req, res) => {
    try {
        const eventsFile = path.join(__dirname, '../12-cross-cloud-correlation/multicloud_events.jsonl');
        if (!fs.existsSync(eventsFile)) {
            return res.json([]);
        }
        
        const data = fs.readFileSync(eventsFile, 'utf8');
        const events = data.split('\n')
            .filter(line => line.trim())
            .map(line => {
                try { return JSON.parse(line); } 
                catch { return null; }
            })
            .filter(event => event !== null);

        // Simple correlation logic
        const userStats = {};
        events.forEach(event => {
            if (!event.user) return;
            
            if (!userStats[event.user]) {
                userStats[event.user] = {
                    user: event.user,
                    clouds: new Set(),
                    total_events: 0,
                    high_sev: 0
                };
            }
            
            userStats[event.user].clouds.add(event.cloud);
            userStats[event.user].total_events++;
            if (event.severity >= 4) {
                userStats[event.user].high_sev++;
            }
        });

        // Convert to array and format
        const correlations = Object.values(userStats).map(stats => ({
            user: stats.user,
            clouds: Array.from(stats.clouds),
            total_events: stats.total_events,
            high_sev: stats.high_sev,
            correlated: stats.clouds.size > 1
        }));

        res.json(correlations);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Dashboard server running on http://0.0.0.0:${PORT}`);
    console.log(`📊 Health check: http://0.0.0.0:${PORT}/health`);
    console.log(`📊 Events API: http://0.0.0.0:${PORT}/api/events`);
});
