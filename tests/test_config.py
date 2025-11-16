"""Basic validation tests for the Gluetun add-on configuration."""
from __future__ import annotations

from pathlib import Path

import pytest

yaml = pytest.importorskip("yaml")


ROOT = Path(__file__).resolve().parents[1]
ADDON_DIR = ROOT / "gluetun"
CONFIG_PATH = ADDON_DIR / "config.yaml"


def load_config() -> dict:
    with CONFIG_PATH.open(encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def test_metadata_core_fields_present() -> None:
    config = load_config()

    assert config["slug"] == "gluetun"
    assert config["name"].lower().startswith("gluetun")
    assert config["startup"] == "services"
    assert sorted(config["arch"]) == ["aarch64", "amd64", "armv7"]


def test_options_are_defined_in_schema() -> None:
    config = load_config()
    schema_keys = {key for key in config["schema"].keys()}

    # Nested schema entries represent lists of values. They are accounted for
    # by their parent keys, so we only validate the top-level mappings.
    option_keys = set(config["options"].keys())

    # Optional keys may not appear as an option (e.g. nested structures).
    option_keys.add("additional_env")
    option_keys.add("dns_servers")

    assert option_keys.issubset(schema_keys)


def test_ports_have_descriptions() -> None:
    config = load_config()

    for port, description in config["ports_description"].items():
        assert port in config["ports"], f"Port {port} missing from ports"
        assert description, f"Port {port} is missing a description"


def test_environment_defaults() -> None:
    config = load_config()

    assert config["environment"]["TZ"] == "UTC"
    assert config["options"]["log_level"] in {"trace", "debug", "info", "warn", "error"}
