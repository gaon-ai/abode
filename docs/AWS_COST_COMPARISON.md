# AWS Cost Comparison: Airflow & PostgreSQL Hosting Options

A comprehensive cost analysis for deploying Apache Airflow and PostgreSQL on AWS, comparing managed services (MWAA, RDS) versus self-hosted options (EC2).

---

## Table of Contents

1. [Airflow Hosting Options](#airflow-hosting-options)
2. [PostgreSQL Hosting Options](#postgresql-hosting-options)
3. [Complete Architecture Scenarios](#complete-architecture-scenarios)
4. [Recommendations](#recommendations)

---

## Airflow Hosting Options

### Option 1: AWS Managed Workflows for Apache Airflow (MWAA)

**Monthly Cost: ~$480**

**Pricing Breakdown:**
- Environment cost: $0.49/hour × 730 hours = ~$358/month
- Scheduler: 1 × $0.10/hour × 730 hours = ~$73/month
- Worker: 1 × $0.10/hour × 730 hours = ~$73/month
- **Total: ~$480-500/month**

**Pros:**
- ✅ Fully managed service (zero ops overhead)
- ✅ Auto-scaling workers
- ✅ Built-in monitoring and logging
- ✅ Integrated with AWS services (S3, IAM, KMS)
- ✅ Automatic Airflow version updates
- ✅ High availability built-in

**Cons:**
- ❌ Very expensive ($480/month minimum)
- ❌ Limited customization
- ❌ Vendor lock-in
- ❌ Cold start issues (slower DAG response)
- ❌ Cannot install custom system packages easily

**Best for:**
- Enterprise teams with large budgets
- Teams that value zero operational overhead
- Organizations already heavily invested in AWS ecosystem

---

### Option 2: Self-Hosted Airflow on EC2

**Monthly Cost: ~$26**

**Pricing Breakdown:**
- EC2 t4g.medium (2 vCPU, 4GB RAM): ~$24/month
- EBS 20GB gp3 storage: ~$2/month
- PostgreSQL (Docker container): $0
- **Total: ~$26/month**

**Pros:**
- ✅ 96% cheaper than MWAA
- ✅ Full control over configuration
- ✅ Can install any packages/extensions
- ✅ No vendor lock-in
- ✅ Fast DAG response (no cold starts)
- ✅ Can use ARM-based instances (t4g = cheaper)

**Cons:**
- ❌ You manage everything (updates, patches, backups)
- ❌ No auto-scaling (fixed capacity)
- ❌ Single point of failure (unless you build HA)
- ❌ Requires DevOps knowledge
- ❌ Manual monitoring setup

**Best for:**
- Cost-conscious startups
- Small teams with DevOps skills
- Development/staging environments
- Predictable workloads that don't need auto-scaling

---

### Airflow Hosting Comparison

| Aspect | MWAA (Managed) | EC2 (Self-Hosted) | Difference |
|--------|----------------|-------------------|------------|
| **Monthly Cost** | **$480** | **$26** | **-96%** |
| Setup Time | 15 minutes | 30-60 minutes | - |
| Operational Overhead | Zero | Medium | - |
| Auto-scaling | Yes | No | - |
| High Availability | Built-in | DIY | - |
| Customization | Limited | Full | - |
| Version Control | AWS managed | You manage | - |
| Annual Cost | **$5,760** | **$312** | **-$5,448/year** |

**Savings: $454/month or $5,448/year with EC2 self-hosted**

---

## PostgreSQL Hosting Options

For storing client/application data (not Airflow metadata).

### Option 1: PostgreSQL on EC2 (Docker)

**Monthly Cost: ~$30** (incremental: +$4)

**Pricing Breakdown:**
- EC2 t4g.medium: ~$24/month (shared with Airflow)
- EBS 50GB gp3: ~$6/month (+$4 for extra storage)
- PostgreSQL container: $0
- **Incremental cost: +$4/month**

**Pros:**
- ✅ Cheapest option
- ✅ No network latency (local access)
- ✅ Full PostgreSQL control
- ✅ Can install any extensions (PostGIS, pgvector, etc.)
- ✅ Shared EC2 instance with Airflow

**Cons:**
- ❌ No automated backups (must set up EBS snapshots)
- ❌ Single point of failure
- ❌ Shared CPU/memory with Airflow (resource contention)
- ❌ Manual scaling and maintenance
- ❌ You manage security patches
- ❌ Higher data loss risk

**Best for:**
- Development/testing environments
- Non-critical data that can be recreated
- Very tight budgets
- Teams comfortable managing databases

---

### Option 2: Amazon RDS for PostgreSQL (Managed)

**Monthly Cost: ~$40** (incremental: +$14)

**Pricing Breakdown:**
- EC2 t4g.medium: ~$24/month (Airflow only)
- EBS 20GB: ~$2/month (Airflow only)
- RDS db.t4g.micro (1 vCPU, 1GB): ~$11.50/month
- RDS storage 20GB gp3: ~$2.30/month
- Backup storage (7 days): ~$0.50/month
- **Incremental cost: +$14/month**

**Pros:**
- ✅ Automated daily backups
- ✅ Point-in-time recovery (7-35 days)
- ✅ Managed updates and security patches
- ✅ Easy vertical/horizontal scaling
- ✅ Isolated from Airflow (no resource contention)
- ✅ CloudWatch monitoring included
- ✅ Upgrade path to multi-AZ HA
- ✅ Connection pooling available

**Cons:**
- ❌ More expensive (+$14/month)
- ❌ Network latency (minimal in same VPC)
- ❌ Less PostgreSQL config control
- ❌ Cannot install some extensions

**Best for:**
- Production environments
- Business-critical data
- Teams without deep PostgreSQL expertise
- Applications requiring high availability

---

### PostgreSQL Hosting Comparison

| Aspect | EC2 PostgreSQL | RDS Managed | Difference |
|--------|----------------|-------------|------------|
| **Incremental Cost** | **+$4/mo** | **+$14/mo** | **+$10/mo** |
| **Total Cost** | **$30/mo** | **$40/mo** | **+$10/mo** |
| Automated Backups | ❌ Manual | ✅ Automatic | - |
| Point-in-time Recovery | ❌ No | ✅ Yes (7 days) | - |
| Data Loss Risk | ⚠️ High | ✅ Low | - |
| Scaling Effort | ⚠️ Manual + downtime | ✅ Easy + minimal downtime | - |
| Security Patches | ⚠️ You manage | ✅ AWS manages | - |
| Resource Isolation | ⚠️ Shares with Airflow | ✅ Dedicated | - |
| Setup Complexity | Low | Medium | - |
| Annual Cost | **$360** | **$480** | **+$120/year** |

**Cost difference: $10/month or $120/year for RDS managed**

---

## Complete Architecture Scenarios

### Scenario 1: Maximum Cost Savings (Development)

**Architecture:**
- Airflow on EC2 (LocalExecutor)
- Airflow metadata: PostgreSQL on EC2 (Docker)
- Client data: PostgreSQL on EC2 (Docker, same instance)

**Monthly Cost: ~$30**

**Annual Cost: ~$360**

**Best for:** Development, testing, proof-of-concept, non-critical workloads

---

### Scenario 2: Balanced Approach (Small Production)

**Architecture:**
- Airflow on EC2 (LocalExecutor)
- Airflow metadata: PostgreSQL on EC2 (Docker)
- Client data: RDS db.t4g.micro (single-AZ)

**Monthly Cost: ~$40**

**Annual Cost: ~$480**

**Best for:** Small production workloads, startups, cost-conscious teams with important data

---

### Scenario 3: Production-Ready (High Availability)

**Architecture:**
- Airflow on EC2 (LocalExecutor)
- Airflow metadata: PostgreSQL on EC2 (Docker)
- Client data: RDS db.t4g.small (multi-AZ)

**Monthly Cost: ~$83**
- EC2 t4g.medium: ~$24/month
- EBS 20GB: ~$2/month
- RDS db.t4g.small multi-AZ: ~$51/month
- RDS storage 50GB + backups: ~$6/month

**Annual Cost: ~$996**

**Best for:** Business-critical applications requiring 99.95% uptime SLA

---

### Scenario 4: Fully Managed (Enterprise)

**Architecture:**
- AWS MWAA (Managed Airflow)
- Client data: RDS db.m5.large (multi-AZ)

**Monthly Cost: ~$700**
- MWAA environment: ~$480/month
- RDS db.m5.large multi-AZ: ~$220/month

**Annual Cost: ~$8,400**

**Best for:** Large enterprises with ample budget, minimal DevOps resources

---

## Complete Architecture Comparison Table

| Scenario | Airflow | Client DB | Monthly | Annual | Savings vs Managed |
|----------|---------|-----------|---------|--------|-------------------|
| **Max Savings** | EC2 | EC2 PostgreSQL | **$30** | **$360** | -$8,040/year |
| **Balanced** | EC2 | RDS micro | **$40** | **$480** | -$7,920/year |
| **Production HA** | EC2 | RDS small multi-AZ | **$83** | **$996** | -$7,404/year |
| **Fully Managed** | MWAA | RDS large multi-AZ | **$700** | **$8,400** | Baseline |

---

## Recommendations

### For Development/Testing
**Use: EC2 Airflow + EC2 PostgreSQL**
- Cost: $30/month
- Rationale: Lowest cost, acceptable risk for non-production data

### For Small Production
**Use: EC2 Airflow + RDS micro single-AZ**
- Cost: $40/month
- Rationale: Only $10/month more than dev setup, but client data is protected with automated backups

### For Business-Critical Production
**Use: EC2 Airflow + RDS small multi-AZ**
- Cost: $83/month
- Rationale: High availability for client data, still 88% cheaper than MWAA

### For Enterprise with Large Budget
**Use: MWAA + RDS multi-AZ**
- Cost: $700/month
- Rationale: Zero operational overhead, full AWS integration, auto-scaling

---

## Key Takeaways

1. **Airflow on EC2 is 96% cheaper than MWAA** ($26 vs $480/month)
   - Savings: $5,448/year
   - Trade-off: You manage infrastructure

2. **RDS for client data costs $10/month more than EC2 PostgreSQL** ($40 vs $30 total)
   - Extra $10/month gets you automated backups and point-in-time recovery
   - Worth it for production data

3. **Our recommended setup: EC2 Airflow + RDS micro = $40/month**
   - Protects client data while keeping Airflow costs minimal
   - 94% cheaper than fully managed ($40 vs $700/month)
   - Annual savings: $7,920/year

4. **Multi-AZ adds significant cost but provides HA**
   - RDS multi-AZ doubles RDS cost (~$51 vs $14 for micro)
   - Provides 99.95% uptime SLA with automatic failover
   - Consider for business-critical applications

---

## Cost Breakdown Summary

| Component | EC2 Option | RDS/MWAA Option | Monthly Savings |
|-----------|------------|-----------------|-----------------|
| **Airflow** | $26 (EC2) | $480 (MWAA) | **$454** |
| **Client DB** | +$4 (EC2 PG) | +$14 (RDS micro) | **$10** |
| **Total Minimum** | **$30/mo** | **$494/mo** | **$464/mo** |
| **Annual** | **$360/year** | **$5,928/year** | **$5,568/year** |

---

## Additional Considerations

### When to Choose EC2 Self-Hosted:
- ✅ You have DevOps expertise
- ✅ Predictable workloads (no need for auto-scaling)
- ✅ Budget constraints
- ✅ Need full control over configuration
- ✅ Want to minimize vendor lock-in

### When to Choose Managed Services (MWAA/RDS):
- ✅ Limited DevOps resources
- ✅ Need auto-scaling (variable workloads)
- ✅ Require high availability SLA
- ✅ Value operational simplicity over cost
- ✅ Already heavily invested in AWS ecosystem

---

## Next Steps

1. **Start with minimal setup** ($30-40/month) for development
2. **Add RDS for production** (+$10/month) when you have real client data
3. **Upgrade to multi-AZ** (+$43/month) if you need HA
4. **Consider MWAA** only if budget allows and you value zero ops overhead

**Current Implementation:** EC2 Airflow ($26/month) - See main [README.md](../README.md) for deployment instructions.

---

*Last updated: November 2025*
*Prices based on us-east-1 region, on-demand pricing*
