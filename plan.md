| Deployment Strategy | Platform-Orchestrated (Cloud, PaaS) | Container-Orchestrated (Kubernetes, Nomad) | Config-as-Code (Terraform, Ansible) | Self-Managed (VMs, NGINX/OpenResty) | Serverless (Lambda, Cloud Run) |
|---------------------|--------------------------------------|--------------------------------------------|--------------------------------------|-------------------------------------|-------------------------------|
| Recreate            | ✅ Built-in                          | ✅ Built-in                                | ✅ With scripts/playbooks            | ✅ Manual (e.g., systemd, restart)  | ✅ Default behavior           |
| Rolling Update      | ✅ Auto-managed                      | ✅ Native (Deployment spec)                | ⚠️ Manual coordination               | ⚠️ Manual with health checks        | ✅ Version alias              |
| Blue-Green          | ✅ With slots / revisions            | ⚠️ Manual or with Flagger                  | ⚠️ Requires logic and 2 environments | ⚠️ Manual with NGINX upstream flip  | ✅ Routing by version         |
| Canary              | ⚠️ Limited traffic split (GCP, AWS) | ✅ Flagger, Argo, Service Mesh             | ❌ Not native                        | ⚠️ Complex via Lua + proxy weights | ✅ Versions + weights         |
| Shadow Traffic      | ❌ Not supported                     | ✅ Istio/Linkerd Service Mesh              | ❌ Not available                     | ⚠️ Advanced Lua mirror logic        | ❌ Not supported              |
| A/B Testing         | ⚠️ API Gateway header-based         | ✅ Ingress rules or Mesh                   | ❌ Manual only                       | ✅ NGINX header map + Lua           | ⚠️ Manual per function router |

----

| Purpose / Use Case                          | Deployment Strategy     | Description                                                                 |
|---------------------------------------------|--------------------------|-----------------------------------------------------------------------------|
| 🛠️ Basic Deployment                         | Recreate                 | Stop old version, start new — simplest, but causes downtime.               |
| 🔄 Zero-Downtime Upgrade                    | Rolling Update           | Gradually replace instances one by one with readiness checks.              |
| ✅ Safe Cutover                             | Blue-Green               | Run two environments (old/new), switch traffic instantly when ready.       |
| 🧪 Controlled Experimentation               | Canary                   | Gradually shift a small percentage of traffic to new version.              |
| 👻 Silent Validation                        | Shadow Traffic           | Duplicate real traffic to new version without affecting real users.        |
| 🎯 Targeted Testing / Segmentation          | A/B Testing              | Route users to different versions based on headers, cookies, or segments.  |


----

## 🎯 Deployment Strategies by Purpose

| **Deployment Strategy** | **Best Used For**                                  |
|-------------------------|----------------------------------------------------|
| **Recreate**            | Simple restart, downtime acceptable                |
| **Rolling Update**      | Zero-downtime upgrade                              |
| **Blue-Green**          | Full validation in parallel before switching live  |
| **Canary**              | Progressive rollout with monitoring and control    |
| **Shadow Traffic**      | Internal validation with mirrored real traffic     |
| **A/B Testing**         | User segmentation, UX or logic variant comparison  |

