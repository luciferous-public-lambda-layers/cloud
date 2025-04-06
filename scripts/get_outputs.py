from __future__ import annotations

import json
from typing import TYPE_CHECKING

import boto3

if TYPE_CHECKING:
    from mypy_boto3_ssm import SSMClient

PREFIX = "/Output"
ssm: SSMClient = boto3.client("ssm")


def main():
    params = get_parameters()
    print(json.dumps(params, indent=2, ensure_ascii=False))


def get_parameters() -> dict[str, str]:
    token = None
    is_first = True
    result = {}
    while token or is_first:
        if is_first:
            is_first = False
        option = {
            "Path": PREFIX,
            "Recursive": True,
        }
        if token:
            option["NextToken"] = token

        resp = ssm.get_parameters_by_path(**option)
        for param in resp["Parameters"]:
            result[param["Name"]] = param["Value"]
        token = resp.get("NextToken")
    return {k: result[k] for k in sorted(result.keys())}


if __name__ == "__main__":
    main()
