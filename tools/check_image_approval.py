"""Read-only preflight for explicit image approval before promotion/integration."""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def check(record, root=ROOT):
    approval = record.get('image_approval', {})
    if approval.get('status') != 'approved':
        raise ValueError('Explicit image approval is missing or pending.')
    evidence = approval.get('evidence', {})
    if not all(evidence.get(key) for key in ('date', 'source', 'quote')):
        raise ValueError('Approval needs a date and explicit user evidence.')
    if not approval.get('scope') or not approval.get('files'):
        raise ValueError('Approval needs its scope and exact reviewed files.')
    seen = set()
    for item in approval['files']:
        path = (root / item['path'].removeprefix('res://')).resolve()
        if not path.is_relative_to(root.resolve()) or path in seen:
            raise ValueError('Approval paths must be unique and inside the project.')
        seen.add(path)
        if not path.is_file():
            raise ValueError('Approved file is missing: ' + item['path'])
        if hashlib.sha256(path.read_bytes()).hexdigest() != item.get('sha256'):
            raise ValueError('Approved file has changed: ' + item['path'])
    return len(seen)


def main():
    if len(sys.argv) != 2:
        raise SystemExit('Usage: python tools/check_image_approval.py <manifest.json>')
    try:
        record = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))
        count = check(record)
    except (ValueError, OSError, KeyError, TypeError) as exc:
        raise SystemExit('IMAGE_APPROVAL_BLOCKED: ' + str(exc)) from exc
    print(json.dumps({'ok': True, 'approved_files_verified': count,
                      'scope': 'explicit recorded image approval; not runtime fit'}))


if __name__ == '__main__':
    main()
