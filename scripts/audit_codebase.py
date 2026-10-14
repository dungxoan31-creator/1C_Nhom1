"""Contextual BSL audit warnings, not verified business defects.

Transaction inspection is local to each procedure/function and recognizes
Try/Except scopes, including batched commits sharing one rollback handler.
It is a lexical heuristic, not control-flow or interprocedural proof. Findings
need review and runtime evidence. The shared lifecycle guard is resolved only
when its target procedure actually checks DataExchange.Load.
"""

import argparse
from pathlib import Path
import re

if __package__:
    from .verify_bsl_syntax import strip_bsl_code
else:
    from verify_bsl_syntax import strip_bsl_code


PROCEDURE = re.compile(
    r'^[ \t]*(?:Async\s+)?(Procedure|Function)\s+(\w+)\s*\(', re.I | re.M
)
LOAD_CHECK = re.compile(r'\bIf\s+(?:Not\s+)?(?:\w+\s*\.\s*)?DataExchange\s*\.\s*Load\b', re.I)
LIFECYCLE_CALL = re.compile(
    r'\bQuanLyVongDoiChungTuServer\s*\.\s*KiemTraTrangThaiVaQuyen\s*\(\s*ThisObject\s*,',
    re.I,
)
SHARED_MODULE = Path('CommonModules/QuanLyVongDoiChungTuServer/Ext/Module.bsl')
QUERY_TEXT = re.compile(r'^[ \t]*\w+\s*\.\s*Text\s*=\s*"((?:[^"]|"")*)"', re.I | re.M)


def iter_procedures(content):
    """Yield method boundaries; strings/comments cannot create declarations."""
    clean = strip_bsl_code(content.removeprefix('\ufeff'))
    starts = list(PROCEDURE.finditer(clean))
    for index, match in enumerate(starts):
        limit = starts[index + 1].start() if index + 1 < len(starts) else len(clean)
        end = re.search(r'\bEnd' + match.group(1) + r'\b', clean[match.end():limit], re.I)
        stop = match.end() + end.end() if end else limit
        yield {
            'name': match.group(2),
            'start': match.start(),
            'stop': stop,
            'line': clean.count('\n', 0, match.start()) + 1,
            'body': clean[match.start():stop],
        }


def transaction_issues(body):
    """Return suspect BeginTransaction offsets; never compare token totals."""
    scopes = []
    stack = []
    for token in re.finditer(r'\b(Try|Except|EndTry)\b', body, re.I):
        kind = token.group().lower()
        if kind == 'try':
            stack.append([token.start(), None, None])
        elif kind == 'except' and stack:
            stack[-1][1] = token.start()
        elif kind == 'endtry' and stack:
            scope = stack.pop()
            scope[2] = token.start()
            if scope[1] is not None:
                scopes.append(scope)
    issues = []
    for begin in re.finditer(r'\bBeginTransaction\s*\(\s*\)\s*;?', body, re.I):
        protected = False
        for start, handler, stop in scopes:
            inside = start < begin.start() < handler
            # Legacy pattern: BeginTransaction(); immediately followed by Try.
            immediately_before = begin.end() <= start and not body[begin.end():start].strip()
            if not (inside or immediately_before):
                continue
            commit = re.search(r'\bCommitTransaction\s*\(', body[begin.end():handler], re.I)
            rollback = re.search(r'\bRollbackTransaction\s*\(', body[handler:stop], re.I)
            if commit and rollback:
                protected = True
                break
        if not protected:
            issues.append(begin.start())
    return issues


def audit_file(file_path, shared_guard=False):
    """Return contextual warning dictionaries; importing this module does no I/O."""
    file_path = Path(file_path)
    content = file_path.read_text(encoding='utf-8-sig')
    clean = strip_bsl_code(content)
    with_strings = strip_bsl_code(content, keep_strings=True)
    raw_lines = content.splitlines()
    methods = list(iter_procedures(content))
    findings = []

    def add(rule, std, severity, offset, issue, why, fix):
        line = clean.count('\n', 0, offset) + 1
        method = next((m['name'] for m in methods if m['start'] <= offset < m['stop']), '<module>')
        findings.append({
            'file': file_path.as_posix(), 'line': line, 'procedure': method,
            'rule': rule, 'std': std, 'severity': severity,
            'classification': 'needs_runtime_proof',
            'context': '\n'.join(raw_lines[max(0, line - 2):line + 1]),
            'issue': issue, 'why': why, 'fix': fix,
        })

    for method in methods:
        body = method['body']
        name = method['name']
        if name.lower() in ('beforewrite', 'onwrite'):
            handled = LOAD_CHECK.search(body) or (shared_guard and LIFECYCLE_CALL.search(body))
            if not handled:
                add('V5', '#std773', 'warning', method['start'],
                    f'{name}: no local or resolved shared DataExchange.Load check found.',
                    'A call-chain review is needed; another helper may handle imports.',
                    'Trace the lifecycle validation and test draft/posted imports before changing guards.')
        for offset in transaction_issues(body):
            add('T1', '#std783', 'warning', method['start'] + offset,
                f'{name}: transaction has no recognized local commit/exception rollback scope.',
                'Lexical structure does not prove leaks or exception safety; helpers and branches need review.',
                'Trace transaction ownership and test injected failures at batch boundaries.')

        if name.lower() == 'posting':
            # SQL lives in string literals, so inspect actual Query.Text assignments separately.
            source_body = with_strings[method['start']:method['stop']]
            queries = '\n'.join(m.group(1) for m in QUERY_TEXT.finditer(source_body))
            register_access = re.search(r'\.Balance\b|\bAccumulationRegister\b', body + '\n' + queries, re.I)
            if register_access and not re.search(r'\b(DataLock|LockForUpdate)\b', body, re.I):
                add('P6', '#std460', 'warning', method['start'],
                    'Posting accesses register data with no local lock marker found.',
                    'Delegated locking and platform behavior may be sufficient; a marker alone cannot prove safety.',
                    'Trace balance reads and lock dimensions, then run a two-session concurrency test.')

    code_rules = (
        ('V1', '#std686', r'\bCancel\s*=\s*False\b',
         'Cancel is explicitly reset to False.',
         'This may erase a prior cancellation, or may initialize an unrelated local flag.',
         'Review the event/call context and preserve prior validation failures.'),
        ('F6', '#std703', r'\b(DoMessageBox|DoQueryBox|OpenFormModal|InputValue)\s*\(',
         'Modal method call found.',
         'Compatibility depends on modality settings and the client that executes this method.',
         'Check supported clients and use asynchronous dialogs where required.'),
        ('F7', '#std418', r'\bCurrentDate\s*\(\s*\)',
         'CurrentDate() uses the machine clock.',
         'Server logging can intentionally use machine time; business dates may need session time.',
         'Review log versus document/session usage before choosing CurrentSessionDate().'),
        ('V2', '#std418', r'^[ \t]*Message\s*\(',
         'Message() call found.',
         'Diagnostic messages can be intentional; business validation may need field context.',
         'Review the purpose before choosing UserMessage for field-specific validation.'),
    )
    for rule, std, pattern, issue, why, fix in code_rules:
        for match in re.finditer(pattern, clean, re.I | re.M):
            add(rule, std, 'warning', match.start(), issue, why, fix)

    # Detect executable Balance() calls and SQL virtual tables, not arbitrary string examples.
    for match in re.finditer(r'\.Balance\s*\(\s*\)', clean, re.I):
        add('P8', '#std733', 'warning', match.start(),
            'Balance() has no explicit parameters.',
            'The required time/filter depends on the query purpose and data volume.',
            'Review query intent and measure/test historical posting before adding parameters.')
    for query in QUERY_TEXT.finditer(with_strings):
        for match in re.finditer(r'\.Balance\s*\(\s*\)', query.group(1), re.I):
            add('P8', '#std733', 'warning', query.start(1) + match.start(),
                'SQL Balance() has no explicit parameters.',
                'The query may intentionally read current balances; performance and dates require evidence.',
                'Review query intent and measure/test historical posting before adding parameters.')
    return sorted(findings, key=lambda item: (item['line'], item['rule']))


def audit_tree(src_dir):
    """Resolve the known shared lifecycle check and audit BSL files deterministically."""
    src_dir = Path(src_dir)
    if not src_dir.is_dir():
        raise ValueError(f'Source directory does not exist: {src_dir}')
    files = sorted(src_dir.rglob('*.bsl'))
    if not files:
        raise ValueError(f'No BSL files found in: {src_dir}')
    shared_guard = False
    shared_path = src_dir / SHARED_MODULE
    if shared_path.is_file():
        content = shared_path.read_text(encoding='utf-8-sig')
        shared_guard = any(
            m['name'].lower() == 'kiemtratrangthaivaquyen' and LOAD_CHECK.search(m['body'])
            for m in iter_procedures(content)
        )
    return [finding for path in files for finding in audit_file(path, shared_guard)]


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--src', type=Path, default=Path('src'))
    args = parser.parse_args(argv)
    try:
        findings = audit_tree(args.src)
    except (OSError, UnicodeError, ValueError) as exc:
        print(f'FAILED: {exc}')
        return 1
    print(f'Static audit warnings: {len(findings)}; heuristics require review/runtime evidence.')
    for item in findings:
        print(f"[{item['classification']}] {item['file']}:{item['line']} "
              f"| {item['procedure']} | {item['rule']} ({item['std']}) -> {item['issue']}")
        print(f"  Context: {item['context']}")
        print(f"  Review: {item['why']} {item['fix']}")
    # Warnings are advisory; this audit cannot verify a business defect.
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
