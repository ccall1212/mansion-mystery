"""Validate saved environment files and assemble a local review gallery."""
from __future__ import annotations

import hashlib
import html
import json
import os
from pathlib import Path
from urllib.parse import quote

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ROOMS = ROOT / "assets/rooms"
REVIEW = ROOMS / "review"


def file_for(resource: str) -> Path:
    assert resource.startswith("res://assets/rooms/")
    result = (ROOT / resource.removeprefix("res://")).resolve()
    result.relative_to(ROOMS)
    assert result.is_file(), result
    return result


def url(path: Path) -> str:
    return quote(Path(os.path.relpath(path, REVIEW)).as_posix(), safe="/.")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    data = json.loads((ROOMS / "room-manifest.json").read_text(encoding="utf-8"))
    assert len(data["rooms"]) == 9 and data["expected_backgrounds"] == 18
    layouts = [v for room in data["rooms"] for v in room["variants"]]
    assert len(layouts) == len({v["asset"] for v in layouts}) == 18
    results = []
    sections = []
    roster = [
        "# Mansion room roster", "",
        "Nine environments, each with two distinct layouts (18 separate backgrounds).",
        "All runtime backgrounds are opaque 480 x 320 PNGs, matching the preserved",
        "foyer region. Higher-resolution 3:2 masters are in assets/rooms/masters.",
        "Entrance directions describe observed artwork, not implemented door triggers.",
        "", "| Room | Purpose | Layout A | Layout B | Required before playable |",
        "| --- | --- | --- | --- | --- |",
    ]
    for room in data["rooms"]:
        figures = []
        for v in room["variants"]:
            path = file_for(v["asset"])
            master = file_for(v["master"])
            file_for(v["prompt"])
            with Image.open(path) as image:
                assert image.size == (480, 320)
                assert image.convert("RGBA").getchannel("A").getextrema() == (255, 255)
                colors = image.convert("RGB").getextrema()
                assert max(high - low for low, high in colors) > 50
            with Image.open(master) as image:
                assert image.width * 2 == image.height * 3
                assert image.convert("RGBA").getchannel("A").getextrema() == (255, 255)
                master_size = list(image.size)
            captures = []
            for zoom in [1, 2]:
                capture = ROOT / f"test-results/environments/{v['id']}-{zoom}x.png"
                with Image.open(capture) as image:
                    assert image.size == (480, 360)
                captures.append({"zoom": zoom, "path": capture.relative_to(ROOT).as_posix(), "sha256": sha(capture)})
            results.append({
                "id": v["id"], "asset": path.relative_to(ROOT).as_posix(),
                "runtime_size": [480, 320], "master_size": master_size,
                "opaque": True, "asset_sha256": sha(path), "master_sha256": sha(master),
                "captures": captures,
            })
            caption = f"{room['number']:02d}{v['layout']} — {room['name']} / {v['label']}"
            figures.append(
                f'<figure><a href="{url(master)}"><img src="{url(path)}" alt="{html.escape(caption)}"></a>'
                f'<figcaption><strong>{html.escape(caption)}</strong><br>'
                f'Entrances: {html.escape(", ".join(v["entrance_directions"]))}<br>'
                f'<a href="{url(path)}">Native PNG</a> · <a href="{url(master)}">Master</a> · '
                f'<a href="{url(file_for(v["prompt"]))}">Prompt</a> · '
                f'<a href="{url(ROOT / captures[0]["path"])}">Engine 1×</a> · '
                f'<a href="{url(ROOT / captures[1]["path"])}">Engine 2×</a></figcaption></figure>'
            )
        sections.append(f'<section><h2>{room["number"]:02d} / {html.escape(room["name"])}</h2><p>{html.escape(room["purpose"])}</p><div class="pair">{"".join(figures)}</div></section>')
        a, b = room["variants"]
        roster.append(f'| {room["number"]:02d} {room["name"]} | {room["purpose"]} | [{Path(a["asset"]).name}](../{a["asset"].removeprefix("res://")}) — {", ".join(a["entrance_directions"])} | [{Path(b["asset"]).name}](../{b["asset"].removeprefix("res://")}) — {", ".join(b["entrance_directions"])} | {room["collision_requirements"]} |')
    assert len({r["asset_sha256"] for r in results}) == 18, "Duplicate background export"
    for prop in data.get("props", []):
        path = file_for(prop["asset"])
        file_for(prop["master"])
        with Image.open(path) as image:
            assert image.size == tuple(prop["size"])
            assert image.mode == "RGBA" and image.getchannel("A").getextrema() == (0, 255)
    for name, size in [
        ("environment-contact-sheet.png", (1440, 2204)),
        ("environment-layouts-a.png", (1440, 1154)),
        ("environment-layouts-b.png", (1440, 1154)),
    ]:
        with Image.open(REVIEW / name) as image:
            assert image.size == size
    engine = json.loads((ROOT / "test-results/environments/engine-review.json").read_text(encoding="utf-8"))
    assert engine["ok"] and engine["capture_count"] == 36 and engine["layout_count"] == 18
    report = {
        "technical_passed": True, "rooms": 9, "layouts": 18,
        "runtime_size": [480, 320], "engine_capture_size": [480, 360],
        "engine_captures": 36, "source_and_runtime_paths_verified": True,
        "unique_backgrounds": True, "gameplay_navigation_tested": False,
        "generated_with": "built-in imagegen", "technical_export": "Godot nearest sampling",
        "assets": results,
    }
    (REVIEW / "asset-checks.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    document = """<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Sleuth — Mansion environment review</title><style>
body{background:#101a21;color:#c7d1cf;font:16px/1.5 system-ui;margin:auto;max-width:1480px;padding:24px}h1,h2,strong{color:#dfc895}a{color:#c2dcdf}
.pair{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:20px}figure{margin:0;padding:12px;background:#1c2c34}figure img{width:100%;height:auto;image-rendering:pixelated}figcaption{padding:10px 0}section{margin:32px 0}.sheet{width:100%;height:auto}@media(max-width:800px){.pair{grid-template-columns:1fr}}
</style><h1>Sleuth / Mansion environments</h1>
<p>Nine rooms, two layouts each. Click a room image for its source master. No characters are baked into these backgrounds.</p>
<p>Native backgrounds: 480 × 320. Engine previews: 480 × 360 with the original 48-pixel investigator and 47-pixel Eleanor. These are art previews; collisions, doors and house connections remain to be authored.</p>
<p>Built-in imagegen artwork; prompts are linked per layout. Earlier library and bright-window exterior tests remain archived.</p>
<p><a href="engine-actors-1x.png">All native engine previews</a> · <a href="engine-actors-2x.png">All close engine previews</a></p>
""" + "".join(sections) + '<section><h2>All 18 layouts</h2><a href="environment-contact-sheet.png"><img class="sheet" src="environment-contact-sheet.png" alt="All 18 environment layouts"></a></section></html>'
    (REVIEW / "environment-gallery.html").write_text(document, encoding="utf-8")
    roster.extend([
        "", "## Integration boundary", "",
        "Open src/environments/environment_review.tscn for engine art review.",
        "1-9 select a room, V switches its layout, arrows browse all layouts, Z toggles",
        "1x/2x, A toggles comparison actors and P toggles separate props.",
        "The library evidence book is a separate visual prop, not an implemented clue.",
        "The main playable foyer and its original files are preserved. New background",
        "assets are registered for loading; no gameplay transitions or collision data",
        "are invented. Trace geometry, split occluding props, and validate one connected",
        "room before expanding the playable house.", "",
    ])
    (ROOT / "docs/ROOM_ROSTER.md").write_text("\n".join(roster), encoding="utf-8")
    print(json.dumps({key: report[key] for key in ["technical_passed", "rooms", "layouts", "engine_captures"]}))


if __name__ == "__main__":
    main()
