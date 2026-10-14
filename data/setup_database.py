import sqlite3
import os
import pandas as pd

base_dir = r"c:\Users\durge\OneDrive\Desktop\Antigravity App\Skill_Nexis-Week-2"
data_dir = os.path.join(base_dir, "data")
sql_file = os.path.join(data_dir, "awesome-chocolates-data.sql")
db_file = os.path.join(data_dir, "awesome_chocolates.db")

if os.path.exists(db_file):
    os.remove(db_file)

conn = sqlite3.connect(db_file)
cur = conn.cursor()

# 1. Create Tables
cur.execute("""CREATE TABLE IF NOT EXISTS geo (
    GeoID TEXT PRIMARY KEY,
    Geo TEXT,
    Region TEXT
)""")

cur.execute("""CREATE TABLE IF NOT EXISTS people (
    Salesperson TEXT,
    SPID TEXT PRIMARY KEY,
    Team TEXT,
    Location TEXT
)""")

cur.execute("""CREATE TABLE IF NOT EXISTS products (
    PID TEXT PRIMARY KEY,
    Product TEXT,
    Category TEXT,
    Size TEXT,
    Cost_per_box REAL
)""")

cur.execute("""CREATE TABLE IF NOT EXISTS sales (
    SPID TEXT,
    GeoID TEXT,
    PID TEXT,
    SaleDate TEXT,
    Amount REAL,
    Customers INTEGER,
    Boxes INTEGER
)""")

# 2. Populate SQLite Tables from MySQL dump
print("Importing SQL dump into SQLite database...")
with open(sql_file, "r", encoding="utf-8") as f:
    for line in f:
        if line.startswith("INSERT INTO `"):
            clean_line = (line.replace("`geo`", "geo")
                              .replace("`people`", "people")
                              .replace("`products`", "products")
                              .replace("`sales`", "sales")
                              .replace(r"\'", "''"))
            cur.execute(clean_line)

conn.commit()

# 3. Export Normalized CSVs
print("Exporting normalized tables to CSV...")
for table in ["geo", "people", "products", "sales"]:
    df_t = pd.read_sql_query(f"SELECT * FROM {table}", conn)
    csv_path = os.path.join(data_dir, f"{table}.csv")
    df_t.to_csv(csv_path, index=False)
    print(f"Exported {table}.csv: {len(df_t)} rows")

# 4. Create Enriched Master CSV (chocolate_sales.csv)
print("Creating enriched master chocolate_sales.csv...")
query = """
SELECT 
    s.SaleDate,
    s.Amount,
    s.Customers,
    s.Boxes,
    p.Salesperson,
    p.Team,
    p.Location,
    pr.Product,
    pr.Category,
    pr.Size,
    pr.Cost_per_box,
    g.Geo AS Country,
    g.Region
FROM sales s
LEFT JOIN people p ON s.SPID = p.SPID
LEFT JOIN products pr ON s.PID = pr.PID
LEFT JOIN geo g ON s.GeoID = g.GeoID
"""
df_master = pd.read_sql_query(query, conn)
master_csv = os.path.join(data_dir, "chocolate_sales.csv")
df_master.to_csv(master_csv, index=False)
print(f"Exported chocolate_sales.csv: {len(df_master)} rows, {len(df_master.columns)} columns")

conn.close()
print("Database setup and CSV exports completed successfully!")
