# -*- coding: utf-8 -*-
import os, re, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

def strip_bsl_code(content):
    result = []
    in_string = False
    i = 0
    n = len(content)
    while i < n:
        if not in_string:
            if content[i:i+2] == '//':
                nl = content.find('\n', i)
                if nl == -1:
                    break
                result.append('\n')
                i = nl + 1
                continue
            elif content[i] == '"':
                in_string = True
                result.append(' ')
                i += 1
                continue
            else:
                result.append(content[i])
                i += 1
        else:
            if content[i] == '"':
                if i + 1 < n and content[i+1] == '"':
                    i += 2
                    continue
                else:
                    in_string = False
                    result.append(' ')
                    i += 1
                    continue
            else:
                if content[i] == '\n':
                    result.append('\n')
                i += 1
    return ''.join(result)

bsl_files = []
for root, _, files in os.walk('src'):
    for f in files:
        if f.endswith('.bsl'):
            bsl_files.append(os.path.join(root, f))

bsl_files.sort()
total_issues = 0
for bf in bsl_files:
    with open(bf, 'r', encoding='utf-8', errors='ignore') as f:
        raw = f.read()
    clean = strip_bsl_code(raw)
    
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

    if issues:
        print(f'{bf}: {issues}')
        total_issues += len(issues)

print(f'Checked {len(bsl_files)} BSL files. Total syntax balance issues: {total_issues}')
