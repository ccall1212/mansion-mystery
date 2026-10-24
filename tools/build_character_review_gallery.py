"""Validate the naming catalog and assemble a local gallery of existing PNGs.

No art editing, generation, network requests, or runtime asset replacement.
"""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import re
from pathlib import Path
from urllib.parse import quote

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]


def relative_url(path: Path, review: Path) -> str:
    import os

    return quote(Path(os.path.relpath(path, review)).as_posix(), safe="/.")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--review", default="review-v5")
    args = parser.parse_args()
    assert re.fullmatch(r"review-v[0-9]+", args.review), "Invalid review folder"
    review = ROOT / "assets/characters" / args.review
    catalog = json.loads((review / "cast-catalog.json").read_text(encoding="utf-8"))
    people = json.loads((ROOT / "assets/characters/likeness-identities.json").read_text(encoding="utf-8"))
    entries = catalog["entries"]
    total = catalog.get("expected_numbered_designs", 19)
    expected_numbers = catalog.get("expected_review_numbers", [f"{i:02d}" for i in range(1, total + 1)])
    assert len(entries) == total and len(set(expected_numbers)) == total
    assert [e["number"] for e in entries] == expected_numbers
    assert len({e["identity_id"] for e in entries}) == total
    photo_count = sum(e["group"] == "photo-based" for e in entries)
    people_by_id = {person["id"]: person for person in people["identities"]}
    photo_ids = {e["identity_id"] for e in entries if e["group"] == "photo-based"}
    assert len(photo_ids) == photo_count and photo_ids.issubset(people_by_id)
    aliases: dict[str, str] = {}
    for person in people["identities"]:
        for alias in person["aliases"]:
            assert alias not in aliases, f"Alias assigned twice: {alias}"
            aliases[alias] = person["id"]
    pairs = [
        ("photo-04-I", "photo-01"), ("photo-04-M", "photo-03-A"),
        ("photo-04-K", "photo-03-F"), ("photo-04-C", "photo-03-D"),
        ("photo-04-D", "photo-03-B"), ("photo-04-F", "photo-04-C"),
        ("photo-04-G", "photo-04-H"), ("photo-03-E", "photo-02"),
        ("photo-05-man-left", "photo-03-E"),
    ]
    assert all(aliases[a] == aliases[b] for a, b in pairs)
    selected: dict[str, dict] = {}
    variant_count = 0
    assigned_names = catalog.get("assigned_names", {})
    for entry in entries:
        if assigned_names:
            assert entry["name"] == assigned_names.get(entry["number"]), "Name differs from the supplied mapping."
            if entry["group"] == "photo-based":
                assert entry["name"] == people_by_id[entry["identity_id"]]["name"]
        else:
            assert entry["name"] is None, "Names must be supplied by the user."
        for variant in entry["variants"]:
            variant_count += 1
            source = variant["source"]
            assert source.startswith("res://")
            path = (ROOT / source.removeprefix("res://")).resolve()
            path.relative_to(ROOT)
            with Image.open(path) as image:
                image.load()
                width, height = image.size
                if "crop_grid" in variant:
                    cols, rows, index = variant["crop_grid"]
                    assert cols > 0 and rows > 0 and 0 <= index < cols * rows
                if "crop_rect" in variant:
                    x, y, w, h = variant["crop_rect"]
                    assert x >= 0 and y >= 0 and w > 0 and h > 0
                    assert x + w <= width and y + h <= height
                if "panel_crop" in variant:
                    x, y, w, h = variant["panel_crop"]
                    assert min(x, y) >= 0 and min(w, h) > 0
                    assert x + w <= 1 and y + h <= 1
                if variant.get("transparent"):
                    assert image.mode == "RGBA"
                    low, high = image.getchannel("A").getextrema()
                    assert low == 0 and high >= 128
                selected[source] = {
                    "size": [width, height], "mode": image.mode,
                    "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                }
    assert variant_count == catalog.get("expected_variant_views", 27)
    sheets = {}
    max_slot = max(e.get("overview_slot", i) for i, e in enumerate(entries))
    overview_rows = (max_slot + 5) // 5
    variant_rows = (sum(len(e["variants"]) > 1 for e in entries) + 2) // 3
    for name, expected in [("current-cast-overview.png", (1500, 76 + overview_rows * 350 + 39)), ("same-person-variants.png", (1500, 76 + variant_rows * 440 + 44))]:
        with Image.open(review / name) as image:
            image.load()
            assert image.size == expected
            sheets[name] = {"size": list(image.size), "sha256": hashlib.sha256((review / name).read_bytes()).hexdigest()}

    masters = sorted((ROOT / "assets/characters/masters").glob("*.png"))
    for folder in sorted((ROOT / "assets/characters").glob("review-*/masters")):
        masters.extend(sorted(folder.glob("*.png")))
    masters.extend([ROOT / "assets/foyer/investigator-sheet.png", ROOT / "assets/foyer/eleanor-sheet.png"])
    archive = []
    for path in masters:
        url = relative_url(path, review)
        caption = path.relative_to(ROOT).as_posix()
        archive.append(f'<figure><a href="{url}"><img loading="lazy" src="{url}" alt="{html.escape(path.stem, quote=True)}"></a><figcaption>{html.escape(caption)}</figcaption></figure>')
    table = "".join(f'<tr><td>{e["number"]}</td><td>{html.escape(e["label"])}</td><td>{html.escape(e["name"]) if e["name"] else "—"}</td></tr>' for e in entries)
    names_pending = any(e["name"] is None for e in entries)
    document = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Sleuth — character naming review</title><style>
body{margin:auto;max-width:1500px;padding:24px;background:#1c272d;color:#d8d9d0;font:16px/1.5 system-ui,sans-serif}h1,h2,summary{color:#dfc895}a{color:#c7ddd9}.sheet{width:100%;height:auto}section{margin:32px 0}table{border-collapse:collapse;width:100%;max-width:900px}td,th{padding:8px 12px;border:1px solid #607075;text-align:left}.archive{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:18px}figure{margin:0;background:#2a383e;padding:12px}figure img{width:100%;height:330px;object-fit:contain}figcaption{overflow-wrap:anywhere;font-size:13px}summary{cursor:pointer;font-size:20px;padding:15px 0}
</style><h1>Sleuth — character naming review</h1>
<p>Confirmed duplicate appearances share one number and name. User-supplied names are shown; unassigned characters remain unnamed. Additional poses follow the appearance review.</p>
<section><h2>Current cast</h2><a href="current-cast-overview.png"><img class="sheet" src="current-cast-overview.png" alt="Numbered current cast"></a></section>
<section><h2>Existing alternate looks of the same people</h2><a href="same-person-variants.png"><img class="sheet" src="same-person-variants.png" alt="Alternate appearances sharing the same review number"></a></section>
<section><h2>Character names</h2><p>Supplied names are saved below. Blank entries remain unnamed.</p><table><tr><th>Number</th><th>Current identifier</th><th>Your name</th></tr>''' + table + '''</table></section>
<details><summary>All generated character masters and earlier versions (''' + str(len(masters)) + ''')</summary><p>This archive preserves earlier versions. Use the numbered current cast above for naming.</p><div class="archive">''' + "".join(archive) + '''</div></details></html>'''
    (review / "all-character-art.html").write_text(document, encoding="utf-8")
    report = {
        "technical_passed": True, "numbered_designs": total, "photo_based_identities": photo_count,
        "variant_views": variant_count, "same_person_cards": sum(len(e["variants"]) > 1 for e in entries),
        "identity_merge_checks": len(pairs), "unique_alias_assignments": True,
        "selected_source_files": selected, "review_sheets": sheets,
        "archive_master_count": len(masters), "gallery": "all-character-art.html",
        "names_pending": names_pending, "named_designs": sum(e["name"] is not None for e in entries),
        "photo_based_names_complete": all(e["name"] is not None for e in entries if e["group"] == "photo-based"),
        "final_cast_approved": False, "new_base_characters": catalog.get("new_base_characters", 0),
        "new_action_pose_sets_generated": False,
        "gameplay_integration_tested": False,
    }
    (review / "draft-file-checks.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({key: report[key] for key in ["technical_passed", "numbered_designs", "photo_based_identities", "variant_views", "same_person_cards", "archive_master_count", "names_pending"]}))


if __name__ == "__main__":
    main()
