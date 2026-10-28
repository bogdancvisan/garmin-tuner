#!/usr/bin/env bash
# Usage: CIQ_SDK_HOME=/path/to/sdk DEVELOPER_KEY=/path/to/developer_key.der ./scripts/build.sh [device]
set -euo pipefail
cd "$(dirname "$0")/.."
DEVICE="${1:-fenix847mm}"
: "${CIQ_SDK_HOME:?Set CIQ_SDK_HOME to the Connect IQ SDK root}"
: "${DEVELOPER_KEY:?Set DEVELOPER_KEY to your developer key (.der)}"
mkdir -p bin
"$CIQ_SDK_HOME/bin/monkeyc" -d "$DEVICE" -f monkey.jungle -o "bin/GarminTuner-$DEVICE.prg" -y "$DEVELOPER_KEY" -w
echo "Built bin/GarminTuner-$DEVICE.prg"
