#!/usr/bin/env bash
# Runs the experimental Plank build without replacing the system installation.
set -euo pipefail

project_root="/home/vicman/Documents/Codex/2026-09-03/te"
core_build="$project_root/work/plank-reloaded-android-groups/build"
group_docklet="$project_root/outputs/plank-group-docklet/build"
test_config="$HOME/.config/plank/android_group_test"
normal_config="$HOME/.config/plank/dock1"

if [ ! -d "$test_config" ] && [ -d "$normal_config" ]; then
  cp -a "$normal_config" "$test_config"
fi

export LD_LIBRARY_PATH="$core_build/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PLANK_DOCKLET_DIRS="$group_docklet"

exec "$core_build/src/plank" -n android_group_test
