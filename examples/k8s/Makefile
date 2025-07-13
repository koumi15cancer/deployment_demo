.PHONY: show-curl-logs run-sample watch-pods

# Usage:
#   make run-sample 1   # for 1-rolling-updates
#   make run-sample 2   # for 2-recreate
#   make run-sample 3   # for 3-blue-green
#   ...

show-curl-logs:
	kubectl logs deployment/curl-deployment -n default -f

watch-pods:
	bash watch_pods_default.sh

run-sample:
	@if [ -z "$(INDEX)" ]; then \
		INDEX=$(word 2,$(MAKECMDGOALS)); \
	fi; \
	if [ -z "$$INDEX" ]; then \
		echo "Please provide an index, e.g., make run-sample 1"; \
		exit 1; \
	fi; \
	bash cleanup_all_namespaces.sh; \
	kubectl apply -f $$INDEX-*/; \
	kubectl apply -f curl-deployment.yaml;

# This trick allows 'make run-sample 1' to work by ignoring the extra argument as a target
default: 

%: ; 