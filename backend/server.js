const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// PostgreSQL Pool connection for Neon
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_URL && process.env.DATABASE_URL.includes('localhost') ? false : { rejectUnauthorized: false }
});

app.use(cors());
app.use(express.json());

// Test DB Connection
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('❌ Neon Database connection error:', err);
  } else {
    console.log('✅ Connected to Neon PostgreSQL successfully at:', res.rows[0].now);
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    app: 'Super App API',
    status: 'Running successfully 🚀',
    database: 'Connected to Neon PostgreSQL',
    version: '1.0.0'
  });
});

// 1. Get Shops (Map Hub)
app.get('/api/shops', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM shops ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create Shop / Booth
app.post('/api/shops', async (req, res) => {
  const { name, category, description, address, phone, latitude, longitude, operatingHours, image_url } = req.body;
  try {
    const query = `
      INSERT INTO shops (name, category, description, address, phone, latitude, longitude, operatingHours, image_url)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *;
    `;
    const values = [name, category, description, address, phone, latitude || 35.6892, longitude || 51.3890, operatingHours || '09:00 - 22:00', image_url || 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=150'];
    const result = await pool.query(query, values);
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create shop' });
  }
});

// 2. Get Products & Rentals
app.get('/api/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 3. Service Requests
app.get('/api/services', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM service_requests ORDER BY id DESC');
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/services', async (req, res) => {
  const { customer_name, service_type, description, address } = req.body;
  try {
    const query = `
      INSERT INTO service_requests (customer_name, service_type, description, address, status)
      VALUES ($1, $2, $3, $4, 'searching') RETURNING *;
    `;
    const result = await pool.query(query, [customer_name || 'کاربر مهمان', service_type || 'تاسیسات', description || '', address || 'تهران']);
    res.json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create service request' });
  }
});

// 4. User Profile & Wallet
app.get('/api/user', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users LIMIT 1');
    res.json(result.rows[0] || { name: 'فرزاد عباسی', wallet_balance: 2500000, bidding_coins: 25 });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.listen(port, () => {
  console.log(`🚀 Super App Backend API listening on port ${port}`);
});
