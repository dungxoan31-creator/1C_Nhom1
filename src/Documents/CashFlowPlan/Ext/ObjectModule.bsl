Procedure Posting(Cancel, Mode)
	RegisterRecords.CashFlowPlan.Write = True;
	For Each Row In PlannedPayments Do
		Record = RegisterRecords.CashFlowPlan.Add();
		Record.Period = Date;
		Record.CashFlowItem = Row.CashFlowItem;
		Record.Counterparty = Row.Counterparty;
		Record.PlannedAmount = Row.PlannedAmount;
	EndDo;
EndProcedure

Procedure FillFromDueDates(BeginDate, EndDate) Export
	Query = New Query;
	Query.Text = 
	"SELECT
	|	AP.Counterparty AS Counterparty,
	|	AP.Contract AS Contract,
	|	AP.Invoice.CashFlowItem AS CashFlowItem,
	|	AP.Invoice.DueDate AS PlannedDueDate,
	|	SUM(AP.AmountBalance) AS PlannedAmount
	|FROM
	|	AccumulationRegister.AccountsPayable.Balance AS AP
	|WHERE
	|	AP.Invoice.DueDate >= &BeginDate
	|	AND AP.Invoice.DueDate <= &EndDate
	|GROUP BY
	|	AP.Counterparty,
	|	AP.Contract,
	|	AP.Invoice.CashFlowItem,
	|	AP.Invoice.DueDate";
	Query.SetParameter("BeginDate", BeginDate);
	Query.SetParameter("EndDate", EndDate);
	
	Result = Query.Execute();
	Selection = Result.Select();
	PlannedPayments.Clear();
	Total = 0;
	While Selection.Next() Do
		NewRow = PlannedPayments.Add();
		NewRow.Counterparty = Selection.Counterparty;
		NewRow.Contract = Selection.Contract;
		NewRow.CashFlowItem = Selection.CashFlowItem;
		NewRow.PlannedDueDate = Selection.PlannedDueDate;
		NewRow.PlannedAmount = Selection.PlannedAmount;
		Total = Total + Selection.PlannedAmount;
	EndDo;
	TotalPlannedAmount = Total;
EndProcedure
