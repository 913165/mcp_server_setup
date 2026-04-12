-- ============================================================
--  productsdb  |  PostgreSQL — public schema
--  Run connected to your target database (e.g. postgres)
--  Tables go into the public schema — no prefix needed
-- ============================================================

-- Drop tables in reverse FK dependency order
DROP TABLE IF EXISTS reviews     CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders      CASCADE;
DROP TABLE IF EXISTS products    CASCADE;
DROP TABLE IF EXISTS categories  CASCADE;
DROP TABLE IF EXISTS customers   CASCADE;

-- ============================================================
-- 1. CATEGORIES
-- ============================================================
CREATE TABLE categories (
    category_id   SERIAL        PRIMARY KEY,
    name          VARCHAR(100)  NOT NULL UNIQUE,
    description   TEXT,
    parent_id     INT           REFERENCES categories(category_id) ON DELETE SET NULL,
    created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

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


-- ============================================================
-- 2. CUSTOMERS
-- ============================================================
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


-- ============================================================
-- 3. PRODUCTS
-- ============================================================
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

INSERT INTO products (category_id, name, description, price, stock_qty, sku, brand, is_active) VALUES
    (2,  'Dell Inspiron 15',         '15.6" FHD laptop, Intel i5, 16GB RAM, 512GB SSD',          65999.00,  30, 'SKU-LAP-001', 'Dell',          TRUE),
    (2,  'HP Pavilion x360',         '14" touch 2-in-1, Ryzen 5, 8GB RAM, 256GB SSD',            58499.00,  25, 'SKU-LAP-002', 'HP',            TRUE),
    (2,  'Logitech MX Master 3',     'Advanced wireless mouse for professionals',                  8999.00,  80, 'SKU-PER-001', 'Logitech',      TRUE),
    (2,  'Mechanical Keyboard RGB',  'Tenkeyless mechanical keyboard with Cherry MX switches',    4499.00,   60, 'SKU-PER-002', 'Keychron',      TRUE),
    (3,  'Samsung Galaxy S24',       '6.1" AMOLED, Snapdragon 8 Gen 3, 128GB',                  74999.00,  50, 'SKU-MOB-001', 'Samsung',       TRUE),
    (3,  'iPhone 15',                '6.1" Super Retina XDR, A16 Bionic, 128GB',                79999.00,  40, 'SKU-MOB-002', 'Apple',         TRUE),
    (3,  'OnePlus 12',               '6.82" LTPO AMOLED, Snapdragon 8 Gen 3, 256GB',            64999.00,  35, 'SKU-MOB-003', 'OnePlus',       TRUE),
    (5,  'Men''s Slim Fit Shirt',    '100% cotton slim fit formal shirt',                         1299.00, 150, 'SKU-CLT-001', 'Raymond',       TRUE),
    (5,  'Men''s Chino Trousers',    'Stretch chino trousers, available in 4 colours',            1899.00, 120, 'SKU-CLT-002', 'Arrow',         TRUE),
    (6,  'Women''s Kurta Set',       'Embroidered cotton kurta with palazzo pants',               2499.00,  90, 'SKU-CLT-003', 'Biba',          TRUE),
    (7,  'Stainless Steel Cookware', '5-piece non-stick cookware set with glass lids',            3999.00,  45, 'SKU-HOM-001', 'Prestige',      TRUE),
    (7,  'Electric Kettle 1.7L',     '1500W stainless steel kettle with auto shut-off',           1299.00,  70, 'SKU-HOM-002', 'Philips',       TRUE),
    (8,  'Atomic Habits',            'James Clear — build good habits, break bad ones',            499.00, 200, 'SKU-BOK-001', 'Penguin',       TRUE),
    (8,  'The Alchemist',            'Paulo Coelho — international bestseller',                    299.00, 180, 'SKU-BOK-002', 'HarperCollins', TRUE),
    (9,  'Yoga Mat 6mm',             'Anti-slip TPE yoga mat with carry strap',                   1199.00,  95, 'SKU-SPT-001', 'Boldfit',       TRUE),
    (9,  'Resistance Bands Set',     'Set of 5 latex resistance bands (5–40 lbs)',                 799.00, 110, 'SKU-SPT-002', 'Fitkit',        TRUE),
    (10, 'LEGO Classic Bricks',      'Creative building bricks set, 790 pieces, age 4+',         3499.00,  55, 'SKU-TOY-001', 'LEGO',          TRUE),
    (10, 'Remote Control Car',       '1:16 scale RC car with 2.4GHz control, 30km/h',            1999.00,  65, 'SKU-TOY-002', 'Webby',         TRUE),
    (1,  'Sony WH-1000XM5',         'Industry-leading noise cancelling wireless headphones',    29999.00,  40, 'SKU-ELC-001', 'Sony',          TRUE),
    (1,  'Anker 65W GaN Charger',   'Compact 3-port GaN charger (2x USB-C, 1x USB-A)',          2999.00, 100, 'SKU-ELC-002', 'Anker',         TRUE);


-- ============================================================
-- 4. ORDERS
-- ============================================================
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


-- ============================================================
-- 5. ORDER_ITEMS
-- ============================================================
CREATE TABLE order_items (
    order_item_id   SERIAL        PRIMARY KEY,
    order_id        INT           NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      INT           NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity        INT           NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL,
    discount        NUMERIC(10,2) DEFAULT 0.00,
    subtotal        NUMERIC(12,2) GENERATED ALWAYS AS (quantity * unit_price - discount) STORED
);

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


-- ============================================================
-- 6. REVIEWS
-- ============================================================
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

INSERT INTO reviews (product_id, customer_id, rating, title, body, is_verified, helpful_count) VALUES
    (5,  1,  5, 'Absolutely love this phone!',   'The Galaxy S24 camera is stunning. Battery life is excellent and display is super vibrant.',          TRUE, 14),
    (6,  2,  5, 'Best iPhone yet',               'Smooth performance, great camera system. iOS 17 feels polished. Totally worth the price.',            TRUE, 22),
    (1,  3,  4, 'Great laptop for the price',    'Dell Inspiron handles multitasking well. Thermal management could be better under heavy load.',       TRUE,  9),
    (10, 4,  5, 'Beautiful kurta set',           'Quality fabric, stitching is excellent and the colour is exactly as shown. Will buy again.',          TRUE,  7),
    (3,  5,  5, 'Best mouse I have ever used',   'The MX Master 3 is incredibly precise. The scroll wheel alone is worth the upgrade.',                 TRUE, 18),
    (19, 7,  5, 'Worth every rupee',             'Sony XM5 noise cancellation is on another level. Perfect for flights and open offices.',              TRUE, 31),
    (13, 8,  4, 'Great book, changed my habits', 'Atomic Habits is genuinely practical. Some chapters feel repetitive but the core message is solid.',  TRUE,  6),
    (17, 9,  5, 'Kids absolutely love it',       'LEGO Classic set kept my 6-year-old busy for days. Pieces are sturdy and well-designed.',             TRUE, 11),
    (15, 6,  3, 'Decent yoga mat',               'Good grip on smooth floors but slightly slippery on tiles. Thickness is fine for light yoga.',        TRUE,  4),
    (7,  10, 5, 'OnePlus at its best',           'Blazing fast, gorgeous display and Hasselblad camera is exceptional. Best phone under 70k easily.',   TRUE, 19),
    (4,  1,  4, 'Solid mechanical keyboard',     'Tactile feedback is satisfying. RGB lighting is beautiful. Slightly loud for office use.',            TRUE,  8),
    (20, 2,  5, 'Compact and fast charger',      'Anker GaN charger charges my laptop and phone simultaneously. Runs barely warm. Excellent build.',    TRUE, 13),
    (12, 3,  4, 'Heats water fast',              'Philips kettle boils 1.7L in under 4 minutes. Auto shut-off works perfectly. Good value.',           TRUE,  5),
    (16, 4,  5, 'Perfect resistance bands',      'All five resistance levels are clearly differentiated. Great for home workouts. Durable material.',   TRUE,  9),
    (14, 5,  5, 'A timeless classic',            'The Alchemist never gets old. Beautiful storytelling and a powerful message about following dreams.', FALSE, 3);


-- ============================================================
-- Views
-- ============================================================

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
