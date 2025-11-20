-- ============================
-- Table: client_ref
-- ============================
CREATE TABLE client_ref (
    client_id INT NOT NULL AUTO_INCREMENT,
    client_name VARCHAR(100) NOT NULL,
    industry_type VARCHAR(100),
    country VARCHAR(50),
    city VARCHAR(50),
    contact_person VARCHAR(100),
    contact_email VARCHAR(100),
    PRIMARY KEY (client_id),
    UNIQUE KEY (client_name)
);

-- ============================
-- Table: product_ref
-- ============================
CREATE TABLE product_ref (
    stock_code VARCHAR(20) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    product_category VARCHAR(100),
    uom VARCHAR(20),
    hs_code VARCHAR(20),
    PRIMARY KEY (stock_code)
);

-- ============================
-- Table: transporter
-- ============================
CREATE TABLE transporter (
    transporter_id INT NOT NULL AUTO_INCREMENT,
    transporter_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (transporter_id)
);

-- ============================
-- Table: driver
-- ============================
CREATE TABLE driver (
    driver_id INT NOT NULL AUTO_INCREMENT,
    transporter_id INT,
    driver_name VARCHAR(100),
    id_no VARCHAR(20),
    drivers_licence_no VARCHAR(20),
    nationality VARCHAR(50),
    PRIMARY KEY (driver_id),
    FOREIGN KEY (transporter_id) REFERENCES transporter(transporter_id)
);

-- ============================
-- Table: truck
-- ============================
CREATE TABLE truck (
    truck_id INT NOT NULL AUTO_INCREMENT,
    transporter_id INT,
    truck_reg_no VARCHAR(20),
    trailer1_reg_no VARCHAR(20),
    trailer2_reg_no VARCHAR(20),
    PRIMARY KEY (truck_id),
    FOREIGN KEY (transporter_id) REFERENCES transporter(transporter_id)
);

-- ============================
-- Table: location_ref
-- ============================
CREATE TABLE location_ref (
    location_id INT NOT NULL AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL,
    location_type ENUM('City','Border','Mine','Warehouse','Other') DEFAULT 'City',
    country VARCHAR(50),
    region VARCHAR(50),
    gps_lat DECIMAL(10,6),
    gps_long DECIMAL(10,6),
    PRIMARY KEY (location_id),
    UNIQUE KEY (location_name)
);

-- ============================
-- Table: deal_overview
-- ============================
CREATE TABLE deal_overview (
    deal_no VARCHAR(20) NOT NULL,
    client_id INT,
    stock_code VARCHAR(20),
    transporter_id INT,
    PRIMARY KEY (deal_no),
    FOREIGN KEY (client_id) REFERENCES client_ref(client_id),
    FOREIGN KEY (stock_code) REFERENCES product_ref(stock_code),
    FOREIGN KEY (transporter_id) REFERENCES transporter(transporter_id)
);

-- ============================
-- Table: deal_trip
-- ============================
CREATE TABLE deal_trip (
    trip_id INT NOT NULL AUTO_INCREMENT,
    deal_no VARCHAR(20),
    load_no INT,
    supplier_invoice_no VARCHAR(20),
    loading_point_id INT,
    border_of_exit_id INT,
    border_of_entry_id INT,
    offloading_point_id INT,
    current_location_id INT,
    driver_id INT,
    truck_id INT,
    no_of_items INT,
    tonnage_dispatched DECIMAL(10,2),
    date_loaded DATE,
    date_dispatched DATE,
    bo_exit_arrived DATE,
    bo_exit_departed DATE,
    bo_entry_arrived DATE,
    bo_entry_departed DATE,
    date_arrived_site DATE,
    date_offloaded DATE,
    truck_status VARCHAR(50) DEFAULT 'Offloaded',
    PRIMARY KEY (trip_id),
    FOREIGN KEY (deal_no) REFERENCES deal_overview(deal_no),
    FOREIGN KEY (driver_id) REFERENCES driver(driver_id),
    FOREIGN KEY (truck_id) REFERENCES truck(truck_id),
    FOREIGN KEY (loading_point_id) REFERENCES location_ref(location_id),
    FOREIGN KEY (border_of_exit_id) REFERENCES location_ref(location_id),
    FOREIGN KEY (border_of_entry_id) REFERENCES location_ref(location_id),
    FOREIGN KEY (offloading_point_id) REFERENCES location_ref(location_id),
    FOREIGN KEY (current_location_id) REFERENCES location_ref(location_id)
);
