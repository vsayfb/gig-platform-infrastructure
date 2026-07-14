#!/bin/bash
set -euxo pipefail

AWS_REGION="${aws_region}"
OPAMP_ENDPOINT_PARAMETER_NAME="${opamp_endpoint_parameter_name}"
OPAMP_AUTH_TOKEN_PARAMETER_NAME="${opamp_auth_token_parameter_name}"
OTLP_WRITE_KEY_PARAMETER_NAME="${otlp_write_key_parameter_name}"
OTEL_COLLECTOR_VERSION="${otel_collector_version}"
SERVICE_NAME="${service_name}"

dnf install -y unzip

if ! command -v aws >/dev/null 2>&1; then
    curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
        -o /tmp/awscliv2.zip

    unzip -q /tmp/awscliv2.zip -d /tmp
    /tmp/aws/install
fi

set +x
OPAMP_ENDPOINT=$(
    aws ssm get-parameter \
        --region "$AWS_REGION" \
        --name "$OPAMP_ENDPOINT_PARAMETER_NAME" \
        --query 'Parameter.Value' \
        --output text
)

OPAMP_AUTH_TOKEN=$(
    aws ssm get-parameter \
        --region "$AWS_REGION" \
        --name "$OPAMP_AUTH_TOKEN_PARAMETER_NAME" \
        --with-decryption \
        --query 'Parameter.Value' \
        --output text
)

OTLP_WRITE_KEY=$(
    aws ssm get-parameter \
        --region "$AWS_REGION" \
        --name "$OTLP_WRITE_KEY_PARAMETER_NAME" \
        --with-decryption \
        --query 'Parameter.Value' \
        --output text
)
set -x

mkdir -p /opt/otel/bin /opt/otel/storage

curl -sL "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v$${OTEL_COLLECTOR_VERSION}/otelcol-contrib_$${OTEL_COLLECTOR_VERSION}_linux_amd64.tar.gz" \
  | tar -xz -C /opt/otel/bin otelcol-contrib

mv /opt/otel/bin/otelcol-contrib /opt/otel/bin/otelcontribcol_linux_amd64

curl -sL -o /opt/otel/bin/opampsupervisor \
  "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/cmd/opampsupervisor/v$${OTEL_COLLECTOR_VERSION}/opampsupervisor_$${OTEL_COLLECTOR_VERSION}_linux_amd64"

chmod +x /opt/otel/bin/opampsupervisor

cat >/opt/otel/supervisor.yaml <<EOF
server:
  endpoint: "$${OPAMP_ENDPOINT%/}/v1/opamp"
  headers:
    Authorization: "Basic $OPAMP_AUTH_TOKEN"

capabilities:
  reports_effective_config: true
  accepts_remote_config: true
  reports_remote_config: true

agent:
  executable: /opt/otel/bin/otelcontribcol_linux_amd64
  description:
    identifying_attributes:
      service.name: "$SERVICE_NAME"
  args:
    - --feature-gates
    - service.AllowNoPipelines
  env:
    GCLOUD_FM_URL: "$OPAMP_ENDPOINT"
    GCLOUD_BASIC_AUTH_BASE64: "$OPAMP_AUTH_TOKEN"
    GCLOUD_RW_API_KEY: "$OTLP_WRITE_KEY"

storage:
  directory: /opt/otel/storage
EOF

if [ ! -f /etc/systemd/system/otel-supervisor.service ]; then
    cat >/etc/systemd/system/otel-supervisor.service <<EOF
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
EOF

    systemctl daemon-reload
    systemctl enable --now otel-supervisor
fi

mkdir -p /opt/deploy

cat >/opt/deploy/remote-deploy.sh <<'DEPLOYSCRIPT'
#!/bin/bash
set -euo pipefail

APP_DIR="/opt/app/$${SERVICE_NAME}"
RELEASE_DIR="$${APP_DIR}/releases/$(date +%Y%m%d%H%M%S)"
CURRENT_LINK="$${APP_DIR}/current"
PREVIOUS_LINK="$${APP_DIR}/previous"
UNIT_NAME="$${SERVICE_NAME}.service"

mkdir -p "$${RELEASE_DIR}"

aws s3 cp "s3://$${S3_BUCKET}/$${S3_KEY}" "$${RELEASE_DIR}/$${BINARY_NAME}"
chmod +x "$${RELEASE_DIR}/$${BINARY_NAME}"

if [ -L "$${CURRENT_LINK}" ]; then
    ln -sfn "$(readlink -f "$${CURRENT_LINK}")" "$${PREVIOUS_LINK}"
fi

ln -sfn "$${RELEASE_DIR}" "$${CURRENT_LINK}"

cat > "/etc/systemd/system/$${UNIT_NAME}" <<UNIT
[Unit]
Description=worker
After=network-online.target otel-supervisor.service
Wants=network-online.target otel-supervisor.service

[Service]
Type=simple
WorkingDirectory=$${CURRENT_LINK}
ExecStart=$${CURRENT_LINK}/$${BINARY_NAME}

Environment=APP_ENV=production
Environment=AWS_REGION=${aws_region}
Environment=OTEL_COLLECTOR_ADDR=localhost:4317

Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable "$${UNIT_NAME}"

echo "Checking OpenTelemetry Collector..."

systemctl is-active --quiet otel-supervisor || {
    echo "otel-supervisor is not running"
    exit 1
}

ss -ltn | grep -q ':4317 ' || {
    echo "Collector is not listening on localhost:4317"
    exit 1
}

systemctl restart "$${UNIT_NAME}"

sleep 5

if curl -sf "http://localhost:$${PORT}$${HEALTH_PATH}" >/dev/null; then
    echo "Health check passed - deploy successful."

    ls -1dt "$${APP_DIR}"/releases/*/ | tail -n +6 | xargs -r rm -rf
else
    echo "Health check FAILED - rolling back."

    if [ -L "$${PREVIOUS_LINK}" ]; then
        ln -sfn "$(readlink -f "$${PREVIOUS_LINK}")" "$${CURRENT_LINK}"
        systemctl restart "$${UNIT_NAME}"
    fi

    exit 1
fi
DEPLOYSCRIPT

chmod +x /opt/deploy/remote-deploy.sh

cat >/usr/local/bin/install-ollama.sh <<'EOF'
#!/bin/bash
set -euxo pipefail

if ! command -v ollama >/dev/null 2>&1; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

systemctl daemon-reload

systemctl enable ollama

if ! systemctl is-active --quiet ollama; then
    systemctl start ollama
fi

for i in $(seq 1 60); do
    if systemctl is-active --quiet ollama; then
        break
    fi
    sleep 2
done

systemctl is-active --quiet ollama || {
    echo "ollama failed to start"
    exit 1
}

OLLAMA_HOME="$(getent passwd ollama | cut -d: -f6)"

sudo -u ollama env HOME="$OLLAMA_HOME" ollama list >/dev/null

if ! sudo -u ollama env HOME="$OLLAMA_HOME" ollama list | awk 'NR>1 {print $1}' | grep -qx 'all-minilm:l12-v2'; then
    sudo -u ollama env HOME="$OLLAMA_HOME" ollama pull all-minilm:l12-v2
else
    echo "Model already present."
fi

mkdir -p /var/lib/ollama
touch /var/lib/ollama/.bootstrap-complete
EOF

chmod +x /usr/local/bin/install-ollama.sh

cat >/etc/systemd/system/install-ollama.service <<'EOF'
[Unit]
Description=Bootstrap Ollama
After=network-online.target
Wants=network-online.target

ConditionPathExists=!/var/lib/ollama/.bootstrap-complete

[Service]
Type=oneshot
ExecStart=/usr/local/bin/install-ollama.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now install-ollama.service

echo "Installation complete."