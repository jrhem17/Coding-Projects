# Coding-Projects
Coding projects leveraging MATLAB &amp; Python.

Most scripts here support ATA 28 (fuel system) engineering reliability analysis, taking
in cleaned maintenance/discrepancy data and producing summary statistics, charts, and
exported reports.

## Scripts

- **Fuel_System_Data_Cleaner.m** — Imports a raw ATA 28 fuel system CSV export,
  standardizes column names, and normalizes text fields for downstream analysis.
- **Fuel_System_Reliability.m** — Loads the cleaned ATA 28 dataset and summarizes
  discrepancies by category, including a chart of the top discrepancy types.
- **ATA28_ROI1.m** — Transfer/XFLOW/SOV event analysis: filters transfer/crossflow
  discrepancies and breaks down repair outcomes.
- **ATA28_ROI2.m** — Refuel system investigation: builds a refuel-specific dataset for
  deeper analysis.
- **ATA28_ROI3.m** — Fuel leak analysis: isolates fuel leak discrepancies and checks for
  follow-on issues.
- **Aircraft_Data_Organizer.m** — Produces fleet-wide statistics (CRJ700 vs. CRJ900),
  including top repeating items, ATA chapter breakdowns, part commonality, outlier
  detection, and a dashboard data package (`DashboardData.mat`).
