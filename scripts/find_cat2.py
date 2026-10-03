with open(r'C:\Program Files (x86)\1cv8t\8.3.22.1704\bin\accntt.dll', 'rb') as f:
    d = f.read()

import re

# Search for the string ChartOfAccountsExtDimensionTypes
idx = d.find('ChartOfAccountsExtDimensionTypes'.encode('utf-16le'))
print('Found at:', idx)
if idx != -1:
    chunk = d[idx-400:idx+400]
    # filter out non-printable
    chars = []
    for i in range(0, len(chunk), 2):
        val = chunk[i] | (chunk[i+1] << 8)
        if 32 <= val < 127 or 0x0400 <= val <= 0x04FF:
            chars.append(chr(val))
        else:
            chars.append(' ')
    print(''.join(chars))
