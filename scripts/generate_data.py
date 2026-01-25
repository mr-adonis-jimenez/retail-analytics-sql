""" 
Retail Analytics Data Generator
Generates realistic sample data for PostgreSQL database
"""
import random
import os
from datetime import date, timedelta
from typing import List, Tuple
import psycopg2
from psycopg2.extras import execute_batch

# Seed for reproducibility
random.seed(42)


# Configuration - Use environment variables in CI/CD, fallback to defaults locally
DB_CONFIG = {
    "dbname": os.getenv('PGDATABASE', 'retail_analytics'),
    "user": os.getenv('PGUSER', 'postgres'),
    "password": os.getenv('PGPASSWORD', 'postgres'),
    "host": os.getenv('PGHOST', 'localhost'),
    "port": os.getenv('PGPORT', '5432')
}

# Sample name lists for customer generation
FIRST_NAMES = [
    "James", "John", "Robert", "Michael", "William", "David", "Richard", "Joseph",
    "Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica",
    "Sarah", "Karen", "Nancy", "Lisa", "Betty", "Margaret", "Sandra", "Ashley",
    "Kimberly", "Emily", "Donna", "Michelle", "Carol", "Amanda", "Dorothy", "Melissa",
    "Daniel", "Matthew", "Christopher", "Andrew", "Joshua", "Kevin", "Brian", "George",
    "Helen", "Deborah", "Rachel", "Stephanie", "Nicole", "Laura", "Rebecca", "Virginia"
]

LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
    "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas",
    "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White",
    "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young",
    "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores",
    "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell"
]

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

def random_date(start: date, end: date) -> date:
    """Generate random date between start and end"""
    return start + timedelta(days=random.randint(0, (end - start).days))

def connect_db():
    """Establish database connection with improved error handling"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print(f"✓ Connected to database: {DB_CONFIG['dbname']}")
        return conn
    except psycopg2.OperationalError as e:
        print(f"✗ Database connection error: {e}")
        print("\nTroubleshooting tips:")
        print("1. Ensure PostgreSQL is running: sudo service postgresql status")
        print(f"2. Verify database exists: psql -U {DB_CONFIG['user']} -l")
        print(f"3. Check credentials for user: {DB_CONFIG['user']}")
        print(f"4. Confirm host/port: {DB_CONFIG['host']}:{DB_CONFIG['port']}")
        raise
    except psycopg2.Error as e:
        print(f"✗ Database error: {e}")
        raise

def generate_customers(num_customers: int = 200) -> List[Tuple]:
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

def generate_products() -> List[Tuple]:
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

def generate_orders(num_customers: int, num_products: int, num_orders: int = 1000) -> List[Tuple]:
    """Generate order records with realistic patterns"""
    orders = []
    
    # Weight distribution: 20% of customers make 80% of purchases (Pareto principle)
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

def insert_customers(conn, customers: List[Tuple]) -> None:
    """Insert customer records in batches"""
    cur = conn.cursor()
    try:
        query = """
            INSERT INTO customers (first_name, last_name, email, signup_date, acquisition_channel)
            VALUES (%s, %s, %s, %s, %s)
        """
        execute_batch(cur, query, customers)
        conn.commit()
        print(f"✓ Inserted {len(customers)} customers")
    except psycopg2.Error as e:
        print(f"✗ Error inserting customers: {e}")
        conn.rollback()
        raise
    finally:
        cur.close()

def insert_products(conn, products: List[Tuple]) -> None:
    """Insert product records"""
    cur = conn.cursor()
    try:
        query = """
            INSERT INTO products (product_name, category, price)
            VALUES (%s, %s, %s)
        """
        execute_batch(cur, query, products)
        conn.commit()
        print(f"✓ Inserted {len(products)} products")
    except psycopg2.Error as e:
        print(f"✗ Error inserting products: {e}")
        conn.rollback()
        raise
    finally:
        cur.close()

def insert_orders(conn, orders: List[Tuple]) -> None:
    """Insert order records with calculated totals"""
    cur = conn.cursor()
    
    try:
        for customer_id, product_id, quantity, order_date in orders:
            # Get product price
            cur.execute("SELECT price FROM products WHERE product_id = %s", (product_id,))
            result = cur.fetchone()
            
            if result is None:
                print(f"✗ Warning: Product ID {product_id} not found, skipping order")
                continue
                
            price = result[0]
            order_total = float(price) * quantity
            
            cur.execute("""
                INSERT INTO orders (customer_id, product_id, quantity, order_date, order_total)
                VALUES (%s, %s, %s, %s, %s)
            """, (customer_id, product_id, quantity, order_date, order_total))
        
        conn.commit()
        print(f"✓ Inserted {len(orders)} orders")
    except psycopg2.Error as e:
        print(f"✗ Error inserting orders: {e}")
        conn.rollback()
        raise
    finally:
        cur.close()

def verify_data(conn) -> None:
    """Verify data insertion was successful"""
    cur = conn.cursor()
    try:
        cur.execute("SELECT COUNT(*) FROM customers")
        customer_count = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM products")
        product_count = cur.fetchone()[0]
        
        cur.execute("SELECT COUNT(*) FROM orders")
        order_count = cur.fetchone()[0]
        
        print("\n" + "="*50)
        print("Data Verification")
        print("="*50)
        print(f"Customers in database: {customer_count}")
        print(f"Products in database: {product_count}")
        print(f"Orders in database: {order_count}")
        print()
        
    except psycopg2.Error as e:
        print(f"✗ Error verifying data: {e}")
    finally:
        cur.close()

def main():
    """Main execution function"""
    print("\n" + "="*50)
    print("Retail Analytics Data Generator")
    print("="*50 + "\n")
    
    # Connect to database
    try:
        conn = connect_db()
    except Exception:
        print("\n✗ Failed to connect to database. Exiting.")
        return
    
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
        
        # Verify insertion
        verify_data(conn)
        
        # Summary
        print("="*50)
        print("Data generation complete!")
        print("="*50)
        print(f"Generated: {len(customers)} customers, {len(products)} products, {len(orders)} orders")
        print("\nNext steps:")
        print("1. Run analytics queries: psql -U postgres -d retail_analytics -f queries/customer_lifetime_value.sql")
        print("2. Check data quality: psql -U postgres -d retail_analytics -f validation/data_quality_checks.sql")
        print()
        
    except Exception as e:
        print(f"\n✗ Error during data generation: {e}")
        conn.rollback()
    finally:
        conn.close()
        print("✓ Database connection closed\n")

if __name__ == "__main__":
    main()
