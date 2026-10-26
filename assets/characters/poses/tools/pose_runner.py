"""Durable Chris draft jobs, non-destructive technical QA and local review gallery.

No image synthesis or image editing is performed here. Generation uses imagegen.
"""
import argparse
import hashlib
import html
import json
import shutil
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[4]
BASE = ROOT / "assets/characters/poses/chris"
QUEUE = BASE / "queue.json"
CATALOG = ROOT / "assets/characters/pose-catalog.json"
MODEL = "assets/characters/poses/chris/masters/model-review-01/chris-model-v2.png"


def now():
    return datetime.now(timezone.utc).isoformat()


def read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_suffix(path.suffix + ".tmp")
    temp.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    temp.replace(path)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def legacy_pending():
    model_hash = digest(ROOT / MODEL)
    results = []
    for image in (BASE / "drafts/model-review-01").glob("*.png"):
        record = read(image.with_suffix(".json")) if image.with_suffix(".json").exists() else {}
        if digest(image) != model_hash and record.get("approval") not in ["approved","rejected","superseded"]:
            results.append(image)
    return results


def render(queue):
    cards = []
    approved = BASE / "south/chris_standing_idle_south_neutral.png"
    assert approved.is_file()
    cards.append(f'<article><h2>Approved identity / south idle</h2><img src="../south/{approved.name}" alt="Approved Chris model"><p>Approved anime v2. This does not approve new poses.</p></article>')
    for item in sorted(queue, key=lambda item: ({"draft": 0, "needs_help": 0, "approved": 2, "changes_requested": 3}.get(item["status"], 4), -datetime.fromisoformat(item["updated"]).timestamp() if item.get("updated") else 0)):
        if item["status"] in ["changes_requested", "rejected", "superseded", "skipped"] or not item.get("draft_path"):
            continue
        image = ROOT / item["draft_path"]
        assert image.is_file()
        relative = "../" + image.relative_to(BASE).as_posix()
        checks = item.get("checks") or {}
        summary = f"{checks.get('canvas')} · alpha {checks.get('alpha_extrema')} · height {checks.get('occupied_height')} / 1564 · {item['status']}"
        cards.append(f'<article><h2>Tier {item["tier"]}: {html.escape(item["pose_id"])}</h2><img src="{html.escape(relative)}" alt="{html.escape(item["pose_id"])}"><p>{html.escape(image.name)}</p><p>{html.escape(summary)}</p><p>{html.escape(item.get("notes") or "")}</p></article>')
    for image in legacy_pending():
        relative = "../" + image.relative_to(BASE).as_posix()
        cards.append(f'<article><h2>Earlier model alternative / pending</h2><img src="{html.escape(relative)}" alt="Earlier Chris model option"><p>{html.escape(image.name)}</p><p>Counts toward backlog. Not the production identity.</p></article>')
    page = '''<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Chris pose production review</title><style>
body{font:16px system-ui;background:#202730;color:#f4f1e9;margin:24px}main{display:grid;grid-template-columns:repeat(auto-fit,minmax(270px,1fr));gap:20px}article{background:#34404b;border:1px solid #66737d;border-radius:9px;padding:16px}h2{font-size:17px}img{width:100%;height:460px;object-fit:contain;background:#9aa0a2;border-radius:4px}p{font-size:13px;overflow-wrap:anywhere}header{max-width:1000px;margin-bottom:24px}</style><header><h1>Chris / pose production</h1><p>New poses are drafts pending user approval. Gray backgrounds are viewer backing, not part of the PNG. Compare the approved identity with each candidate. Furniture and runtime fit remain unverified.</p></header><main>'''+"\n".join(cards)+"</main></html>"
    target = BASE / "review/index.html"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(page, encoding="utf-8")
    counts = Counter(i["status"] for i in queue)
    backlog = len(legacy_pending()) + sum(i["status"] in ["draft","needs_help","generating"] for i in queue)
    next_items = [i for i in queue if i["status"] == "queued"][:5]
    status = "# Pose production status\n\nUpdated "+now()+". Branch: `art/pose-production`.\n\n"
    status += "Catalog confirmed by user: “Approved. Continue”. 100 poses per character; Chris first.\n\n"
    status += f"Chris queue: {dict(counts)}. Unreviewed Chris backlog: {backlog}/24, including {len(legacy_pending())} earlier model alternatives. Global cap: 60.\n\n"
    status += "Canonical identity: approved larger-eyed anime v2, gray cap, red shirt, charcoal vest, black trousers and boots.\n\n"
    status += "Review: [Chris gallery](../../assets/characters/poses/chris/review/index.html). New poses are not approved or runtime integrated.\n\nNext five:\n"
    status += "\n".join("- `"+i["pose_id"]+" / "+i["variant_id"]+"`" for i in next_items)
    status += "\n\nRemaining holds: 19 Tier 4 matching Char references unmade; later cast bases and final playable pool require approval reconciliation. Furniture contacts and in-game scale/readability remain unverified.\n"
    (ROOT / "docs/pose-production/STATUS.md").write_text(status, encoding="utf-8")
    return backlog


def prepare(pose_id=None):
    catalog = read(CATALOG)
    assert catalog["status"] == "confirmed_for_draft_production"
    manifest = read(BASE / "production-manifest.json")
    assert digest(ROOT / MODEL) == manifest["canonical_reference"]["sha256"]
    queue = read(QUEUE)
    assert not any(i["status"] == "generating" for i in queue), "Recover current generating job before starting another"
    assert len(legacy_pending()) + sum(i["status"] in ["draft","needs_help"] for i in queue) < 24, "Character backlog cap reached"
    global_pending = {p.resolve() for p in legacy_pending()}
    for qp in (ROOT / "assets/characters/poses").glob("*/queue.json"):
        for job in read(qp):
            if job.get("status") in ["draft","needs_help"] and job.get("draft_path"):
                global_pending.add((ROOT/job["draft_path"]).resolve())
    # Existing Char batch candidates are counted once by actual file path.
    for bp in (ROOT/"assets/characters/poses/char/batches").glob("*.json"):
        for job in read(bp).get("jobs",[]):
            if job.get("artwork_status") == "pending_review" and job.get("path"):
                global_pending.add((ROOT/job["path"]).resolve())
    assert len(global_pending) < 60, "Global backlog cap reached"
    item = next(i for i in queue if i["status"] == "queued" and (pose_id is None or i["pose_id"] == pose_id))
    spec = next(e for e in catalog["entries"] if e["pose_id"] == item["pose_id"] and e["variant_id"] == item["variant_id"])
    assert spec["tier"] < 4 and spec["source_char_asset"], "Matching Char source not available"
    references = [MODEL,spec["source_char_asset"]]
    for reference in references:
        assert (ROOT / reference).is_file(),reference
    direction = item["direction"]
    orientation = {"south":"toward viewer (SOUTH)","east":"screen RIGHT (EAST)","west":"screen LEFT (WEST)","north":"AWAY from viewer (NORTH), showing his BACK"}.get(direction, "lying on body axis "+str(item["body_axis"])+", head "+str(item["head_direction"]))
    prompt = f"""Create ONE separate full-body transparent PNG game character pose of CHRIS, {item['pose_id']}, variant {item['variant_id']}.
REFERENCE 1 is Chris's USER-APPROVED canonical model: preserve this exact identity, male adult body proportions, common head scale and drawing scale. REFERENCE 2 is Char's SAME-POSE composition/expression reference ONLY. Do not copy her face, feminine body, outfit, hair, jewelry or hand gesture where the male override differs.
IDENTITY LOCK: expressive larger blue anime eyes exactly like approved Chris v2, simplified softly shaded nose/face, full brown beard and connected moustache, brown brows, gray tweed flat cap KEPT ON. No cap removal or head scratching. RED collared shirt with rolled sleeves and small cream undershirt at throat, CHARCOAL textured waistcoat with brass buttons, gold watch chain on his anatomical LEFT waist (screen-right in south view), black tailored trousers and BLACK lace-up boots. Preserve asymmetric pocket/chain construction across directions with natural occlusion, never move it to another anatomical side to make it visible. Same richly shaded outlined anime/cartoon game rendering with deliberate crisp detail, no photoreal skin or tiny chibi anatomy.
POSE: {spec['male_template']}
EXPRESSION: {item['variant_id']}. Communicate it through eyes/brows/mouth and posture where visible. Suspicious does not mean furious. Nervous is anxious uncertainty, not crying or terror. Neutral has relaxed brows and a small closed-mouth friendly expression where face is visible.
FACING: whole body faces {orientation}. Head/chest/hips/knees/boots agree. North must show actual back, no over-shoulder face. Elevated three-quarter mansion camera showing a little crown and shoulder tops. Independently draw this direction; NEVER mirror/flip another pose.
SCALE/FRAMING: reference 1 has native 948x1659 canvas and occupied standing height 1564 pixels. Keep that SAME character drawing scale and comparable portrait canvas. Reference 2's native canvas {spec['canvas']} supplies pose composition, not stature. Full standing figure about 1564 pixels tall, within 4 percent, comfortably inside transparent margins on all sides; no cropping. Do not resize a seated/kneeling pose to standing height. Both shoes visible.
OUTPUT: exactly ONE complete character with actual PNG alpha transparency (empty outside silhouette), complete arms/hands/legs/hat/boots, clean margins and gaps. No furniture, chair, floor, scenery, shadow, glow, text, labels, borders, grid or extra character. Any book is allowed only when required by the named action. Return only this image; draft production, not approval.
"""
    item["status"]="generating"
    item["attempts"]+=1
    item["prompt"]=prompt
    item["references"]=[{"path":r,"sha256":digest(ROOT/r)} for r in references]
    item["updated"]=now()
    item["notes"]="Draft production authorized; pending actual image generation and QA."
    write(QUEUE,queue)
    attempt=item["attempts"]
    filename=f"chris_{item['pose_id']}_{item['variant_id']}"+(f"_r{attempt}" if attempt>1 else "")+".png"
    target=BASE/(item.get("direction") or item["head_direction"])/filename
    assert not target.exists(), "Existing candidate must not be overwritten"
    spec_path=BASE/"prompts/runner-01"/(filename.removesuffix(".png")+".json")
    write(spec_path,{"queue_id":item["queue_id"],"prompt":prompt,"references":item["references"],"tool":"built-in image_gen","transparent_background":True,"draft_destination":target.relative_to(ROOT).as_posix(),"status":"prepared","prepared":now()})
    print(json.dumps({"queue_id":item["queue_id"],"prompt":prompt,"references":[str(ROOT/r) for r in references],"target":str(target)}))


def finish(source):
    queue=read(QUEUE)
    item=next(i for i in queue if i["status"]=="generating")
    attempt=item["attempts"]
    filename=f"chris_{item['pose_id']}_{item['variant_id']}"+(f"_r{attempt}" if attempt>1 else "")+".png"
    target=BASE/(item.get("direction") or item["head_direction"])/filename
    assert not target.exists()
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(source,target)
    image=Image.open(target)
    assert image.format=="PNG"
    alpha=image.getchannel("A") if image.mode=="RGBA" else None
    bounds=alpha.point(lambda p:255 if p>=128 else 0).getbbox() if alpha else None
    corners=[alpha.getpixel(p) for p in [(0,0),(image.width-1,0),(0,image.height-1),(image.width-1,image.height-1)]] if alpha else []
    occupied_height=bounds[3]-bounds[1] if bounds else 0
    standing=item["pose_id"].startswith("standing_")
    checks={"format":image.format,"canvas":list(image.size),"alpha_extrema":list(alpha.getextrema()) if alpha else None,"solid_bounds":list(bounds) if bounds else None,
        "corner_alpha":corners,"occupied_height":occupied_height,
        "standing_height_ratio":round(occupied_height/1564,4) if standing else None,
        "standing_height_within_four_percent":abs(occupied_height/1564-1)<=.04 if standing else None,
        "canvas_within_one_percent_of_reference":abs(image.width/948-1)<=.01 and abs(image.height/1659-1)<=.01,
        "solid_pixels_clear_of_edges":bool(bounds and bounds[0]>0 and bounds[1]>0 and bounds[2]<image.width and bounds[3]<image.height),
        "alpha_present":alpha is not None and alpha.getextrema()[0]==0 and alpha.getextrema()[1]>=254,
        "maximum_alpha_255":alpha is not None and alpha.getextrema()[1]==255,
        "opaque_fraction":round(sum(alpha.histogram()[128:])/(image.width*image.height),4) if alpha else 1}
    errors=[]
    for key in ["alpha_present","maximum_alpha_255","solid_pixels_clear_of_edges"]:
        if not checks[key]:errors.append(key)
    if corners!=[0,0,0,0]:errors.append("nonempty_corner")
    if standing and not checks["standing_height_within_four_percent"]:errors.append("standing_height")
    if checks["opaque_fraction"]>.8:errors.append("possible_large_opaque_background")
    checks["warnings"]=[] if checks["canvas_within_one_percent_of_reference"] else ["Native canvas differs; source pixels preserved. Common export canvas/pivot alignment remains pending; stature checked separately."]
    checks["technical_pass"]=not errors
    checks["errors"]=errors
    item["draft_path"]=target.relative_to(ROOT).as_posix()
    item["checks"]=checks
    item["status"]="draft" if not errors else "needs_help"
    item["updated"]=now()
    item["notes"]="Technical checks complete; visual QA pending. Furniture and runtime fit unverified."
    write(target.with_suffix(".json"),{"queue_id":item["queue_id"],"pose_id":item["pose_id"],"variant_id":item["variant_id"],"direction":item["direction"],"tier":item["tier"],"status":item["status"],"approval":"pending_user_review","tool":"built-in image_gen","prompt":item["prompt"],"references":item["references"],"path":item["draft_path"],"sha256":digest(target),"checks":checks,"runtime_integrated":False,"created":now()})
    write(QUEUE,queue)
    backlog=render(queue)
    print(json.dumps({"queue_id":item["queue_id"],"draft_path":str(target),"checks":checks,"backlog":backlog}))


def visual(pose_id,note):
    queue=read(QUEUE)
    item=next(i for i in queue if i["pose_id"]==pose_id)
    assert item.get("draft_path")
    item["notes"]=note+" Furniture and runtime fit unverified."
    item["visual_qa"]={"inspected":True,"note":note,"user_approval":"pending","date":now()}
    item["updated"]=now()
    record_path=(ROOT/item["draft_path"]).with_suffix(".json")
    record=read(record_path)
    record["visual_qa"]=item["visual_qa"]
    record["notes"]=item["notes"]
    write(record_path,record)
    write(QUEUE,queue)
    print(json.dumps({"backlog":render(queue),"visual_qa_recorded":pose_id}))


if __name__=="__main__":
    parser=argparse.ArgumentParser()
    sub=parser.add_subparsers(dest="command",required=True)
    p=sub.add_parser("prepare");p.add_argument("--pose")
    p=sub.add_parser("finish");p.add_argument("source")
    p=sub.add_parser("visual");p.add_argument("pose");p.add_argument("note")
    sub.add_parser("gallery")
    args=parser.parse_args()
    if args.command=="prepare":prepare(args.pose)
    elif args.command=="finish":finish(args.source)
    elif args.command=="visual":visual(args.pose,args.note)
    else: print(json.dumps({"backlog":render(read(QUEUE))}))
