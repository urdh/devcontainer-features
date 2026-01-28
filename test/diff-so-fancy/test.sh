#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

check "diff-so-fancy" diff-so-fancy --colors

reportResults
