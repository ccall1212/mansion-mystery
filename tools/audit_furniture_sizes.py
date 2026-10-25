"""Inventory painted seats; missing measurements never imply size/placement approval."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
standards = json.loads((ROOT / 'assets/furniture/size-standards.json').read_text())
catalog = json.loads((ROOT / 'assets/furniture/catalog.json').read_text())
adult = json.loads((ROOT / 'assets/characters/rendering.json').read_text())['adult_height']
factor = adult / standards['reference_adult_height']
profiles = standards['profiles']
by_type = {p['furniture_type']: key for key, p in profiles.items()}
rows = []
for path in sorted((ROOT / 'assets/furniture/layouts').glob('*.json')):
    layout = json.loads(path.read_text())
    for item in layout['instances']:
        kind = catalog['variants'][item['variant_id']]['type']
        if kind not in by_type:
            continue
        profile_id = item.get('size_profile_id', by_type[kind])
        row = dict(layout=layout['id'], background=layout['background'],
                   instance_id=item['id'], orientation_id=item['variant_id'],
                   size_profile_id=profile_id, review=item.get('size_review', 'unmeasured'),
                   findings=[])
        measurements = item.get('size_measurements', {})
        if profile_id not in profiles:
            row['findings'].append('Unknown size profile')
        elif not measurements:
            row['findings'].append('Measure floor reference, seat contact, usable width and depth')
        else:
            profile = profiles[profile_id]
            values = {key: measurements.get(key) for key in ['seat_width', 'seat_depth']}
            floor, seat = measurements.get('floor_reference'), measurements.get('seat_contact')
            values['seat_above_floor'] = floor[1] - seat[1] if floor and seat else None
            unit_factor = layout['coordinate_size'][0] / standards['coordinate_size'][0]
            for key, value in values.items():
                target = profile[key] * factor * unit_factor
                if value is None:
                    row['findings'].append('Missing ' + key)
                elif abs(value - target) > target * standards['tolerance_fraction']:
                    row['findings'].append(f'{key}: {value:g}; target {target:g} ±15% (review projection)')
            if kind == 'bar_stool' and not measurements.get('footrest_contact'):
                row['findings'].append('Missing stool footrest contact')
        row['result'] = 'needs_measurement_or_review' if row['findings'] else 'within_target_band_fit_still_requires_review'
        rows.append(row)
output = ROOT / 'test-results/furniture-size-audit.json'
output.parent.mkdir(exist_ok=True)
output.write_text(json.dumps(dict(reference_adult_height=adult, seats=rows), indent=2)+'\n')
print(f'{len(rows)} annotated seats inventoried; {sum(bool(r["findings"]) for r in rows)} need measurements/review. No artwork or anchors changed.')
print(output)
