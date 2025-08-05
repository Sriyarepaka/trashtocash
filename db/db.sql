-- Drop tables if they exist (for clean initialization)
DROP TABLE IF EXISTS SELLER_BUYER_LINEAGE_REQUESTS;
DROP TABLE IF EXISTS SELLERS_REQUESTS;
DROP TABLE IF EXISTS ITEMS_STORE;
DROP TABLE IF EXISTS USER_SESSION_AUDIT;
DROP TABLE IF EXISTS USERS_OTP_STORE;
DROP TABLE IF EXISTS USERS;
DROP TABLE IF EXISTS ROLES;

-- Create ROLES table
CREATE TABLE ROLES (
    id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Create USERS table
CREATE TABLE USERS (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email_id VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    role_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES ROLES(id)
);

-- Create USERS_OTP_STORE table
CREATE TABLE USERS_OTP_STORE (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    otp VARCHAR(10) NOT NULL,
    generated_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_time TIMESTAMP,
    validated BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES USERS(id)
);

-- Set default for expiry_time to be 15 minutes after generated_time
ALTER TABLE USERS_OTP_STORE 
    ALTER COLUMN expiry_time SET DEFAULT CURRENT_TIMESTAMP + INTERVAL '15 minutes';

-- Create USER_SESSION_AUDIT table
CREATE TABLE USER_SESSION_AUDIT (
    id INTEGER NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    logout_time TIMESTAMP,
    FOREIGN KEY (id) REFERENCES USERS(id)
);

-- Create ITEMS_STORE table
CREATE TABLE ITEMS_STORE (
    id SERIAL PRIMARY KEY,
    item_type VARCHAR(100) NOT NULL,
    unit VARCHAR(20) NOT NULL
);

-- Create SELLERS_REQUESTS table
CREATE TABLE SELLERS_REQUESTS (
    id SERIAL PRIMARY KEY,
    seller_id INTEGER NOT NULL,
    poc_number VARCHAR(20),
    poc_email_id VARCHAR(100),
    address_line_1 VARCHAR(255) NOT NULL,
    address_line_2 VARCHAR(255),
    pincode VARCHAR(10) NOT NULL,
    item_id INTEGER NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    image VARCHAR(255),
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    preferred_date DATE,
    preferred_time TIME,
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (seller_id) REFERENCES USERS(id),
    FOREIGN KEY (item_id) REFERENCES ITEMS_STORE(id)
);

-- Create SELLER_BUYER_LINEAGE_REQUESTS table
CREATE TABLE SELLER_BUYER_LINEAGE_REQUESTS (
    seller_request_id INTEGER NOT NULL,
    buyer_id INTEGER NOT NULL,
    request_created_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_accepted BOOLEAN DEFAULT FALSE,
    quantity DECIMAL(10, 2) NOT NULL,
    purchase_bid_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (seller_request_id, buyer_id),
    FOREIGN KEY (seller_request_id) REFERENCES SELLERS_REQUESTS(id),
    FOREIGN KEY (buyer_id) REFERENCES USERS(id)
);

-- Insert default roles
INSERT INTO ROLES (role_name) VALUES ('Admin');
INSERT INTO ROLES (role_name) VALUES ('Seller');
INSERT INTO ROLES (role_name) VALUES ('Buyer');

-- Insert default item categories from README
INSERT INTO ITEMS_STORE (item_type, unit) VALUES ('Food', 'kg');
INSERT INTO ITEMS_STORE (item_type, unit) VALUES ('Plastic Bottles', 'kg');
INSERT INTO ITEMS_STORE (item_type, unit) VALUES ('Newspapers', 'kg');
INSERT INTO ITEMS_STORE (item_type, unit) VALUES ('Spare Parts (Electronics)', 'unit');
INSERT INTO ITEMS_STORE (item_type, unit) VALUES ('Dry Waste', 'kg');
INSERT INTO ITEMS_STORE (item_type, unit) VALUES ('Wet Waste', 'kg');

-- =============================================================================
-- BAZARIO MARKETPLACE DATABASE
-- =============================================================================
-- This schema supports a multi-category marketplace that connects sellers and buyers
-- with role-based authentication, product listings, and transaction tracking.
-- =============================================================================

-- =============================================================================
-- SAMPLE DATA FOR TESTING AND DEVELOPMENT
-- =============================================================================

-- Add sample users (password would be hashed in production)
INSERT INTO USERS (name, email_id, phone_number, password, role_id) VALUES
    ('Admin User', 'admin@bazario.com', '9876543210', 'admin123', 1),
    ('Rahul Singh', 'rahul@example.com', '9876543211', 'seller123', 2),
    ('Priya Sharma', 'priya@example.com', '9876543212', 'seller123', 2),
    ('Akash Kumar', 'akash@example.com', '9876543213', 'buyer123', 3),
    ('Neha Gupta', 'neha@example.com', '9876543214', 'buyer123', 3),
    ('Vikram Joshi', 'vikram@example.com', '9876543215', 'buyer123', 3);

-- Add sample OTP entries
INSERT INTO USERS_OTP_STORE (user_id, otp, generated_time, expiry_time, validated) VALUES
    (2, '123456', CURRENT_TIMESTAMP - INTERVAL '5 minutes', CURRENT_TIMESTAMP + INTERVAL '10 minutes', FALSE),
    (3, '654321', CURRENT_TIMESTAMP - INTERVAL '10 minutes', CURRENT_TIMESTAMP + INTERVAL '5 minutes', TRUE);

-- Add sample session audits
INSERT INTO USER_SESSION_AUDIT (id, login_time, logout_time) VALUES
    (2, CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '1 hour'),
    (3, CURRENT_TIMESTAMP - INTERVAL '30 minutes', NULL),
    (4, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '23 hours'),
    (5, CURRENT_TIMESTAMP - INTERVAL '15 minutes', NULL);

-- Add sample seller requests
INSERT INTO SELLERS_REQUESTS (
    seller_id, poc_number, poc_email_id, address_line_1, address_line_2, 
    pincode, item_id, quantity, image, description, price, 
    preferred_date, preferred_time, is_closed
) VALUES
    (2, '9876543211', 'rahul@example.com', '123 Green Park', 'Near Metro Station', 
    '110016', 1, 5.5, 'food_image1.jpg', 'Excess restaurant food in good condition', 1200.00, 
    CURRENT_DATE + INTERVAL '1 day', '14:00:00', FALSE),
    
    (2, '9876543211', 'rahul@example.com', '123 Green Park', 'Near Metro Station', 
    '110016', 2, 10.0, 'plastic_bottles.jpg', 'Clean plastic bottles for recycling', 300.00, 
    CURRENT_DATE + INTERVAL '2 days', '10:00:00', FALSE),
    
    (3, '9876543212', 'priya@example.com', '456 Sunshine Colony', 'Block B', 
    '110025', 3, 15.0, 'newspapers.jpg', 'Old newspapers and magazines', 450.00, 
    CURRENT_DATE + INTERVAL '1 day', '16:00:00', FALSE),
    
    (3, '9876543212', 'priya@example.com', '456 Sunshine Colony', 'Block B', 
    '110025', 4, 3.0, 'electronics.jpg', 'Used smartphone parts in working condition', 2500.00, 
    CURRENT_DATE - INTERVAL '5 days', '11:00:00', TRUE);

-- Add sample buyer bids
INSERT INTO SELLER_BUYER_LINEAGE_REQUESTS (
    seller_request_id, buyer_id, request_created_time, is_accepted, quantity, purchase_bid_price
) VALUES
    (1, 4, CURRENT_TIMESTAMP - INTERVAL '12 hours', TRUE, 5.5, 1100.00),
    (2, 4, CURRENT_TIMESTAMP - INTERVAL '10 hours', FALSE, 10.0, 250.00),
    (3, 5, CURRENT_TIMESTAMP - INTERVAL '8 hours', TRUE, 15.0, 450.00),
    (4, 6, CURRENT_TIMESTAMP - INTERVAL '7 days', TRUE, 3.0, 2400.00),
    (2, 5, CURRENT_TIMESTAMP - INTERVAL '6 hours', FALSE, 5.0, 160.00),
    (3, 6, CURRENT_TIMESTAMP - INTERVAL '5 hours', FALSE, 7.5, 200.00);

-- =============================================================================
-- SAMPLE QUERIES FOR COMMON APPLICATION SCENARIOS
-- =============================================================================

-- 1. User Authentication Query
-- SELECT id, name, email_id, role_id FROM USERS WHERE email_id = 'rahul@example.com' AND password = 'seller123';

-- 2. Validate OTP
-- SELECT u.id, u.name, u.role_id FROM USERS u
-- JOIN USERS_OTP_STORE o ON u.id = o.user_id
-- WHERE o.otp = '123456' AND o.validated = FALSE AND o.expiry_time > CURRENT_TIMESTAMP;

-- 3. Seller Dashboard - View all my listings
-- SELECT sr.id, i.item_type, sr.quantity, sr.price, sr.preferred_date, sr.is_closed,
--     (SELECT COUNT(*) FROM SELLER_BUYER_LINEAGE_REQUESTS WHERE seller_request_id = sr.id) as bid_count
-- FROM SELLERS_REQUESTS sr
-- JOIN ITEMS_STORE i ON sr.item_id = i.id
-- WHERE sr.seller_id = 2
-- ORDER BY sr.preferred_date;

-- 4. Buyer Dashboard - View available listings with filters
-- SELECT sr.id, u.name as seller_name, i.item_type, sr.quantity, i.unit, sr.price, 
--     sr.preferred_date, sr.preferred_time, sr.description
-- FROM SELLERS_REQUESTS sr
-- JOIN USERS u ON sr.seller_id = u.id
-- JOIN ITEMS_STORE i ON sr.item_id = i.id
-- WHERE sr.is_closed = FALSE 
--     AND sr.item_id = 2  -- Filter by item type (plastic bottles)
--     AND sr.price <= 500  -- Filter by max price
--     AND sr.preferred_date >= CURRENT_DATE  -- Only future dates
-- ORDER BY sr.price;

-- 5. View all bids for a seller's request
-- SELECT u.name as buyer_name, sblr.quantity, sblr.purchase_bid_price, 
--     sblr.request_created_time, sblr.is_accepted
-- FROM SELLER_BUYER_LINEAGE_REQUESTS sblr
-- JOIN USERS u ON sblr.buyer_id = u.id
-- WHERE sblr.seller_request_id = 2
-- ORDER BY sblr.purchase_bid_price DESC;

-- 6. View buyer's order history
-- SELECT sr.id, u.name as seller_name, i.item_type, sblr.quantity, i.unit, 
--     sblr.purchase_bid_price, sblr.request_created_time, sblr.is_accepted
-- FROM SELLER_BUYER_LINEAGE_REQUESTS sblr
-- JOIN SELLERS_REQUESTS sr ON sblr.seller_request_id = sr.id
-- JOIN USERS u ON sr.seller_id = u.id
-- JOIN ITEMS_STORE i ON sr.item_id = i.id
-- WHERE sblr.buyer_id = 4
-- ORDER BY sblr.request_created_time DESC;

-- 7. Admin query - View all transactions
-- SELECT sr.id as request_id, 
--     seller.name as seller_name, 
--     buyer.name as buyer_name,
--     i.item_type, 
--     sblr.quantity, 
--     i.unit,
--     sblr.purchase_bid_price, 
--     sblr.request_created_time, 
--     sblr.is_accepted
-- FROM SELLER_BUYER_LINEAGE_REQUESTS sblr
-- JOIN SELLERS_REQUESTS sr ON sblr.seller_request_id = sr.id
-- JOIN USERS seller ON sr.seller_id = seller.id
-- JOIN USERS buyer ON sblr.buyer_id = buyer.id
-- JOIN ITEMS_STORE i ON sr.item_id = i.id
-- ORDER BY sblr.request_created_time DESC;

-- 8. Get summary counts for admin dashboard
-- SELECT 'Total Users' as metric, COUNT(*) as count FROM USERS
-- UNION ALL
-- SELECT 'Active Sellers' as metric, COUNT(DISTINCT seller_id) FROM SELLERS_REQUESTS WHERE is_closed = FALSE
-- UNION ALL
-- SELECT 'Open Requests' as metric, COUNT(*) FROM SELLERS_REQUESTS WHERE is_closed = FALSE
-- UNION ALL
-- SELECT 'Completed Transactions' as metric, COUNT(*) FROM SELLER_BUYER_LINEAGE_REQUESTS WHERE is_accepted = TRUE;