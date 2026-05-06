#!/usr/bin/env bash
set -e

. ./library_scripts.sh

# Determine the appropriate non-root user
USERNAME=${USERNAME:-"automatic"}
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
  USERNAME=""
  POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
  for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
    if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
      USERNAME=${CURRENT_USER}
      break
    fi
  done
  if [ "${USERNAME}" = "" ]; then
    USERNAME=root
  fi
elif [ "${USERNAME}" = "none" ] || ! id -u "${USERNAME}" > /dev/null 2>&1; then
  USERNAME=root
fi

# nanolayer is a cli utility which keeps container layers as small as possible
# source code: https://github.com/devcontainers-extra/nanolayer
# `ensure_nanolayer` is a bash function that will find any existing nanolayer installations,
# and if missing - will download a temporary copy that automatically get deleted at the end
# of the script
ensure_nanolayer nanolayer_location "v0.5.4"

# Install fish from Github Releases
$nanolayer_location \
    install \
    devcontainer-feature \
    "ghcr.io/devcontainers-extra/features/gh-release:1.0.25" \
    --option repo='fish-shell/fish-shell' --option binaryNames='fish' --option version="$VERSION" --option assetRegex='fish-.*-linux-.*(.tar.xz)$'

# Optionally install fisher
if [ "${FISHER:-"true"}" = "true" ]; then
    if ! type curl >/dev/null 2>&1; then
        source /etc/os-release
        case "${ID}" in
            debian|ubuntu)
                $nanolayer_location install apt curl
                ;;
            alpine)
                $nanolayer_location install apk curl
                ;;
        esac
    fi

    echo "Installing Fisher..."
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
    if [ "${USERNAME}" != "root" ]; then
        su "${USERNAME}" -c 'fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"'
    fi
    fish -c "fisher -v"

    # Then optionally install & configure the pure prompt
    if [ "${PURE:-"false"}" = "true" ]; then
      fish -c 'fisher install pure-fish/pure'
      if [ "${USERNAME}" != "root" ]; then
          su "${USERNAME}" -c 'fish -c "fisher install pure-fish/pure"'
      fi
    fi
fi

echo 'Done!'
