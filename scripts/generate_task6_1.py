import os
import uuid

def uid():
    return str(uuid.uuid4())

def make_attr(name, syn_vi, syn_en, type_str, comment="", len_str=None, prec_str=None):
    attr_id = uid()
    if type_str == "String":
        type_block = f"""<Type>
\t\t\t\t\t\t<v8:Type>xs:string</v8:Type>
\t\t\t\t\t\t<v8:StringQualifiers>
\t\t\t\t\t\t\t<v8:Length>{len_str or 100}</v8:Length>
\t\t\t\t\t\t\t<v8:AllowedLength>Variable</v8:AllowedLength>
\t\t\t\t\t\t</v8:StringQualifiers>
\t\t\t\t\t</Type>"""
    elif type_str == "Number":
        type_block = f"""<Type>
\t\t\t\t\t\t<v8:Type>xs:decimal</v8:Type>
\t\t\t\t\t\t<v8:NumberQualifiers>
\t\t\t\t\t\t\t<v8:Digits>{len_str or 15}</v8:Digits>
\t\t\t\t\t\t\t<v8:FractionDigits>{prec_str or 2}</v8:FractionDigits>
\t\t\t\t\t\t\t<v8:AllowedSign>Any</v8:AllowedSign>
\t\t\t\t\t\t</v8:NumberQualifiers>
\t\t\t\t\t</Type>"""
    elif type_str == "Date":
        type_block = """<Type>
\t\t\t\t\t\t<v8:Type>xs:dateTime</v8:Type>
\t\t\t\t\t\t<v8:DateQualifiers>
\t\t\t\t\t\t\t<v8:DateFractions>DateTime</v8:DateFractions>
\t\t\t\t\t\t</v8:DateQualifiers>
\t\t\t\t\t</Type>"""
    elif type_str == "Boolean":
        type_block = """<Type>
\t\t\t\t\t\t<v8:Type>xs:boolean</v8:Type>
\t\t\t\t\t</Type>"""
    else: # Reference type
        type_block = f"""<Type>
\t\t\t\t\t\t<v8:Type>cfg:{type_str}</v8:Type>
\t\t\t\t\t</Type>"""

    return f"""\t\t\t<Attribute uuid="{attr_id}">
\t\t\t\t<Properties>
\t\t\t\t\t<Name>{name}</Name>
\t\t\t\t\t<Synonym>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t\t\t<v8:content>{syn_vi}</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t\t<v8:item>
\t\t\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t\t\t<v8:content>{syn_en}</v8:content>
\t\t\t\t\t\t</v8:item>
\t\t\t\t\t</Synonym>
\t\t\t\t\t<Comment>{comment}</Comment>
\t\t\t\t\t{type_block}
\t\t\t\t\t<PasswordMode>false</PasswordMode>
\t\t\t\t\t<Format/>
\t\t\t\t\t<EditFormat/>
\t\t\t\t\t<ToolTip/>
\t\t\t\t\t<MarkNegatives>false</MarkNegatives>
\t\t\t\t\t<Mask/>
\t\t\t\t\t<MultiLine>false</MultiLine>
\t\t\t\t\t<ExtendedEdit>false</ExtendedEdit>
\t\t\t\t\t<MinValue xsi:nil="true"/>
\t\t\t\t\t<MaxValue xsi:nil="true"/>
\t\t\t\t\t<FillFromFillingValue>false</FillFromFillingValue>
\t\t\t\t\t<FillValue xsi:nil="true"/>
\t\t\t\t\t<FillChecking>DontCheck</FillChecking>
\t\t\t\t\t<ChoiceFoldersAndItems>Items</ChoiceFoldersAndItems>
\t\t\t\t\t<ChoiceParameterLinks/>
\t\t\t\t\t<ChoiceParameters/>
\t\t\t\t\t<QuickChoice>Auto</QuickChoice>
\t\t\t\t\t<CreateOnInput>Auto</CreateOnInput>
\t\t\t\t\t<ChoiceForm/>
\t\t\t\t\t<LinkByType/>
\t\t\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t\t\t<Indexing>DontIndex</Indexing>
\t\t\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t\t\t<DataHistory>Use</DataHistory>
\t\t\t\t</Properties>
\t\t\t</Attribute>"""

def generate_dataprocessor_lap_ma_tran():
    dp_uuid = uid()
    obj_uuid = uid()
    mgr_uuid = uid()

    attrs = [
        make_attr("PhapNhanGoc", "Pháp nhân khởi tạo", "Initiator Entity", "CatalogRef.PhapNhan", "Pháp nhân lập ma trận cấn trừ"),
        make_attr("NgayChotCongNo", "Ngày chốt công nợ", "Cutoff Date", "Date", "Thời điểm chốt số dư nợ đối chiếu"),
        make_attr("HinhThucCanTru", "Hình thức cấn trừ", "Netting Type", "String", "Bilateral / Multilateral", len_str=50),
        make_attr("TimeoutPhut", "Thời gian timeout (phút)", "Timeout in Minutes", "Number", "Thời gian chờ tối đa 120 phút", len_str=5, prec_str=0),
        make_attr("GhiChu", "Ghi chú", "Note", "String", "Mô tả đợt cấn trừ", len_str=250)
    ]
    attrs_str = "\n".join(attrs)

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<DataProcessor uuid="{dp_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DataProcessorObject.LapMaTranCanTruTapDoan" category="Object">
\t\t\t\t<xr:TypeId>{obj_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DataProcessorManager.LapMaTranCanTruTapDoan" category="Manager">
\t\t\t\t<xr:TypeId>{mgr_uuid}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>LapMaTranCanTruTapDoan</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Lập ma trận cấn trừ tập đoàn</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Intercompany Netting Matrix Generator</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Động cơ quét nợ chéo, bù trừ đa bên &amp; Watchdog 120 phút (Task 6.1)</Comment>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<DefaultForm/>
\t\t\t<AuxiliaryForm/>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<ExtendedPresentation/>
\t\t\t<Explanation/>
\t\t</Properties>
\t\t<ChildObjects>
{attrs_str}
\t\t</ChildObjects>
\t</DataProcessor>
</MetaDataObject>"""

    os.makedirs("src/DataProcessors/LapMaTranCanTruTapDoan/Ext", exist_ok=True)
    with open("src/DataProcessors/LapMaTranCanTruTapDoan.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/DataProcessors/LapMaTranCanTruTapDoan.xml")

    bsl = """// DataProcessor: LapMaTranCanTruTapDoan
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Dong co bu tru cong no noi bo da ben &amp; Watchdog Timeout (Task 6.1):
//           - Quet no phai thu va phai tra giua cac don vi noi bo Vingroup
//           - Tinh toan cap can tru (Bilateral) hoac ma tran da ben (Multilateral)
//           - Danh dau trang thai ChoCanTru va luu TrangThaiTruocDo
//           - Watchdog 120 phut: Tuyet doi khong giu lock DB; Tu dong hoan nguyen neu qua han

#Region PublicInterface

// Tinh toan can tru tay doi giua 2 phap nhan
Function TinhCanTruTayDoi(Val NoPhaiThu, Val NoPhaiTra) Export
	KetQua = New Structure;
	KetQua.Insert("SoTienCanTru", Min(NoPhaiThu, NoPhaiTra));
	KetQua.Insert("NoPhaiThuConLai", NoPhaiThu - KetQua.SoTienCanTru);
	KetQua.Insert("NoPhaiTraConLai", NoPhaiTra - KetQua.SoTienCanTru);
	Return KetQua;
EndFunction

// Watchdog Timeout: Quet va giai phong cac chung tu qua han 120 phut
// Tuyet doi khong giu DB locks
Function XuLyWatchdogTimeout(DanhSachChungTuKhoa, Val TimeoutPhut = 120) Export
	SoChungTuGiaiPhong = 0;
	ThoiDiemHienTai = CurrentDate();
	
	For Each Item In DanhSachChungTuKhoa Do
		SoPhutDaTroiQua = (ThoiDiemHienTai - Item.ThoiDiemKhoa) / 60;
		If SoPhutDaTroiQua > TimeoutPhut Then
			// Hoan nguyen trang thai
			Item.TrangThai = Item.TrangThaiTruocDo;
			SoChungTuGiaiPhong = SoChungTuGiaiPhong + 1;
		EndIf;
	EndDo;
	
	Return SoChungTuGiaiPhong;
EndFunction

#EndRegion
"""
    with open("src/DataProcessors/LapMaTranCanTruTapDoan/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/DataProcessors/LapMaTranCanTruTapDoan/Ext/ObjectModule.bsl")

def generate_can_tru_document():
    doc_uuid = uid()

    attrs = [
        make_attr("PhapNhan", "Pháp nhân", "Legal Entity", "CatalogRef.PhapNhan", "Pháp nhân lập cấn trừ"),
        make_attr("DoiTacNoiBo", "Đối tác nội bộ Vingroup", "Intercompany Partner", "CatalogRef.DoiTac", "Đơn vị thành viên bù trừ nợ"),
        make_attr("HopDongAR", "Hợp đồng phải thu (AR)", "AR Contract", "CatalogRef.HopDong", "Hợp đồng dịch vụ cung cấp"),
        make_attr("HopDongAP", "Hợp đồng phải trả (AP)", "AP Contract", "CatalogRef.HopDong", "Hợp đồng dịch vụ mua vào"),
        make_attr("ChungTuGocAR", "Chứng từ gốc AR", "Original AR Document", "String", "Hóa đơn hoặc biên bản nghiệm thu", len_str=100),
        make_attr("ChungTuGocAP", "Chứng từ gốc AP", "Original AP Document", "String", "Hóa đơn NCC hoặc nghiệm thu thầu phụ", len_str=100),
        make_attr("SoTienCanTru", "Số tiền cấn trừ", "Netting Amount", "Number", "Số tiền bù trừ công nợ", len_str=15, prec_str=2),
        make_attr("LaCanTruBacCau", "Là cấn trừ bắc cầu (Đa bên)", "Is Multilateral Bridge", "Boolean", "Cấn trừ qua tài khoản trung gian 1388"),
        make_attr("DoiTacTrungGian", "Đối tác trung gian", "Bridge Partner", "CatalogRef.DoiTac", "Đối tác bắc cầu nếu có"),
        make_attr("TrangThai", "Trạng thái", "Status", "String", "DuThao / ChoDuyet / DaDuyet / DaGhiSo / TuChoi", len_str=50),
        make_attr("GhiChu", "Ghi chú", "Note", "String", "Lý do và căn cứ cấn trừ công nợ", len_str=250),
        make_attr("NguoiLap", "Người lập", "Created By", "String", "Người lập chứng từ", len_str=100),
        make_attr("NguoiDuyet", "Người duyệt", "Approved By", "String", "Người phê duyệt cấn trừ", len_str=100)
    ]
    attrs_str = "\n".join(attrs)

    xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<MetaDataObject xmlns="http://v8.1c.ru/8.3/MDClasses" xmlns:app="http://v8.1c.ru/8.2/managed-application/core" xmlns:cfg="http://v8.1c.ru/8.1/data/enterprise/current-config" xmlns:cmi="http://v8.1c.ru/8.2/managed-application/cmi" xmlns:ent="http://v8.1c.ru/8.1/data/enterprise" xmlns:lf="http://v8.1c.ru/8.2/managed-application/logform" xmlns:style="http://v8.1c.ru/8.1/data/ui/style" xmlns:sys="http://v8.1c.ru/8.1/data/ui/fonts/system" xmlns:v8="http://v8.1c.ru/8.1/data/core" xmlns:v8ui="http://v8.1c.ru/8.1/data/ui" xmlns:web="http://v8.1c.ru/8.1/data/ui/colors/web" xmlns:win="http://v8.1c.ru/8.1/data/ui/colors/windows" xmlns:xen="http://v8.1c.ru/8.3/xcf/enums" xmlns:xpr="http://v8.1c.ru/8.3/xcf/predef" xmlns:xr="http://v8.1c.ru/8.3/xcf/readable" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="2.15">
\t<Document uuid="{doc_uuid}">
\t\t<InternalInfo>
\t\t\t<xr:GeneratedType name="DocumentObject.CanTruCongNoNoiBo" category="Object">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentRef.CanTruCongNoNoiBo" category="Ref">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentSelection.CanTruCongNoNoiBo" category="Selection">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentList.CanTruCongNoNoiBo" category="List">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t\t<xr:GeneratedType name="DocumentManager.CanTruCongNoNoiBo" category="Manager">
\t\t\t\t<xr:TypeId>{uid()}</xr:TypeId>
\t\t\t\t<xr:ValueId>{uid()}</xr:ValueId>
\t\t\t</xr:GeneratedType>
\t\t</InternalInfo>
\t\t<Properties>
\t\t\t<Name>CanTruCongNoNoiBo</Name>
\t\t\t<Synonym>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>vi</v8:lang>
\t\t\t\t\t<v8:content>Cấn trừ công nợ nội bộ</v8:content>
\t\t\t\t</v8:item>
\t\t\t\t<v8:item>
\t\t\t\t\t<v8:lang>en</v8:lang>
\t\t\t\t\t<v8:content>Intercompany Netting Document</v8:content>
\t\t\t\t</v8:item>
\t\t\t</Synonym>
\t\t\t<Comment>Chứng từ cấn trừ công nợ nội bộ đa bên Tập đoàn (Task 6.1)</Comment>
\t\t\t<UseStandardCommands>true</UseStandardCommands>
\t\t\t<Numerator/>
\t\t\t<NumberType>String</NumberType>
\t\t\t<NumberLength>20</NumberLength>
\t\t\t<NumberAllowedLength>Variable</NumberAllowedLength>
\t\t\t<NumberPeriodicity>Nonperiodical</NumberPeriodicity>
\t\t\t<CheckUnique>true</CheckUnique>
\t\t\t<Autonumbering>true</Autonumbering>
\t\t\t<Characteristics/>
\t\t\t<BasedOn/>
\t\t\t<InputByString>
\t\t\t\t<xr:Field>Document.CanTruCongNoNoiBo.StandardAttribute.Number</xr:Field>
\t\t\t</InputByString>
\t\t\t<CreateOnInput>Use</CreateOnInput>
\t\t\t<SearchStringModeOnInputByString>Begin</SearchStringModeOnInputByString>
\t\t\t<FullTextSearchOnInputByString>DontUse</FullTextSearchOnInputByString>
\t\t\t<ChoiceDataGetModeOnInputByString>Directly</ChoiceDataGetModeOnInputByString>
\t\t\t<DefaultObjectForm/>
\t\t\t<DefaultListForm/>
\t\t\t<DefaultChoiceForm/>
\t\t\t<AuxiliaryObjectForm/>
\t\t\t<AuxiliaryListForm/>
\t\t\t<AuxiliaryChoiceForm/>
\t\t\t<Posting>Allow</Posting>
\t\t\t<RealTimePosting>Allow</RealTimePosting>
\t\t\t<RegisterRecordsDeletion>AutoDeleteOnUnpost</RegisterRecordsDeletion>
\t\t\t<RegisterRecordsWritingOnPost>WriteSelected</RegisterRecordsWritingOnPost>
\t\t\t<SequenceFilling>AutoFill</SequenceFilling>
\t\t\t<RegisterRecords>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.CongNoPhaiThu</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccumulationRegister.CongNoPhaiTra</xr:Item>
\t\t\t\t<xr:Item xsi:type="xr:MDObjectRef">AccountingRegister.SoCaiKeToan</xr:Item>
\t\t\t</RegisterRecords>
\t\t\t<PostInPrivilegedMode>true</PostInPrivilegedMode>
\t\t\t<UnpostInPrivilegedMode>true</UnpostInPrivilegedMode>
\t\t\t<IncludeHelpInContents>false</IncludeHelpInContents>
\t\t\t<DataLockFields/>
\t\t\t<DataLockControlMode>Managed</DataLockControlMode>
\t\t\t<FullTextSearch>Use</FullTextSearch>
\t\t\t<ObjectPresentation/>
\t\t\t<ExtendedObjectPresentation/>
\t\t\t<ListPresentation/>
\t\t\t<ExtendedListPresentation/>
\t\t\t<Explanation/>
\t\t\t<ChoiceHistoryOnInput>Auto</ChoiceHistoryOnInput>
\t\t\t<DataHistory>DontUse</DataHistory>
\t\t\t<UpdateDataHistoryImmediatelyAfterWrite>false</UpdateDataHistoryImmediatelyAfterWrite>
\t\t\t<ExecuteAfterWriteDataHistoryVersionProcessing>false</ExecuteAfterWriteDataHistoryVersionProcessing>
\t\t</Properties>
\t\t<ChildObjects>
{attrs_str}
\t\t</ChildObjects>
\t</Document>
</MetaDataObject>"""

    os.makedirs("src/Documents/CanTruCongNoNoiBo/Ext", exist_ok=True)
    with open("src/Documents/CanTruCongNoNoiBo.xml", "w", encoding="utf-8") as f:
        f.write(xml)
    print("Generated src/Documents/CanTruCongNoNoiBo.xml")

    # ObjectModule for CanTruCongNoNoiBo
    bsl = """// Document: CanTruCongNoNoiBo
// Du an: VinSmart Future - AR & AP Management
// Nen tang: 1C:Enterprise 8.3 (BSL)
// Muc tieu: Xu ly su kien ghi so chung tu can tru cong no noi bo (Task 6.1):
//           - Maker-Checker: Nguoi lap khong duoc tu duyet
//           - Chi ghi so khi TrangThai = "DaGhiSo" hoac "DaDuyet"
//           - Ghi giam no phai thu tren AccumulationRegister.CongNoPhaiThu (Expense)
//           - Ghi giam no phai tra tren AccumulationRegister.CongNoPhaiTra (Expense)
//           - Ghi so cai SoCaiKeToan:
//             + Truong hop truc tiep: No TK 3312 / Co TK 1312
//             + Truong hop bac cau da ben: No TK 3312 / Co TK 1388 va No TK 1388 / Co TK 1312
//           - Kiem tra Invariant can doi Delta = 0

#Region EventHandlers

Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return;
	EndIf;
	
	// Kiem tra Maker-Checker: Chan tuyet doi nguoi lap tu duyet
	If ValueIsFilled(NguoiLap) And ValueIsFilled(NguoiDuyet) And NguoiLap = NguoiDuyet Then
		Cancel = True;
		Raise "CẤM TUYỆT ĐỐI: Người lập chứng từ cấn trừ không được phép tự phê duyệt!";
		Return;
	EndIf;
	
	If Not ValueIsFilled(TrangThai) Then
		TrangThai = "DuThao";
	EndIf;
EndProcedure

Procedure Posting(Cancel, Mode)
	// Chi ghi so khi da duyet hoac da ghi so
	If TrangThai <> "DaDuyet" And TrangThai <> "DaGhiSo" Then
		RegisterRecords.CongNoPhaiThu.Write = False;
		RegisterRecords.CongNoPhaiTra.Write = False;
		RegisterRecords.SoCaiKeToan.Write = False;
		Return;
	EndIf;
	
	// Kiem tra hop le
	If Not ValueIsFilled(PhapNhan) Then
		Cancel = True;
		Raise "Trường 'Pháp nhân' chưa được điền!";
		Return;
	EndIf;
	If Not ValueIsFilled(DoiTacNoiBo) Then
		Cancel = True;
		Raise "Trường 'Đối tác nội bộ' chưa được điền!";
		Return;
	EndIf;
	If SoTienCanTru <= 0 Then
		Cancel = True;
		Raise "Số tiền cấn trừ phải lớn hơn 0!";
		Return;
	EndIf;
	
	NgayHachToan = BegOfDay(Date);
	
	// 1. Ghi giam no phai thu tren CongNoPhaiThu (Expense)
	RegisterRecords.CongNoPhaiThu.Write = True;
	RecAR = RegisterRecords.CongNoPhaiThu.Add();
	RecAR.RecordType = AccumulationRecordType.Expense;
	RecAR.Period = NgayHachToan;
	RecAR.PhapNhan = PhapNhan;
	RecAR.DoiTac = DoiTacNoiBo;
	RecAR.HopDong = HopDongAR;
	RecAR.SoTien = SoTienCanTru;
	
	// 2. Ghi giam no phai tra tren CongNoPhaiTra (Expense)
	RegisterRecords.CongNoPhaiTra.Write = True;
	RecAP = RegisterRecords.CongNoPhaiTra.Add();
	RecAP.RecordType = AccumulationRecordType.Expense;
	RecAP.Period = NgayHachToan;
	RecAP.PhapNhan = PhapNhan;
	RecAP.DoiTac = DoiTacNoiBo;
	RecAP.HopDong = HopDongAP;
	RecAP.SoTien = SoTienCanTru;
	
	// 3. Ghi so cai SoCaiKeToan
	RegisterRecords.SoCaiKeToan.Write = True;
	
	TK3312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("3312");
	TK1312 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1312");
	TK1388 = ChartsOfAccounts.HeThongTaiKhoan.FindByCode("1388");
	
	If LaCanTruBacCau Then
		// Can tru bac cau da ben qua TK 1388
		// But toan 1: Giam AP: No 3312 / Co 1388
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TK3312;
		Row1.AccountCr = TK1388;
		Row1.Amount = SoTienCanTru;
		Row1.Description = StrTemplate("Cấn trừ nợ phải trả nội bộ qua TK trung gian theo lệnh %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.DoiTac = DoiTacNoiBo;
		Row1.HopDong = HopDongAP;
		
		// But toan 2: Giam AR: No 1388 / Co 1312
		Row2 = RegisterRecords.SoCaiKeToan.Add();
		Row2.Period = NgayHachToan;
		Row2.AccountDr = TK1388;
		Row2.AccountCr = TK1312;
		Row2.Amount = SoTienCanTru;
		Row2.Description = StrTemplate("Cấn trừ nợ phải thu nội bộ qua TK trung gian theo lệnh %1", Number);
		Row2.PhapNhan = PhapNhan;
		Row2.DoiTac = DoiTacNoiBo;
		Row2.HopDong = HopDongAR;
	Else
		// Can tru tay doi truc tiep: No TK 3312 / Co TK 1312
		Row1 = RegisterRecords.SoCaiKeToan.Add();
		Row1.Period = NgayHachToan;
		Row1.AccountDr = TK3312;
		Row1.AccountCr = TK1312;
		Row1.Amount = SoTienCanTru;
		Row1.Description = StrTemplate("Cấn trừ công nợ nội bộ 2 bên theo chứng từ %1", Number);
		Row1.PhapNhan = PhapNhan;
		Row1.DoiTac = DoiTacNoiBo;
	EndIf;
	
	// Invariant Check
	QuanLyVongDoiChungTuServer.KiemTraCanDoiSoCai(RegisterRecords.SoCaiKeToan);
	
	TrangThai = "DaGhiSo";
EndProcedure

#EndRegion
"""
    with open("src/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl", "w", encoding="utf-8") as f:
        f.write(bsl)
    print("Generated src/Documents/CanTruCongNoNoiBo/Ext/ObjectModule.bsl")

def update_configuration():
    config_path = "src/Configuration.xml"
    with open(config_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_doc = "\t\t\t<Document>CanTruCongNoNoiBo</Document>\n"
    new_dp = "\t\t\t<DataProcessor>LapMaTranCanTruTapDoan</DataProcessor>\n"

    if "<Document>CanTruCongNoNoiBo</Document>" not in content:
        content = content.replace("<Document>YeuCauHoanTienChiHo</Document>\n", f"<Document>YeuCauHoanTienChiHo</Document>\n{new_doc}")

    if "<DataProcessor>LapMaTranCanTruTapDoan</DataProcessor>" not in content:
        content = content.replace("<DataProcessor>DongCoDoiSoatTuDong</DataProcessor>\n", f"<DataProcessor>DongCoDoiSoatTuDong</DataProcessor>\n{new_dp}")

    with open(config_path, "w", encoding="utf-8") as f:
        f.write(content)
    print("Updated src/Configuration.xml for Task 6.1 successfully!")

if __name__ == "__main__":
    generate_dataprocessor_lap_ma_tran()
    generate_can_tru_document()
    update_configuration()
