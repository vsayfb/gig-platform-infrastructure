#!/bin/bash
set -euxo pipefail

dnf install -y docker
systemctl enable --now docker
usermod -aG docker ec2-user

# TODO: install/start the Grafana Alloy container once observability/ exists
