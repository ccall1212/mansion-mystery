"""Read ZIPs as data; validate the entire archive before extracting anything."""
import hashlib
import re
import stat
import zipfile
from pathlib import Path, PurePosixPath


def inventory(archive: Path) -> dict:
    rows, seen, total = [], set(), 0
    with zipfile.ZipFile(archive) as z:
        if len(z.infolist()) > 4096:
            raise ValueError('Archive exceeds 4096 entries')
        for f in z.infolist():
            name = f.orig_filename
            parts = PurePosixPath(name).parts
            if (not parts or '\\' in name or ':' in name or name.startswith('/')
                    or any(p in ('.', '..') or p.endswith((' ', '.'))
                           or re.match(r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\.|$)', p, re.I)
                           or re.search(r'[\x00-\x1f<>"|?*]', p) for p in parts)
                    or stat.S_ISLNK(f.external_attr >> 16) or f.flag_bits & 1):
                raise ValueError(f'Unsafe archive entry: {name!r}')
            key = name.rstrip('/').casefold()
            if key in seen:
                raise ValueError('Duplicate case-insensitive archive path')
            seen.add(key)
            total += f.file_size
            if f.file_size > 32_000_000 or total > 128_000_000:
                raise ValueError('Archive exceeds extraction size limits')
            rows.append({'name': name, 'size': f.file_size, 'compressed_size': f.compress_size,
                         'type': Path(name).suffix.lower() or 'extensionless', 'directory': f.is_dir()})
    with archive.open('rb') as stream:
        digest = hashlib.file_digest(stream, 'sha256').hexdigest()
    return {'sha256': digest, 'files': rows, 'total_size': total}


def extract_reference(archive: Path, destination: Path) -> dict:
    result = inventory(archive)
    if destination.exists():
        raise ValueError('Refusing to overwrite an existing reference directory')
    destination.mkdir(parents=True)
    root = destination.resolve()
    with zipfile.ZipFile(archive) as z:
        for entry in result['files']:
            target = (root / entry['name']).resolve()
            if not target.is_relative_to(root):
                raise ValueError('Extraction escaped destination')
            if entry['directory']:
                target.mkdir(parents=True, exist_ok=True)
            else:
                target.parent.mkdir(parents=True, exist_ok=True)
                with target.open('xb') as out:
                    out.write(z.read(entry['name']))
    return result
