-- Super App Database Schema for Neon PostgreSQL

-- 1. Users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) DEFAULT 'customer', -- 'customer' or 'professional'
    wallet_balance NUMERIC(12, 2) DEFAULT 500000.00,
    bidding_coins INT DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Shops / Booths table (Map hub)
CREATE TABLE IF NOT EXISTS shops (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    phone VARCHAR(50),
    latitude NUMERIC(10, 6) NOT NULL,
    longitude NUMERIC(10, 6) NOT NULL,
    rating NUMERIC(3, 2) DEFAULT 5.0,
    review_count INT DEFAULT 0,
    is_open BOOLEAN DEFAULT TRUE,
    operatingHours VARCHAR(100) DEFAULT '09:00 - 22:00',
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Products table (Marketplace & Rentals)
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(12, 2) DEFAULT 0.00,
    is_rental BOOLEAN DEFAULT FALSE,
    rental_price_per_day NUMERIC(12, 2) DEFAULT 0.00,
    stock INT DEFAULT 10,
    image_url TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Service Requests table (Expert booking pipeline)
CREATE TABLE IF NOT EXISTS service_requests (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    service_type VARCHAR(100) NOT NULL,
    description TEXT,
    address TEXT,
    status VARCHAR(50) DEFAULT 'searching', -- 'searching', 'assigned', 'completed'
    assigned_expert VARCHAR(255),
    agreed_price NUMERIC(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Transactions table (Wallet ledger)
CREATE TABLE IF NOT EXISTS transactions (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    is_income BOOLEAN DEFAULT FALSE,
    icon VARCHAR(10) DEFAULT '💳',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed initial mock data
INSERT INTO users (name, email, role, wallet_balance, bidding_coins) 
VALUES ('فرزاد عباسی', 'farzadabbasi@superapp.ir', 'professional', 2500000.00, 25)
ON CONFLICT (email) DO NOTHING;

INSERT INTO shops (name, category, description, address, phone, latitude, longitude, rating, review_count, is_open, operatingHours)
VALUES 
('فروشگاه دیجیتال مرکزی', 'Electronics', 'عرضه انواع لوازم جانبی و گوشی موبایل', 'تهران، خیابان ولیعصر، پلاک ۱۲', '۰۲۱۸۸۸۸۷۷۶۶', 35.6892, 51.3890, 4.8, 120, TRUE, '۰۹:۰۰ الی ۲۲:۰۰'),
('گلخانه ارکیده سبز', 'Plants', 'انواع گل و گیاهان آپارتمانی شاداب', 'تهران، تجریش، میدان قدس', '۰۲۱ּ۲۲۳۳۴۴۵۵', 35.6950, 51.4120, 4.9, 85, TRUE, '۰۸:۰۰ الی ۲۱:۰۰'),
('کافه دنج اسپشیالتی', 'Cafe', 'قهوه اسپشیالتی و کرواسان تازه پخت', 'تهران، بلوار کشاورز', '۰۲۱۸۸۹۹۰۰۱۱', 35.6780, 51.3750, 4.7, 210, TRUE, '۰۷:۰۰ الی ۲۳:۰۰')
ON CONFLICT DO NOTHING;

INSERT INTO products (name, category, description, price, is_rental, rental_price_per_day)
VALUES 
('گوشی آیفون ۱۵ پرو تیتانیوم', 'Electronics', 'حافظه ۲۵۶ گیگابایت پارت نامبر اصلی', 65000000.00, FALSE, 0.00),
('پاوربانک ۲۰۰۰۰ میلی‌آمپر ان커', 'Electronics', 'فست شارژ خروجی تایپ سی', 2500000.00, FALSE, 0.00),
('میکسر بتن کارگاهی موتوری', 'Industrial', 'میکسر ۲۵۰ لیتری بنزینی صنعتی', 0.00, TRUE, 450000.00),
('تراکتور کشاورزی سنگین', 'Agriculture', 'تراکتور جفت دیفرانسیل با ادوات کامل', 0.00, TRUE, 1800000.00)
ON CONFLICT DO NOTHING;
