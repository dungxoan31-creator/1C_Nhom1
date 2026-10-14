"""Compare explicit source/dump trees; binary hashes are byte-for-byte exact.

Known UTF-8 text formats normalize one leading BOM and CRLF only. Unknown
formats (including binary assets) retain every byte. ConfigDumpInfo.xml is
dump metadata and excluded. A matching dump alone does not prove freshness
or identify the infobase that produced it; the runtime runner owns that evidence.
"""

import argparse
import hashlib
import os
from pathlib import Path


TEXT_SUFFIXES = {'.bsl', '.xml', '.txt', '.json', '.html', '.css', '.js', '.svg'}


def compute_content_sha256(file_path):
    file_path = Path(file_path)
    data = file_path.read_bytes()
    if file_path.suffix.lower() in TEXT_SUFFIXES and b'\x00' not in data:
        # Invalid UTF-8 is compared exactly, never decoded with ignored errors.
        try:
            data.decode('utf-8')
        except UnicodeDecodeError:
            pass
        else:
            data = data.removeprefix(b'\xef\xbb\xbf').replace(b'\r\n', b'\n')
    return hashlib.sha256(data).hexdigest()


def get_relative_files(base_dir):
    base_dir = Path(base_dir)
    if not base_dir.is_dir():
        raise ValueError(f'Directory does not exist: {base_dir}')
    rel_files = {}

    def on_error(exc):
        raise exc

    for root, _, files in os.walk(base_dir, onerror=on_error):
        for name in sorted(files):
            if name == 'ConfigDumpInfo.xml':
                continue
            path = Path(root) / name
            rel_files[path.relative_to(base_dir).as_posix()] = path
    return rel_files


def compare_trees(src_dir, dump_dir):
    """Return deterministic differences; no prints, assertions or default dump."""
    src_files = get_relative_files(src_dir)
    dump_files = get_relative_files(dump_dir)
    if not src_files or not dump_files:
        raise ValueError('Source and dump must both contain configuration files.')
    mismatches = []
    for name in sorted(src_files.keys() & dump_files.keys()):
        src_hash = compute_content_sha256(src_files[name])
        dump_hash = compute_content_sha256(dump_files[name])
        if src_hash != dump_hash:
            mismatches.append((name, src_hash, dump_hash))
    return {
        'source_count': len(src_files),
        'dump_count': len(dump_files),
        'missing_in_dump': sorted(src_files.keys() - dump_files.keys()),
        'extra_in_dump': sorted(dump_files.keys() - src_files.keys()),
        'hash_mismatches': mismatches,
    }


def run_parity_audit(src_dir, dump_dir):
    """Print the comparison and return the number of differences."""
    result = compare_trees(src_dir, dump_dir)
    print(f'Source dir: {Path(src_dir).resolve()} ({result["source_count"]} files)')
    print(f'Dump dir: {Path(dump_dir).resolve()} ({result["dump_count"]} files)')
    for label in ('missing_in_dump', 'extra_in_dump', 'hash_mismatches'):
        items = result[label]
        if items:
            print(f'{label}: {len(items)}')
            for item in items:
                print(f'  {item}')
    total = sum(len(result[key]) for key in ('missing_in_dump', 'extra_in_dump', 'hash_mismatches'))
    print(f'Total differences: {total}')
    print('FAIL: source/dump differ.' if total else 'PASS: supplied source/dump trees match.')
    return total


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--src', type=Path, required=True)
    parser.add_argument('--dump', type=Path, required=True)
    args = parser.parse_args(argv)
    try:
        return 1 if run_parity_audit(args.src, args.dump) else 0
    except (OSError, ValueError) as exc:
        print(f'FAILED: {exc}')
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
