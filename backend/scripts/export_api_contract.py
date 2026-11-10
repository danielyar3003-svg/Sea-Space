"""Capture real API responses (against the TEST database) for the Flutter contract test.

Usage (from backend/): uv run python scripts/export_api_contract.py ../app/test/fixtures/api_contract.json
"""
import json
import os
import sys

sys.path.insert(0, os.getcwd())
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient

import tests.conftest as cf  # sets env (test DB, HS256 secret)
from app.main import create_app

cfg = Config("alembic.ini")
command.downgrade(cfg, "base")
command.upgrade(cfg, "head")
c = TestClient(create_app())
h = cf.auth_headers("contract-user")
A = "/api/v1"
co = c.post(f"{A}/companies", headers=h, json={"name": "Contract Fishing AS", "country_code": "NO",
     "industries": ["krill"], "websites": [{"url": "https://contract.example/"}]}).json()
c.post(f"{A}/companies/{co['id']}/notes", headers=h, json={"body": "Note"})
c.post(f"{A}/companies/{co['id']}/contacts", headers=h, json={"email": "crew@contract.example",
       "contact_kind": "generic_inbox", "source_url": "https://contract.example/jobs"})
types = c.get(f"{A}/vessel-types", headers=h).json()
v = c.post(f"{A}/vessels", headers=h, json={"name": "MV Contract", "imo_number": "9074729",
           "vessel_type_id": types[0]["id"]}).json()
c.post(f"{A}/vessels/{v['id']}/links", headers=h, json={"company_id": co["id"], "role": "operator"})
c.post(f"{A}/vacancies", headers=h, json={"employer_name": "Contract Fishing AS", "position": "AB",
       "source_url": "https://contract.example/jobs/1", "salary_min": "3000", "currency": "EUR",
       "salary_period": "monthly", "application_deadline": "2099-01-01"})
app = c.post(f"{A}/applications", headers=h, json={"company_id": co["id"], "position": "AB"}).json()
app = c.patch(f"{A}/applications/{app['id']}", headers=h,
              json={"status": "sent", "status_note": "CV sent", "follow_up_in_days": 7}).json()
dup = c.post(f"{A}/companies", headers=h, json={"name": "Contract Fishing", "country_code": "DK"})
out = {
  "companies": c.get(f"{A}/companies", headers=h).json(),
  "company_detail": c.get(f"{A}/companies/{co['id']}", headers=h).json(),
  "contacts": c.get(f"{A}/contacts", headers=h).json(),
  "vessel_types": types,
  "vessels": c.get(f"{A}/vessels", headers=h).json(),
  "vacancies": c.get(f"{A}/vacancies", headers=h).json(),
  "targets": c.get(f"{A}/discovery/targets", headers=h).json(),
  "duplicate_error": {"status": dup.status_code, "body": dup.json()},
  "dashboard": c.get(f"{A}/dashboard/summary", headers=h).json(),
  "primary_profile": c.post(f"{A}/profiles", headers=h, json={"label": "P", "english_level": "intermediate",
                            "years_of_experience": "4"}).json(),
  "health": c.get("/health/ready").json(),
  "application_detail": app,
  "board": c.get(f"{A}/applications/board", headers=h).json(),
  "stats": c.get(f"{A}/applications/stats", headers=h).json(),
  "follow_ups": c.get(f"{A}/follow-ups", headers=h).json(),
  "timeline": c.get(f"{A}/companies/{co['id']}/timeline", headers=h).json(),
  "me": c.get(f"{A}/me", headers=h).json(),
}
command.downgrade(cfg, "base")
command.upgrade(cfg, "head")
json.dump(out, open(sys.argv[1], "w"), indent=1, default=str)
print("ok", {k: (len(v) if isinstance(v, list) else "obj") for k, v in out.items()})
