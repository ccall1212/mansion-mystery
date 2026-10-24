"""Build four original, reviewable door graphs and asset compatibility reports."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/mansion"
SIDES = {(1, 0): ("east", "west"), (-1, 0): ("west", "east"),
         (0, 1): ("south", "north"), (0, -1): ("north", "south")}


def build():
    manifest = json.loads((ROOT / "assets/rooms/room-manifest.json").read_text(encoding="utf-8"))
    art = {r["id"]: r for r in manifest["rooms"]}
    names = ["West Hall House", "East Hall House", "Central Study House", "North Landing House"]
    # Four functional rooms and two circulation/stair spaces per floor.
    patterns = [
        {0: [["foyer",0,0],["library",1,0],["main_stair",0,1],["service_stair",1,1],["dining",0,2],["kitchen",1,2]],
         1: [["master",0,0],["guest_a",1,0],["main_stair",0,1],["service_stair",1,1],["bath",0,2],["guest_b",1,2]],
         -1:[["wine",0,0],["archive",1,0],["main_stair",0,1],["service_stair",1,1],["utility",0,2],["stores",1,2]]},
        {0: [["library",1,0],["foyer",2,0],["service_stair",1,1],["main_stair",2,1],["kitchen",1,2],["dining",2,2]],
         1: [["guest_a",1,0],["master",2,0],["service_stair",1,1],["main_stair",2,1],["guest_b",1,2],["bath",2,2]],
         -1:[["archive",1,0],["wine",2,0],["service_stair",1,1],["main_stair",2,1],["stores",1,2],["utility",2,2]]},
        {0: [["kitchen",0,0],["foyer",1,0],["library",2,0],["main_stair",0,1],["dining",1,1],["service_stair",2,1]],
         1: [["master",0,0],["guest_a",1,0],["bath",2,0],["main_stair",0,1],["study",1,1],["service_stair",2,1]],
         -1:[["wine",0,0],["utility",1,0],["stores",2,0],["main_stair",0,1],["archive",1,1],["service_stair",2,1]]},
        {0: [["main_stair",0,0],["foyer",1,0],["service_stair",2,0],["library",0,1],["dining",1,1],["kitchen",2,1]],
         1: [["main_stair",0,0],["study",1,0],["service_stair",2,0],["master",0,1],["bath",1,1],["guest_a",2,1]],
         -1:[["main_stair",0,0],["archive",1,0],["service_stair",2,0],["wine",0,1],["utility",1,1],["stores",2,1]]},
    ]
    labels = {"foyer":("Foyer","existing-foyer"), "library":("Library","library"),
              "dining":("Dining room",None), "kitchen":("Kitchen",None),
              "master":("Master bedroom","guest-bedroom"),"guest_a":("Guest bedroom A","guest-bedroom"),
              "guest_b":("Guest bedroom B","guest-bedroom"),"bath":("Bathroom",None),
              "study":("Study","library"),"wine":("Wine cellar",None),
              "archive":("Records archive","library"),"utility":("Utility room",None),"stores":("Store room",None)}
    plans = []
    for index, pattern in enumerate(patterns):
        rooms, links = [], []
        by_floor = {}
        for floor, cells in pattern.items():
            prefix = {0:"g",1:"u",-1:"b"}[floor]
            floor_rooms = {}
            for key,x,y in cells:
                if key.endswith("stair"):
                    shaft=key.removesuffix("_stair")
                    name=("Main hall" if shaft=="main" else "Service passage") if floor==0 else ("Main landing" if shaft=="main" else "Service landing")
                    asset="dark-stairwell"
                    role="passage"
                else:
                    name,asset=labels[key]; role="room"
                item={"id":prefix+"_"+key,"name":name,"floor":floor,"grid":[x,y],
                      "asset_type":asset,"role":role,"contains_stairs":key.endswith("stair"),"gameplay_ready":False}
                rooms.append(item); floor_rooms[x,y]=item
            by_floor[floor]=floor_rooms
            for (x,y),r in floor_rooms.items():
                for delta in [(1,0),(0,1)]:
                    at=(x+delta[0],y+delta[1])
                    if at not in floor_rooms: continue
                    other=floor_rooms[at]
                    # Upper bedrooms/bathrooms open to circulation or the shared study,
                    # rather than creating a mandatory route through private bedrooms.
                    if floor==1 and not (r['role']=='passage' or other['role']=='passage' or r['id']=='u_study' or other['id']=='u_study'):
                        continue
                    pa,pb=SIDES[delta]
                    kind="archway" if r['role']==other['role']=="passage" else "door"
                    links.append({"id":r['id']+"--"+other['id'],"kind":kind,
                                  "a":{"room":r['id'],"port":pa},"b":{"room":other['id'],"port":pb}})
        for shaft in ["main","service"]:
            for floor in [1,-1]:
                a="g_"+shaft+"_stair";b={1:"u",-1:"b"}[floor]+"_"+shaft+"_stair"
                pa,pb=("up","down") if floor==1 else ("down","up")
                links.append({"id":a+"--"+b,"kind":"stairs","shaft":shaft,
                              "a":{"room":a,"port":pa},"b":{"room":b,"port":pb}})
        boundaries=[{"id":"locked-front-door","room":"g_foyer","port":"north",
                     "locked":True,"traversable":False,"outside_destination":None}]
        for r in rooms:
            ports = sorted({e[side]["port"] for e in links for side in ["a", "b"] if e[side]["room"] == r["id"]})
            r["traversable_ports"] = ports.copy()
            if r["id"] == "g_foyer":
                ports = sorted(set(ports) | {"north"})
                r["locked_ports"] = ["north"]
            r["ports"] = ports
            r["asset_candidates"] = []
            if r["asset_type"] == "existing-foyer":
                r["asset_candidates"] = [{"id": "original-foyer", "asset": "res://assets/foyer/foyer-background.png",
                                           "missing_ports": sorted(set(ports) - {"north", "south"}),
                                           "stair_direction_gap": False}]
            elif r["asset_type"] in art:
                for v in art[r["asset_type"]]["variants"]:
                    present = set()
                    for direction in v["entrance_directions"]:
                        if direction in {"north", "south", "east", "west"}:
                            present.add(direction)
                    # Existing stair art is an ascent OR a descent, never a full three-level landing.
                    stair_gap = ("up" in ports and v["id"].endswith("basement")) or ("down" in ports and not v["id"].endswith("basement"))
                    missing = sorted(set(ports) - present - {"up", "down"})
                    r["asset_candidates"].append({"id": v["id"], "asset": v["asset"],
                                                   "missing_ports": missing, "stair_direction_gap": stair_gap})
            r["art_status"] = "new-room-art-required" if not r["asset_candidates"] else "existing-reference-needs-port-review"
        plans.append({"id": f"manor-{index + 1}", "name": names[index], "status": "blueprint-review",
                      "start_room": "g_foyer", "start_entry_port": "north", "grid_size": [3, 3],
                      "boundaries": boundaries, "per_floor_counts": {str(f): {"rooms": 4, "hallways": 2} for f in [-1,0,1]},
                      "rooms": rooms, "links": links})
    result = {"schema_version": 2, "status": "proposed-blueprints; not playable room geometry",
              "floors": [{"id": -1, "name": "Basement"}, {"id": 0, "name": "Ground floor"}, {"id": 1, "name": "Upper floor"}],
              "selection": "new game chooses a seeded template and stable per-room asset references; never reroll on re-entry",
              "source_basis": "User connectivity sketch and supplied original-game screenshots; original proposed layouts, not decoded DOS maps.",
              "blueprints": plans}
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "blueprints.json").write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    gaps = ["# Mansion blueprint art requirements", "",
            "Four proposed layouts are the source of truth for required exits. The",
            "existing art is a reference selection, not a claim that these doors already",
            "exist. No backgrounds were redrawn for this blueprint milestone.", "",
            "## Compact first-playable scope", "",
            "Each floor has four rooms and two hallways/landings, with stairs integrated into those hallways.",
            "The north foyer door is a locked boundary. There is no exterior playable room or escape link.",
            "Target a short deduction slice first; 10-15 minutes is a playtest goal, not a measured duration.",
            "A clue book for examined objects and collected items is planned separately.", "",
            "## Shared additions", "",
            "- Kitchen, dining room, bathroom, utility/store room and wine-cellar art.",
            "- Compact hallway and landing variants with the exact paired doorway positions.",
            "- Three-level main/service stair landings: current ascent and descent images each show only one flight.",
            "- Distinct foyer side exits for each template; preserve the current playable foyer until those are built.",
            "- Separate door/foreground layers and safe arrival positions after the blueprints are approved.", "",
            "## Per-template port review", ""]
    for plan in plans:
        gaps += [f'### {plan["name"]}', "", "| Room | Floor | Required ports | Best existing reference | Needed |", "| --- | --- | --- | --- | --- |"]
        for r in plan["rooms"]:
            candidates = r["asset_candidates"]
            best = min(candidates, key=lambda c: len(c["missing_ports"]) + 100 * int(c["stair_direction_gap"])) if candidates else None
            needed = "New room art" if not best else ", ".join(best["missing_ports"]) or "No cardinal port gap; collision/scale review still required"
            if best and best["stair_direction_gap"]:
                needed += "; matching stair flight / landing"
            gaps.append(f'| {r["name"]} ({r["id"]}) | {r["floor"]} | {", ".join(r["ports"])} | {best["id"] if best else "—"} | {needed} |')
        gaps.append("")
    (ROOT / "docs/MANSION_ASSET_REQUIREMENTS.md").write_text("\n".join(gaps), encoding="utf-8")
    print(json.dumps({"templates": len(plans), "rooms": [len(p["rooms"]) for p in plans], "links": [len(p["links"]) for p in plans]}))


if __name__ == "__main__":
    build()
