----> nginx as server 
- routing on nginx/ reverse proxy -> 1 file .conf -> static .conf
- routing dynamics with open resty -> multiple .conf 
- routing canary : by header, by % values percentage
- feature flag on nginx routing, on app backend, on frontend
- multiple backend: A/B testing - Blue/green



----> Kubernates support 
- without service mesh, nginx ingress
- with service mesh : Istio

-> Zero downtime: rolling 

------> AWS ECS
- Rolling Updates (Default ECS Strategy):
- Blue/Green Deployments (with CodeDeploy):
Uses two environments: Blue (current production) and Green (new version).
Traffic is shifted from Blue to Green after validation, with the ability to roll back if issues arise.
Requires an ALB or NLB and CodeDeploy integration with ECS.

= Canary Deployments:
A subset of traffic is routed to the new version (Green) while most traffic remains on the current version (Blue).
Gradually increase traffic to the Green environment based on success metrics.
Achieved using CodeDeploy with ECS and ALB for traffic splitting.

- Feature Toggles:
Control feature rollout within the application code, enabling or disabling features without redeploying.
Implemented in the application layer, not directly by ECS, but ECS supports deploying updated task definitions with toggle changes

- A/B Testing:
Two or more versions of an application (e.g., with different features or UI) are served to different user segments to compare performance.
Uses ALB routing rules to direct traffic to different ECS services or target groups.