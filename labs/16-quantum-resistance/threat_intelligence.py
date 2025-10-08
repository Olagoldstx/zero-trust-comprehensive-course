#!/usr/bin/env python3
"""
Lesson 16: Quantum Threat Intelligence
Real-time monitoring for quantum computing threats
"""

import json
import time
from datetime import datetime, timezone, timedelta
import random

class QuantumThreatMonitor:
    """Monitor and detect quantum computing attack patterns"""
    
    def __init__(self):
        self.threat_levels = ["NORMAL", "ELEVATED", "QUANTUM_IMMINENT"]
        self.current_level = "NORMAL"
        self.anomalies_detected = []
        self.quantum_indicators = {
            "MASSIVE_DATA_HARVESTING": 0,
            "UNUSUAL_CRYPTO_PATTERNS": 0, 
            "SHORS_TIMING_SUSPECTED": 0,
            "GROVER_SEARCH_PATTERNS": 0
        }
        
    def analyze_network_traffic(self, traffic_data):
        """Analyze network patterns for quantum threat indicators"""
        threats_detected = []
        
        # Check for massive encrypted data collection (harvest now, decrypt later)
        if traffic_data.get('encrypted_data_volume', 0) > 500000:  # 500MB+
            self.quantum_indicators["MASSIVE_DATA_HARVESTING"] += 1
            threats_detected.append("MASSIVE_DATA_HARVESTING")
            
        # Check for unusual cryptographic operations
        crypto_ops = traffic_data.get('cryptographic_operations', 0)
        if crypto_ops > 10000 and crypto_ops % 2 == 0:  # Even numbers can indicate Shor's
            self.quantum_indicators["UNUSUAL_CRYPTO_PATTERNS"] += 1
            threats_detected.append("UNUSUAL_CRYPTO_PATTERNS")
            
        # Check timing patterns for quantum algorithm signatures
        if self.detect_quantum_timing_patterns(traffic_data.get('request_timings', [])):
            self.quantum_indicators["SHORS_TIMING_SUSPECTED"] += 1
            threats_detected.append("SHORS_TIMING_SUSPECTED")
            
        return threats_detected
    
    def detect_quantum_timing_patterns(self, timings):
        """Detect timing patterns characteristic of quantum algorithms"""
        if len(timings) < 8:
            return False
            
        # Quantum algorithms often show specific periodicity
        # Check for consistent small variances (quantum parallelism)
        variances = [abs(timings[i] - timings[i-1]) for i in range(1, len(timings))]
        avg_variance = sum(variances) / len(variances)
        
        # Quantum computers often show very consistent timing
        return avg_variance < 0.0001
    
    def assess_quantum_threat_level(self, detected_threats, system_context):
        """Assess overall quantum threat level"""
        threat_score = 0
        
        # Base score from detected threats
        threat_score += len(detected_threats) * 2
        
        # Add indicator weights
        for indicator, count in self.quantum_indicators.items():
            threat_score += count * 1.5
            
        # Context modifiers
        if system_context.get('sensitive_data_exposed', False):
            threat_score += 3
        if system_context.get('legacy_crypto_active', False):
            threat_score += 2
            
        # Determine threat level
        if threat_score >= 8:
            new_level = "QUANTUM_IMMINENT"
        elif threat_score >= 5:
            new_level = "ELEVATED" 
        else:
            new_level = "NORMAL"
            
        if new_level != self.current_level:
            self.record_threat_level_change(new_level)
            self.current_level = new_level
            
        return {
            'threat_level': self.current_level,
            'threat_score': threat_score,
            'indicators_active': self.quantum_indicators,
            'recommendations': self.get_threat_recommendations()
        }
    
    def record_threat_level_change(self, new_level):
        """Record threat level changes with timestamp"""
        change_record = {
            'timestamp': datetime.now(timezone.utc).isoformat(),
            'from_level': self.current_level,
            'to_level': new_level,
            'indicators': self.quantum_indicators.copy()
        }
        self.anomalies_detected.append(change_record)
        
    def get_threat_recommendations(self):
        """Get security recommendations based on threat level"""
        recommendations = {
            "NORMAL": [
                "Continue standard quantum monitoring",
                "Review crypto migration progress",
                "Update threat intelligence feeds"
            ],
            "ELEVATED": [
                "Activate hybrid cryptography",
                "Increase monitoring frequency", 
                "Prepare emergency policies",
                "Alert security team"
            ],
            "QUANTUM_IMMINENT": [
                "ACTIVATE QUANTUM LOCKDOWN",
                "Force crypto migration completion",
                "Isolate legacy systems",
                "Enable maximum logging",
                "Alert executive team"
            ]
        }
        return recommendations.get(self.current_level, [])
    
    def generate_threat_report(self):
        """Generate comprehensive threat intelligence report"""
        return {
            'current_threat_level': self.current_level,
            'report_time': datetime.now(timezone.utc).isoformat(),
            'active_indicators': {k: v for k, v in self.quantum_indicators.items() if v > 0},
            'recent_anomalies': self.anomalies_detected[-5:],
            'recommendations': self.get_threat_recommendations(),
            'system_status': 'QUANTUM_RESILIENT' if self.current_level != "QUANTUM_IMMINENT" else 'CRITICAL'
        }

def demonstrate_threat_intelligence():
    """Demonstrate quantum threat intelligence capabilities"""
    print("QUANTUM THREAT INTELLIGENCE DEMONSTRATION")
    print("=" * 50)
    
    monitor = QuantumThreatMonitor()
    
    # Test scenarios
    scenarios = [
        {
            'name': 'Normal Traffic',
            'traffic': {'encrypted_data_volume': 1000, 'cryptographic_operations': 500},
            'context': {'sensitive_data_exposed': False, 'legacy_crypto_active': True}
        },
        {
            'name': 'Suspicious Harvesting', 
            'traffic': {'encrypted_data_volume': 800000, 'cryptographic_operations': 15000},
            'context': {'sensitive_data_exposed': True, 'legacy_crypto_active': True}
        }
    ]
    
    for scenario in scenarios:
        print(f"\nScenario: {scenario['name']}")
        print("   Analyzing network patterns...")
        
        threats = monitor.analyze_network_traffic(scenario['traffic'])
        assessment = monitor.assess_quantum_threat_level(threats, scenario['context'])
        
        print(f"   Threat Level: {assessment['threat_level']}")
        print(f"   Threat Score: {assessment['threat_score']}")
        print(f"   Detected Threats: {threats}")
    
    # Generate final report
    print(f"\nFINAL THREAT INTELLIGENCE REPORT")
    report = monitor.generate_threat_report()
    print(f"   System Status: {report['system_status']}")

if __name__ == "__main__":
    demonstrate_threat_intelligence()
