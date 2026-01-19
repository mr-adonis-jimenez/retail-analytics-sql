# Contributing Guidelines

## Code Standards

### SQL Style Guide

#### Naming Conventions

```sql
-- Tables: plural, lowercase with underscores
CREATE TABLE customers (...)
CREATE TABLE order_items (...)

-- Columns: lowercase with underscores
customer_id
first_name
order_date

-- Indexes: prefix with idx_
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Foreign keys: prefix with fk_
CONSTRAINT fk_customer FOREIGN KEY (customer_id) ...
```

#### Query Formatting

```sql
-- Use uppercase for SQL keywords
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(o.order_id) AS total_orders
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE c.signup_date >= '2024-01-01'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) > 5
ORDER BY total_orders DESC;

-- Use meaningful aliases
FROM customers c  -- Good
FROM customers t1 -- Bad

-- Add comments for complex logic
-- Calculate 90-day rolling average
WITH rolling_metrics AS (
    SELECT 
        order_date,
        AVG(order_total) OVER (
            ORDER BY order_date 
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS rolling_avg
    FROM orders
)
...
```

#### File Organization

```
queries/
  ├── descriptive_name.sql  -- One query per file
  └── comments at top explaining purpose

-- Header template for query files:
-- =========================
-- Query: Customer Lifetime Value Analysis
-- Purpose: Calculate CLV and segment customers
-- Author: Your Name
-- Date: YYYY-MM-DD
-- =========================
```

### Python Style Guide

```python
# Follow PEP 8
import random
from datetime import datetime

# Use type hints
def generate_customers(num_customers: int) -> list:
    """Generate customer records.
    
    Args:
        num_customers: Number of customers to generate
        
    Returns:
        List of customer tuples
    """
    pass

# Use descriptive variable names
customer_count = 100  # Good
n = 100              # Bad

# Add docstrings to functions
def calculate_revenue(orders: list) -> float:
    """Calculate total revenue from orders."""
    return sum(order['total'] for order in orders)
```

## Adding New Queries

### 1. Check if Query Already Exists

Search existing queries to avoid duplication:

```bash
grep -r "SELECT.*FROM customers" queries/
```

### 2. Create New Query File

```sql
-- queries/your_new_analysis.sql

-- =========================
-- Query: [Descriptive Name]
-- Purpose: [What business question does this answer?]
-- Dependencies: [Any required tables/views]
-- Estimated Runtime: [Execution time with sample data]
-- =========================

-- Query implementation
SELECT ...
```

### 3. Test Query

```bash
# Verify syntax
psql -U postgres -d retail_analytics -f queries/your_new_analysis.sql

# Check execution time
\timing on
\i queries/your_new_analysis.sql
```

### 4. Document Results

Add expected output format:

```sql
-- Expected Output:
-- | column_1 | column_2 | column_3 |
-- |----------|----------|----------|
-- | value_1  | value_2  | value_3  |
```

## Performance Best Practices

### Index Usage

```sql
-- Before adding index, check query plan
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 123;

-- Add index if seeing sequential scans
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Verify improvement
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 123;
```

### Avoid Common Pitfalls

```sql
-- BAD: SELECT * (retrieves unnecessary columns)
SELECT * FROM orders;

-- GOOD: Select only needed columns
SELECT order_id, customer_id, order_total FROM orders;

-- BAD: Function on indexed column (prevents index usage)
SELECT * FROM customers WHERE UPPER(email) = 'TEST@EXAMPLE.COM';

-- GOOD: Match index format
SELECT * FROM customers WHERE email = 'test@example.com';

-- BAD: OR condition across different columns
SELECT * FROM orders WHERE customer_id = 1 OR product_id = 2;

-- GOOD: Use UNION or separate queries
SELECT * FROM orders WHERE customer_id = 1
UNION
SELECT * FROM orders WHERE product_id = 2;
```

## Testing Checklist

Before submitting:

- [ ] Query executes without errors
- [ ] Results are accurate and match expected output
- [ ] Query uses appropriate indexes
- [ ] Execution time is acceptable (<1s for small datasets)
- [ ] Comments explain complex logic
- [ ] Column names are descriptive
- [ ] Business logic is validated
- [ ] Edge cases are handled (NULL values, empty results)

## Data Quality Standards

### Validation Requirements

```sql
-- Check for NULLs in required fields
SELECT COUNT(*) FROM customers WHERE email IS NULL;

-- Verify referential integrity
SELECT COUNT(*) 
FROM orders o 
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Validate data ranges
SELECT COUNT(*) FROM products WHERE price <= 0;
```

### Data Generation Standards

```python
# Use realistic distributions
quantity = random.choices([1, 2, 3, 4, 5], weights=[50, 25, 15, 7, 3])[0]

# Ensure data consistency
assert order_total == quantity * price

# Add data validation
if customer_id not in valid_customer_ids:
    raise ValueError(f"Invalid customer_id: {customer_id}")
```

## Commit Message Guidelines

Follow conventional commits:

```bash
# Format: type(scope): description

# Types:
feat:     # New feature
fix:      # Bug fix
docs:     # Documentation changes
refactor: # Code refactoring
perf:     # Performance improvements
test:     # Adding tests

# Examples:
git commit -m "feat(queries): add customer cohort analysis"
git commit -m "fix(schema): correct foreign key constraint"
git commit -m "docs(readme): update setup instructions"
git commit -m "perf(indexes): add composite index on orders"
```

## Pull Request Process

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Follow code standards
   - Add tests if applicable
   - Update documentation

3. **Test Locally**
   ```bash
   psql -U postgres -d retail_analytics -f your_query.sql
   python scripts/generate_data.py
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: descriptive message"
   ```

5. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **PR Description Template**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] New feature
   - [ ] Bug fix
   - [ ] Documentation update
   - [ ] Performance improvement
   
   ## Testing
   - [ ] Tested locally
   - [ ] Query executes successfully
   - [ ] Results validated
   
   ## Related Issues
   Closes #issue_number
   ```

## Getting Help

- Check existing documentation first
- Review similar queries in `/queries` directory
- Open an issue for bugs or feature requests
- Tag maintainers for urgent questions

## Code of Conduct

- Be respectful and constructive
- Focus on code quality and learning
- Help others improve their contributions
- Follow project standards consistently

---

Thank you for contributing to improve this project!
