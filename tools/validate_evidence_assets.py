"""Metadata-only QA; raster art is generated with imagegen and exported by Godot."""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def main():
    manifest = json.loads((ROOT / 'assets/objects/object-manifest.json').read_text(encoding='utf-8'))
    paths = []
    for definition in manifest['definitions'].values():
        for variant in definition['conditions'].values():
            paths += [(variant['asset'], (32,40)), (variant['closeup'], (160,160))]
    paths += [(f['inset'], (160,160)) for f in manifest['forensics'].values() if f['inset']]
    records = []
    for reference, dimensions in paths:
        path = ROOT / reference.removeprefix('res://')
        with Image.open(path) as image:
            assert image.mode == 'RGBA' and image.size == dimensions, path
            alpha = image.getchannel('A')
            assert set(alpha.tobytes()) == {0,255}, path
            records.append({'file':reference, 'size':list(image.size), 'mode':image.mode,
                            'opaque_bounds':alpha.getbbox(), 'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
    sheet = ROOT / 'assets/objects/review/object-contact-sheet.png'
    assert sheet.is_file()
    with Image.open(sheet) as image:
        assert image.size == (1040,96+180*len(manifest['definitions']))
        # A missing-texture capture produces white squares; detect that regression.
        rgb = image.convert('RGB')
        assert sum(pixel == (255,255,255) for pixel in rgb.get_flattened_data()) < image.width * image.height // 10
    behavior = json.loads((ROOT/'test-results/evidence-engine-tests.json').read_text())
    rendered = json.loads((ROOT/'test-results/evidence-playtest.json').read_text())
    assert behavior['ok'] and rendered['ok']
    report = {'ok':True, 'generator':'built-in imagegen', 'identities':len(manifest['definitions']),
              'physical_variants':sum(len(d['conditions']) for d in manifest['definitions'].values()),
              'runtime_pngs':len(records), 'planned_catalog_entries':len(manifest['expansion_catalog']),
              'engine_checks':behavior['checks'], 'rendered_checks':rendered['checks'], 'assets':records}
    (ROOT/'assets/objects/review/asset-checks.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k != 'assets'}))


if __name__ == '__main__':
    main()
