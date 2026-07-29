#!/usr/bin/env bash
#
# Discover what `defaults write` commands correspond to a macOS settings change.
#
# Usage:
#   ./macos/defaults-diff.sh
#
# It snapshots all preferences, waits for you to change something in System
# Settings, then snapshots again and shows the diff. Copy the diff output into
# macos/defaults.sh as `defaults write` commands.
#
# Source: https://github.com/yannbertrand/macos-defaults/blob/main/diff.sh
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

printf '\033[1m❓ Insert diff name (to store it for future usage): \033[0m'
read -r name
name=${name:-default}
printf '\033[1mSaving plist files to "%s/diffs/%s" folder.\033[0m\n' "$REPO_ROOT" "$name"

mkdir -p "diffs/${name}"
defaults read > "diffs/${name}/old.plist"
defaults -currentHost read > "diffs/${name}/host-old.plist"

printf '\n\033[1m⏳ Change settings and press any key to continue\033[0m\n'

read -r -n 1 -s
defaults read > "diffs/${name}/new.plist"
defaults -currentHost read > "diffs/${name}/host-new.plist"

printf '\n\033[1m➡️ Here is your diff:\033[0m\n\n'
git --no-pager diff --no-index "diffs/${name}/old.plist" "diffs/${name}/new.plist" || true

printf '\n\n\033[1m➡️ And here with the -currentHost option:\033[0m\n\n'
git --no-pager diff --no-index "diffs/${name}/host-old.plist" "diffs/${name}/host-new.plist" || true

printf '\n\n\033[1m🔮 Commands to print the diffs again:\033[0m\n'
printf 'git --no-pager diff --no-index diffs/%s/old.plist diffs/%s/new.plist\n' "$name" "$name"
printf 'git --no-pager diff --no-index diffs/%s/host-old.plist diffs/%s/host-new.plist\n' "$name" "$name"
