#!/usr/bin/env python3
"""Validate a landing-zone vending request without third-party dependencies."""

from __future__ import annotations

import argparse
import json
import re
import sys
import uuid
from datetime import datetime
from pathlib import Path
from typing import Any

REQUIRED_FIELDS = {
    "application_name",
    "owner",
    "cost_center",
    "environment",
    "data_classification",
    "subscription_id",
    "management_group_destination",
    "connectivity_profile",
    "monthly_budget",
    "budget_start_date",
    "budget_contact_emails",
    "expiration_date",
    "log_analytics_workspace_id",
}
OPTIONAL_FIELDS = {"role_assignments", "additional_tags"}
PRIVILEGED_ROLES = {
    "Owner",
    "User Access Administrator",
    "Role Based Access Control Administrator",
}
EMAIL = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
APP_NAME = re.compile(r"^[a-z][a-z0-9-]{2,30}$")
WORKSPACE_ID = re.compile(
    r"^/subscriptions/[0-9a-fA-F-]{36}/resourceGroups/[^/]+/"
    r"providers/Microsoft\.OperationalInsights/workspaces/[^/]+$"
)


class RequestError(ValueError):
    """Raised when a request violates the factory contract."""


def _date(value: Any, field: str) -> datetime:
    if not isinstance(value, str):
        raise RequestError(f"{field} must be an RFC3339 string")
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as error:
        raise RequestError(f"{field} must be a valid RFC3339 timestamp") from error


def _uuid(value: Any, field: str) -> None:
    try:
        uuid.UUID(str(value))
    except (ValueError, AttributeError) as error:
        raise RequestError(f"{field} must be a UUID") from error


def validate(request: dict[str, Any]) -> None:
    missing = REQUIRED_FIELDS - request.keys()
    unknown = request.keys() - REQUIRED_FIELDS - OPTIONAL_FIELDS
    if missing:
        raise RequestError(f"missing required fields: {', '.join(sorted(missing))}")
    if unknown:
        raise RequestError(f"unknown fields: {', '.join(sorted(unknown))}")

    if not APP_NAME.fullmatch(str(request["application_name"])):
        raise RequestError("application_name must be 3-31 lowercase letters, digits, or hyphens")
    if not EMAIL.fullmatch(str(request["owner"])):
        raise RequestError("owner must be an email address")
    _uuid(request["subscription_id"], "subscription_id")

    allowed_values = {
        "environment": {"dev", "test", "stage", "prod", "sandbox"},
        "data_classification": {"public", "internal", "confidential", "restricted"},
        "management_group_destination": {"corp", "online", "local", "sandbox"},
        "connectivity_profile": {"isolated", "corp", "online"},
    }
    for field, allowed in allowed_values.items():
        if request[field] not in allowed:
            raise RequestError(f"{field} must be one of: {', '.join(sorted(allowed))}")

    profile = request["connectivity_profile"]
    destination = request["management_group_destination"]
    if profile in {"corp", "online"} and profile != destination:
        raise RequestError(f"{profile} connectivity requires the {profile} destination")
    if request["data_classification"] == "restricted" and destination == "sandbox":
        raise RequestError("restricted data is not permitted in sandbox")

    if not isinstance(request["monthly_budget"], (int, float)) or request["monthly_budget"] <= 0:
        raise RequestError("monthly_budget must be a positive number")

    start = _date(request["budget_start_date"], "budget_start_date")
    end = _date(request["expiration_date"], "expiration_date")
    if start.day != 1:
        raise RequestError("budget_start_date must be the first day of a month")
    if end <= start:
        raise RequestError("expiration_date must be after budget_start_date")

    emails = request["budget_contact_emails"]
    if not isinstance(emails, list) or not emails or any(not EMAIL.fullmatch(str(e)) for e in emails):
        raise RequestError("budget_contact_emails must contain at least one email address")
    if len(emails) != len(set(emails)):
        raise RequestError("budget_contact_emails must not contain duplicates")

    if not WORKSPACE_ID.fullmatch(str(request["log_analytics_workspace_id"])):
        raise RequestError("log_analytics_workspace_id is not a valid workspace resource ID")

    for assignment in request.get("role_assignments", []):
        _uuid(assignment.get("principal_id"), "role_assignments[].principal_id")
        if assignment.get("role_definition_name", "Contributor") in PRIVILEGED_ROLES:
            raise RequestError("vending requests cannot grant privileged role administration")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("requests", nargs="+", type=Path)
    args = parser.parse_args()
    failed = False
    for path in args.requests:
        try:
            request = json.loads(path.read_text(encoding="utf-8"))
            if not isinstance(request, dict):
                raise RequestError("request root must be an object")
            validate(request)
            print(f"valid: {path}")
        except (OSError, json.JSONDecodeError, RequestError) as error:
            print(f"invalid: {path}: {error}", file=sys.stderr)
            failed = True
    return int(failed)


if __name__ == "__main__":
    raise SystemExit(main())
