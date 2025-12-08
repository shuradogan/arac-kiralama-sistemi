const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

pool.on('connect', () => {
  console.log(' PostgreSQL bağlandı');
});

pool.on('error', (err) => {
  console.error(' PostgreSQL hatası:', err.message);
});

module.exports = pool;
