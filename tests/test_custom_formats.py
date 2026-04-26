"""Tests to ensure custom format patterns reference valid regex pattern files."""

from pathlib import Path

import pytest
import yaml


# Get the project root directory
PROJECT_ROOT = Path(__file__).parent.parent
CUSTOM_FORMATS_DIR = PROJECT_ROOT / "custom_formats"
REGEX_PATTERNS_DIR = PROJECT_ROOT / "regex_patterns"


def get_all_custom_formats():
    """Get all custom format YAML files."""
    if not CUSTOM_FORMATS_DIR.exists():
        return []
    return list(CUSTOM_FORMATS_DIR.glob("*.yml"))

@pytest.fixture(scope="module")
def available_regex_patterns_file_names():
    """Fixture to load all available regex pattern names once."""
    if not REGEX_PATTERNS_DIR.exists():
        return set()

    pattern_names = set()
    for yml_file in REGEX_PATTERNS_DIR.glob("*.yml"):
        # Use filename without extension as pattern name
        pattern_names.add(yml_file.stem)
    return pattern_names


@pytest.fixture(scope="module")
def available_regex_patterns_names():
    """Fixture to load all available regex pattern names once."""
    if not REGEX_PATTERNS_DIR.exists():
        return set()

    pattern_names = set()
    for yml_file in REGEX_PATTERNS_DIR.glob("*.yml"):
        # Read name from YAML file content
        with open(yml_file, encoding="utf-8") as f:
            data = yaml.safe_load(f)
            if data and "name" in data:
                pattern_names.add(data["name"])
    return pattern_names


@pytest.mark.parametrize("custom_format_file", get_all_custom_formats())
def test_custom_format_patterns_exist(
    custom_format_file,
    available_regex_patterns_file_names,
    available_regex_patterns_names,
):
    """Test that every pattern referenced in a custom format exists in regex_patterns."""
    with open(custom_format_file, encoding="utf-8") as f:
        data = yaml.safe_load(f)

    if not data or "conditions" not in data:
        pytest.skip(f"No conditions found in {custom_format_file.name}")

    missing_patterns_files = []
    missing_patterns_names = []

    for condition in data["conditions"]:
        pattern_name = condition.get("pattern")
        if not pattern_name:
            continue

        # Check if the referenced pattern exists in regex_patterns
        if pattern_name not in available_regex_patterns_file_names:
            missing_patterns_files.append(pattern_name)

        if pattern_name not in available_regex_patterns_names:
            missing_patterns_names.append(pattern_name)

    if missing_patterns_files:
        pytest.fail(
            f"Custom format '{custom_format_file.name}' references missing regex patterns:\n"
            + "\n".join(f"  - {pattern}" for pattern in missing_patterns_files)
        )

    if missing_patterns_names:
        pytest.fail(
            f"Custom format '{custom_format_file.name}' references missing regex patterns:\n"
            + "\n".join(f"  - {pattern}" for pattern in missing_patterns_names)
        )


def test_custom_formats_directory_exists():
    """Test that the custom_formats directory exists."""
    assert CUSTOM_FORMATS_DIR.exists(), f"Custom formats directory not found: {CUSTOM_FORMATS_DIR}"


def test_regex_patterns_directory_exists():
    """Test that the regex_patterns directory exists."""
    assert REGEX_PATTERNS_DIR.exists(), f"Regex patterns directory not found: {REGEX_PATTERNS_DIR}"


def test_spanish_priority_custom_formats_promote_known_spanish_sources():
    """Spanish Priority should include known Spanish-friendly sources in one CF."""
    expected_conditions = {
        "BTM": "release_group",
        "BTM (Release Title)": "release_title",
        "BEN THE MEN": "release_title",
        "LatTeam": "release_group",
        "LatTeam (Release Title)": "release_title",
        "SyncTeam": "release_group",
        "SyncTeam (Release Title)": "release_title",
        "SMS": "release_group",
        "SMS (Release Title)": "release_title",
    }

    for service in ["Radarr", "Sonarr"]:
        custom_format_file = CUSTOM_FORMATS_DIR / f"{service} - Spanish Priority.yml"
        assert custom_format_file.exists()

        with open(custom_format_file, encoding="utf-8") as f:
            data = yaml.safe_load(f)

        assert data["name"] == f"{service} - Spanish Priority"
        conditions = {condition["pattern"]: condition for condition in data["conditions"]}

        for pattern, condition_type in expected_conditions.items():
            assert conditions[pattern]["type"] == condition_type
            assert conditions[pattern]["required"] is False
            assert conditions[pattern]["negate"] is False


def test_spanish_priority_sources_are_not_lq_penalized():
    """Sources moved to Spanish Priority should no longer trigger LQ penalties."""
    for service in ["Radarr", "Sonarr"]:
        lq_file = CUSTOM_FORMATS_DIR / f"{service} - LQ.yml"
        lq_title_file = CUSTOM_FORMATS_DIR / f"{service} - LQ (Release Title).yml"

        with open(lq_file, encoding="utf-8") as f:
            lq_data = yaml.safe_load(f)
        with open(lq_title_file, encoding="utf-8") as f:
            lq_title_data = yaml.safe_load(f)

        assert all(condition["pattern"] != "BTM" for condition in lq_data["conditions"])
        assert all(
            condition["pattern"] != "BEN THE MEN"
            for condition in lq_title_data["conditions"]
        )
