# -*- coding: utf-8 -*-
"""
Auditor for 1C:Enterprise codebase against 1C-Mentor-Skill-Gemini standards:
- Category P: Posting & Registers (P1-P10, #std603, #std450, #std661, #std460, #std792, #std477)
- Category Q: Queries & Performance (Q1-Q5, #std436, #std657, #std733, #std654)
- Category F: Forms & Client/Server (F1-F9, #std703, #std404, #std418)
- Category V: Validations & Data Integrity (V1-V5, #std463, #std464, #std465, #std773, #std686, #std396)
- Category T: Transactions & Errors (T1-T3, #std783)
- Category X: External, Files & Subsystems (X1-X5)
- Category M: Modules, Pragma & Code Style (M1-M2)
"""

import os
import re
import sys
import io

if sys.stdout.encoding != 'utf-8':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

src_dir = 'src'
bsl_files = []
for root, dirs, files in os.walk(src_dir):
    for f in files:
        if f.endswith('.bsl'):
            bsl_files.append(os.path.join(root, f))

bsl_files.sort()

findings = []

for file_path in bsl_files:
    rel_path = os.path.relpath(file_path, '.').replace('\\', '/')
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
        lines = content.splitlines()

    # Check 1: V5 (#std773) - BeforeWrite / OnWrite checking DataExchange.Load
    for i, line in enumerate(lines):
        m_bw = re.search(r'^\s*Procedure\s+(BeforeWrite|OnWrite)\s*\(', line, re.IGNORECASE)
        if m_bw:
            handler_name = m_bw.group(1)
            # check the next 15 lines for DataExchange.Load
            block = "\n".join(lines[i:min(len(lines), i+20)])
            if 'DataExchange.Load' not in block:
                findings.append({
                    'file': rel_path,
                    'line': i + 1,
                    'rule': 'V5',
                    'std': '#std773',
                    'severity': 'Vừa',
                    'issue': f'Handler {handler_name} thiếu kiểm tra DataExchange.Load ở đầu handler',
                    'why': 'Khi đồng bộ hoặc nạp dữ liệu trao đổi (DataExchange), handler có thể ghi đè logic hoặc chặn sai dữ liệu trao đổi.',
                    'fix': 'Thêm `If DataExchange.Load Then Return; EndIf;` ở dòng đầu của handler.'
                })

    # Check 2: V1 (#std686) - Assignment Cancel = False
    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped.startswith('//'):
            if re.search(r'\bCancel\s*=\s*False\b', line, re.IGNORECASE):
                findings.append({
                    'file': rel_path,
                    'line': i + 1,
                    'rule': 'V1',
                    'std': '#std686',
                    'severity': 'Nặng',
                    'issue': 'Gán trực tiếp Cancel = False trong sự kiện kiểm tra',
                    'why': 'Có thể xóa cờ Cancel = True đã được đặt bởi các bước kiểm tra trước đó hoặc nền tảng.',
                    'fix': 'Dùng `If HasError Then Cancel = True; EndIf;` thay vì gán trực tiếp False.'
                })

    # Check 3: F6 (#std703) - Modal windows / methods
    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped.startswith('//'):
            m_modal = re.search(r'\b(DoMessageBox|DoQueryBox|OpenFormModal|InputValue)\b', line, re.IGNORECASE)
            if m_modal:
                findings.append({
                    'file': rel_path,
                    'line': i + 1,
                    'rule': 'F6',
                    'std': '#std703',
                    'severity': 'Nặng',
                    'issue': f'Sử dụng phương thức modal `{m_modal.group(1)}`',
                    'why': 'Gây lỗi khi Modality use mode = Do not use và không hỗ trợ Web client.',
                    'fix': f'Thay bằng `Show{m_modal.group(1)[2:]}` hoặc CallbackDescription không đồng bộ.'
                })

    # Check 4: F7/M2 (#std) - Deprecated CurrentDate vs CurrentSessionDate
    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped.startswith('//'):
            if re.search(r'\bCurrentDate\(\)', line, re.IGNORECASE):
                findings.append({
                    'file': rel_path,
                    'line': i + 1,
                    'rule': 'F7',
                    'std': '#std418',
                    'severity': 'Vừa',
                    'issue': 'Sử dụng CurrentDate() thay vì CurrentSessionDate()',
                    'why': 'CurrentDate() lấy giờ máy chủ hoặc máy trạm không đồng bộ theo múi giờ phiên làm việc.',
                    'fix': 'Thay bằng `CurrentSessionDate()`.'
                })

    # Check 5: V2/M2 (#std418) - Message() vs UserMessage
    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped.startswith('//'):
            if re.search(r'^\s*Message\(', line, re.IGNORECASE):
                findings.append({
                    'file': rel_path,
                    'line': i + 1,
                    'rule': 'V2',
                    'std': '#std418',
                    'severity': 'Nhẹ',
                    'issue': 'Sử dụng lệnh Message() thông báo nghiệp vụ',
                    'why': 'Lệnh Message() không gắn được vào ô dữ liệu trên Form và không theo chuẩn 1C.',
                    'fix': 'Sử dụng `New UserMessage` với trường Field và SetData(ThisObject).'
                })

    # Check 6: P8 (#std657, #std733) - Empty virtual table call or without parameters
    for i, line in enumerate(lines):
        stripped = line.strip()
        if not stripped.startswith('//'):
            if re.search(r'\.Balance\s*\(\s*\)', line, re.IGNORECASE):
                findings.append({
                    'file': rel_path,
                    'line': i + 1,
                    'rule': 'P8',
                    'std': '#std733',
                    'severity': 'Vừa',
                    'issue': 'Gọi bảng ảo .Balance() không truyền tham số thời điểm và điều kiện lọc',
                    'why': 'Đọc toàn bộ bảng số dư hiện tại của register, gây chậm và sai lệch khi post chứng từ lùi ngày.',
                    'fix': 'Truyền tham số thời điểm `&PointInTime` và điều kiện lọc `Dimension = &Value` vào bảng ảo.'
                })

    # Check 7: T1 (#std783) - BeginTransaction inside method without Try/Except or pairing
    if 'BeginTransaction(' in content:
        # Check if paired with CommitTransaction and RollbackTransaction
        commits = len(re.findall(r'\bCommitTransaction\(', content, re.IGNORECASE))
        rollbacks = len(re.findall(r'\bRollbackTransaction\(', content, re.IGNORECASE))
        begins = len(re.findall(r'\bBeginTransaction\(', content, re.IGNORECASE))
        if begins != commits or rollbacks < begins:
            findings.append({
                'file': rel_path,
                'line': 1,
                'rule': 'T1',
                'std': '#std783',
                'severity': 'Nặng',
                'issue': f'Số lượng BeginTransaction ({begins}) không khớp Commit ({commits}) / Rollback ({rollbacks})',
                'why': 'Transaction có nguy cơ bị treo hoặc rò rỉ khóa nếu xảy ra ngoại lệ không được rollback.',
                'fix': 'Đảm bảo bọc toàn bộ khối transaction trong Try...Except RollbackTransaction; Raise; EndTry.'
            })

    # Check 8: P6 (#std460) - Posting procedure without DataLock in Managed mode
    for i, line in enumerate(lines):
        if re.search(r'^\s*Procedure\s+Posting\s*\(', line, re.IGNORECASE):
            # check the whole posting procedure for DataLock or LockForUpdate
            posting_block = "\n".join(lines[i:])
            end_pos = posting_block.find("EndProcedure")
            if end_pos != -1:
                posting_body = posting_block[:end_pos]
                # Check if reading registers or balances
                if ('.Balance' in posting_body or 'AccumulationRegister' in posting_body) and 'DataLock' not in posting_body and 'LockForUpdate' not in posting_body:
                    findings.append({
                        'file': rel_path,
                        'line': i + 1,
                        'rule': 'P6',
                        'std': '#std460',
                        'severity': 'Vừa',
                        'issue': 'Procedure Posting đọc/ghi register mà không thiết lập DataLock hoặc LockForUpdate',
                        'why': 'Trong chế độ Managed Lock, hai phiên post đồng thời có thể gây race condition hoặc deadlock.',
                        'fix': 'Khai báo `New DataLock` hoặc gán `RegisterRecords.X.LockForUpdate = True` trước khi đọc số dư.'
                    })

print(f"Tổng số phát hiện qua phân tích tĩnh: {len(findings)}")
for item in findings:
    print(f"[{item['severity'].upper()}] {item['file']}:{item['line']} | {item['rule']} ({item['std']}) -> {item['issue']}")
