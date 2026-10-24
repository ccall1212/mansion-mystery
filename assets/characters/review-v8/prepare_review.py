"""Record the requested v8 catalog changes; no raster editing."""
import copy
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]

def read(path):
    return json.loads(path.read_text(encoding="utf-8"))

def write(path, data):
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")

old = read(HERE.parent / "review-v7/cast-catalog.json")
catalog = copy.deepcopy(old)
removed = {"16", "17", "18", "19"}
catalog.update(
    version=8,
    status="Jessica-and-John-cartoon-revisions-awaiting-review",
    description="15 named photo-based people and two earlier game designs. Removed 16-19; original numbers retained.",
    expected_numbered_designs=17,
    expected_variant_views=24,
    new_base_characters=0,
    new_poses_authorized_after="Remaining appearance review followed by pose direction; Sarah Jo's short-hair look is approved.",
    overview_footer="Jessica and John: cartoon face review. Sarah Jo: look approved. 16-19 removed. Eleanor: proposed opening maid.",
)
catalog["removed_entries"] = [
    dict(entry, removal_reason="Removed from active cast at user request; preserved as earlier artwork.")
    for entry in catalog["entries"] if entry["number"] in removed
]
catalog["entries"] = [e for e in catalog["entries"] if e["number"] not in removed]
catalog["expected_review_numbers"] = [e["number"] for e in catalog["entries"]]
catalog["assigned_names"].update({"20": "Jessica", "21": "John"})
for entry in catalog["entries"]:
    number = entry["number"]
    if number == "13":
        entry["appearance_approved_by_user"] = True
        entry["review_note"] = "Short-hair look approved"
    if number == "15":
        entry["proposed_narrative_role"] = "Opening maid"
        entry["role_status"] = "Proposed by user; costume and gameplay integration pending."
        entry["review_note"] = "Proposed opening maid"
    if number in {"20", "21"}:
        name = catalog["assigned_names"][number]
        entry["name"] = name
        entry["overview_slot"] = 15 if number == "20" else 16
        entry.setdefault("archived_variants", []).extend(entry["variants"])
        entry["variants"] = [{
            "source": f"res://assets/characters/review-v8/masters/{name.lower()}-cartoon-v8.png",
            "transparent": True,
            "caption": "Cartoon face revision",
        }]
        entry["appearance_notes"] += " Cartoon face with large expressive eyes, simplified features and soft grouped shading, matching the established cast."
        entry["label"] = name + (" / short adult" if number == "20" else " / glasses and goatee")
        entry["review_note"] = "Petite adult / approx. 5 ft" if number == "20" else "Cartoon face / review pending"
write(HERE / "cast-catalog.json", catalog)

identity_path = HERE.parent / "likeness-identities.json"
identities = read(identity_path)
identities["version"] = 4
identities["status"] = "15-photo-based-people-named; remaining-appearance-review-pending"
identities["next_step"] = "Review Jessica and John's cartoon revisions with the remaining cast before further pose production; Sarah Jo's new look approved."
for person in identities["identities"]:
    person["preferred_art_catalog"] = "assets/characters/review-v8/cast-catalog.json"
    if person["review_number"] in {"20", "21"}:
        person["name"] = catalog["assigned_names"][person["review_number"]]
        person["appearance_notes"] += " Use cartoon facial features matching the established RPG cast, not realistic photo faces."
    if person["review_number"] == "13":
        person["appearance_approved_by_user"] = True
write(identity_path, identities)

manifest = {
    "version": 8, "status": catalog["status"],
    "identity_catalog": "../likeness-identities.json", "cast_catalog": "cast-catalog.json",
    "numbered_designs": 17, "photo_based_identities": 15, "active_variant_views": 24,
    "assigned_names": catalog["assigned_names"], "unnamed_review_numbers": ["14", "15"],
    "removed_review_numbers": sorted(removed), "numbering_preserved": True,
    "new_selected_art": ["masters/jessica-cartoon-v8.png", "masters/john-cartoon-v8.png"],
    "review_sheets": ["current-cast-overview.png", "same-person-variants.png"],
    "gallery": "all-character-art.html", "prompts": ["prompts/jessica-cartoon-v8.txt", "prompts/john-cartoon-v8.txt"],
    "generation_mode": "Built-in imagegen for Jessica and John face style edits; Godot for contact sheet composition.",
    "appearance_approved_review_numbers": ["13"], "proposed_opening_maid_review_number": "15",
    "review_height_ratio_20": 0.85, "runtime_replaced": False,
    "new_base_characters": 0, "new_action_pose_sets_generated": False, "final_cast_approved": False,
}
write(HERE / "review-manifest.json", manifest)

unchanged = []
for previous in old["entries"]:
    number = previous["number"]
    if number in removed or number in {"20", "21"}:
        continue
    current = next(e for e in catalog["entries"] if e["number"] == number)
    assert current["variants"] == previous["variants"]
    unchanged.append(number)
sarah = next(e for e in catalog["entries"] if e["number"] == "13")
sarah_path = ROOT / sarah["variants"][0]["source"].removeprefix("res://")
write(HERE / "change-checks.json", {
    "unchanged_art_selections": unchanged,
    "sarah_jo_preserved_sha256": hashlib.sha256(sarah_path.read_bytes()).hexdigest(),
    "removed_from_active_cast": sorted(removed), "original_art_preserved": True,
    "changed_art_review_numbers": ["20", "21"], "new_names": {"20": "Jessica", "21": "John"},
    "final_cast_approved": False,
})
print("Prepared 17-design v8 review; all 15 photo-based people named.")
