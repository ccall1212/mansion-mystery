"""Read-only original-data audit; decoded material is written only to ignored local output.

No archive program is executed and no executable is disassembled/decompiled.
"""
import hashlib
import json
import re
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "test-results/original-dialogue-audit"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def terminated_records(data, width, count):
    records = []
    for index in range(count):
        raw = data[index * width:(index + 1) * width]
        assert len(raw) == width
        assert raw.count(b"\\") == 1, (index, width)
        text, padding = raw.split(b"\\", 1)
        assert not padding.strip(b" "), (index, padding)
        records.append(text.decode("cp437"))
    assert not data[width * count:].strip(b"\0")
    return records


def audit():
    configuration = json.loads((ROOT / "tools/dos-game-mcp/local.json").read_text())
    archive = Path(configuration["archive"])
    inventory = json.loads((ROOT / "reference/inventory.json").read_text())
    assert sha(archive.read_bytes()) == inventory["sha256"]
    expected = {entry["name"]: entry for entry in inventory["files"]}
    decoded, files = {}, []
    with zipfile.ZipFile(archive) as bundle:
        assert set(bundle.namelist()) == set(expected)
        for entry in bundle.infolist():
            content = bundle.read(entry)
            reference = ROOT / "reference/original" / entry.filename
            assert reference.read_bytes() == content
            assert sha(content) == expected[entry.filename]["sha256"]
            if entry.filename.endswith(".EXE"):
                category = "executable_metadata_and_printable_data_only"
                assert content[:2] == b"MZ"
                decoded[entry.filename] = [
                    {"offset": match.start(), "text": match.group().decode("ascii")}
                    for match in re.finditer(rb"[\x20-\x7e]{8,}", content)
                ]
            elif entry.filename.startswith("SUSPICT."):
                category = "display_data"
                assert len(content) == 2816
                decoded[entry.filename] = {"byte_histogram": {
                    str(value): content.count(value) for value in sorted(set(content))
                }}
            elif entry.filename.startswith("RMDEF."):
                category = "numeric_room_geometry"
                decoded[entry.filename] = content.decode("cp437")
            else:
                category = "data_or_historical_document"
                decoded[entry.filename] = content.decode("cp437")
            files.append({"name": entry.filename, "size": len(content),
                          "sha256": sha(content), "category": category,
                          "archive_matches_preserved_reference": True})

    assert not any(Path(name).suffix.lower() in
                   {".bas", ".pas", ".c", ".cpp", ".asm"} for name in expected)
    reference = ROOT / "reference/original"
    intro = terminated_records((reference / "ALIBI1").read_bytes(), 70, 36)
    action_tables = {}
    for version in (1, 2):
        name = f"ACT.V{version}"
        records = terminated_records((reference / name).read_bytes(), 55, 120)
        action_tables[name] = records
        decoded[name] = [
            {"index": i, "bank": i // 24, "context_slot": i % 24 // 2,
             "alternative": i % 2, "text": text}
            for i, text in enumerate(records)
        ]
    decoded["ALIBI1"] = [
        {"index": i, "bank": i // 12, "slot": i % 12, "text": text}
        for i, text in enumerate(intro)
    ]
    raw = (reference / "ALIBI2").read_bytes()
    assert not raw[56 * 188:].strip(b"\0")
    endings = [raw[i * 188:(i + 1) * 188].replace(b"\0", b" ").decode("cp437")
               for i in range(56)]
    # These seven confession slots were manually read in full. Keyword matches
    # elsewhere include denials and hypothetical accusations, not confessions.
    confession_indices = list(range(7, 56, 8))
    assert all(re.search(r"I\s+killed", endings[i]) or "I never meantfor" in endings[i]
               for i in confession_indices)
    decoded["ALIBI2"] = [
        {"index": i, "bank": i // 8, "slot": i % 8, "text": text.rstrip()}
        for i, text in enumerate(endings)
    ]
    weapon_stats = {}
    for version in (1, 2):
        name = f"WEAPN.V{version}"
        raw = (reference / name).read_bytes()
        assert not raw[33 * 220:].strip(b"\0")
        records = []
        for index in range(33):
            record = raw[index * 220:(index + 1) * 220]
            fields = []
            for start, end in ((0, 80), (80, 100), (110, 125), (125, 140), (140, 220)):
                value = record[start:end]
                assert value.count(b"\\") == 1
                fields.append(value.split(b"\\")[0].decode("cp437"))
            records.append({"index": index, "group": index // 3,
                            "slot": index % 3, "fields": fields})
        decoded[name] = records
        weapon_stats[name] = {"records": 33, "bytes_per_record": 220,
                              "empty_name_slots": [r["index"] for r in records
                                                   if not r["fields"][1].strip()]}

    summary = {
        "archive_sha256": inventory["sha256"], "files_verified": len(files),
        "source_code_present": False, "executed_original": False,
        "decompiled_or_disassembled": False,
        "alibi1": {"records": 36, "bytes_per_record": 70, "banks_of_12": 3,
                   "slot_pattern": "six delivery, two refusal, four repeat"},
        "alibi2": {"records": 56, "bytes_per_record": 188, "banks_of_8": 7,
                   "confession_indices_zero_based": confession_indices,
                   "victim_marker_occurrences": sum(t.count("#+++++++++") for t in endings),
                   "other_person_marker_occurrences": sum(t.count("@+++++++++") for t in endings)},
        "actions": {name: {"records": len(rows), "bytes_per_record": 55,
                           "banks_of_24": 5, "paired_context_slots_per_bank": 12,
                           "distinct_texts": len(set(rows))}
                    for name, rows in action_tables.items()},
        "weapons": weapon_stats,
        "house_data_families": 2, "display_files": 10,
        "warning": "Bank layouts are data observations, not proof of executable selection logic.",
    }
    OUTPUT.mkdir(parents=True, exist_ok=True)
    (OUTPUT / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    (OUTPUT / "inventory.json").write_text(json.dumps(files, indent=2) + "\n")
    (OUTPUT / "decoded-local-only.json").write_text(json.dumps(decoded, indent=2) + "\n")
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    audit()
