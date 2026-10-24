"""Add draft side-view contacts without resetting hand-calibrated front anchors."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OPPOSITE = {'north': 'south', 'south': 'north', 'east': 'west', 'west': 'east'}


def update(layout, catalog):
    added = 0
    for item in layout['instances']:
        variant = catalog['variants'][item['variant_id']]
        if variant['type'] not in ['window', 'painting', 'clock']:
            continue
        x, y, w, h = item['bounds']
        front = item['anchors'][0]
        target = [x + w / 2, y + h * .35]
        front.setdefault('gaze_target', target)
        if variant['type'] == 'window' and 'look_up' not in front['activities']:
            front['activities'].append('look_up')
        existing = {a['id'] for a in item['anchors']}
        for template in variant['anchors']:
            side = template.get('interaction_side')
            if not side or template['id'] in existing:
                continue
            if side in ['east', 'west']:
                point = [x - 16 if side == 'west' else x + w + 16, front['contact'][1]]
                approach = [point[0] + (-12 if side == 'west' else 12), front['approach'][1]]
            else:
                point = [front['contact'][0], y - 16 if side == 'north' else y + h + 16]
                approach = [front['approach'][0], point[1] + (-12 if side == 'north' else 12)]
            ox, oy = item['position']
            cw, ch = layout['coordinate_size']
            in_bounds = all(0 <= ox + p[0] < cw and 0 <= oy + p[1] < ch for p in [point, approach])
            item['anchors'].append(dict(id=template['id'], enabled=in_bounds,
                contact=point, approach=approach, actor_facing=OPPOSITE[side],
                posture='standing', activities=['inspect', 'look_up'], contact_kind='feet',
                clearance=[-12, -8, 24, 16], interaction_side=side, gaze_target=target,
                visual_review='pending', notes='Draft side viewing position; review access, gaze, skirt and occlusion. Outside-image contacts stay disabled.'))
            item['ready_for_staging'] = False
            added += 1
    return added


def main():
    catalog = json.loads((ROOT / 'assets/furniture/catalog.json').read_text(encoding='utf-8'))
    total = 0
    for path in sorted((ROOT / 'assets/furniture/layouts').glob('*.json')):
        layout = json.loads(path.read_text(encoding='utf-8'))
        before = json.dumps(layout, sort_keys=True)
        total += update(layout, catalog)
        if json.dumps(layout, sort_keys=True) != before:
            path.write_text(json.dumps(layout, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({'added_side_contacts': total, 'artwork_changed': False, 'staging_approved': False}))


if __name__ == '__main__':
    main()
