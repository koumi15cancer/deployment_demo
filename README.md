# Deployment Demo Project

## Project Overview

This repository demonstrates modern deployment strategies and infrastructure patterns using Kubernetes, NGINX (OpenResty/Lua), and a simple Go backend. It is designed for learning, experimentation, and showcasing best practices in cloud-native deployments.

## Quick Start: Kubernetes Playground

The main playground for this project is the [`examples/k8s`](examples/k8s/) folder. Here you will find:
- Ready-to-run Kubernetes manifests for rolling updates, recreate, blue-green, canary, shadowing, and A/B testing scenarios.
- A Makefile for easy cleanup, sample application, and log monitoring.
- Step-by-step instructions in the folder's README to help you get started quickly.

**To get started:**
1. Follow the setup in [`examples/k8s/README.md`](examples/k8s/README.md) to install Kind, create a local cluster, and run sample scenarios.
2. Use the provided Makefile commands to clean, deploy, and observe different deployment strategies in action.

## Folder Structure

- [`examples/k8s/`](examples/k8s/):
  - The main playground for Kubernetes deployment strategies and experiments.
  - Includes sample manifests, automation scripts, and a detailed README for hands-on learning.

- [`nginx/`](nginx/):
  - Contains a raw NGINX gateway setup using OpenResty and Lua scripting.
  - Useful for experimenting with custom routing, traffic shaping, and advanced gateway logic.

- [`backend/`](backend/):
  - A simple service to play with deployment scenarios.
  - Great for testing how services are built, containerized, and rolled out in Kubernetes or other platforms.

- [`infra/`](infra/):
  - Purpose-built for playing with ECS, Kubernetes, and free cloud service usage for learning purposes.
  - Contains Infrastructure-as-Code examples (Terraform, Kubernetes templates) for provisioning and managing cloud resources.

## Contributing

We welcome contributions! To get started:

1. **Fork the repository** and create a new branch for your feature or fix.
2. **Follow code style and best practices** for the language or tool you are working with.
3. **Test your changes** locally (e.g., using Kind for Kubernetes, or Docker for NGINX/Go backend).
4. **Open a pull request** with a clear description of your changes and why they are needed.
5. For major changes, please open an issue first to discuss what you would like to change.

**Areas to contribute:**
- New deployment scenarios or improvements in `examples/k8s/`
- Enhancements to the NGINX gateway or Lua scripts
- Backend features or bug fixes
- Documentation improvements

---

For more details and scenario-specific instructions, see the README files in each subfolder. 