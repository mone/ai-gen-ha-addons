# Gluetun VPN Client Home Assistant add-on

This add-on wraps the official [`qmcgaw/gluetun`](https://github.com/qdm12/gluetun) container so that you can route other add-ons or custom services through a VPN connection managed by Home Assistant.

## Configuration

All configuration is handled from the Home Assistant add-on UI. The main options are mapped to the environment variables that Gluetun expects.

| Option | Description |
| --- | --- |
| `vpn_provider` | VPN provider identifier (e.g. `nordvpn`, `custom`). |
| `vpn_type` | Choose `openvpn` or `wireguard`. |
| `openvpn_username` / `openvpn_password` | Credentials for OpenVPN providers. |
| `server_region`, `server_country`, `server_city`, `server_hostname` | Narrow down the VPN server selection. Leave blank to let Gluetun decide. |
| `wireguard_*` | Keys and endpoints required for Wireguard connections. |
| `dns_servers` | Optional list of DoT DNS resolvers (add one entry per resolver). |
| `firewall_allowed_subnets` | Comma-separated list of additional subnets that should bypass the VPN tunnel. |
| `enable_http_control_server` | Enable the Gluetun HTTP control server and expose it on port 8000. |
| `enable_prometheus` | Enable the Prometheus metrics endpoint on port 9999. |
| `shadowsocks_address` | Bind address for the optional Shadowsocks server. |
| `additional_env` | Extra environment variables to pass directly to Gluetun. |

Any option left empty will fall back to the defaults supplied by the Gluetun image.

## Web UI

The add-on exposes the Gluetun HTTP control server on port 8000. Use the “Open Web UI” button in Home Assistant to access it. If you disable the HTTP control server the web UI button will no longer work.

## Logs

The Gluetun logs are available in the standard Home Assistant add-on log viewer. You can also set `log_level` to adjust the verbosity of the Gluetun output.

## Ports

The add-on forwards the following ports from the underlying container. You may disable any ports you do not need from the add-on configuration panel.

- `8000/tcp` – HTTP control server (default enabled)
- `8388/tcp` and `8388/udp` – Shadowsocks proxy (optional)
- `9999/tcp` – Prometheus metrics (optional)

## Notes

- The add-on requires access to `/dev/net/tun` and the `NET_ADMIN` capability to create the VPN tunnel. Ensure your Home Assistant host provides these.
- Depending on your VPN provider you may need to supply additional environment variables. Use the `additional_env` option for full flexibility.
