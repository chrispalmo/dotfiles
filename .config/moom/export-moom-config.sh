#!/bin/sh
set -eu

MOOM_CONFIG_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
defaults export com.manytricks.Moom "$MOOM_CONFIG_DIR/moom.plist"
