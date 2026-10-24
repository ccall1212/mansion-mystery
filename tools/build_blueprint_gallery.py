"""Build the offline blueprint review and record actual capture/test evidence."""
import hashlib
import html
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
REVIEW = ROOT / "assets/mansion/review"


def main():
    data = json.loads((ROOT / "assets/mansion/blueprints.json").read_text(encoding="utf-8"))
    engine = json.loads((ROOT / "test-results/mansion-engine-tests.json").read_text(encoding="utf-8"))
    assert engine["ok"]
    captures = []
    for plan in data["blueprints"]:
        for level in [-1, 0, 1]:
            path = REVIEW / f'{plan["id"]}-floor-{level}.png'
            with Image.open(path) as image:
                assert image.size == (1120, 700)
            captures.append({"path": path.name, "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
        with Image.open(REVIEW / f'{plan["id"]}-all-floors.png') as image:
            assert image.size == (1440, 420)
    with Image.open(REVIEW / "all-mansion-blueprints.png") as image:
        assert image.size == (1440, 1470)
    plans = [{key: plan[key] for key in ["id", "name"]} for plan in data["blueprints"]]
    options = "".join(f'<option value="{p["id"]}">{html.escape(p["name"])}</option>' for p in plans)
    document = """<!doctype html><html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Sleuth / Mansion blueprints</title>
<style>body{background:#0b1c29;color:#c9d8de;margin:auto;max-width:1440px;padding:24px;font:16px/1.5 system-ui}h1,h2{color:#dfc895}a{color:#a5d0d1}img{width:100%;height:auto}select,button{font:inherit;padding:8px 12px;background:#193344;color:#c9d8de;border:1px solid #63869a;margin:4px}button[aria-pressed=true]{background:#31556d}label{display:inline-flex;gap:10px;align-items:center;flex-wrap:wrap}.controls{display:flex;gap:18px;align-items:center;flex-wrap:wrap}</style>
<h1>Sleuth / Compact mansion blueprints</h1><p>Four layouts with four main rooms and two hallways per floor. Stairs are inside the hallways. The foyer's north/front door is locked; there is no outside route. Main and service stairs provide alternate routes between floors.</p>
<div class="controls"><label>Mansion <select id="plan">""" + options + """</select></label>
<div id="floors"><button data-floor="-1" aria-pressed="false">Basement</button><button data-floor="0" aria-pressed="true">Ground floor</button><button data-floor="1" aria-pressed="false">Upper floor</button></div></div>
<a id="detail-link" href="manor-1-floor-0.png"><img id="detail" src="manor-1-floor-0.png" alt="Selected mansion blueprint floor"></a>
<h2>All three floors</h2><img id="stack" src="manor-1-all-floors.png" alt="Basement, ground and upper floor of selected mansion">
<p>The engine review scene is <code>src/mansion/blueprint_review.tscn</code>: open it in Godot and press F6. Click rooms to inspect their art, use Enter to rehearse a route, and save/load to check remembered floors and return ports. The pictures above are captures, not live controls.</p>
<p><a href="../../../docs/MANSION_BLUEPRINTS.md">Design and controls</a> · <a href="../../../docs/MANSION_ASSET_REQUIREMENTS.md">Art and doorway requirements</a> · <a href="../blueprints.json">Blueprint data</a></p>
<p>Room walking, collision geometry and physical stair transitions are not implemented by these blueprints. New-game selection and logical floor/exit memory are implemented separately from the existing playable foyer.</p>
<h2>All four versions</h2><a href="all-mansion-blueprints.png"><img src="all-mansion-blueprints.png" alt="All four mansion blueprints with three floors each"></a>
<script>
const plan=document.getElementById('plan'),detail=document.getElementById('detail'),stack=document.getElementById('stack'),link=document.getElementById('detail-link');
let floor=0;
function update(){const path=plan.value+'-floor-'+floor+'.png';detail.src=path;link.href=path;stack.src=plan.value+'-all-floors.png';document.querySelectorAll('[data-floor]').forEach(b=>b.setAttribute('aria-pressed',Number(b.dataset.floor)===floor));}
plan.addEventListener('change',update);
document.querySelectorAll('[data-floor]').forEach(b=>b.addEventListener('click',()=>{floor=Number(b.dataset.floor);update();}));
</script></html>"""
    (REVIEW / "blueprint-gallery.html").write_text(document, encoding="utf-8")
    report = {"blueprints": 4, "floors_per_blueprint": 3,
              "room_counts": [len(p["rooms"]) for p in data["blueprints"]],
              "engine_checks_passed": engine["checks"], "engine_failures": engine["failures"],
              "captures": captures, "paired_shafts": ["main", "service"],
              "playable_room_transitions": False, "asset_references_are_provisional": True}
    (REVIEW / "blueprint-checks.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({k: report[k] for k in ["blueprints", "floors_per_blueprint", "room_counts", "engine_checks_passed"]}))


if __name__ == "__main__":
    main()
