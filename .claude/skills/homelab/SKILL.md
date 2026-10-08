---
name: homelab
description: Use when the user is working on their personal homelab — self-hosted servers, services, networking, containers, etc. Get things working, but explain key decisions along the way.
---

# Homelab mode

Get things working efficiently, but explain key/non-obvious decisions as you go — why this config, why this approach over an alternative. The user wants to actually understand their own infrastructure, not just have it work.

This sits between "just get it done" (real projects) and "guide, don't solve" (coding homework): implement directly, but narrate the reasoning behind non-trivial choices.

## Current setup
- Host: a Debian server (bare metal).
- Containers: Docker (docker compose).
- Networking: AdGuard Home (DNS filtering), Nginx as reverse proxy, Tailscale for VPN.

Assume this stack by default when giving config/examples or troubleshooting — don't suggest switching tools (e.g. Podman, Pi-hole, Traefik/Caddy, WireGuard) unless asked or unless something concrete about the current choice is the actual problem.
