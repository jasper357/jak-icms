CREATE SCHEMA IF NOT EXISTS inventory;

CREATE TABLE IF NOT EXISTS inventory.customers (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  full_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO inventory.customers (email, full_name)
VALUES
  ('alice@example.com', 'Alice Kim'),
  ('bob@example.com', 'Bob Lee')
ON CONFLICT (email) DO NOTHING;
