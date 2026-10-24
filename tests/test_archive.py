import hashlib
import zipfile
from pathlib import Path
import pytest
from archive import inventory, extract_reference
import server


def test_real_archive_and_reference():
    result = server.inspect_game_archive()
    assert result['ok'] and len(result['files']) == 33
    assert result['sha256'] == 'b294d2815ee285cd1f03c377af4d866a420676994abcf6348ff75e4ccb4bada8'
    assert (server.ROOT / 'reference/original/SLEUTH0.EXE').read_bytes()[:2] == b'MZ'


@pytest.mark.parametrize('name', ['../escape', '/absolute', 'C:/escape', 'dir\\escape', 'CON.txt', 'name:stream', 'trailing.', 'a/../../b', 'bad?.txt'])
def test_reject_unsafe_archive_paths(tmp_path, name):
    archive = tmp_path / 'bad.zip'
    with zipfile.ZipFile(archive, 'w') as z:
        z.writestr('safe.txt', 'safe')
        info = zipfile.ZipInfo('placeholder')
        info.filename = name  # Windows ZipInfo normally normalizes backslashes; emulate an untrusted ZIP.
        z.writestr(info, 'unsafe')
    with pytest.raises(ValueError):
        extract_reference(archive, tmp_path / 'output')
    assert not (tmp_path / 'output').exists()


def test_no_overwrite_and_duplicate_case(tmp_path):
    archive = tmp_path / 'small.zip'
    with zipfile.ZipFile(archive, 'w') as z:
        z.writestr('safe.txt', 'safe')
    target = tmp_path / 'reference'
    extract_reference(archive, target)
    with pytest.raises(ValueError):
        extract_reference(archive, target)
    with zipfile.ZipFile(archive, 'a') as z:
        z.writestr('SAFE.TXT', 'unsafe')
    with pytest.raises(ValueError):
        inventory(archive)


def test_symlink_rejected(tmp_path):
    archive = tmp_path / 'link.zip'
    with zipfile.ZipFile(archive, 'w') as z:
        info = zipfile.ZipInfo('link')
        info.create_system = 3
        info.external_attr = 0o120777 << 16
        z.writestr(info, '../escape')
    with pytest.raises(ValueError):
        inventory(archive)
