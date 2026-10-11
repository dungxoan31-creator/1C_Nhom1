# -*- coding: utf-8 -*-
import sys, io, re
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

with open('Infobase_FullData/1Cv8Log/20261011000000.lgp', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

lines = text.splitlines()
for i, line in enumerate(lines):
    if 'Posting.CanTru' in line or 'Intercompany' in line or 'Netting' in line:
        for j in range(max(0, i-5), min(len(lines), i+15)):
            print(f'{j}: {lines[j]}')
        print('='*50)
