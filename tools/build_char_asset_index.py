"""Build Char's human-readable asset browser from the existing approved index."""
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets/characters/poses/char'


def main():
    catalog = json.loads((BASE / 'directional-index.json').read_text(encoding='utf-8'))
    special = catalog.get('special_groups', {}).get('murderer_reveal', [])
    lines = ['<!doctype html><html lang="en"><meta charset="utf-8">',
        '<meta name="viewport" content="width=device-width, initial-scale=1"><title>Char — approved directional assets</title>',
        '<style>body{background:#17242b;color:#e7edf0;font:17px system-ui;margin:28px}a,h1,h2{color:#efd29a}nav{display:flex;gap:24px}.grid{display:flex;gap:24px;flex-wrap:wrap}article{background:#27343c;padding:18px;width:300px;border-radius:8px}img{max-width:100%;height:380px;object-fit:contain}code{overflow-wrap:anywhere}p{max-width:1000px}</style>',
        '<h1>Char — approved directional assets</h1>',
        '<p>81 pose artworks approved across the six export groups. Image pixels are unchanged. Folder organization and filenames now identify character, pose, direction and variant. Runtime contact alignment and furniture masks remain pending.</p>',
        '<nav>' + ''.join(f'<a href="#{d}">{d.title()}</a>' for d in catalog['direction_groups']) + ('<a href="#murderer-reveal">Murderer reveal</a>' if special else '') + '<a href="#lying">Laying</a></nav>',
        '<p><a href="review/alignment_01/index.html">Comparison and chair context review</a> · <a href="production-manifest.json">Production manifest</a> · <a href="directional-index.json">Asset metadata</a></p>']
    for direction in catalog['direction_groups']:
        lines.append(f'<h2 id="{direction}">{direction.title()}</h2><div class="grid">')
        for item in catalog['assets']:
            if item['actor_facing'] != direction or item['pose_id'] in special:
                continue
            path = Path(item['export']).relative_to(BASE.relative_to(ROOT)).as_posix()
            name = html.escape(Path(path).name)
            lines.append(f'<article><h3>{html.escape(item["pose_id"])}</h3><a href="{path}"><img src="{path}" alt="Char {html.escape(item["pose_id"])}"></a><p><code>{name}</code></p><p>Artwork approved · {html.escape(item.get("contact_kind") or item["variant_id"])}</p></article>')
        lines.append('</div>')
    if special:
        lines.append('<h2 id="murderer-reveal">Murderer reveal poses</h2><div class="grid">')
        for item in catalog['assets']:
            if item['pose_id'] not in special:
                continue
            path = Path(item['export']).relative_to(BASE.relative_to(ROOT)).as_posix()
            lines.append(f'<article><h3>{html.escape(item["pose_id"])}</h3><a href="{path}"><img src="{path}" alt="Char {html.escape(item["pose_id"])}"></a><p><code>{html.escape(Path(path).name)}</code></p><p>Artwork approved</p></article>')
        lines.append('</div>')
    lying = [item for item in catalog['assets'] if '/exports/lying/' in item.get('export', '')]
    if lying:
        lines.append('<h2 id="lying">Laying</h2><div class="grid">')
        for item in lying:
            path = Path(item['export']).relative_to(BASE.relative_to(ROOT)).as_posix()
            lines.append(f'<article><h3>{html.escape(item["pose_id"])}</h3><a href="{path}"><img src="{path}" alt="{html.escape(item["pose_id"])}"></a><p><code>{html.escape(Path(path).name)}</code></p><p>Artwork approved; furniture fit pending</p></article>')
        lines.append('</div>')
    lines.append('</html>')
    (BASE / 'index.html').write_text('\n'.join(lines), encoding='utf-8')
    print('Char asset browser: assets/characters/poses/char/index.html')


if __name__ == '__main__':
    main()
