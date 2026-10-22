SELECT
	"AR" AS LoaiCongNo,
	AR.PhapNhan AS PhapNhan,
	AR.DoiTac AS DoiTac,
	AR.HopDong AS HopDong,
	AR.ChungTuGoc AS ChungTuGoc,
	ISNULL(BBNT.Date, ARInvoice.Date) AS NgayChungTu,
	ContractRow.HanThanhToanNgay AS HanThanhToanNgay,
	AR.SoTienBalance AS SoDuConLai,
	ISNULL(ARInvoice.TienTe, VND.Ref) AS TienTe,
	CASE WHEN ContractRow.HanThanhToanNgay IS NULL OR ISNULL(BBNT.Date, ARInvoice.Date) IS NULL THEN NULL
		ELSE DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay) END AS NgayDenHan,
	CASE WHEN ContractRow.HanThanhToanNgay IS NULL OR ISNULL(BBNT.Date, ARInvoice.Date) IS NULL THEN "ChuaXacDinhHan"
		WHEN DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay) >= BEGINOFPERIOD(&NgayChot, DAY) THEN "TrongHan"
		WHEN DATEDIFF(DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay), BEGINOFPERIOD(&NgayChot, DAY), DAY) <= 30 THEN "QuaHan1Den30"
		WHEN DATEDIFF(DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay), BEGINOFPERIOD(&NgayChot, DAY), DAY) <= 60 THEN "QuaHan31Den60"
		WHEN DATEDIFF(DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay), BEGINOFPERIOD(&NgayChot, DAY), DAY) <= 90 THEN "QuaHan61Den90"
		ELSE "Tren90Ngay" END AS NhomTuoiNo,
	CASE WHEN ContractRow.HanThanhToanNgay IS NULL OR ISNULL(BBNT.Date, ARInvoice.Date) IS NULL THEN 0
		WHEN DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay) >= BEGINOFPERIOD(&NgayChot, DAY)
			THEN DATEDIFF(BEGINOFPERIOD(&NgayChot, DAY), DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay), DAY)
		ELSE 0 END AS SoNgayDenHan,
	CASE WHEN ContractRow.HanThanhToanNgay IS NULL OR ISNULL(BBNT.Date, ARInvoice.Date) IS NULL THEN 0
		WHEN DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay) < BEGINOFPERIOD(&NgayChot, DAY)
			THEN DATEDIFF(DATEADD(BEGINOFPERIOD(ISNULL(BBNT.Date, ARInvoice.Date), DAY), DAY, ContractRow.HanThanhToanNgay), BEGINOFPERIOD(&NgayChot, DAY), DAY)
		ELSE 0 END AS SoNgayQuaHan
FROM
	AccumulationRegister.CongNoPhaiThu.Balance(DATEADD(&NgayChot, DAY, 1), ) AS AR
	LEFT JOIN Document.BienBanNghiemThuGiaiDoan AS BBNT ON BBNT.Ref = AR.ChungTuGoc
	LEFT JOIN Document.HoaDonGTGTDauRa AS ARInvoice ON ARInvoice.Ref = AR.ChungTuGoc
	LEFT JOIN Catalog.HopDong AS ContractRow ON ContractRow.Ref = AR.HopDong
	LEFT JOIN Catalog.TienTe AS VND ON VND.Code = "VND"
WHERE
	AR.SoTienBalance > 0
	AND (BBNT.Ref IS NULL OR (BBNT.Posted = TRUE AND BBNT.DeletionMark = FALSE))
	AND (ARInvoice.Ref IS NULL OR (ARInvoice.Posted = TRUE AND ARInvoice.DeletionMark = FALSE))

UNION ALL

SELECT
	"AP" AS LoaiCongNo,
	AP.PhapNhan AS PhapNhan,
	AP.DoiTac AS DoiTac,
	AP.HopDong AS HopDong,
	AP.ChungTuGoc AS ChungTuGoc,
	APInvoice.Date AS NgayChungTu,
	ContractRow.HanThanhToanNgay AS HanThanhToanNgay,
	AP.SoTienBalance AS SoDuConLai,
	ISNULL(APInvoice.TienTe, VND.Ref) AS TienTe,
	CASE WHEN ContractRow.HanThanhToanNgay IS NULL OR APInvoice.Date IS NULL THEN NULL
		ELSE DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay) END AS NgayDenHan,
	CASE WHEN ContractRow.HanThanhToanNgay IS NULL OR APInvoice.Date IS NULL THEN "ChuaXacDinhHan"
		WHEN DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay) >= BEGINOFPERIOD(&NgayChot, DAY) THEN "TrongHan"
		WHEN DATEDIFF(DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay), BEGINOFPERIOD(&NgayChot, DAY), DAY) <= 30 THEN "QuaHan1Den30"
		WHEN DATEDIFF(DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay), BEGINOFPERIOD(&NgayChot, DAY), DAY) <= 60 THEN "QuaHan31Den60"
		WHEN DATEDIFF(DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay), BEGINOFPERIOD(&NgayChot, DAY), DAY) <= 90 THEN "QuaHan61Den90"
		ELSE "Tren90Ngay" END AS NhomTuoiNo,
	CASE WHEN ContractRow.HanThanhToanNgay IS NULL OR APInvoice.Date IS NULL THEN 0
		WHEN DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay) >= BEGINOFPERIOD(&NgayChot, DAY)
			THEN DATEDIFF(BEGINOFPERIOD(&NgayChot, DAY), DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay), DAY)
		ELSE 0 END AS SoNgayDenHan,
	CASE WHEN ContractRow.HanThanhToanNgay IS NULL OR APInvoice.Date IS NULL THEN 0
		WHEN DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay) < BEGINOFPERIOD(&NgayChot, DAY)
			THEN DATEDIFF(DATEADD(BEGINOFPERIOD(APInvoice.Date, DAY), DAY, ContractRow.HanThanhToanNgay), BEGINOFPERIOD(&NgayChot, DAY), DAY)
		ELSE 0 END AS SoNgayQuaHan
FROM
	AccumulationRegister.CongNoPhaiTra.Balance(DATEADD(&NgayChot, DAY, 1), ) AS AP
	LEFT JOIN Document.HoaDonNhaCungCap AS APInvoice ON APInvoice.Ref = AP.ChungTuGoc
	LEFT JOIN Catalog.HopDong AS ContractRow ON ContractRow.Ref = AP.HopDong
	LEFT JOIN Catalog.TienTe AS VND ON VND.Code = "VND"
WHERE
	AP.SoTienBalance > 0
	AND (APInvoice.Ref IS NULL OR (APInvoice.Posted = TRUE AND APInvoice.DeletionMark = FALSE))
