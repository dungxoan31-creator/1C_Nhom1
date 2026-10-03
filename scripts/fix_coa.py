import uuid

with open('src/ChartsOfAccounts/Main.xml', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace any existing InternalInfo
internal_info = f"""\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="ChartOfAccountsObject.Main" category="Object">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsRef.Main" category="Ref">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsSelection.Main" category="Selection">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsList.Main" category="List">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsManager.Main" category="Manager">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsExtDimensionTypes.Main" category="ExtDimensionTypes">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsExtDimensionTypesRow.Main" category="ExtDimensionTypesRow">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>"""

import re
content = re.sub(r'\t\t<InternalInfo>.*?</InternalInfo>', internal_info, content, flags=re.DOTALL)

with open('src/ChartsOfAccounts/Main.xml', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated Main.xml with exact ExtDimensionTypes categories!")
