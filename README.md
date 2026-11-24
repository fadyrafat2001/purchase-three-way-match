# Purchase order receipt and invoice matching

**Status: synthetic build-in-progress case study, not a completed Power BI report.**

Prepared with assistant support for review, testing and adaptation. This is not presented as prior independent work or a real company engagement. No confidential employer data is included.

## Business question
Which PO lines need review for billed quantity above receipts or invoice-price differences?

## Data and method
12 fictional PO lines with split receipts and invoices, 23 rows in each source. Aggregate receipts and invoices by PO line before joining. One orphan receipt and one orphan invoice are deliberately seeded for separate QA review.

## Reference results and limits
Matched synthetic invoice amount is EGP 46,970, with 3 exception lines, overbilled quantity 20 and invoice-price variance EGP 640. The orphan invoice amount EGP 1,485 is excluded from matched KPIs and disclosed separately. No fraud, approval, payment or policy-compliance conclusion is made.

All figures describe the designed synthetic scenario, not an actual business outcome. Reference calculations and input checks were performed outside Power BI. They are acceptance targets, not proof that the M, DAX or native model works.

## Included assets
Synthetic input data, data dictionary, model specification, Power Query M source, DAX measure source, report-build steps and expected-results tests. See the supplied build documentation for table grains, relationship directions, measure definitions, tests and exclusions.

## Not yet implemented or verified
A generated PBIX draft is included for testing in Power BI Desktop. This version has not been natively tested. M and DAX have not been executed in Power BI Desktop. Relationships, refresh, visuals, slicers, drill-through and interactions still need native implementation and testing. No RLS, incremental refresh, gateway or built-in time intelligence is claimed.

## Completion criteria
Import and type the source data; validate keys and relationships; create each measure; compare whole-data and filtered results; test interactions; save and reopen PBIX; record the Desktop version and refresh/test results; capture actual report and Model view screenshots. Update this status only after those checks pass.
