-- Create and select database
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- One user can have many addresses (1:N)
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(100) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(32) UNIQUE,
  created_at DATETIME NOT NULL DEFAULT
  CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
  address_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  county VARCHAR(100) NOT NULL,
  town VARCHAR(100) NOT NULL,
  estate VARCHAR(100),
  street VARCHAR(255),
  postal_code VARCHAR(10) NOT NULL,
  is_default TINYINT NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_addresses_user
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Products, Categories, Inventory
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  active TINYINT NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  parent_id INT,
  CONSTRAINT fk_categories_parent
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

-- Many-to-Many such that a product can be in many categories and a category has many products
CREATE TABLE product_categories (
  product_id INT NOT NULL,
  category_id INT NOT NULL,
  PRIMARY KEY (product_id, category_id),
  CONSTRAINT fk_pc_product
    FOREIGN KEY (product_id) REFERENCES products(product_id),
  CONSTRAINT fk_pc_category
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- Inventory has a 1:1 with product
CREATE TABLE inventory (
  product_id INT PRIMARY KEY,
  quantity INT NOT NULL DEFAULT 0,
  reorder_level INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_inventory_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Orders, Items, Payments, Shipments
-- One user can place many orders (1:N)
CREATE TABLE orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  ship_address_id INT,
  status ENUM('PENDING','PAID','SHIPPED','DELIVERED','CANCELLED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user
    FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_orders_ship_addr
    FOREIGN KEY (ship_address_id) REFERENCES addresses(address_id)
);

-- Each order has multiple items (1:N), each item references a product
CREATE TABLE order_items (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id),
  CONSTRAINT fk_oi_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_oi_product
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- One order can have multiple payment records
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  method ENUM('CARD','BANK_TRANSFER','PAYPAL','CASH_ON_DELIVERY') NOT NULL,
  status ENUM('PENDING','AUTHORIZED','CAPTURED','FAILED','REFUNDED') NOT NULL DEFAULT 'PENDING',
  amount DECIMAL(12,2) NOT NULL,
  transaction_ref VARCHAR(128) UNIQUE,
  paid_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payments_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- One order can have shipments
CREATE TABLE shipments (
  shipment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  carrier VARCHAR(100) NOT NULL,
  tracking_number VARCHAR(100) UNIQUE,
  shipped_at DATETIME,
  delivered_at DATETIME,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_shipments_order
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- INDEXES
-- Index on users for fast login by email or phone
CREATE INDEX idx_users_created_at ON users(created_at);

-- Index on addresses that fetches addresses per user
CREATE INDEX idx_addresses_user ON addresses(user_id);
CREATE INDEX idx_addresses_user_default ON addresses(user_id, is_default);

-- Index on categories for hierarchy traversal
CREATE INDEX idx_categories_parent ON categories(parent_id);

-- Index on products for search by name and filter by active
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_active ON products(active);

-- Index on product categories
CREATE INDEX idx_pc_category ON product_categories(category_id);

-- Index on inventory
CREATE INDEX idx_inventory_reorder ON inventory(reorder_level, quantity);
CREATE INDEX idx_inventory_updated_at ON inventory(updated_at);

-- Index on orders
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Index on order items
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Index on payments
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- Index on shipments for listing shipments for an order
CREATE INDEX idx_shipments_order ON shipments(order_id);
CREATE INDEX idx_shipments_created_at ON shipments(created_at);
