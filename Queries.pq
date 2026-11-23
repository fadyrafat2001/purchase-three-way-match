// UNEXECUTED M SOURCE. Create text parameter WorkbookPath with full local XLSX path.
// Create this function as fxSheet; invoke it once per data sheet below.
(sheetName as text) as table =>
let
    Source = Excel.Workbook(File.Contents(WorkbookPath), null, true),
    Data = Source{[Item=sheetName, Kind="Sheet"]}[Data],
    Headers = Table.PromoteHeaders(Data, [PromoteAllScalars=true])
in
    Headers

// Separate query named PurchaseOrders:
let
    Source = fxSheet("PurchaseOrders"),
    Typed = Table.TransformColumnTypes(Source, {{"PO_Line", type text}, {"Supplier", type text}, {"Month", type text}, {"Ordered_Qty", type number}, {"PO_UnitPrice_EGP", type number}}, "en-US")
in
    Typed

// Separate query named Receipts:
let
    Source = fxSheet("Receipts"),
    Typed = Table.TransformColumnTypes(Source, {{"Receipt_ID", type text}, {"PO_Line", type text}, {"Receipt_Qty", type number}}, "en-US")
in
    Typed

// Separate query named Invoices:
let
    Source = fxSheet("Invoices"),
    Typed = Table.TransformColumnTypes(Source, {{"Invoice_ID", type text}, {"PO_Line", type text}, {"Invoice_Qty", type number}, {"Invoice_UnitPrice_EGP", type number}}, "en-US")
in
    Typed

// Separate query named FactMatch:
let
    Source = fxSheet("FactMatch"),
    Typed = Table.TransformColumnTypes(Source, {{"PO_Line", type text}, {"Supplier", type text}, {"Month", type text}, {"Ordered_Qty", type number}, {"PO_UnitPrice_EGP", type number}, {"Received_Qty", type number}, {"Invoiced_Qty", type number}, {"Invoice_Amount_EGP", type number}, {"Overbilled_Qty", type number}, {"Overreceived_Qty", type number}, {"Invoice_Price_Variance_EGP", type number}, {"Exception_Flag", type number}}, "en-US")
in
    Typed

// Separate query named DimSupplier:
let
    Source = fxSheet("DimSupplier"),
    Typed = Table.TransformColumnTypes(Source, {{"Supplier", type text}}, "en-US")
in
    Typed

// Separate query named DimMonth:
let
    Source = fxSheet("DimMonth"),
    Typed = Table.TransformColumnTypes(Source, {{"Month", type text}}, "en-US")
in
    Typed

// OPTIONAL REPLACEMENT FactMatch QUERY. UNEXECUTED.
// First create typed PurchaseOrders, Receipts and Invoices using the query blocks above.
// Aggregate both many-side tables BEFORE any join. Never join raw receipt and invoice rows together.
let
    RG = Table.Group(Receipts, {"PO_Line"}, {{"Received_Qty", each List.Sum([Receipt_Qty]), type number}}),
    IA = Table.AddColumn(Invoices, "LineAmount", each [Invoice_Qty] * [Invoice_UnitPrice_EGP], type number),
    IG = Table.Group(IA, {"PO_Line"}, {{"Invoiced_Qty", each List.Sum([Invoice_Qty]), type number}, {"Invoice_Amount_EGP", each List.Sum([LineAmount]), type number}}),
    JR = Table.NestedJoin(PurchaseOrders, {"PO_Line"}, RG, {"PO_Line"}, "R", JoinKind.LeftOuter),
    ER = Table.ExpandTableColumn(JR, "R", {"Received_Qty"}),
    JI = Table.NestedJoin(ER, {"PO_Line"}, IG, {"PO_Line"}, "I", JoinKind.LeftOuter),
    EI = Table.ExpandTableColumn(JI, "I", {"Invoiced_Qty", "Invoice_Amount_EGP"}),
    Z = Table.ReplaceValue(EI, null, 0, Replacer.ReplaceValue, {"Received_Qty", "Invoiced_Qty", "Invoice_Amount_EGP"}),
    Q = Table.AddColumn(Z, "Overbilled_Qty", each List.Max({[Invoiced_Qty]-[Received_Qty],0}), type number),
    O = Table.AddColumn(Q, "Overreceived_Qty", each List.Max({[Received_Qty]-[Ordered_Qty],0}), type number),
    P = Table.AddColumn(O, "Invoice_Price_Variance_EGP", each [Invoice_Amount_EGP]-[Invoiced_Qty]*[PO_UnitPrice_EGP], type number),
    F = Table.AddColumn(P, "Exception_Flag", each if [Overbilled_Qty]>0 or [Overreceived_Qty]>0 or Number.Abs([Invoice_Price_Variance_EGP])>0.01 then 1 else 0, Int64.Type)
in
    F

// Separate audit query named OrphanReceipts (load as QA evidence, no relationship):
Table.NestedJoin(Receipts, {"PO_Line"}, PurchaseOrders, {"PO_Line"}, "PO", JoinKind.LeftAnti)

// Separate audit query named OrphanInvoices (load as QA evidence, no relationship):
Table.NestedJoin(Invoices, {"PO_Line"}, PurchaseOrders, {"PO_Line"}, "PO", JoinKind.LeftAnti)
