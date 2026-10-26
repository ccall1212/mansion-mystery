"""Prepare the runner's reviewable catalog and Chris queue; never generate art.

Run from the repository root. Writes only new runner-owned planning files.
Existing art, approval records, manifests and catalogs are read-only inputs.
"""
import hashlib
import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[4]


def read(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def write_new(path, data):
    target = ROOT / path
    if target.exists():
        raise RuntimeError(f"Reconcile existing runner file before replacing: {path}")
    target.parent.mkdir(parents=True, exist_ok=True)
    text = json.dumps(data, indent=2) + "\n" if not isinstance(data, str) else data
    target.write_text(text, encoding="utf-8")


def main():
    now = datetime.now(timezone.utc).isoformat()
    char_root = "assets/characters/poses/char"
    index = read(f"{char_root}/directional-index.json")
    reference_records = list(index["assets"])
    for path in (ROOT / char_root / "metadata").rglob("*.json"):
        record = json.loads(path.read_text(encoding="utf-8"))
        if isinstance(record, dict) and record.get("export"):
            reference_records.append(record)

    specs = [
        (1,"standing","idle","neutral","NESW","Hands in trouser pockets; relaxed planted stance."),
        (1,"standing","talk","friendly","NESW","One hand gestures openly, other in pocket or on hip."),
        (1,"standing","look_down","neutral","ESW","Attentive downward inspection; upright, hands relaxed."),
        (1,"standing","cross_arms","suspicious","NESW","Arms folded, feet apart; skeptical expression."),
        (1,"standing","deny","defensive","ESW","One hand at back of neck, other on hip; cap stays on."),
        (1,"standing","startle","surprised","ESW","Step back with hands raised, no hand on heart."),
        (1,"standing","accuse","defiant","S","Point accusingly and defiantly."),
        (1,"standing","cry","remorseful","S","Remorseful sobbing with one hand covering or rubbing face."),
        (1,"standing","laugh","evil","S","Triumphant laugh, head back, one hand on lapel or hip."),
        (1,"standing","threaten","furious","S","Furious threat, clenched fist, step forward."),
        (1,"standing","shrug","resigned","S","Palms up, shoulders raised, tired resignation."),
        (2,"standing","fidget","nervous","NESW","Biting fingernails, other hand on hip; cap stays on."),
        (2,"standing","hands_hips","confident","NESW","Hands on hips, wide stance, chest out."),
        (2,"standing","think","curious","NESW","Stroke chin or jaw, other arm across body."),
        (2,"standing","withdraw","sad","ESW","Head down, hands in pockets, shoulders slumped."),
        (2,"standing","clasp_hands","friendly","ESW","Hands clasped behind back, relaxed and cheerful."),
        (3,"seated","idle","neutral","NESW","Legs crossed, arms resting; establish seat contact."),
        (3,"seated","read","neutral","NESW","Crossed legs, reading open book; preserve seated-idle contact."),
        (3,"standing","hold_book","neutral","NESW","Hold closed book, independently authored facing."),
        (3,"standing","read","neutral","NESW","Read open book with appropriate gaze and grip."),
        (3,"standing","look_up","neutral","NESW","Attentive upward gaze."),
        (3,"standing","reach_table","neutral","ESW","Reach at table height, not overhead."),
        (3,"kneeling","reach","neutral","ESW","Kneel and reach naturally; male clothing and visible legs."),
        (3,"standing","lean","resting","S","Shoulder on invisible wall, ankles crossed, hands in pockets."),
        (3,"seated","sleep","napping","ESW","Arms folded, head tilted, legs extended with ankles crossed."),
    ]
    names = {"N":"north","E":"east","S":"south","W":"west"}
    entries = []

    def append(tier, posture, activity, variant, direction=None, axis=None, head=None, male=None):
        pose_id = f"{posture}_{activity}_" + (direction or f"{axis}_head_{head}")
        group = direction or "lying"
        relative = f"{char_root}/exports/{group}/char_{pose_id}_{variant}.png"
        path = ROOT / relative
        source = None
        source_status = "not_generated"
        dimensions = [1536,1024] if axis == "east_west" else ([1024,1536] if axis else [944,1665])
        if path.exists():
            matches = [r for r in reference_records if r.get("export") == relative]
            if not matches:
                raise RuntimeError(f"Export has no owning reference record: {relative}")
            matched = matches[0]
            expected = matched.get("export_sha256")
            if expected and expected != sha(relative):
                # Several legacy replacement records still name a revision export
                # subdirectory, while the live export is flattened. Resolve only
                # an exact recorded replacement hash, never invent new approval.
                replacements = [r for r in reference_records
                    if r.get("pose_id") == pose_id and r.get("variant_id") == variant
                    and r.get("supersedes") and r.get("export_sha256") == sha(relative)]
                if not replacements:
                    raise RuntimeError(f"Reference hash conflict without recorded replacement: {relative}")
                matched = replacements[0]
            source = relative
            source_status = matched.get("approval","unknown") + "_export"
            dimensions = list(Image.open(path).size)
        elif posture == "seated" and activity == "sleep":
            draft = f"{char_root}/drafts/seated-nap-01/char_{pose_id}_{variant}.png"
            if (ROOT / draft).exists():
                source = draft
                dimensions = list(Image.open(ROOT / draft).size)
                jobs = read(f"{char_root}/batches/seated-nap-01.json")["jobs"]
                job = next(j for j in jobs if j["direction"] == direction)
                if sha(draft) != job["sha256"]:
                    raise RuntimeError(f"Reviewed nap candidate changed: {draft}")
                source_status = job["artwork_status"] + "_candidate"
        entries.append({"pose_id":pose_id,"posture":posture,"activity":activity,
            "variant_id":variant,"directions":[direction] if direction else [],
            "body_axis":axis,"head_direction":head,"tier":tier,"reuse_from":None,
            "source_char_asset":source,"source_char_status":source_status,"canvas":dimensions,
            "female_template":"Use Char's matching action and gesture; preserve character identity.",
            "male_template":male or "Same action with male body and own clothing; preserve contacts.",
            "planned_source_missing":source is None})

    for tier,posture,activity,variant,directions,male in specs:
        for direction in directions:
            append(tier,posture,activity,variant,names[direction],male=male)
    for axis,head in [("north_south","north"),("east_west","east"),("east_west","west")]:
        append(3,"lying","idle","awake",axis=axis,head=head,male="One arm behind head, other relaxed; compact hair; cap stays on.")
        append(3,"lying","sleep","peaceful",axis=axis,head=head,male="Arms on chest or draped, sleeping, relaxed limbs; cap stays on.")
    append(3,"lying","lounge","napping",axis="north_south",head="north",male="Half-reclined sofa nap, relaxed bent legs; no sofa drawn; cap stays on.")

    # Only the runner's named Tier 4 activities, using exact active-contact directions.
    # Generic standing_reach is not added: explicit table/kneeling reaches already exist.
    inventory = read("assets/characters/poses/pose-requirements.json")
    allowed = {"kneeling_inspect","seated_talk","seated_write","standing_drink",
               "standing_inspect","standing_look_out","standing_peek","standing_warm_hands"}
    for item in inventory["concrete_poses"]:
        family,direction = item["id"].rsplit("_",1)
        if family not in allowed:
            continue
        posture,activity = family.split("_",1)
        append(4,posture,activity,"friendly" if activity == "talk" else "neutral",direction)
        entries[-1]["source_contacts"] = item["source_contacts"]
        entries[-1]["generation_hold"] = "Char same-pose source missing; define and review geometry before this tier."

    keys = [(e["pose_id"],e["variant_id"]) for e in entries]
    assert len(keys) == len(set(keys)) == 100
    exports = {p.relative_to(ROOT).as_posix() for p in (ROOT/char_root/"exports").glob("*/*.png")}
    assert exports == {e["source_char_asset"] for e in entries if e["source_char_status"].endswith("_export")}
    chris = read("assets/characters/poses/chris/production-manifest.json")
    for item in chris["image_approval"]["files"]:
        assert sha(item["path"]) == item["sha256"],item["path"]

    roster = read("assets/characters/review-v8/cast-catalog.json")
    male = {"Chris","Kwinn","Justin","Danny","Gage","Robbie","Matt","John"}
    order = ["Chris","Kwinn","Justin","Danny","Gage","Robbie","Matt","John",
             "Char","Sarah Jo","Chloe","Camille","Carolyn","Isabelle","Jessica"]
    characters = []
    for item in roster["entries"]:
        name = item.get("name")
        characters.append({"character_id":item["identity_id"],"review_number":item["number"],
            "name":name or item["label"],"slug":name.lower().replace(" ","-") if name else None,
            "template_proposal":"male" if name in male else ("female" if name else "unassigned"),
            "height_ratio":item.get("height_ratio",1),"target_images":len(entries),
            "proposed_order":order.index(name)+1 if name in order else None,
            "production_eligibility":"approved_base" if name in ["Chris","Char","Sarah Jo"] else "needs_base_approval_or_selection",
            "new_pose_approval":"not_requested","pool_membership":"pending_final_pool_selection",
            "identity_reference":chris["canonical_reference"] if name == "Chris" else item["variants"][0]})
    catalog={"schema_version":1,"authoring_only":True,"status":"awaiting_user_catalog_confirmation",
        "prepared":now,"source":"Claude observations/CODEX_POSE_PRODUCTION_RUNNER_PROMPT.md",
        "counts_by_tier":dict(sorted(Counter(e["tier"] for e in entries).items())),
        "unique_images_per_character":100,"core_images_per_character":81,"tier4_images_per_character":19,
        "aliases":[{"pose_id":"standing_listen_"+d,"reuse_from":"standing_idle_"+d,"variant_id":"neutral","new_image":False} for d in names.values()],
        "exclusions":["Chris hat removal and head scratch", "Walking animations", "Unspecified extra north-facing emotions", "Generic extra standing reaches beyond explicit table and kneeling reach"],
        "characters":characters,"entries":entries,
        "caps":{"unreviewed_per_character":24,"unreviewed_global":60},
        "confirmation_pending":["100-image catalog including 19 held Tier 4 entries", "Chris-first order and later cast selection", "24/60 caps"],
        "canonical_chris_already_confirmed":True,
        "notes":["17 cataloged designs are not a finalized ten-character playable pool.",
                 "Char's 78 exports include legacy user-supplied and reference-only approval states; preserve those states, not blanket approval.",
                 "Legacy flattened Char exports sometimes differ from the old index; exact replacement metadata hashes resolve them. Historical revision export subpaths may be absent; no source records were rewritten.",
                 "Chris's earlier unapproved-look exception is obsolete; anime v2 is explicitly approved.",
                 "Runtime adult stature is 80 world units; historical 64-unit prose is superseded.",
                 "Canvas size is not stature. Chris's approved native 948x1659 is not to be stretched to Char's canvas.",
                 "An approved alpha maximum of 254 exists in lying references; do not modify approved bytes to force 255. New draft checks must report exact alpha and limitations."]}
    write_new("assets/characters/pose-catalog.json",catalog)

    approved={(a["pose_id"],a["variant_id"]):a for a in chris["approved_assets"]}
    first=["standing_idle_south","standing_cross_arms_south","standing_fidget_south",
           "standing_idle_east","standing_idle_west","standing_idle_north"]
    ordered=sorted(entries,key=lambda e:(0,first.index(e["pose_id"])) if e["pose_id"] in first else (e["tier"],e["pose_id"]))
    queue=[]
    for e in ordered:
        existing=approved.get((e["pose_id"],e["variant_id"]))
        queue.append({"queue_id":f"chris-{e['pose_id']}-{e['variant_id']}",
            "pose_id":e["pose_id"],"variant_id":e["variant_id"],"direction":e["directions"][0] if e["directions"] else None,
            "body_axis":e["body_axis"],"head_direction":e["head_direction"],"tier":e["tier"],
            "status":"imported" if existing else "queued","draft_path":None,"attempts":0,"checks":None,"prompt":None,
            "approved_export":existing["path"] if existing else None,
            "notes":"Existing approved anime v2; do not regenerate." if existing else (e.get("generation_hold") or "Awaiting initial catalog confirmation."),"updated":now})
    write_new("assets/characters/poses/chris/queue.json",queue)
    counts=Counter(e["status"] for e in queue)
    pending=[e for e in queue if e["status"]=="queued"]
    write_new("docs/pose-production/STATUS.md",f"""# Pose production status

Prepared 2026-10-26. Branch: `art/pose-production`. No runner images generated yet.

Catalog: 100 unique images per character: Tier 1 = 26, Tier 2 = 18,
Tier 3 = 37, Tier 4 = 19. Listening aliases add no images.

Chris: 1 imported approved south idle; 99 queued (80 core, 19 held Tier 4).
Canonical model: larger-eyed anime v2, gray cap on, red shirt, charcoal vest,
black trousers and boots. Smaller-eyed v3 is rejected.

Char: 78 exports with mixed approval states; three seated-nap candidates (two approved, west pending).
19 Tier 4 source poses remain unmade. No existing art or metadata was changed.

Other bases: Sarah Jo has documented approval; other named bases need explicit
approval reconciliation before generation. Active catalog has 17 designs, not
a finalized playable pool. Proposed order is in pose-catalog.json.

Caps: 24 unreviewed per character / 60 global, including prior pending candidates.
Legacy Chris model candidates are pending/rejected alternatives, not completed queue
poses. Reconcile their review status before counting available generation slots.

Next five new Chris jobs:
"""+"\n".join("- `"+e["pose_id"]+" / "+e["variant_id"]+"`" for e in pending[:5])+"\n\nInitial catalog confirmation is required by the runner's FIRST ACTION before generation.\n")
    write_new("docs/pose-production/QUESTIONS.md","""# Production decisions pending

- Confirm the 100-image catalog (81 core plus 19 Tier 4 contact-derived poses),
  Chris-first proposed order, and 24/60 draft caps. Chris's canonical v2 identity
  is already explicitly approved in this conversation; do not ask again.
- Final playable pool is not selected: 17 cataloged designs versus about ten intended.
  Later cast generation can wait; this does not block the Chris pass after confirmation.
- Tier 4 has no matching Char art. Hold those entries until their geometry/reference
  scope is established; do not invent duplicate reaches or pretend references exist.
- Other named character bases need approval reconciliation. Selected catalog views
  alone do not establish final model approval.
- Existing Chris model color experiments remain pending alternatives; do not turn
  them into approvals or silently delete them. Count prior pending assets toward caps.
- Char's export records include user_supplied_added_to_project and reference_only
  states. These are not blanket explicit artwork approvals; preserve the distinctions.
""")
    write_new("docs/pose-production/HANDOFF.md","""# Pose production handoff

2026-10-26: Prepared shared pose-catalog.json and Chris queue.json from current
Char exports/metadata, runner tiers and contact-derived Tier 4 requirements.
No images generated by this runner yet. No source artwork or shared character
manifests altered. No gameplay, research or Claude-owned documents changed.

Chris's approved model is poses/chris/masters/model-review-01/chris-model-v2.png;
the older selected-hat-pair outfit and smaller-eyed v3 are not production authority.

Current checkout is on art/pose-production, with pre-existing unrelated uncommitted
work preserved. A branch alone is not checkout isolation: other assistants must not
switch this shared checkout's branch or include these files in unrelated commits.
Use separate checkouts if concurrently committing. No commit or push was performed.

Resume by checking catalog confirmation and actual files before generating. Review
gallery will be created and opened when new runner candidates exist. Existing model
approval does not approve new poses. Furniture/runtime fit is still unverified.
""")
    print(json.dumps({"images_per_character":len(entries),"tiers":catalog["counts_by_tier"],
        "cataloged_designs":len(characters),"chris_queue":dict(counts),"first_new_jobs":[e["pose_id"] for e in pending[:5]]}))


if __name__ == "__main__":
    main()
