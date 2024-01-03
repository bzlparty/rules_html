#!/usr/bin/env bash

platform_arch=({platform_arch})

cat > {out} <<EOF

ARTIFACTS = {
{artifacts}
}
EOF
