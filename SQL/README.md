# 🧱 Transport Operations Database (MySQL)

## 📘 Overview
This database forms the backbone of the **Transport Operations Management System**, designed to manage and track cross-border truck movements, product deliveries, and deal-level logistics activities across Southern and Central Africa.

The goal was to build a **normalized, scalable MySQL schema** that supports:
- Multi-leg transport deals (one deal, multiple loads/trips)
- Clear relationships between clients, products, transporters, and drivers
- Accurate milestone tracking (load, border exits/entries, arrival/offload)
- Flexible integration with ETL and BI tools

---

## 🧩 Core Design Principles
- **3NF normalization:** to eliminate redundancy and enforce referential integrity  
- **Lookup/reference tables:** for reusable entities such as locations, clients, products, and transporters  
- **Foreign key constraints:** to ensure consistency between all operational layers  
- **Unique trip logic:** enforced through `(deal_no, load_no)` uniqueness constraint  
- **Portfolio realism:** data is fully synthetic but designed to reflect real-world freight logistics patterns

---

## 🧠 Entity–Relationship Structure

Client (client_ref) Product (product_ref)
│ │
│ │
└──── deal_overview ───┘
│
│ 1 ─── n
▼
deal_trip
│
┌─────────┼───────────┐
│ │ │
transporter driver truck
│
└── location_ref (for loading, border, offload points)

pgsql
Copy code

---

## 🗄️ Database Schema

### 1️⃣ `transporter`
Stores registered transport companies.
| Column | Type | Notes |
|--------|------|-------|
| transporter_id | INT | Primary key |
| transporter_name | VARCHAR(100) | Transport company name |

---

### 2️⃣ `driver`
Stores driver information, each linked to a transporter.
| Column | Type | Notes |
|--------|------|-------|
| driver_id | INT | Primary key |
| transporter_id | INT | FK → transporter |
| driver_name | VARCHAR(100) | |
| id_no | VARCHAR(20) | National ID |
| drivers_licence_no | VARCHAR(20) | |
| nationality | VARCHAR(50) | |

---

### 3️⃣ `truck`
Captures trucks and trailers linked to each transporter.
| Column | Type | Notes |
|--------|------|-------|
| truck_id | INT | Primary key |
| transporter_id | INT | FK → transporter |
| truck_reg_no | VARCHAR(20) | |
| trailer1_reg_no | VARCHAR(20) | |
| trailer2_reg_no | VARCHAR(20) | |

---

### 4️⃣ `client_ref`
Stores client (mining company) information.
| Column | Type | Notes |
|--------|------|-------|
| client_id | INT | Primary key |
| client_name | VARCHAR(100) | Unique |
| industry_type | VARCHAR(100) | Optional |
| country | VARCHAR(50) | |
| city | VARCHAR(50) | |
| contact_person | VARCHAR(100) | |
| contact_email | VARCHAR(100) | |

---

### 5️⃣ `product_ref`
Reference table for all products transported.
| Column | Type | Notes |
|--------|------|-------|
| stock_code | VARCHAR(20) | Primary key |
| product_name | VARCHAR(100) | |
| product_category | VARCHAR(100) | |
| uom | VARCHAR(20) | Unit of Measure |
| hs_code | VARCHAR(20) | Optional customs classification |

---

### 6️⃣ `location_ref`
Centralized location lookup for cities, borders, and offloading points.
| Column | Type | Notes |
|--------|------|-------|
| location_id | INT | Primary key |
| location_name | VARCHAR(100) | Unique |
| location_type | ENUM('City','Border','Mine','Warehouse','Other') | |
| country | VARCHAR(50) | |
| region | VARCHAR(50) | |
| gps_lat / gps_long | DECIMAL(10,6) | Optional coordinates |

---

### 7️⃣ `deal_overview`
Represents the commercial deal between the client and transporter.
| Column | Type | Notes |
|--------|------|-------|
| deal_no | VARCHAR(20) | Primary key |
| client_id | INT | FK → client_ref |
| stock_code | VARCHAR(20) | FK → product_ref |
| transporter_id | INT | FK → transporter |

---

### 8️⃣ `deal_trip`
Stores trip-level detail for each deal (2–10 trips per deal).
| Column | Type | Notes |
|--------|------|-------|
| trip_id | INT | Primary key |
| deal_no | VARCHAR(20) | FK → deal_overview |
| load_no | INT | Trip number within deal |
| supplier_invoice_no | VARCHAR(20) | |
| loading_point_id | INT | FK → location_ref |
| border_of_exit_id | INT | FK → location_ref |
| border_of_entry_id | INT | FK → location_ref |
| offloading_point_id | INT | FK → location_ref |
| current_location_id | INT | FK → location_ref |
| driver_id | INT | FK → driver |
| truck_id | INT | FK → truck |
| no_of_items | INT | |
| tonnage_dispatched | DECIMAL(10,2) | |
| date_loaded → date_offloaded | DATE | Milestone tracking |
| truck_status | VARCHAR(50) | Defaults to 'Offloaded' |

🔒 **Constraint:**  
```sql
UNIQUE (deal_no, load_no)
Ensures each deal/load combination is unique.

🔗 Key Relationships
deal_trip → deal_overview (1:N)

deal_overview → client_ref, product_ref, transporter (N:1)

driver, truck → transporter (N:1)

All location fields in deal_trip reference location_ref

🧰 Technical Highlights
Fully relational schema using MySQL 8.0+

Foreign key enforcement for all dependencies

Unique trip constraint for data integrity

ETL-ready design: built to support automated inserts from Python (Pandas + mysql.connector)

Easily extensible: can integrate additional tables (finance, cost tracking, etc.)

⚙️ Setup Instructions
Open MySQL Workbench or CLI

Run the provided transport_operations_v2.sql script

Verify with:

sql
Copy code
USE transport_operations_v2;
SHOW TABLES;
📊 Example Use Cases
Track all active loads per transporter

Analyze border crossing times per route

Link product movement to client performance

Integrate with Power BI for live logistics dashboards

🧩 Next Steps
Add cost, revenue, and margin tables for financial analytics

Create summary views (per client, per route, per month)

Build a Power BI model over the schema for performance visualization

