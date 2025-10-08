#!/usr/bin/env python3
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import LabelEncoder

print("🤖 Lesson 14: AI-Powered Threat Detection")
print("=========================================")

# Sample security events
data = {
    'user': ['user1', 'user2', 'user3', 'user1', 'admin', 'attacker'],
    'cloud': ['aws', 'azure', 'gcp', 'aws', 'aws', 'aws'],
    'severity': [1, 1, 1, 2, 1, 4]
}

df = pd.DataFrame(data)
print(f"📊 Analyzing {len(df)} security events...")

# Feature engineering
user_encoder = LabelEncoder()
cloud_encoder = LabelEncoder()

df['user_encoded'] = user_encoder.fit_transform(df['user'])
df['cloud_encoded'] = cloud_encoder.fit_transform(df['cloud'])

# Prepare features for ML
X = df[['user_encoded', 'cloud_encoded', 'severity']]

# Train Isolation Forest model
print("🤖 Training ML model...")
model = IsolationForest(n_estimators=100, contamination=0.1, random_state=42)
model.fit(X)

# Generate predictions
df['anomaly_score'] = model.decision_function(X)
df['anomaly_flag'] = model.predict(X) == -1

# Display results
anomalies = df[df['anomaly_flag']]
print(f"✅ Detected {len(anomalies)} anomalies")

print("\n🚨 ANOMALIES DETECTED:")
for _, row in anomalies.iterrows():
    print(f"👤 User: {row['user']} | ☁️ Cloud: {row['cloud']} | Score: {row['anomaly_score']:.3f}")
