# 📦 Transport Operations Data System

**Excel → Python ETL → MySQL → Power BI**

This project is an end-to-end data pipeline designed to manage, track, and analyse cross-border transport operations.  
It replaces manual spreadsheets with a fully integrated system comprising:

- A structured Excel data capture workbook  
- A Python ETL process for automated loading  
- A normalised MySQL database for logistics tracking  
- Power BI dashboards (optional) for analysis  

All data used in this portfolio is based on real business logic but has been fully anonymised and replaced with synthetic values for security.

---

## 🧱 1. MySQL Transport Operations Database

A fully normalised schema that models all logistics activity.

### **Core Entities**

- Transporters, drivers, trucks  
- Clients, products  
- Locations (cities, borders, mines, warehouses)  
- Deals (commercial agreements)  
- Trips (individual load movements)

### **Key Features**

- Enforced referential integrity using foreign keys  
- Centralised location and product reference tables  
- `deal_trip` table supports full milestone tracking  
- Unique trip constraint (`deal_no`, `load_no`)  
- ETL-ready design for automated inserts from Python  

### **Supported Use Cases**

- Tracker for active loads per transporter  
- Border crossing analysis  
- Deal performance & movement trends  
- Power BI dashboards (per route, per client, per product)

---

## 📘 2. Deal Tracking Excel Workbook

A structured data capture interface used by operations teams.

### **Highlights**

- Controlled dropdown lists for consistent inputs  
- Power Query refreshing of reference data (clients, mines, transporters)  
- VBA macros automate:

  - Data submission into staging tables  
  - Refreshing of validation lists  
  - Clearing/resetting forms  

- Protected cells prevent accidental edits  
- Output table is ETL-ready for Python ingestion  

### **Captured Fields**

- Deal metadata (client, product, transporter)  
- Driver & truck details  
- Loading/border/offloading milestones  
- Item & tonnage metrics  

---

## 🐍 3. Python ETL Loader

A robust ETL pipeline that converts Excel data into clean MySQL records.

### **ETL Process**

**Extract:**  
- Read Excel file (Pandas) and validate required columns  

**Transform:**  
- Clean NULL/blank data  
- Standardise dates  
- Normalise naming  

**Load:**  
- Auto-creates missing dimension records  
- Inserts deal and trip records  
- Skips duplicates safely  
- Commits in batches for performance  

### **Entities Automatically Created**

- transporters  
- clients  
- products  
- locations  
- drivers  
- trucks  
- deal_overview  

### **End Result**

A fully populated, consistent relational database ready for operational analytics.

---

## 🔄 End-to-End Workflow Overview

1. Operations capture deal/trip data in the Excel workbook  
2. Power Query keeps dropdowns & reference values up to date  
3. VBA macros push validated data into structured Excel tables  
4. Python ETL reads the table and loads it into MySQL  
5. MySQL becomes the central data source for Power BI and reporting  

---

## 🔒 Data Notice

All data is based on genuine business logic but has been fully anonymised and fictionalised for confidentiality.
