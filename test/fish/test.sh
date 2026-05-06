#!/usr/bin/env bash

set -e

source /etc/os-release

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "fish" fish -v

if [ "${FISHER:-"true"}" = "true" ]; then
  check "fisher" fish -c "fisher -v"
fi

if [ "${PURE:-"false"}" = "true" ]; then
  check "pure" fish -c "echo \$pure_version"
fi

# Report result
reportResults
