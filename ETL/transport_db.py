import pandas as pd
import mysql.connector
from mysql.connector import Error
from datetime import datetime
import math

# ========= CONFIGURATION =========
EXCEL_FILE = r"C:\Users\Andrew Earle\OneDrive - Hodari Group\Desktop\transport_import.xlsx"

DB_CONFIG = {
    "host": "YOUR_DB_HOST",
    "user": "YOUR_DB_USER",
    "password": "YOUR_DB_PASSWORD",
    "database": "YOUR_DATABASE_NAME"
}

# ========= HELPER FUNCTIONS =========
def clean_value(val):
    if val is None:
        return None
    if isinstance(val, float) and math.isnan(val):
        return None
    if isinstance(val, str) and val.strip().upper() == "NULL":
        return None
    return val

def clean_date(val):
    val = clean_value(val)
    if val is None:
        return None
    if isinstance(val, (datetime, pd.Timestamp)):
        return val.date()
    try:
        return pd.to_datetime(val).date()
    except Exception:
        return None

def get_or_create_transporter(cursor, cache, name):
    name = name.strip()
    if name in cache:
        return cache[name]
    cursor.execute("INSERT INTO transporter (transporter_name) VALUES (%s)", (name,))
    transporter_id = cursor.lastrowid
    cache[name] = transporter_id
    return transporter_id

def get_or_create_client(cursor, cache, name):
    name = name.strip()
    if name in cache:
        return cache[name]
    cursor.execute("INSERT INTO client_ref (client_name) VALUES (%s)", (name,))
    client_id = cursor.lastrowid
    cache[name] = client_id
    return client_id

def get_or_create_product(cursor, cache, stock_code, product_name):
    stock_code = stock_code.strip()
    if stock_code in cache:
        return stock_code
    cursor.execute(
        "INSERT INTO product_ref (stock_code, product_name) VALUES (%s, %s)",
        (stock_code, product_name.strip()),
    )
    cache[stock_code] = True
    return stock_code

def get_or_create_location(cursor, cache, name, type_hint):
    if name is None:
        return None
    name = name.strip()
    if not name:
        return None
    if name in cache:
        return cache[name]
    location_type = "Border" if type_hint == "Border" else "City"
    cursor.execute(
        "INSERT INTO location_ref (location_name, location_type) VALUES (%s, %s)",
        (name, location_type),
    )
    location_id = cursor.lastrowid
    cache[name] = location_id
    return location_id

def get_or_create_driver(cursor, cache, driver_name, id_no, licence_no, nationality, transporter_id):
    driver_name = str(driver_name).strip() if driver_name else ""
    id_no_str = str(id_no).strip() if id_no not in (None, float("nan")) and not pd.isna(id_no) else ""
    licence_no = str(licence_no).strip() if licence_no else None
    nationality = str(nationality).strip() if nationality else None
    key = (driver_name, id_no_str)
    if key in cache:
        return cache[key]
    cursor.execute(
        """
        INSERT INTO driver (transporter_id, driver_name, id_no, drivers_licence_no, nationality)
        VALUES (%s, %s, %s, %s, %s)
        """,
        (transporter_id, driver_name, id_no_str, licence_no, nationality),
    )
    driver_id = cursor.lastrowid
    cache[key] = driver_id
    return driver_id

def get_or_create_truck(cursor, cache, truck_reg, trailer1_reg, trailer2_reg, transporter_id):
    if not truck_reg:
        return None
    key = truck_reg.strip()
    if key in cache:
        return cache[key]
    cursor.execute(
        """
        INSERT INTO truck (transporter_id, truck_reg_no, trailer1_reg_no, trailer2_reg_no)
        VALUES (%s, %s, %s, %s)
        """,
        (transporter_id, truck_reg.strip(), trailer1_reg, trailer2_reg),
    )
    truck_id = cursor.lastrowid
    cache[key] = truck_id
    return truck_id

def get_or_create_deal(cursor, cache, deal_no, client_id, stock_code, transporter_id):
    if deal_no in cache:
        return
    cursor.execute(
        """
        INSERT INTO deal_overview (deal_no, client_id, stock_code, transporter_id)
        VALUES (%s, %s, %s, %s)
        """,
        (deal_no, client_id, stock_code, transporter_id),
    )
    cache[deal_no] = True

# ========= MAIN ETL =========
def main():
    print("Loading Excel file...")
    df = pd.read_excel(EXCEL_FILE, sheet_name="Sheet1")

    expected_cols = [
        "Deal No.", "Load #", "Supplier Invoice #", "Client Name", "Product",
        "Stock Code", "Loading Point", "Border of Exit", "Border of Entry",
        "Offloading Point", "Current Location", "Transporter", "Truck Status",
        "Truck REG #", "Trailer 1 REG #", "Trailer 2 REG #", "Driver Name",
        "ID No.", "Drivers Licence No.", "Nationality", "No. of Items",
        "Tonnage Dispatched", "Date: Loaded", "Date: Dispatched",
        "BoExit Arrived", "BoExit Departed", "BoEntry Date Arrived",
        "BoEntry Date Departed", "Date: Arrived Site", "Date: Offloaded"
    ]
    missing = [c for c in expected_cols if c not in df.columns]
    if missing:
        raise ValueError(f"Missing expected columns in Excel: {missing}")

    print("Connecting to MySQL...")
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()

    transporter_cache = {}
    client_cache = {}
    product_cache = {}
    location_cache = {}
    driver_cache = {}
    truck_cache = {}
    deal_cache = {}
    inserted_counts = {k: 0 for k in
        ["transporter","client","product","location","driver","truck","deal_overview","deal_trip"]}

    print("Starting row processing...")
    for idx, row in df.iterrows():
        deal_no = str(row["Deal No."]).strip()
        load_no = int(row["Load #"])
        supplier_invoice_no = str(row["Supplier Invoice #"]).strip()
        client_name = str(row["Client Name"]).strip()
        product_name = str(row["Product"]).strip()
        stock_code = str(row["Stock Code"]).strip()

        loading_point = clean_value(row["Loading Point"])
        border_of_exit = clean_value(row["Border of Exit"])
        border_of_entry = clean_value(row["Border of Entry"])
        offloading_point = clean_value(row["Offloading Point"])
        current_location = clean_value(row["Current Location"])

        transporter_name = str(row["Transporter"]).strip()
        truck_status = str(row["Truck Status"]).strip()
        truck_reg = clean_value(row["Truck REG #"])
        trailer1_reg = clean_value(row["Trailer 1 REG #"])
        trailer2_reg = clean_value(row["Trailer 2 REG #"])

        driver_name = str(row["Driver Name"]).strip()
        id_no = clean_value(row["ID No."])
        licence_no = clean_value(row["Drivers Licence No."])
        nationality = clean_value(row["Nationality"])

        no_of_items = clean_value(row["No. of Items"])
        tonnage_dispatched = clean_value(row["Tonnage Dispatched"])
        date_loaded = clean_date(row["Date: Loaded"])
        date_dispatched = clean_date(row["Date: Dispatched"])
        bo_exit_arrived = clean_date(row["BoExit Arrived"])
        bo_exit_departed = clean_date(row["BoExit Departed"])
        bo_entry_arrived = clean_date(row["BoEntry Date Arrived"])
        bo_entry_departed = clean_date(row["BoEntry Date Departed"])
        date_arrived_site = clean_date(row["Date: Arrived Site"])
        date_offloaded = clean_date(row["Date: Offloaded"])

        transporter_id = get_or_create_transporter(cursor, transporter_cache, transporter_name)
        client_id = get_or_create_client(cursor, client_cache, client_name)
        product_pk = get_or_create_product(cursor, product_cache, stock_code, product_name)

        loading_point_id = get_or_create_location(cursor, location_cache, loading_point, "City")
        border_of_exit_id = get_or_create_location(cursor, location_cache, border_of_exit, "Border")
        border_of_entry_id = get_or_create_location(cursor, location_cache, border_of_entry, "Border")
        offloading_point_id = get_or_create_location(cursor, location_cache, offloading_point, "City")
        current_location_id = get_or_create_location(cursor, location_cache, current_location, "City")

        driver_id = get_or_create_driver(cursor, driver_cache, driver_name, id_no, licence_no, nationality, transporter_id)
        truck_id = get_or_create_truck(cursor, truck_cache, truck_reg, trailer1_reg, trailer2_reg, transporter_id)

        get_or_create_deal(cursor, deal_cache, deal_no, client_id, product_pk, transporter_id)

        # --- Insert deal_trip with duplicate-skip ---
        try:
            cursor.execute(
                """
                INSERT INTO deal_trip (
                    deal_no, load_no, supplier_invoice_no,
                    loading_point_id, border_of_exit_id, border_of_entry_id,
                    offloading_point_id, current_location_id,
                    driver_id, truck_id,
                    no_of_items, tonnage_dispatched,
                    date_loaded, date_dispatched,
                    bo_exit_arrived, bo_exit_departed,
                    bo_entry_arrived, bo_entry_departed,
                    date_arrived_site, date_offloaded,
                    truck_status
                ) VALUES (
                    %s, %s, %s,
                    %s, %s, %s,
                    %s, %s,
                    %s, %s,
                    %s, %s,
                    %s, %s,
                    %s, %s,
                    %s, %s,
                    %s, %s,
                    %s
                )
                """,
                (
                    deal_no, load_no, supplier_invoice_no,
                    loading_point_id, border_of_exit_id, border_of_entry_id,
                    offloading_point_id, current_location_id,
                    driver_id, truck_id,
                    no_of_items, tonnage_dispatched,
                    date_loaded, date_dispatched,
                    bo_exit_arrived, bo_exit_departed,
                    bo_entry_arrived, bo_entry_departed,
                    date_arrived_site, date_offloaded,
                    truck_status,
                ),
            )
            inserted_counts["deal_trip"] += 1

        except mysql.connector.errors.IntegrityError as e:
            if e.errno == 1062:
                print(f"Skipping duplicate trip: {deal_no} - Load {load_no}")
                conn.rollback()
            else:
                raise e

        if (idx + 1) % 500 == 0:
            print(f"Processed {idx + 1} rows...")
            conn.commit()

    conn.commit()
    print("=== ETL COMPLETE ===")
    for k, v in inserted_counts.items():
        print(f"{k:15}: {v}")

    cursor.close()
    conn.close()

if __name__ == "__main__":
    main()

