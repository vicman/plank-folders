#!/usr/bin/env bash
set -euo pipefail

# Run from the repository root after building the patched Plank source next to it.
repo_root="$(cd "$(dirname "$0")/.." && pwd)"
core_build="${PLANK_CORE_BUILD:-$repo_root/../plank-reloaded-android-groups/build}"
test_config="$HOME/.config/plank/android_group_test"

if [ ! -d "$test_config" ] && [ -d "$HOME/.config/plank/dock1" ]; then
  cp -a "$HOME/.config/plank/dock1" "$test_config"
fi

export LD_LIBRARY_PATH="$core_build/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PLANK_DOCKLET_DIRS="$repo_root/docklet/build"
exec "$core_build/src/plank" -n android_group_test
