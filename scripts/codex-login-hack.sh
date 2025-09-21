#!/bin/sh
# The Codex CLI login mechanism binds an HTTP server to TCP port 1455 to receive the OAuth 2.0 callback.
# Since the binding is hardcoded to 127.0.0.1 instead of 0.0.0.0 and cannot be configured, it’s not possible
# to expose the service to the host directly from Docker.
# This workaround creates a DNAT rule to bypass this limitation.

set -e

iptables -t nat -I PREROUTING 1 -i eth0 -p tcp --dport 1455 \
  -j DNAT --to-destination 127.0.0.1:1455

chown -R node:node /home/node/.codex
exec gosu node:node codex login
