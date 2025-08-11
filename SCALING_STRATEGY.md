# Scaling Strategy

This document describes the autoscaling policies and design rationale for services deployed on our AWS EKS platform.  
The goal is to maintain high availability, cost efficiency, and predictable performance during variable load conditions.


## 1. Overview

Each service is deployed with **Horizontal Pod Autoscalers (HPA)** configured for metrics-based scaling.  
We use:
- **CPU utilization**
- **Memory utilization**
- **Custom application metrics** (where applicable)

Policies are designed to **scale up before reaching service degradation thresholds** and to **scale down conservatively** to avoid thrashing.



## 2. Service-Specific Policies

### **2.1 LiveKit Egress**
**Metrics Used:**
- CPU utilization (%)
- Memory utilization (%)
- Custom metric: `livekit_egress_available` (number of available egress workers)

e.g

**Scaling Triggers:**
- **Scale Up** when:
  - CPU ≥ 50% _or_
  - Memory ≥ 65% _or_
  - `livekit_egress_available` ≤ 1
- **Scale Down** when:
  - CPU ≤ 30% _and_
  - Memory ≤ 45% _and_
  - `livekit_egress_available` ≥ 3

**Rationale:**
- Scaling up early on CPU/memory avoids saturation during encoding-heavy workloads.
- The `livekit_egress_available` metric ensures capacity is provisioned before egress workers are exhausted.
- Conservative scale down ensures ongoing egress tasks complete without disruption.


### **2.2 SIP Service**
**Metrics Used:**
- CPU utilization (%)
- Memory utilization (%)
- Custom metric: For autoscaling

E.g

**Scaling Triggers:**
- **Scale Up** when:
  - CPU ≥ 50% _or_
  - Memory ≥ 65% _or_
  - `custom_metric` ≤ 5
- **Scale Down** when:
  - CPU ≤ 30% _and_
  - Memory ≤ 45% _and_
  - `custom_metric` ≥ 10

**Rationale:**
- Custom metric for autoscaling the pod

---

### **2.3 SFU Server**
**Metrics Used:**
- CPU utilization (%)
- Memory utilization (%)

**Scaling Triggers:**
- **Scale Up** when:
  - CPU ≥ 60% _or_
  - Memory ≥ 70%
- **Scale Down** when:
  - CPU ≤ 35% _and_
  - Memory ≤ 50%

**Rationale:**
- SFU Server is infrastructure-critical; scaling on resource usage ensures stability.
- No custom metrics are required; workload behavior is predictable under CPU/memory constraints.

---

### **2.4 Agent Service**
**Metrics Used:**
- CPU utilization (%)

**Special Scaling Logic (Based on Vendor Guidance):**
- Scale up at **0.5 CPU utilization** (50%) — lower than the load threshold (0.7) to ensure continuity.
- Reduce **cooldown/stabilization period** for scale-up (e.g., `stabilizationWindowSeconds: 15`) to respond quickly to load.
- Increase **cooldown/stabilization period** for scale-down (e.g., `stabilizationWindowSeconds: 300`) to allow ongoing voice agent tasks to drain.

**Rationale:**
- Voice agents are long-running; spikes tend to be sustained.
- Early scale-up prevents overloading workers.
- Longer scale-down avoids terminating pods in the middle of active sessions.



## 3. General Scaling Principles

1. **Proactive Scaling:**  
   Scale up **before** reaching load thresholds to maintain service quality.
   
2. **Stabilization Windows:**  
   - **Short for scale-up** to respond to real demand spikes.
   - **Long for scale-down** to avoid disruption.

3. **Multiple Metrics:**  
   Use both CPU/memory and relevant custom metrics to ensure scaling decisions match actual service capacity.

4. **Testing & Validation:**  
   Policies should be validated under simulated load to ensure they perform as intended.


## 4. Example Kubernetes HPA Config Snippets

### LiveKit Egress
```yaml
metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 65
  - type: Pods
    pods:
      metric:
        name: livekit_egress_available
      target:
        type: AverageValue
        averageValue: 1
