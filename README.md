# week8_db_assign - E-Commerce DB

## Objective
Design and implement a **relational database** in **MySQL** for an **E-commerce Store**.  
The goal is to demonstrate the use of **well-structured tables**, **constraints**, and **relationships**.

## Deliverables
- `ecommerce.sql` file containing:
  - `CREATE DATABASE` statement  
  - `CREATE TABLE` statements  
  - Relationship constraints (`PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `UNIQUE`)  
  - Helpful indexes

## Schema Overview

### 1. Users & Addresses
- **users** - customer accounts.  
- **addresses**   
- **Relationship** - One user can have Many addresses.

### . Catalog
- **products** - items sold.  
- **categories** - hierarchical categories (self-referenced with `parent_id`).  
- **product_categories** - join table for many-to-many between products and categories.  
- **inventory** - stock quantity and `reorder_level` (threshold to trigger restocking).  

### 3. Orders & Fulfillment
- **orders** - placed by users.  
- **order_items** - products included in each order.  
- **payments** - payment records for each order.  
- **shipments**  

## Constraints Used
- **PRIMARY KEY**  
- **FOREIGN KEY**  
- **NOT NULL** 
- **UNIQUE**  
- **ENUM** 

## ▶️ How to Run
1. Open MySQL:
```bash
  mysql -u root -p
```
2. Load the SQL file:
  ```sql
    SOURCE ecommerce.sql;
  ```
3. Verify tables:
  ```sql
    SHOW TABLES;
  ```

## Example Queries

### 1. Find all products that need restocking
  ```sql
  SELECT p.name, i.quantity, i.reorder_level
  FROM products p
  JOIN inventory i ON p.product_id = i.product_id
  WHERE i.quantity <= i.reorder_level;
  ```

### 2. List all orders with number of items and total amount
```sql
  SELECT o.order_id, COUNT(oi.product_id) AS items, o.total_amount
  FROM orders o
  JOIN order_items oi ON o.order_id = oi.order_id
  GROUP BY o.order_id, o.total_amount;
```

### 3. Show all products under a given category
```sql

  SELECT c.name AS category, p.name AS product
  FROM categories c
  JOIN product_categories pc ON c.category_id = pc.category_id
  JOIN products p ON p.product_id = pc.product_id
  WHERE c.name = 'Electronics';
```
### 4. Get all orders placed by a specific user (e.g., user_id = 1)
```sql
  SELECT o.order_id, o.status, o.total_amount, o.created_at
  FROM orders o
  WHERE o.user_id = 1;
```
### 5. Find all payments that failed
  ```sql
  SELECT payment_id, order_id, method, amount, status
  FROM payments
  WHERE status = 'FAILED';
```




