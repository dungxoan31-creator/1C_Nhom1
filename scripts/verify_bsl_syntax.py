"""Supplementary BSL token-balance heuristic; 1C /CheckConfig is authoritative."""

import argparse
from pathlib import Path
import re


def strip_bsl_code(content, keep_strings=False):
    """Mask comments/string literals while preserving offsets and line numbers."""
    result = []
    in_string = False
    i = 0
    n = len(content)
    while i < n:
        if not in_string:
            if content[i:i+2] == '//':
                nl = content.find('\n', i)
                if nl == -1:
                    nl = n
                result.append(' ' * (nl - i))
                i = nl
                continue
            elif content[i] == '"':
                in_string = True
                result.append('"' if keep_strings else ' ')
                i += 1
                continue
            else:
                result.append(content[i])
                i += 1
        else:
            if content[i] == '"':
                if i + 1 < n and content[i+1] == '"':
                    result.append('""' if keep_strings else '  ')
                    i += 2
                    continue
                else:
                    in_string = False
                    result.append('"' if keep_strings else ' ')
                    i += 1
                    continue
            else:
                result.append(content[i] if keep_strings or content[i] == '\n' else ' ')
                i += 1
    return ''.join(result)


def check_content(content):
    """Return balance issues without I/O; comments and strings are ignored."""
    clean = strip_bsl_code(content.removeprefix('\ufeff'))
    procs = len(re.findall(r'^\s*(?:Async\s+)?Procedure\b', clean, re.I | re.M))
    endprocs = len(re.findall(r'^\s*EndProcedure\b', clean, re.I | re.M))
    funcs = len(re.findall(r'^\s*(?:Async\s+)?Function\b', clean, re.I | re.M))
    endfuncs = len(re.findall(r'^\s*EndFunction\b', clean, re.I | re.M))
    ifs = len(re.findall(r'\bIf\b', clean, re.I))
    endifs = len(re.findall(r'\bEndIf\b', clean, re.I))
    dos = len(re.findall(r'\b(While|For)\b', clean, re.I))
    enddos = len(re.findall(r'\bEndDo\b', clean, re.I))
    trys = len(re.findall(r'\bTry\b', clean, re.I))
    endtrys = len(re.findall(r'\bEndTry\b', clean, re.I))

    issues = []
    if procs != endprocs:
        issues.append(f'Procedures: {procs} vs EndProcedures: {endprocs}')
    if funcs != endfuncs:
        issues.append(f'Functions: {funcs} vs EndFunctions: {endfuncs}')
    if ifs != endifs:
        issues.append(f'Ifs: {ifs} vs EndIfs: {endifs}')
    if dos != enddos:
        issues.append(f'Loops: {dos} vs EndDos: {enddos}')
    if trys != endtrys:
        issues.append(f'Trys: {trys} vs EndTrys: {endtrys}')
    return issues


def check_file(file_path):
    return check_content(Path(file_path).read_text(encoding='utf-8-sig'))


def scan_tree(src_dir):
    """Return (file count, findings); reject missing or empty source trees."""
    src_dir = Path(src_dir)
    if not src_dir.is_dir():
        raise ValueError(f'Source directory does not exist: {src_dir}')
    files = sorted(src_dir.rglob('*.bsl'))
    if not files:
        raise ValueError(f'No BSL files found in: {src_dir}')
    findings = []
    for file_path in files:
        issues = check_file(file_path)
        if issues:
            findings.append({'file': file_path.as_posix(), 'issues': issues})
    return len(files), findings


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--src', type=Path, default=Path('src'))
    args = parser.parse_args(argv)
    try:
        count, findings = scan_tree(args.src)
    except (OSError, UnicodeError, ValueError) as exc:
        print(f'FAILED: {exc}')
        return 1
    for item in findings:
        print(f"{item['file']}: {item['issues']}")
    total_issues = sum(len(item['issues']) for item in findings)
    print(f'Checked {count} BSL files. Total syntax balance issues: {total_issues}')
    print('Heuristic only; run 1C /CheckConfig for authoritative syntax validation.')
    return 1 if total_issues else 0


if __name__ == '__main__':
    raise SystemExit(main())
