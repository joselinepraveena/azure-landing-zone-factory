import importlib.util
import json
import unittest
from copy import deepcopy
from pathlib import Path

ROOT = Path(__file__).parents[2]
SPEC = importlib.util.spec_from_file_location(
    "validate_request", ROOT / "scripts" / "validate-request.py"
)
assert SPEC and SPEC.loader
VALIDATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(VALIDATOR)


class VendingRequestContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.sample = json.loads(
            (ROOT / "config/vending-requests/sample-sandbox.json").read_text()
        )

    def test_sample_is_valid(self):
        VALIDATOR.validate(deepcopy(self.sample))

    def test_missing_owner_is_rejected(self):
        request = deepcopy(self.sample)
        request.pop("owner")
        with self.assertRaisesRegex(VALIDATOR.RequestError, "missing required"):
            VALIDATOR.validate(request)

    def test_privileged_role_is_rejected(self):
        request = deepcopy(self.sample)
        request["role_assignments"][0]["role_definition_name"] = "Owner"
        with self.assertRaisesRegex(VALIDATOR.RequestError, "privileged"):
            VALIDATOR.validate(request)

    def test_restricted_data_is_rejected_in_sandbox(self):
        request = deepcopy(self.sample)
        request["data_classification"] = "restricted"
        with self.assertRaisesRegex(VALIDATOR.RequestError, "restricted"):
            VALIDATOR.validate(request)

    def test_network_profile_must_match_destination(self):
        request = deepcopy(self.sample)
        request["connectivity_profile"] = "corp"
        with self.assertRaisesRegex(VALIDATOR.RequestError, "corp destination"):
            VALIDATOR.validate(request)


if __name__ == "__main__":
    unittest.main()
