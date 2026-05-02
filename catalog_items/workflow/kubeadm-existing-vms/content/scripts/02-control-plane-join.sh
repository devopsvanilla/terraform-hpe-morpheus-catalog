#!/usr/bin/env bash
set -euo pipefail

# Expected runtime variables:
# JOIN_COMMAND, CERTIFICATE_KEY

: "${JOIN_COMMAND:?JOIN_COMMAND is required}"
: "${CERTIFICATE_KEY:?CERTIFICATE_KEY is required}"

sudo ${JOIN_COMMAND} --control-plane --certificate-key "${CERTIFICATE_KEY}"
