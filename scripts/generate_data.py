"""
Retail Analytics Data Generator
Generates realistic sample data for PostgreSQL database
"""
import random
from datetime import date, timedelta
import psycopg2
from psycopg2.extras import execute_batch

# Seed for reproducibility
random.seed(42)

# Configuration
DB_CONFIG = {
    "dbname": "retail_analytics",
    "user": "postgres",
    "password": "postgres",
    "host": "localhost",
    "port": "5432"
}

# Data constants
FIRST_NAMES = ["James", "Mary", "John", "Patricia", "Robert", "Jennifer", "Michael", "Linda", 
               "William", "Barbara", "David", "Elizabeth", "Richard", "Susan", "Joseph", "Jessica"]
LAST_NAMES = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
              "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson"]
CHANNELS = ["Organic", "Paid Search", "Referral", "Email", "Social Media", "Direct"]
CATEGORIES = ["Electronics", "Home & Garden", "Fitness", "Office Supplies", "Clothing", "Books"]
PRODUCTS = {
    "Electronics": ["Laptop", "Smartphone", "Tablet", "Headphones", "Smartwatch"],
    "Home & Garden": ["Blender", "Vacuum", "Plant Set", "Kitchen Knife Set", "Bedding"],
    "Fitness": ["Yoga Mat", "Dumbbell Set", "Resistance Bands", "Foam Roller", "Jump Rope"],
    "Office Supplies": ["Desk Chair", "Monitor Stand", "Notebook Pack", "Pen Set", "Desk Lamp"],
    "Clothing": ["T-Shirt", "Jeans", "Jacket", "Sneakers", "Backpack"],
    "Books": ["Fiction Novel", "Cookbook", "Self-Help Book", "Biography", "Technical Manual"]
}

def random_date(start, end):
    """Generate random date between start and end"""
    return start + timedelta(days=random.randint(0, (end - start).days))

def connect_db():
    """Establish database connection"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print(f"✓ Connected to database: {DB_CONFIG['dbname']}")
        return conn
    except psycopg2.Error as e:
        print(f"✗ Database connection error: {e}")
        raise

def generate_customers(num_customers=200):
    """Generate customer records with realistic data"""
    customers = []
    used_emails = set()
    
    for i in range(num_customers):
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        
        # Ensure unique email
        email = f"{first_name.lower()}.{last_name.lower()}{i}@example.com"
        while email in used_emails:
            email = f"{first_name.lower()}.{last_name.lower()}{random.randint(1000, 9999)}@example.com"
        used_emails.add(email)
        
        signup_date = random_date(date(2023, 1, 1), date(2024, 12, 31))
        channel = random.choice(CHANNELS)
        
        customers.append((first_name, last_name, email, signup_date, channel))
    
    return customers

def generate_products():
    """Generate product catalog"""
    products = []
    product_id = 1
    
    for category, items in PRODUCTS.items():
        for item in items:
            # Price based on category
            if category == "Electronics":
                price = round(random.uniform(200, 1500), 2)
            elif category == "Home & Garden":
                price = round(random.uniform(50, 500), 2)
            elif category == "Fitness":
                price = round(random.uniform(15, 200), 2)
            elif category == "Office Supplies":
                price = round(random.uniform(25, 400), 2)
            elif category == "Clothing":
                price = round(random.uniform(20, 150), 2)
            else:  # Books
                price = round(random.uniform(10, 50), 2)
            
            products.append((item, category, price))
            product_id += 1
    
    return products

def generate_orders(num_customers, num_products, num_orders=1000):
    """Generate order records with realistic patterns"""
    orders = []
    
    # Weight distribution: 20% of customers make 80% of purchases
    customer_weights = [5 if i < num_customers * 0.2 else 1 for i in range(num_customers)]
    
    for _ in range(num_orders):
        customer_id = random.choices(range(1, num_customers + 1), weights=customer_weights)[0]
        product_id = random.randint(1, num_products)
        
        # Quantity with realistic distribution
        quantity = random.choices([1, 2, 3, 4, 5], weights=[50, 25, 15, 7, 3])[0]
        
        order_date = random_date(date(2023, 1, 1), date(2024, 12, 31))
        
        # order_total will be calculated based on product price
        orders.append((customer_id, product_id, quantity, order_date))
    
    return orders

def insert_customers(conn, customers):
    """Insert customer records in batches"""
    cur = conn.cursor()
    query = """
        INSERT INTO customers (first_name, last_name, email, signup_date, acquisition_channel)
        VALUES (%s, %s, %s, %s, %s)
    """
    execute_batch(cur, query, customers)
    conn.commit()
    cur.close()
    print(f"✓ Inserted {len(customers)} customers")

def insert_products(conn, products):
    """Insert product records"""
    cur = conn.cursor()
    query = """
        INSERT INTO products (product_name, category, price)
        VALUES (%s, %s, %s)
    """
    execute_batch(cur, query, products)
    conn.commit()
    cur.close()
    print(f"✓ Inserted {len(products)} products")

def insert_orders(conn, orders):
    """Insert order records with calculated totals"""
    cur = conn.cursor()
    
    for customer_id, product_id, quantity, order_date in orders:
        # Get product price
        cur.execute("SELECT price FROM products WHERE product_id = %s", (product_id,))
        price = cur.fetchone()[0]
        order_total = float(price) * quantity
        
        cur.execute("""
            INSERT INTO orders (customer_id, product_id, quantity, order_date, order_total)
            VALUES (%s, %s, %s, %s, %s)
        """, (customer_id, product_id, quantity, order_date, order_total))
    
    conn.commit()
    cur.close()
    print(f"✓ Inserted {len(orders)} orders")

def main():
    """Main execution function"""
    print("\n" + "="*50)
    print("Retail Analytics Data Generator")
    print("="*50 + "\n")
    
    # Connect to database
    conn = connect_db()
    
    try:
        # Generate data
        print("\nGenerating data...")
        customers = generate_customers(200)
        products = generate_products()
        orders = generate_orders(200, len(products), 1000)
        
        # Insert data
        print("\nInserting data...")
        insert_customers(conn, customers)
        insert_products(conn, products)
        insert_orders(conn, orders)
        
        # Summary
        print("\n" + "="*50)
        print("Data generation complete!")
        print("="*50)
        print(f"Customers: {len(customers)}")
        print(f"Products: {len(products)}")
        print(f"Orders: {len(orders)}")
        print()
        
    except Exception as e:
        print(f"\n✗ Error: {e}")
        conn.rollback()
    finally:
        conn.close()
        print("✓ Database connection closed\n")

if __name__ == "__main__":
    main()
