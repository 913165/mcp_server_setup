docker run -d -p 5432:5432 --name postgres-container -e POSTGRES_PASSWORD=postgres123 -e POSTGRES_DB=productsdb postgres:latest

# productsdb — PostgreSQL Schema & Sample Data

> Complete schema with `CREATE TABLE` and `INSERT` statements for all 6 tables.  
> Run with: `psql -U postgres -f productsdb.sql`

---

## Table of Contents

- [Setup](#setup)
- [1. categories](#1-categories)
- [2. customers](#2-customers)
- [3. products](#3-products)
- [4. orders](#4-orders)
- [5. order\_items](#5-order_items)
- [6. reviews](#6-reviews)
- [Bonus Views](#bonus-views)
- [Schema Overview](#schema-overview)

---

## Setup

```sql
CREATE DATABASE productsdb;
\c productsdb;
```

---

## 1. categories

Hierarchical category tree — supports parent/child via `parent_id` self-reference.

### Schema

```sql
CREATE TABLE categories (
    category_id   SERIAL        PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL UNIQUE,
    description   TEXT,
    parent_id     INT           REFERENCES categories(category_id) ON DELETE SET NULL,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
```

### Column Reference

| Column | Type | Notes |
|---|---|---|
| `category_id` | SERIAL | Primary key, auto-increment |
| `name` | VARCHAR(100) | Unique category name |
| `description` | TEXT | Optional description |
| `parent_id` | INT | Self-reference for sub-categories |
| `created_at` | TIMESTAMP | Auto-set on insert |

### Insert Statements

```sql
INSERT INTO categories (name, description, parent_id) VALUES
    ('Electronics',     'Electronic devices and accessories',         NULL),
    ('Computers',       'Laptops, desktops and peripherals',          1),
    ('Mobile Phones',   'Smartphones and accessories',                1),
    ('Clothing',        'Apparel for men, women and kids',            NULL),
    ('Men''s Wear',     'Shirts, trousers, jackets for men',          4),
    ('Women''s Wear',   'Dresses, tops, skirts for women',            4),
    ('Home & Kitchen',  'Furniture, cookware and home essentials',    NULL),
    ('Books',           'Fiction, non-fiction, educational',          NULL),
    ('Sports',          'Sporting goods and fitness equipment',       NULL),
    ('Toys',            'Toys and games for all ages',                NULL);
```

### Sample Data

| category_id | name | description | parent_id |
|---|---|---|---|
| 1 | Electronics | Electronic devices and accessories | NULL |
| 2 | Computers | Laptops, desktops and peripherals | 1 |
| 3 | Mobile Phones | Smartphones and accessories | 1 |
| 4 | Clothing | Apparel for men, women and kids | NULL |
| 5 | Men's Wear | Shirts, trousers, jackets for men | 4 |
| 6 | Women's Wear | Dresses, tops, skirts for women | 4 |
| 7 | Home & Kitchen | Furniture, cookware and home essentials | NULL |
| 8 | Books | Fiction, non-fiction, educational | NULL |
| 9 | Sports | Sporting goods and fitness equipment | NULL |
| 10 | Toys | Toys and games for all ages | NULL |

---

## 2. customers

Stores customer profile and contact information.

### Schema

```sql
CREATE TABLE customers (
    customer_id   SERIAL        PRIMARY KEY,
    first_name    VARCHAR(50)   NOT NULL,
    last_name     VARCHAR(50)   NOT NULL,
    email         VARCHAR(150)  NOT NULL UNIQUE,
    phone         VARCHAR(20),
    address       TEXT,
    city          VARCHAR(80),
    state         VARCHAR(80),
    country       VARCHAR(60)   DEFAULT 'India',
    pincode       VARCHAR(10),
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);
```

### Column Reference

| Column | Type | Notes |
|---|---|---|
| `customer_id` | SERIAL | Primary key |
| `first_name` | VARCHAR(50) | Required |
| `last_name` | VARCHAR(50) | Required |
| `email` | VARCHAR(150) | Unique, required |
| `phone` | VARCHAR(20) | Optional |
| `address` | TEXT | Street address |
| `city` | VARCHAR(80) | City name |
| `state` | VARCHAR(80) | State name |
| `country` | VARCHAR(60) | Defaults to `'India'` |
| `pincode` | VARCHAR(10) | Postal code |
| `created_at` | TIMESTAMP | Auto-set on insert |

### Insert Statements

```sql
INSERT INTO customers (first_name, last_name, email, phone, address, city, state, country, pincode) VALUES
    ('Aarav',   'Sharma',   'aarav.sharma@email.com',   '9812345678', '12 MG Road',          'Mumbai',    'Maharashtra', 'India', '400001'),
    ('Priya',   'Mehta',    'priya.mehta@email.com',    '9823456789', '45 Banjara Hills',    'Hyderabad', 'Telangana',   'India', '500034'),
    ('Rohit',   'Verma',    'rohit.verma@email.com',    '9834567890', '7 Indiranagar',       'Bangalore', 'Karnataka',   'India', '560038'),
    ('Sneha',   'Patel',    'sneha.patel@email.com',    '9845678901', '23 CG Road',          'Ahmedabad', 'Gujarat',     'India', '380009'),
    ('Karan',   'Singh',    'karan.singh@email.com',    '9856789012', '101 Connaught Place', 'New Delhi', 'Delhi',       'India', '110001'),
    ('Divya',   'Nair',     'divya.nair@email.com',     '9867890123', '88 Marine Drive',     'Kochi',     'Kerala',      'India', '682001'),
    ('Vikram',  'Joshi',    'vikram.joshi@email.com',   '9878901234', '5 Anna Salai',        'Chennai',   'Tamil Nadu',  'India', '600002'),
    ('Ananya',  'Reddy',    'ananya.reddy@email.com',   '9889012345', '33 Park Street',      'Kolkata',   'West Bengal', 'India', '700016'),
    ('Manish',  'Gupta',    'manish.gupta@email.com',   '9890123456', '18 Civil Lines',      'Jaipur',    'Rajasthan',   'India', '302006'),
    ('Pooja',   'Kulkarni', 'pooja.kulkarni@email.com', '9801234567', '67 FC Road',          'Pune',      'Maharashtra', 'India', '411004');
```

### Sample Data

| customer_id | name | email | city | state |
|---|---|---|---|---|
| 1 | Aarav Sharma | aarav.sharma@email.com | Mumbai | Maharashtra |
| 2 | Priya Mehta | priya.mehta@email.com | Hyderabad | Telangana |
| 3 | Rohit Verma | rohit.verma@email.com | Bangalore | Karnataka |
| 4 | Sneha Patel | sneha.patel@email.com | Ahmedabad | Gujarat |
| 5 | Karan Singh | karan.singh@email.com | New Delhi | Delhi |
| 6 | Divya Nair | divya.nair@email.com | Kochi | Kerala |
| 7 | Vikram Joshi | vikram.joshi@email.com | Chennai | Tamil Nadu |
| 8 | Ananya Reddy | ananya.reddy@email.com | Kolkata | West Bengal |
| 9 | Manish Gupta | manish.gupta@email.com | Jaipur | Rajasthan |
| 10 | Pooja Kulkarni | pooja.kulkarni@email.com | Pune | Maharashtra |

---

## 3. products

Product catalogue with pricing, stock, and SKU tracking.

### Schema

```sql
CREATE TABLE products (
    product_id    SERIAL          PRIMARY KEY,
    category_id   INT             NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    name          VARCHAR(200)    NOT NULL,
    description   TEXT,
    price         NUMERIC(10,2)   NOT NULL CHECK (price >= 0),
    stock_qty     INT             NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
    sku           VARCHAR(60)     UNIQUE,
    brand         VARCHAR(100),
    image_url     TEXT,
    is_active     BOOLEAN         DEFAULT TRUE,
    created_at    TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);
```

### Column Reference

| Column | Type | Notes |
|---|---|---|
| `product_id` | SERIAL | Primary key |
| `category_id` | INT | FK → `categories`, RESTRICT on delete |
| `name` | VARCHAR(200) | Product name |
| `description` | TEXT | Product description |
| `price` | NUMERIC(10,2) | Must be ≥ 0 |
| `stock_qty` | INT | Defaults to 0, must be ≥ 0 |
| `sku` | VARCHAR(60) | Unique stock-keeping unit |
| `brand` | VARCHAR(100) | Brand name |
| `image_url` | TEXT | Optional product image URL |
| `is_active` | BOOLEAN | Defaults to `TRUE` |
| `created_at` | TIMESTAMP | Auto-set on insert |

### Insert Statements

```sql
INSERT INTO products (category_id, name, description, price, stock_qty, sku, brand, is_active) VALUES
    (2,  'Dell Inspiron 15',         '15.6" FHD laptop, Intel i5, 16GB RAM, 512GB SSD',          65999.00,  30,  'SKU-LAP-001', 'Dell',          TRUE),
    (2,  'HP Pavilion x360',         '14" touch 2-in-1, Ryzen 5, 8GB RAM, 256GB SSD',            58499.00,  25,  'SKU-LAP-002', 'HP',            TRUE),
    (2,  'Logitech MX Master 3',     'Advanced wireless mouse for professionals',                  8999.00,  80,  'SKU-PER-001', 'Logitech',      TRUE),
    (2,  'Mechanical Keyboard RGB',  'Tenkeyless mechanical keyboard with Cherry MX switches',    4499.00,   60,  'SKU-PER-002', 'Keychron',      TRUE),
    (3,  'Samsung Galaxy S24',       '6.1" AMOLED, Snapdragon 8 Gen 3, 128GB',                  74999.00,   50,  'SKU-MOB-001', 'Samsung',       TRUE),
    (3,  'iPhone 15',                '6.1" Super Retina XDR, A16 Bionic, 128GB',                79999.00,   40,  'SKU-MOB-002', 'Apple',         TRUE),
    (3,  'OnePlus 12',               '6.82" LTPO AMOLED, Snapdragon 8 Gen 3, 256GB',            64999.00,   35,  'SKU-MOB-003', 'OnePlus',       TRUE),
    (5,  'Men''s Slim Fit Shirt',    '100% cotton slim fit formal shirt',                         1299.00, 150,  'SKU-CLT-001', 'Raymond',       TRUE),
    (5,  'Men''s Chino Trousers',    'Stretch chino trousers, available in 4 colours',            1899.00, 120,  'SKU-CLT-002', 'Arrow',         TRUE),
    (6,  'Women''s Kurta Set',       'Embroidered cotton kurta with palazzo pants',               2499.00,  90,  'SKU-CLT-003', 'Biba',          TRUE),
    (7,  'Stainless Steel Cookware', '5-piece non-stick cookware set with glass lids',            3999.00,  45,  'SKU-HOM-001', 'Prestige',      TRUE),
    (7,  'Electric Kettle 1.7L',     '1500W stainless steel kettle with auto shut-off',           1299.00,  70,  'SKU-HOM-002', 'Philips',       TRUE),
    (8,  'Atomic Habits',            'James Clear — build good habits, break bad ones',            499.00, 200,  'SKU-BOK-001', 'Penguin',       TRUE),
    (8,  'The Alchemist',            'Paulo Coelho — international bestseller',                    299.00, 180,  'SKU-BOK-002', 'HarperCollins', TRUE),
    (9,  'Yoga Mat 6mm',             'Anti-slip TPE yoga mat with carry strap',                   1199.00,  95,  'SKU-SPT-001', 'Boldfit',       TRUE),
    (9,  'Resistance Bands Set',     'Set of 5 latex resistance bands (5–40 lbs)',                 799.00, 110,  'SKU-SPT-002', 'Fitkit',        TRUE),
    (10, 'LEGO Classic Bricks',      'Creative building bricks set, 790 pieces, age 4+',         3499.00,  55,  'SKU-TOY-001', 'LEGO',          TRUE),
    (10, 'Remote Control Car',       '1:16 scale RC car with 2.4GHz control, 30km/h',            1999.00,  65,  'SKU-TOY-002', 'Webby',         TRUE),
    (1,  'Sony WH-1000XM5',         'Industry-leading noise cancelling wireless headphones',    29999.00,  40,  'SKU-ELC-001', 'Sony',          TRUE),
    (1,  'Anker 65W GaN Charger',   'Compact 3-port GaN charger (2x USB-C, 1x USB-A)',          2999.00, 100,  'SKU-ELC-002', 'Anker',         TRUE);
```

### Sample Data

| product_id | name | brand | price (₹) | stock | sku |
|---|---|---|---|---|---|
| 1 | Dell Inspiron 15 | Dell | 65,999 | 30 | SKU-LAP-001 |
| 2 | HP Pavilion x360 | HP | 58,499 | 25 | SKU-LAP-002 |
| 3 | Logitech MX Master 3 | Logitech | 8,999 | 80 | SKU-PER-001 |
| 4 | Mechanical Keyboard RGB | Keychron | 4,499 | 60 | SKU-PER-002 |
| 5 | Samsung Galaxy S24 | Samsung | 74,999 | 50 | SKU-MOB-001 |
| 6 | iPhone 15 | Apple | 79,999 | 40 | SKU-MOB-002 |
| 7 | OnePlus 12 | OnePlus | 64,999 | 35 | SKU-MOB-003 |
| 8 | Men's Slim Fit Shirt | Raymond | 1,299 | 150 | SKU-CLT-001 |
| 9 | Men's Chino Trousers | Arrow | 1,899 | 120 | SKU-CLT-002 |
| 10 | Women's Kurta Set | Biba | 2,499 | 90 | SKU-CLT-003 |
| 11 | Stainless Steel Cookware | Prestige | 3,999 | 45 | SKU-HOM-001 |
| 12 | Electric Kettle 1.7L | Philips | 1,299 | 70 | SKU-HOM-002 |
| 13 | Atomic Habits | Penguin | 499 | 200 | SKU-BOK-001 |
| 14 | The Alchemist | HarperCollins | 299 | 180 | SKU-BOK-002 |
| 15 | Yoga Mat 6mm | Boldfit | 1,199 | 95 | SKU-SPT-001 |
| 16 | Resistance Bands Set | Fitkit | 799 | 110 | SKU-SPT-002 |
| 17 | LEGO Classic Bricks | LEGO | 3,499 | 55 | SKU-TOY-001 |
| 18 | Remote Control Car | Webby | 1,999 | 65 | SKU-TOY-002 |
| 19 | Sony WH-1000XM5 | Sony | 29,999 | 40 | SKU-ELC-001 |
| 20 | Anker 65W GaN Charger | Anker | 2,999 | 100 | SKU-ELC-002 |

---

## 4. orders

Order header records. Each order belongs to one customer.

### Schema

```sql
CREATE TABLE orders (
    order_id        SERIAL        PRIMARY KEY,
    customer_id     INT           NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    status          VARCHAR(30)   NOT NULL DEFAULT 'pending'
                                  CHECK (status IN ('pending','confirmed','shipped','delivered','cancelled','refunded')),
    total_amount    NUMERIC(12,2) NOT NULL DEFAULT 0,
    shipping_addr   TEXT,
    payment_method  VARCHAR(40)   DEFAULT 'UPI',
    payment_status  VARCHAR(20)   DEFAULT 'unpaid'
                                  CHECK (payment_status IN ('unpaid','paid','refunded')),
    ordered_at      TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    delivered_at    TIMESTAMP
);
```

### Column Reference

| Column | Type | Notes |
|---|---|---|
| `order_id` | SERIAL | Primary key |
| `customer_id` | INT | FK → `customers`, RESTRICT on delete |
| `status` | VARCHAR(30) | `pending` / `confirmed` / `shipped` / `delivered` / `cancelled` / `refunded` |
| `total_amount` | NUMERIC(12,2) | Order total in ₹ |
| `shipping_addr` | TEXT | Snapshot of delivery address |
| `payment_method` | VARCHAR(40) | UPI / Credit Card / Debit Card / Net Banking / COD / EMI |
| `payment_status` | VARCHAR(20) | `unpaid` / `paid` / `refunded` |
| `ordered_at` | TIMESTAMP | When order was placed |
| `delivered_at` | TIMESTAMP | When order was delivered (nullable) |

### Insert Statements

```sql
INSERT INTO orders (customer_id, status, total_amount, shipping_addr, payment_method, payment_status, ordered_at, delivered_at) VALUES
    (1,  'delivered',  74498.00, '12 MG Road, Mumbai 400001',           'UPI',         'paid',     '2024-11-01 10:15:00', '2024-11-05 14:30:00'),
    (2,  'delivered',  79999.00, '45 Banjara Hills, Hyderabad 500034',  'Credit Card', 'paid',     '2024-11-03 09:00:00', '2024-11-07 11:00:00'),
    (3,  'shipped',    65798.00, '7 Indiranagar, Bangalore 560038',     'Net Banking', 'paid',     '2024-11-10 16:45:00', NULL),
    (4,  'confirmed',   3798.00, '23 CG Road, Ahmedabad 380009',        'UPI',         'paid',     '2024-11-12 13:20:00', NULL),
    (5,  'delivered',   9498.00, '101 Connaught Place, Delhi 110001',   'Debit Card',  'paid',     '2024-10-28 08:30:00', '2024-11-01 10:00:00'),
    (6,  'cancelled',   2499.00, '88 Marine Drive, Kochi 682001',       'UPI',         'refunded', '2024-11-08 17:00:00', NULL),
    (7,  'delivered',  31298.00, '5 Anna Salai, Chennai 600002',        'Credit Card', 'paid',     '2024-10-20 11:10:00', '2024-10-24 15:45:00'),
    (8,  'pending',     1998.00, '33 Park Street, Kolkata 700016',      'COD',         'unpaid',   '2024-11-14 09:55:00', NULL),
    (9,  'delivered',   4998.00, '18 Civil Lines, Jaipur 302006',       'UPI',         'paid',     '2024-11-05 12:00:00', '2024-11-09 16:20:00'),
    (10, 'shipped',    64999.00, '67 FC Road, Pune 411004',             'EMI',         'paid',     '2024-11-11 14:35:00', NULL);
```

### Sample Data

| order_id | customer_id | status | total (₹) | payment_method | payment_status |
|---|---|---|---|---|---|
| 1 | 1 | delivered | 74,498 | UPI | paid |
| 2 | 2 | delivered | 79,999 | Credit Card | paid |
| 3 | 3 | shipped | 65,798 | Net Banking | paid |
| 4 | 4 | confirmed | 3,798 | UPI | paid |
| 5 | 5 | delivered | 9,498 | Debit Card | paid |
| 6 | 6 | cancelled | 2,499 | UPI | refunded |
| 7 | 7 | delivered | 31,298 | Credit Card | paid |
| 8 | 8 | pending | 1,998 | COD | unpaid |
| 9 | 9 | delivered | 4,998 | UPI | paid |
| 10 | 10 | shipped | 64,999 | EMI | paid |

---

## 5. order_items

Line items for each order. `subtotal` is a generated (computed) column.

### Schema

```sql
CREATE TABLE order_items (
    order_item_id   SERIAL        PRIMARY KEY,
    order_id        INT           NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      INT           NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity        INT           NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL,
    discount        NUMERIC(10,2) DEFAULT 0.00,
    subtotal        NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price - discount) STORED
);
```

### Column Reference

| Column | Type | Notes |
|---|---|---|
| `order_item_id` | SERIAL | Primary key |
| `order_id` | INT | FK → `orders`, CASCADE on delete |
| `product_id` | INT | FK → `products`, RESTRICT on delete |
| `quantity` | INT | Must be > 0 |
| `unit_price` | NUMERIC(10,2) | Price at time of order |
| `discount` | NUMERIC(10,2) | Item-level discount in ₹ |
| `subtotal` | NUMERIC(12,2) | **Generated** = `(quantity × unit_price) − discount` |

### Insert Statements

```sql
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount) VALUES
    -- Order 1: Samsung Galaxy S24 + Anker Charger
    (1,  5,  1, 74999.00, 1000.00),
    (1,  20, 1,  2999.00,  500.00),
    -- Order 2: iPhone 15
    (2,  6,  1, 79999.00,    0.00),
    -- Order 3: Dell Inspiron + Logitech Mouse + Mechanical Keyboard
    (3,  1,  1, 65999.00,  500.00),
    (3,  3,  1,  8999.00, 1000.00),
    (3,  4,  1,  4499.00, 3200.00),
    -- Order 4: Women's Kurta Set + Men's Chino Trousers
    (4,  10, 1,  2499.00,  600.00),
    (4,  9,  1,  1899.00,    0.00),
    -- Order 5: Logitech MX Master + Mechanical Keyboard
    (5,  3,  1,  8999.00,  500.00),
    (5,  4,  1,  4499.00, 3500.00),
    -- Order 6: Women's Kurta Set (cancelled)
    (6,  10, 1,  2499.00,    0.00),
    -- Order 7: Sony WH-1000XM5 + Atomic Habits + The Alchemist
    (7,  19, 1, 29999.00, 1000.00),
    (7,  13, 1,   499.00,    0.00),
    (7,  14, 1,   299.00,    0.00),
    -- Order 8: Resistance Bands + Yoga Mat
    (8,  16, 1,   799.00,    0.00),
    (8,  15, 1,  1199.00,    0.00),
    -- Order 9: LEGO Bricks + RC Car
    (9,  17, 1,  3499.00,    0.00),
    (9,  18, 1,  1999.00,  500.00),
    -- Order 10: OnePlus 12
    (10, 7,  1, 64999.00,    0.00);
```

### Sample Data

| order_item_id | order_id | product_id | qty | unit_price (₹) | discount (₹) | subtotal (₹) |
|---|---|---|---|---|---|---|
| 1 | 1 | 5 — Samsung Galaxy S24 | 1 | 74,999 | 1,000 | 73,999 |
| 2 | 1 | 20 — Anker Charger | 1 | 2,999 | 500 | 2,499 |
| 3 | 2 | 6 — iPhone 15 | 1 | 79,999 | 0 | 79,999 |
| 4 | 3 | 1 — Dell Inspiron | 1 | 65,999 | 500 | 65,499 |
| 5 | 3 | 3 — Logitech Mouse | 1 | 8,999 | 1,000 | 7,999 |
| 6 | 3 | 4 — Keyboard | 1 | 4,499 | 3,200 | 1,299 |
| 7 | 4 | 10 — Kurta Set | 1 | 2,499 | 600 | 1,899 |
| 8 | 4 | 9 — Chino Trousers | 1 | 1,899 | 0 | 1,899 |
| 9 | 5 | 3 — Logitech Mouse | 1 | 8,999 | 500 | 8,499 |
| 10 | 5 | 4 — Keyboard | 1 | 4,499 | 3,500 | 999 |

---

## 6. reviews

Customer reviews per product. One review per customer per product enforced by `UNIQUE` constraint.

### Schema

```sql
CREATE TABLE reviews (
    review_id     SERIAL        PRIMARY KEY,
    product_id    INT           NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    customer_id   INT           NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    rating        SMALLINT      NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title         VARCHAR(150),
    body          TEXT,
    is_verified   BOOLEAN       DEFAULT FALSE,
    helpful_count INT           DEFAULT 0,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, customer_id)
);
```

### Column Reference

| Column | Type | Notes |
|---|---|---|
| `review_id` | SERIAL | Primary key |
| `product_id` | INT | FK → `products`, CASCADE on delete |
| `customer_id` | INT | FK → `customers`, CASCADE on delete |
| `rating` | SMALLINT | 1–5 stars, enforced by CHECK |
| `title` | VARCHAR(150) | Review headline |
| `body` | TEXT | Full review text |
| `is_verified` | BOOLEAN | Verified purchase flag |
| `helpful_count` | INT | Number of "helpful" votes |
| `created_at` | TIMESTAMP | Auto-set on insert |

### Insert Statements

```sql
INSERT INTO reviews (product_id, customer_id, rating, title, body, is_verified, helpful_count) VALUES
    (5,  1, 5, 'Absolutely love this phone!',   'The Galaxy S24 camera is stunning. Battery life is excellent and display is super vibrant.',          TRUE, 14),
    (6,  2, 5, 'Best iPhone yet',               'Smooth performance, great camera system. iOS 17 feels polished. Totally worth the price.',            TRUE, 22),
    (1,  3, 4, 'Great laptop for the price',    'Dell Inspiron handles multitasking well. Thermal management could be better under heavy load.',       TRUE,  9),
    (10, 4, 5, 'Beautiful kurta set',           'Quality fabric, stitching is excellent and the colour is exactly as shown. Will buy again.',          TRUE,  7),
    (3,  5, 5, 'Best mouse I have ever used',   'The MX Master 3 is incredibly precise. The scroll wheel alone is worth the upgrade.',                 TRUE, 18),
    (19, 7, 5, 'Worth every rupee',             'Sony XM5 noise cancellation is on another level. Perfect for flights and open offices.',              TRUE, 31),
    (13, 8, 4, 'Great book, changed my habits', 'Atomic Habits is genuinely practical. Some chapters feel repetitive but the core message is solid.',  TRUE,  6),
    (17, 9, 5, 'Kids absolutely love it',       'LEGO Classic set kept my 6-year-old busy for days. Pieces are sturdy and well-designed.',             TRUE, 11),
    (15, 6, 3, 'Decent yoga mat',               'Good grip on smooth floors but slightly slippery on tiles. Thickness is fine for light yoga.',        TRUE,  4),
    (7,  10,5, 'OnePlus at its best',           'Blazing fast, gorgeous display and Hasselblad camera is exceptional. Best phone under 70k easily.',   TRUE, 19),
    (4,  1, 4, 'Solid mechanical keyboard',     'Tactile feedback is satisfying. RGB lighting is beautiful. Slightly loud for office use.',            TRUE,  8),
    (20, 2, 5, 'Compact and fast charger',      'Anker GaN charger charges my laptop and phone simultaneously. Runs barely warm. Excellent build.',    TRUE, 13),
    (12, 3, 4, 'Heats water fast',              'Philips kettle boils 1.7L in under 4 minutes. Auto shut-off works perfectly. Good value.',           TRUE,  5),
    (16, 4, 5, 'Perfect resistance bands',      'All five resistance levels are clearly differentiated. Great for home workouts. Durable material.',   TRUE,  9),
    (14, 5, 5, 'A timeless classic',            'The Alchemist never gets old. Beautiful storytelling and a powerful message about following dreams.', FALSE, 3);
```

### Sample Data

| review_id | product | customer | rating | title | verified |
|---|---|---|---|---|---|
| 1 | Samsung Galaxy S24 | Aarav Sharma | ⭐⭐⭐⭐⭐ | Absolutely love this phone! | ✓ |
| 2 | iPhone 15 | Priya Mehta | ⭐⭐⭐⭐⭐ | Best iPhone yet | ✓ |
| 3 | Dell Inspiron 15 | Rohit Verma | ⭐⭐⭐⭐ | Great laptop for the price | ✓ |
| 4 | Women's Kurta Set | Sneha Patel | ⭐⭐⭐⭐⭐ | Beautiful kurta set | ✓ |
| 5 | Logitech MX Master 3 | Karan Singh | ⭐⭐⭐⭐⭐ | Best mouse I have ever used | ✓ |
| 6 | Sony WH-1000XM5 | Vikram Joshi | ⭐⭐⭐⭐⭐ | Worth every rupee | ✓ |
| 7 | Atomic Habits | Ananya Reddy | ⭐⭐⭐⭐ | Great book, changed my habits | ✓ |
| 8 | LEGO Classic Bricks | Manish Gupta | ⭐⭐⭐⭐⭐ | Kids absolutely love it | ✓ |
| 9 | Yoga Mat 6mm | Divya Nair | ⭐⭐⭐ | Decent yoga mat | ✓ |
| 10 | OnePlus 12 | Pooja Kulkarni | ⭐⭐⭐⭐⭐ | OnePlus at its best | ✓ |

---

## Bonus Views

### v_top_rated_products

Returns products ranked by average customer rating.

```sql
CREATE VIEW v_top_rated_products AS
SELECT
    p.product_id,
    p.name,
    p.brand,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id)      AS review_count,
    p.price
FROM products p
JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name, p.brand, p.price
ORDER BY avg_rating DESC, review_count DESC;
```

### v_customer_order_summary

Returns lifetime value and order history per customer.

```sql
CREATE VIEW v_customer_order_summary AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    COUNT(o.order_id)   AS total_orders,
    SUM(o.total_amount) AS lifetime_value,
    MAX(o.ordered_at)   AS last_order_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email
ORDER BY lifetime_value DESC;
```

---

## MCP Prompts & SQL Queries

Ready-to-use natural language prompts and their matching PostgreSQL queries.  
All tables are prefixed with `productsdb.` schema.

---

### Basic Lookups

**"Show me all products with their category names and stock quantity"**
```sql
SELECT
    p.product_id,
    p.name          AS product_name,
    c.name          AS category,
    p.brand,
    p.price,
    p.stock_qty
FROM productsdb.products p
JOIN productsdb.categories c ON p.category_id = c.category_id
ORDER BY c.name, p.name;
```

---

**"List all customers with their city and state"**
```sql
SELECT
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    email,
    city,
    state,
    pincode
FROM productsdb.customers
ORDER BY state, city;
```

---

**"Get all orders placed in November 2024 sorted by order date"**
```sql
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.status,
    o.total_amount,
    o.payment_method,
    o.ordered_at
FROM productsdb.orders o
JOIN productsdb.customers c ON o.customer_id = c.customer_id
WHERE o.ordered_at BETWEEN '2024-11-01' AND '2024-11-30'
ORDER BY o.ordered_at;
```

---

**"Show me all active products in the Electronics category"**
```sql
SELECT
    p.product_id,
    p.name,
    p.brand,
    p.price,
    p.stock_qty,
    p.sku
FROM productsdb.products p
JOIN productsdb.categories c ON p.category_id = c.category_id
WHERE c.name = 'Electronics'
  AND p.is_active = TRUE
ORDER BY p.price DESC;
```

---

### Filtering & Searching

**"Find all products priced between ₹1000 and ₹10000 sorted by price"**
```sql
SELECT
    p.name,
    p.brand,
    c.name  AS category,
    p.price,
    p.stock_qty
FROM productsdb.products p
JOIN productsdb.categories c ON p.category_id = c.category_id
WHERE p.price BETWEEN 1000 AND 10000
ORDER BY p.price ASC;
```

---

**"Which customers are from Maharashtra?"**
```sql
SELECT
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    email,
    phone,
    city,
    pincode
FROM productsdb.customers
WHERE state = 'Maharashtra'
ORDER BY city;
```

---

**"Show me all orders that have been cancelled or refunded"**
```sql
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.status,
    o.total_amount,
    o.payment_method,
    o.payment_status,
    o.ordered_at
FROM productsdb.orders o
JOIN productsdb.customers c ON o.customer_id = c.customer_id
WHERE o.status IN ('cancelled', 'refunded')
ORDER BY o.ordered_at DESC;
```

---

**"Find products with stock below 50 that may need reordering"**
```sql
SELECT
    p.product_id,
    p.sku,
    p.name,
    p.brand,
    c.name  AS category,
    p.stock_qty
FROM productsdb.products p
JOIN productsdb.categories c ON p.category_id = c.category_id
WHERE p.stock_qty < 50
  AND p.is_active = TRUE
ORDER BY p.stock_qty ASC;
```

---

### Aggregations & Analytics

**"What is the total revenue from delivered orders?"**
```sql
SELECT
    COUNT(order_id)       AS total_orders,
    SUM(total_amount)     AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM productsdb.orders
WHERE status = 'delivered'
  AND payment_status = 'paid';
```

---

**"Which product has been ordered the most times?"**
```sql
SELECT
    p.product_id,
    p.name,
    p.brand,
    COUNT(oi.order_item_id) AS times_ordered,
    SUM(oi.quantity)        AS total_units_sold
FROM productsdb.order_items oi
JOIN productsdb.products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name, p.brand
ORDER BY total_units_sold DESC
LIMIT 5;
```

---

**"Show the top 5 highest spending customers"**
```sql
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    COUNT(o.order_id)       AS total_orders,
    SUM(o.total_amount)     AS lifetime_value
FROM productsdb.customers c
JOIN productsdb.orders o ON c.customer_id = o.customer_id
WHERE o.status != 'cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
ORDER BY lifetime_value DESC
LIMIT 5;
```

---

**"What is the average rating for each product with at least one review?"**
```sql
SELECT
    p.product_id,
    p.name,
    p.brand,
    ROUND(AVG(r.rating), 2) AS avg_rating,
    COUNT(r.review_id)      AS review_count,
    MIN(r.rating)           AS lowest_rating,
    MAX(r.rating)           AS highest_rating
FROM productsdb.products p
JOIN productsdb.reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name, p.brand
HAVING COUNT(r.review_id) >= 1
ORDER BY avg_rating DESC;
```

---

**"How many orders are in each status?"**
```sql
SELECT
    status,
    COUNT(order_id)     AS order_count,
    SUM(total_amount)   AS total_value
FROM productsdb.orders
GROUP BY status
ORDER BY order_count DESC;
```

---

### Joins Across Tables

**"Show each order with customer name, products ordered, and total"**
```sql
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name  AS customer_name,
    p.name                               AS product,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    oi.subtotal,
    o.status,
    o.ordered_at
FROM productsdb.orders o
JOIN productsdb.customers c    ON o.customer_id  = c.customer_id
JOIN productsdb.order_items oi ON o.order_id     = oi.order_id
JOIN productsdb.products p     ON oi.product_id  = p.product_id
ORDER BY o.order_id, p.name;
```

---

**"Which customers have never placed an order?"**
```sql
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.city
FROM productsdb.customers c
LEFT JOIN productsdb.orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

---

**"List all reviews with reviewer name, product, rating and title"**
```sql
SELECT
    r.review_id,
    c.first_name || ' ' || c.last_name AS reviewer,
    p.name                              AS product,
    p.brand,
    r.rating,
    r.title,
    r.is_verified,
    r.helpful_count,
    r.created_at
FROM productsdb.reviews r
JOIN productsdb.customers c ON r.customer_id = c.customer_id
JOIN productsdb.products p  ON r.product_id  = p.product_id
ORDER BY r.rating DESC, r.helpful_count DESC;
```

---

**"Show order items where a discount was applied"**
```sql
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.name                              AS product,
    oi.unit_price,
    oi.discount,
    oi.subtotal,
    ROUND((oi.discount / oi.unit_price) * 100, 1) AS discount_pct
FROM productsdb.order_items oi
JOIN productsdb.orders o    ON oi.order_id    = o.order_id
JOIN productsdb.customers c ON o.customer_id  = c.customer_id
JOIN productsdb.products p  ON oi.product_id  = p.product_id
WHERE oi.discount > 0
ORDER BY oi.discount DESC;
```

---

### Business Insights

**"Which category has generated the most revenue?"**
```sql
SELECT
    c.name              AS category,
    COUNT(DISTINCT o.order_id)  AS total_orders,
    SUM(oi.subtotal)             AS total_revenue
FROM productsdb.order_items oi
JOIN productsdb.products p     ON oi.product_id  = p.product_id
JOIN productsdb.categories c   ON p.category_id  = c.category_id
JOIN productsdb.orders o       ON oi.order_id    = o.order_id
WHERE o.status != 'cancelled'
GROUP BY c.name
ORDER BY total_revenue DESC;
```

---

**"Show products that have been ordered but never reviewed"**
```sql
SELECT
    p.product_id,
    p.name,
    p.brand,
    COUNT(oi.order_item_id) AS times_ordered
FROM productsdb.products p
JOIN productsdb.order_items oi ON p.product_id = oi.product_id
LEFT JOIN productsdb.reviews r  ON p.product_id = r.product_id
WHERE r.review_id IS NULL
GROUP BY p.product_id, p.name, p.brand
ORDER BY times_ordered DESC;
```

---

**"What is the average order value per payment method?"**
```sql
SELECT
    payment_method,
    COUNT(order_id)             AS total_orders,
    ROUND(AVG(total_amount), 2) AS avg_order_value,
    SUM(total_amount)           AS total_revenue
FROM productsdb.orders
WHERE payment_status = 'paid'
GROUP BY payment_method
ORDER BY total_revenue DESC;
```

---

**"Which brand has the highest average product rating?"**
```sql
SELECT
    p.brand,
    COUNT(DISTINCT p.product_id)    AS products_reviewed,
    ROUND(AVG(r.rating), 2)         AS avg_rating,
    COUNT(r.review_id)              AS total_reviews
FROM productsdb.products p
JOIN productsdb.reviews r ON p.product_id = r.product_id
GROUP BY p.brand
HAVING COUNT(r.review_id) >= 2
ORDER BY avg_rating DESC;
```

---

**"Find customers who have placed more than one order"**
```sql
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.city,
    COUNT(o.order_id)   AS order_count,
    SUM(o.total_amount) AS lifetime_value
FROM productsdb.customers c
JOIN productsdb.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.city
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;
```

---

### Data Integrity Checks

**"Are there order totals that don't match the sum of their order_items?"**
```sql
SELECT
    o.order_id,
    o.total_amount              AS recorded_total,
    SUM(oi.subtotal)            AS calculated_total,
    o.total_amount - SUM(oi.subtotal) AS difference
FROM productsdb.orders o
JOIN productsdb.order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount != SUM(oi.subtotal)
ORDER BY difference DESC;
```

---

**"Show products that have reviews but are currently inactive"**
```sql
SELECT
    p.product_id,
    p.name,
    p.brand,
    p.is_active,
    COUNT(r.review_id)      AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM productsdb.products p
JOIN productsdb.reviews r ON p.product_id = r.product_id
WHERE p.is_active = FALSE
GROUP BY p.product_id, p.name, p.brand, p.is_active;
```

---

**"Find delivered orders with a NULL delivered_at timestamp"**
```sql
SELECT
    o.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.status,
    o.ordered_at,
    o.delivered_at
FROM productsdb.orders o
JOIN productsdb.customers c ON o.customer_id = c.customer_id
WHERE o.status = 'delivered'
  AND o.delivered_at IS NULL;
```

---

## Schema Overview

```
categories ──────────────────────────────┐
    category_id (PK)                     │
    name                                 │ FK
    parent_id (self-ref FK)              ▼
                                     products
customers ───────────────────────────────┐   product_id (PK)
    customer_id (PK)                     │   category_id (FK → categories)
    first_name, last_name                │   name, price, stock_qty, sku
    email, phone, address                │
          │                              │
          │ FK                           │ FK
          ▼                              ▼
        orders ──────────── order_items ─┘
        order_id (PK)           order_item_id (PK)
        customer_id (FK)        order_id (FK → orders)
        status, total_amount    product_id (FK → products)
        payment_method          quantity, unit_price
        ordered_at              discount, subtotal (generated)
          │
          │ FK
          ▼
        reviews
        review_id (PK)
        product_id (FK → products)
        customer_id (FK → customers)
        rating (1–5), title, body
        is_verified, helpful_count
```
