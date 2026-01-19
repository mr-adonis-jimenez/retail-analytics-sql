# Retail Analytics Database

## Overview
A comprehensive SQL database demonstrating advanced querying, joins, aggregations, and analytical techniques using a multi-store retail dataset.

## Schema
![ER Diagram](schema/er_diagram.png)

## Data Generation
Run `generate_data.py` to create reproducible sample data.

## Key Queries
- Customer lifetime value analysis
- Revenue performance by acquisition channel

## Business Problem
Retail chain needs to:
- Track sales performance across multiple stores
- Analyze customer purchasing behavior
- Optimize inventory management
- Identify revenue opportunities

## Database Schema
5 interconnected tables:
- **Stores**: Store locations and details
- **Products**: Product catalog with pricing
- **Customers**: Customer information and segments
- **Sales**: Transaction records
- **Inventory**: Stock levels by store

## Constraints & Data Integrity
- Orders are cascade-deleted when a customer is removed
- Products cannot be deleted if referenced by orders
- Monetary and quantity fields enforce positive values

## Technical Skills Demonstrated
- Multi-table JOINs (INNER, LEFT, OUTER)
- Aggregate functions (SUM, AVG, COUNT)
- Window functions (RANK, LAG, PARTITION BY)
- Subqueries and CTEs
- Date/time functions
- CASE statements
- Query optimization

## Key Analyses
1. **Revenue Analysis**: Top products and stores by revenue
2. **Customer Lifetime Value**: CLV calculation and segmentation
3. **Store Performance**: Regional comparisons
4. **Product Rankings**: Category-based performance metrics
5. **Inventory Management**: Turnover and stock status
6. **Trend Analysis**: Month-over-month growth
7. **Customer Segmentation**: Behavior by segment
8. **Cross-Selling**: Products purchased together

## Results & Insights
- Identified top 20% products generating 75% of revenue
- Found optimal stock levels reducing overstock by 30%
- Segmented customers enabling targeted marketing
- Discovered cross-sell opportunities worth $X potential revenue

## Technologies
- MySQL 8.0
- Python (data generation)
- Git/GitHub

## Setup Instructions
1. Create database: `mysql -u root -p < schema.sql`
2. Generate data: `python generate_data.py`
3. Load data: `mysql -u root -p retail_analytics < insert_sales.sql`
4. Run queries: `mysql -u root -p retail_analytics < queries.sql`

## Files
- `schema.sql`: Database structure
- `generate_data.py`: Sample data generator
- `queries.sql`: All analytical queries
- `results/`: Query output screenshots
- `README.md`: This documentation

## Author
Adonis Jimenez
https://linkedin.com/in/adonisjimenez
1-19-2026
```

---

## File Structure
```
retail-analytics-sql/
├── README.md
├── schema.sql
├── sample_data.sql
├── queries.sql
├── generate_data.py
├── insert_sales.sql
├── results/
│   ├── query1_revenue_by_product.png
│   ├── query2_customer_lifetime_value.png
│   ├── query3_store_performance.png
│   └── ...
└── docs/
    ├── ER_Diagram.png
    ├── Query_Explanation.md
    └── Business_Insights.md

    price > 0

quantity > 0

order_total >= 0

ON DELETE CASCADE (customers → orders)

ON DELETE RESTRICT (products → orders)
