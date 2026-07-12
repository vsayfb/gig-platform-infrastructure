#!/bin/bash
set -euxo pipefail

dnf install -y unzip curl tar gzip

if ! command -v aws &> /dev/null; then
  curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
fi

OPAMP_ENDPOINT=$(aws ssm get-parameter \
  --region "${aws_region}" \
  --name "${opamp_endpoint_parameter_name}" \
  --query 'Parameter.Value' --output text)

OPAMP_AUTH_TOKEN=$(aws ssm get-parameter \
  --region "${aws_region}" \
  --name "${opamp_auth_token_parameter_name}" \
  --with-decryption \
  --query 'Parameter.Value' --output text)

mkdir -p /opt/otel/bin /opt/otel/storage

curl -sL "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${otel_collector_version}/otelcol-contrib_${otel_collector_version}_linux_amd64.tar.gz" \
  | tar -xz -C /opt/otel/bin otelcol-contrib
mv /opt/otel/bin/otelcol-contrib /opt/otel/bin/otelcontribcol_linux_amd64

curl -sL "https://github.com/open-telemetry/opamp-go/releases/download/v${opamp_supervisor_version}/opampsupervisor_linux_amd64.tar.gz" \
  | tar -xz -C /opt/otel/bin

cat > /opt/otel/supervisor.yaml <<CONFIG
server:
  endpoint: "$OPAMP_ENDPOINT"
  headers:
    Authorization: "$OPAMP_AUTH_TOKEN"
capabilities:
  reports_effective_config: true
  accepts_remote_config: true
  reports_remote_config: true
agent:
  executable: /opt/otel/bin/otelcontribcol_linux_amd64
  description:
    identifying_attributes:
      service.name: "${service_name}"
  args: [--feature-gates, service.AllowNoPipelines]
storage:
  directory: /opt/otel/storage
CONFIG

cat > /etc/systemd/system/otel-supervisor.service <<UNIT
[Unit]
Description=OpenTelemetry OpAMP Supervisor
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/opt/otel/bin/opampsupervisor --config=/opt/otel/supervisor.yaml
WorkingDirectory=/opt/otel
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable --now otel-supervisor
