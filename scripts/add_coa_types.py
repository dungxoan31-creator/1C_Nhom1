import uuid

with open('src/ChartsOfAccounts/Main.xml', 'r', encoding='utf-8') as f:
    content = f.read()

extra = f"""\t\t\t<xr:GeneratedType name="ChartOfAccountsExtDimensionTypes.Main" category="TabularSection">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="ChartOfAccountsExtDimensionTypesRow.Main" category="TabularSectionRow">
\t\t\t\t<xr:TypeId>{uuid.uuid4()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uuid.uuid4()}</xr:ValueId>
\t\t\t</xr:GeneratedType>"""

content = content.replace('</xr:GeneratedType>\n\t\t</InternalInfo>', '</xr:GeneratedType>\n' + extra + '\n\t\t</InternalInfo>')

with open('src/ChartsOfAccounts/Main.xml', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated Main.xml")
