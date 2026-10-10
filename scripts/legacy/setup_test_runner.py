import os
import uuid

def uid():
    return str(uuid.uuid4())

def setup_test_runner():
    # 1. CommonModule XML
    cm_dir = "src/CommonModules"
    os.makedirs(os.path.join(cm_dir, "CatalogsCoreTest", "Ext"), exist_ok=True)
    
    cm_id = uid()
    cm_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<CommonModule uuid="{cm_id}">
\t\t<Properties>
\t\t\t<Name>CatalogsCoreTest</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Catalogs Core Test Suite</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment/>
\t\t\t<Global>false</Global>
\t\t\t<ClientManagedApplication>false</ClientManagedApplication>
\t\t\t<Server>true</Server>
\t\t\t<ExternalConnection>false</ExternalConnection>
\t\t\t<ClientOrdinaryApplication>false</ClientOrdinaryApplication>
\t\t\t<ServerCall>true</ServerCall>
\t\t\t<Privileged>false</Privileged>
\t\t\t<ReturnValuesReuse>DontUse</ReturnValuesReuse>
\t\t</Properties>
\t</CommonModule>
</MetaDataObject>"""

    with open(os.path.join(cm_dir, "CatalogsCoreTest.xml"), "w", encoding="utf-8") as f:
        f.write(cm_xml)

    # 2. BSL Module for CatalogsCoreTest
    with open("tests/unit/CatalogsCoreTest.bsl", "r", encoding="utf-8") as f:
        bsl_core = f.read()

    bsl_wrapper = f"""Function RunVerification() Export
\tResults = RunAllTests();
\t
\t// Ghi file ket qua
\tLogPath = "C:/Users/Dung/Documents/1C_Enterprise/tests/unit/test_result.log";
\tTextW = New TextWriter(LogPath, TextEncoding.UTF8);
\tFor Each Line In Results.Log Do
\t\tTextW.WriteLine(Line);
\tEndDo;
\tTextW.Close();
\t
\tReturn Results;
EndFunction

{bsl_core}
"""
    with open(os.path.join(cm_dir, "CatalogsCoreTest", "Ext", "Module.bsl"), "w", encoding="utf-8") as f:
        f.write(bsl_wrapper)

    # 3. ManagedApplicationModule
    os.makedirs("src/Ext", exist_ok=True)
    mam_bsl = """Procedure OnStart()
\tIf LaunchParameter = "RunUnitTests" Then
\t\tCatalogsCoreTest.RunVerification();
\t\tExit(False);
\tEndIf;
EndProcedure
"""
    with open("src/Ext/ManagedApplicationModule.bsl", "w", encoding="utf-8") as f:
        f.write(mam_bsl)

    # 4. Update Configuration.xml to register CommonModule
    with open("src/Configuration.xml", "r", encoding="utf-8") as f:
        cfg = f.read()

    if "<CommonModule>CatalogsCoreTest</CommonModule>" not in cfg:
        cfg = cfg.replace(
            "\t\t</ChildObjects>",
            "\t\t\t<CommonModule>CatalogsCoreTest</CommonModule>\n\t\t</ChildObjects>"
        )
        with open("src/Configuration.xml", "w", encoding="utf-8") as f:
            f.write(cfg)

    print("Test runner setup complete!")

if __name__ == "__main__":
    setup_test_runner()
