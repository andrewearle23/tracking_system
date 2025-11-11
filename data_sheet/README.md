Deal Tracking Workbook (Deal Number - Client - Product - 1A.xlsm)
📘 Overview

This Excel workbook serves as the data capture point for the Tracking Database system.
It is designed to collect, validate, and standardize deal and transport information before loading it into the central MySQL database.

⚙️ Key Features

Data Capture Interface

User-friendly front-end for entering and tracking operational data (Deal Number, Client, Product, Transport, Documentation, etc.)

Structured Excel tables ensure consistency across all captured data.

Power Query Integration

Automatically imports and refreshes master data (Clients, Mines, Transporters, Sub-Contractors, etc.).

Ensures dropdowns and data validation lists always reflect the latest reference data.

Data Validation & Consistency

All key fields use controlled dropdown lists from the Data Validation sheet.

Prevents free-text errors and enforces data integrity across deals and reports.

Automation via VBA Macros

Macros automate repetitive actions such as:

Refreshing reference data

Transferring deal data into structured tables

Clearing and resetting data entry forms

Building automated email lists and subject lines for tracking updates.

Designed to ensure minimal manual intervention and maximum accuracy.

Sheet Protection & Locking

Non-editable fields and formula areas are protected to maintain structure.

Only designated input cells are unlocked for user interaction.

🔄 Workflow Summary

Users record deal and transport details in the Tracking Report sheet.

Power Query keeps reference data up to date for dropdowns.

Macros validate inputs and push the clean data into the Data Table sheet.

ETL pipeline (Python/MySQL) ingests this table into the central Tracking Database.

