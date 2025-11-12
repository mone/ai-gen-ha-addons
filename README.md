# Gluetun Home Assistant add-on repository

This repository packages the [Gluetun VPN client](https://github.com/qdm12/gluetun) as a Home Assistant add-on so that you can manage the container from the Home Assistant UI.

## Add-ons

| Add-on | Description |
| --- | --- |
| [Gluetun VPN Client](./gluetun/README.md) | Wraps the official Gluetun container with Home Assistant configuration, logging and web UI integration. |

## Usage

1. Add this repository to Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Paste the URL of this Git repository and click **Add**.
3. Install the **Gluetun VPN Client** add-on from the store, configure it via the UI and start it.
4. Use the **Open Web UI** button to reach the Gluetun HTTP control server (if enabled) and view logs from the add-on page.

## Development

The add-on image builds directly from `qmcgaw/gluetun` and adds a configuration shim that translates Home Assistant add-on options into the environment variables expected by Gluetun.
