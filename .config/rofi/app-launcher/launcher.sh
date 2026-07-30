#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rofi \
  -show combi \
  -theme "$DIR/config.rasi" \
  -config "$DIR/config.rasi"
