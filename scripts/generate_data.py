import random
import csv
from datetime import datetime, timedelta

# Generate more sales data
def generate_sales_data(num_records=1000):
    sales = []
    start_date = datetime(2023, 1, 1)
    
    for i in range(num_records):
        sale_id = 5000 + i
        sale_date = start_date + timedelta(days=random.randint(0, 365))
        customer_id = random.randint(1001, 1050)  # 50 customers
        store_id = random.randint(1, 5)
        product_id = random.randint(101, 110)
        quantity = random.randint(1, 5)
        discount = random.choice([0, 5, 10, 15, 20])
        
        sales.append([
            sale_id,
            sale_date.strftime('%Y-%m-%d'),
            customer_id,
            store_id,
            product_id,
            quantity,
            discount
        ])
    
    return sales

# Write to CSV
sales_data = generate_sales_data(1000)
with open('sales_data.csv', 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['sale_id', 'sale_date', 'customer_id', 'store_id', 'product_id', 'quantity', 'discount_percent'])
    writer.writerows(sales_data)

print("Generated 1000 sales records in sales_data.csv")

# Generate SQL INSERT statements
with open('insert_sales.sql', 'w') as file:
    file.write("INSERT INTO sales (sale_id, sale_date, customer_id, store_id, product_id, quantity, discount_percent) VALUES\n")
    for i, sale in enumerate(sales_data):
        if i == len(sales_data) - 1:
            file.write(f"({sale[0]}, '{sale[1]}', {sale[2]}, {sale[3]}, {sale[4]}, {sale[5]}, {sale[6]});\n")
        else:
            file.write(f"({sale[0]}, '{sale[1]}', {sale[2]}, {sale[3]}, {sale[4]}, {sale[5]}, {sale[6]}),\n")

print("Generated insert_sales.sql")

import random
from datetime import date, timedelta
import psycopg2

random.seed(42)

conn = psycopg2.connect(
    dbname="analytics_db",
    user="postgres",
    password="postgres",
    host="localhost",
    port="5432"
)
cur = conn.cursor()

CHANNELS = ["Organic", "Paid Search", "Referral", "Email"]
CATEGORIES = ["Electronics", "Home", "Fitness", "Office"]

def random_date(start, end):
    return start + timedelta(days=random.randint(0, (end - start).days))

# Customers
for i in range(100):
    cur.execute("""
        INSERT INTO customers (first_name, last_name, email, signup_date, acquisition_channel)
        VALUES (%s, %s, %s, %s, %s)
    """, (
        f"User{i}",
        "Test",
        f"user{i}@example.com",
        random_date(date(2023,1,1), date(2024,12,31)),
        random.choice(CHANNELS)
    ))

# Products
for i in range(20):
    price = round(random.uniform(10, 500), 2)
    cur.execute("""
        INSERT INTO products (product_name, category, price)
        VALUES (%s, %s, %s)
    """, (
        f"Product {i}",
        random.choice(CATEGORIES),
        price
    ))

# Orders
for _ in range(500):
    customer_id = random.randint(1, 100)
    product_id = random.randint(1, 20)
    quantity = random.randint(1, 5)
    cur.execute("SELECT price FROM products WHERE product_id = %s", (product_id,))
    price = cur.fetchone()[0]
    total = price * quantity

    cur.execute("""
        INSERT INTO orders (customer_id, product_id, quantity, order_date, order_total)
        VALUES (%s, %s, %s, %s, %s)
    """, (
        customer_id,
        product_id,
        quantity,
        random_date(date(2023,1,1), date(2024,12,31)),
        total
    ))

conn.commit()
cur.close()
conn.close()
