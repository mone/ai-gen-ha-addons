#!/command/with-contenv sh
set -eu

CONFIG_PATH=/data/options.json
ENV_DIR=/var/run/s6/container_environment

mkdir -p "$ENV_DIR"

jq_exists() {
    [ -f "$CONFIG_PATH" ]
}

get_option() {
    local key="$1"
    if jq_exists; then
        jq -r --arg key "$key" '.[$key] // ""' "$CONFIG_PATH"
    else
        echo ""
    fi
}

set_env_var() {
    local env_name="$1"
    local value="$2"

    if [ -n "$value" ]; then
        printf '%s' "$value" >"${ENV_DIR}/${env_name}"
    else
        rm -f "${ENV_DIR}/${env_name}" 2>/dev/null || true
    fi
}

set_boolean_env() {
    local option_key="$1"
    local env_name="$2"
    local true_value="$3"
    local false_action="$4"

    if jq_exists && jq -e --arg key "$option_key" '.[$key] == true' "$CONFIG_PATH" >/dev/null; then
        printf '%s' "$true_value" >"${ENV_DIR}/${env_name}"
    else
        case "$false_action" in
            remove)
                rm -f "${ENV_DIR}/${env_name}" 2>/dev/null || true
                ;;
            "")
                ;;
            *)
                printf '%s' "$false_action" >"${ENV_DIR}/${env_name}"
                ;;
        esac
    fi
}

log() {
    printf '[INFO] %s\n' "$*"
}

if ! jq_exists; then
    log "No options.json available, using image defaults"
    exit 0
fi

log "Configuring Gluetun from Home Assistant options"

set_env_var VPN_SERVICE_PROVIDER "$(get_option vpn_provider)"
set_env_var VPN_TYPE "$(get_option vpn_type)"
set_env_var SERVER_REGIONS "$(get_option server_region)"
set_env_var SERVER_COUNTRIES "$(get_option server_country)"
set_env_var SERVER_CITIES "$(get_option server_city)"
set_env_var SERVER_HOSTNAMES "$(get_option server_hostname)"
set_env_var OPENVPN_USER "$(get_option openvpn_username)"
set_env_var OPENVPN_PASSWORD "$(get_option openvpn_password)"
set_env_var LOG_LEVEL "$(get_option log_level)"
set_env_var SHADOWSOCKS_LISTENING_ADDRESS "$(get_option shadowsocks_address)"
set_env_var FIREWALL_OUTBOUND_SUBNETS "$(get_option firewall_allowed_subnets)"
set_env_var SERVER_NETWORKS "$(get_option server_network)"
set_env_var WIREGUARD_PRIVATE_KEY "$(get_option wireguard_private_key)"
set_env_var WIREGUARD_ADDRESSES "$(get_option wireguard_addresses)"
set_env_var WIREGUARD_PRESHARED_KEY "$(get_option wireguard_preshared_key)"
set_env_var WIREGUARD_PUBLIC_KEY "$(get_option wireguard_public_key)"
set_env_var WIREGUARD_ENDPOINT_HOST "$(get_option wireguard_endpoint_host)"
set_env_var WIREGUARD_ENDPOINT_PORT "$(get_option wireguard_endpoint_port)"
set_env_var WIREGUARD_PERSISTENT_KEEPALIVE "$(get_option wireguard_persistent_keepalive)"

set_boolean_env enable_http_control_server HTTP_CONTROL_SERVER_ADDRESS "0.0.0.0:8000" remove
set_boolean_env enable_prometheus PROMETHEUS_ADDRESS "0.0.0.0:9999" remove
if jq -e '.dns_servers and (.dns_servers | length > 0)' "$CONFIG_PATH" >/dev/null 2>&1; then
    dns_servers=$(jq -r '.dns_servers | map(select(. != "")) | join(",")' "$CONFIG_PATH")
    set_env_var DOT_RESOLVERS "$dns_servers"
fi

if jq -e '.additional_env and (.additional_env | length > 0)' "$CONFIG_PATH" >/dev/null 2>&1; then
    jq -c '.additional_env[] | select(.name != null and .value != null and .name != "" and .value != "")' "$CONFIG_PATH" |
    while IFS= read -r pair; do
        name=$(echo "$pair" | jq -r '.name')
        value=$(echo "$pair" | jq -r '.value')
        log "Setting custom environment variable $name"
        set_env_var "$name" "$value"
    done
fi

log "Configuration applied"

