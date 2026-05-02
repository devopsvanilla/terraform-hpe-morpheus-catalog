#!/usr/bin/env bash
set -euo pipefail

# Expected runtime variables:
# JOIN_COMMAND

: "${JOIN_COMMAND:?JOIN_COMMAND is required}"

sudo ${JOIN_COMMAND}
