from tests.conftest import auth_headers

INITIAL_PROFILE = {
    "label": "Deck & processing",
    "nationality": "Ukrainian",
    "english_level": "intermediate",
    "years_of_experience": "4",
    "experience_is_approximate": True,
    "target_positions": ["AB", "Deckhand", "Trawl Deckhand", "Fish Factory Worker",
                         "Processing Crew"],
    "experience_areas": ["Krill factory operations", "Fish processing", "Holdman duties"],
}


def test_profile_crud_and_primary(client):
    h = auth_headers("u1")
    assert client.get("/api/v1/profiles/primary", headers=h).status_code == 404

    r = client.post("/api/v1/profiles", json=INITIAL_PROFILE, headers=h)
    assert r.status_code == 201, r.text
    first = r.json()
    assert first["is_primary"] is True  # first profile becomes primary automatically
    assert first["experience"] == []

    second = client.post("/api/v1/profiles", json={"label": "AB only"}, headers=h).json()
    assert second["is_primary"] is False

    r = client.patch(f"/api/v1/profiles/{second['id']}", json={"is_primary": True}, headers=h)
    assert r.json()["is_primary"] is True
    assert client.get("/api/v1/profiles/primary", headers=h).json()["id"] == second["id"]

    r = client.patch(f"/api/v1/profiles/{first['id']}", json={"summary": "Updated"}, headers=h)
    assert r.json()["summary"] == "Updated"
    assert r.json()["nationality"] == "Ukrainian"  # untouched fields preserved

    assert client.delete(f"/api/v1/profiles/{second['id']}", headers=h).status_code == 204
    # Deleting the primary promotes the remaining profile.
    assert client.get("/api/v1/profiles/primary", headers=h).json()["id"] == first["id"]


def test_experience_without_invented_dates(client):
    h = auth_headers("u2")
    profile = client.post("/api/v1/profiles", json=INITIAL_PROFILE, headers=h).json()
    r = client.post(f"/api/v1/profiles/{profile['id']}/experience", headers=h, json={
        "vessel_name": "M/V More Sodruzhestva",
        "duties": ["Krill factory operations", "Deck maintenance"],
    })
    assert r.status_code == 201, r.text
    exp = r.json()
    assert exp["start_date"] is None and exp["end_date"] is None

    bad = client.put(f"/api/v1/profiles/{profile['id']}/experience/{exp['id']}", headers=h,
                     json={"start_date": "2024-05-01", "end_date": "2023-01-01"})
    assert bad.status_code == 422

    full = client.get(f"/api/v1/profiles/{profile['id']}", headers=h).json()
    assert full["experience"][0]["vessel_name"] == "M/V More Sodruzhestva"


def test_validation(client):
    h = auth_headers("u3")
    r = client.post("/api/v1/profiles", headers=h,
                    json={"english_level": "native-ish", "years_of_experience": -1})
    assert r.status_code == 422


def test_users_cannot_see_each_others_profiles(client):
    alice, bob = auth_headers("alice"), auth_headers("bob")
    profile = client.post("/api/v1/profiles", json=INITIAL_PROFILE, headers=alice).json()

    assert client.get(f"/api/v1/profiles/{profile['id']}", headers=bob).status_code == 404
    assert client.patch(f"/api/v1/profiles/{profile['id']}", json={"summary": "x"},
                        headers=bob).status_code == 404
    assert client.delete(f"/api/v1/profiles/{profile['id']}", headers=bob).status_code == 404
    assert client.post(f"/api/v1/profiles/{profile['id']}/experience", json={},
                       headers=bob).status_code == 404
    assert client.get("/api/v1/profiles", headers=bob).json() == []


def test_export_and_account_deletion(client):
    h = auth_headers("leaver")
    client.post("/api/v1/profiles", json=INITIAL_PROFILE, headers=h)
    export = client.get("/api/v1/me/export", headers=h).json()
    assert len(export["profiles"]) == 1

    assert client.delete("/api/v1/me", headers=h).status_code == 204
    # The same identity signing in again starts from an empty account.
    assert client.get("/api/v1/profiles", headers=h).json() == []
