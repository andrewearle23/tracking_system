# 📦 Transport Operations ETL Loader

**Excel → Python → MySQL**

This script performs a full ETL (Extract, Transform, Load) process that converts structured transport-tracking data from Excel into a fully normalised MySQL database (`transport_operations`).  
It ensures cleaning, validation, referential integrity, and automatic dimension creation for transporters, clients, drivers, trucks, products, and locations.

This ETL pipeline is designed for operational logistics data such as deal trips, dispatch movements, border events, and tracking milestones.

---

## 🚀 Features

### ✔ 1. Reads structured Excel transport/tracking data
The script loads a defined Excel sheet and validates that all required columns exist.

### ✔ 2. Cleans & standardises input data
- Handles NULL/blank values  
- Cleans dates into proper Python date objects  
- Normalises text values  
- Ensures consistent formatting for IDs, drivers, and locations  

### ✔ 3. Auto-creates dimension records
If a referenced entity does not exist in MySQL, the ETL automatically inserts it:

- Transporter  
- Client  
- Product  
- Location  
- Driver  
- Truck  
- Deal overview  

This removes the need to manually preload lookup tables.

### ✔ 4. Inserts fact records into `deal_trip`
Each row in the Excel sheet becomes a movement/dispatch record in MySQL.  
Duplicate trips are safely skipped using a primary-key check.

### ✔ 5. Tracks and reports all insert counts
At the end of the run, the script prints the number of rows inserted for each table.

---

## 🧠 How the ETL Works

### 1️⃣ Extract
The script reads an Excel file containing dispatch details:

- Deal No.  
- Load number  
- Supplier invoice  
- Transporter info  
- Vehicle & trailers  
- Driver info  
- Border events  
- Loading/Offloading timestamps  
- Location info  

### 2️⃣ Transform
The script:

- Converts invalid values to `None`  
- Normalises date fields  
- Formats driver ID numbers and names  
- Ensures truck and location names are consistent  
- Removes whitespace  
- Handles missing values  
- Ensures type correctness  

### 3️⃣ Load
The script connects to MySQL and:

- Inserts (or retrieves existing) lookup table entries  
- Inserts `deal_overview` entries  
- Inserts `deal_trip` fact records  
- Commits every 500 rows for performance  

All operations are wrapped in safe, retry-aware `INSERT` operations.

---

## ⚙️ Configuration

Edit the top of the script before running:

```python
EXCEL_FILE = r"YOUR_FILE_PATH"

DB_CONFIG = {
    "host": "YOUR_DB_HOST",
    "user": "YOUR_DB_USER",
    "password": "YOUR_DB_PASSWORD",
    "database": "YOUR_DATABASE_NAME"
}
