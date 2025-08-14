-- Enhanced Live Data Stock Portfolio Tracker Schema for Neueda API
-- This schema stores all stock data from Neueda API including real-time prices, timestamps, and period data
-- Database will be populated with live data from Neueda API on startup and updated every 30 seconds

-- Create the database
CREATE DATABASE IF NOT EXISTS stock_portfolio_tracker;
USE stock_portfolio_tracker;

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS `order`;
DROP TABLE IF EXISTS stock_price_history;
DROP TABLE IF EXISTS stock_period_stats;
DROP TABLE IF EXISTS stock;
DROP TABLE IF EXISTS stock_symbol;

-- Create stock_symbol table (stores all available symbols from Neueda API)
CREATE TABLE stock_symbol (
    symbol_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    symbol VARCHAR(20) NOT NULL UNIQUE,
    company_name VARCHAR(255) NOT NULL,
    neueda_symbol_id BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_symbol (symbol),
    INDEX idx_neueda_id (neueda_symbol_id),
    INDEX idx_active (is_active)
);

-- Create stock table (for user-held stocks - extends stock_symbol)
CREATE TABLE stock (
    stock_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    symbol_id BIGINT NOT NULL,
    ticker_symbol VARCHAR(20) NOT NULL UNIQUE,
    company_name VARCHAR(255),
    sector VARCHAR(100),
    industry VARCHAR(100),
    country VARCHAR(50),
    current_price DECIMAL(10,4),
    previous_close DECIMAL(10,4),
    volume BIGINT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (symbol_id) REFERENCES stock_symbol(symbol_id),
    INDEX idx_ticker (ticker_symbol),
    INDEX idx_last_updated (last_updated)
);

-- Create stock_price_history table (stores real-time price updates from Neueda API)
CREATE TABLE stock_price_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    symbol_id BIGINT NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    company_name VARCHAR(255),
    price DECIMAL(10,4) NOT NULL,
    period_number BIGINT,
    time_stamp TIME,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (symbol_id) REFERENCES stock_symbol(symbol_id),
    INDEX idx_symbol (symbol),
    INDEX idx_period (period_number),
    INDEX idx_timestamp (time_stamp),
    INDEX idx_recorded_at (recorded_at)
);

-- Create stock_period_stats table (stores period statistics from Neueda API)
CREATE TABLE stock_period_stats (
    stats_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    symbol_id BIGINT NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    period_number BIGINT NOT NULL,
    opening_price DECIMAL(10,4),
    closing_price DECIMAL(10,4),
    max_price DECIMAL(10,4),
    min_price DECIMAL(10,4),
    period_start_time TIME,
    period_end_time TIME,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (symbol_id) REFERENCES stock_symbol(symbol_id),
    UNIQUE KEY unique_symbol_period (symbol, period_number),
    INDEX idx_symbol (symbol),
    INDEX idx_period (period_number),
    INDEX idx_recorded_at (recorded_at)
);

-- Create order table (user trading activity)
CREATE TABLE `order` (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    ticker_symbol VARCHAR(20) NOT NULL,
    order_type ENUM('BUY', 'SELL') NOT NULL,
    quantity BIGINT NOT NULL,
    price DECIMAL(10,4) NOT NULL,
    status ENUM('PENDING', 'COMPLETED', 'FAILED') DEFAULT 'PENDING',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_date TIMESTAMP NULL,
    total_amount DECIMAL(15,4) GENERATED ALWAYS AS (quantity * price) STORED,
    INDEX idx_ticker (ticker_symbol),
    INDEX idx_status (status),
    INDEX idx_order_date (order_date)
);

-- Create account table (for cash balance)
CREATE TABLE IF NOT EXISTS account (
    account_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cash_balance DECIMAL(15,4) NOT NULL DEFAULT 100000.00
);

-- Seed initial account balance
INSERT INTO account (cash_balance) VALUES (100000.00);

-- Create indexes for better performance
CREATE INDEX idx_stock_symbol_active_symbol ON stock_symbol(is_active, symbol);
CREATE INDEX idx_stock_price_history_symbol_time ON stock_price_history(symbol, recorded_at);
CREATE INDEX idx_stock_period_stats_symbol_period ON stock_period_stats(symbol, period_number);

-- Verify the setup
SELECT 'Enhanced database setup complete!' as status;
SELECT COUNT(*) as symbols_count FROM stock_symbol;
SELECT COUNT(*) as stocks_count FROM stock;
SELECT COUNT(*) as price_history_count FROM stock_price_history;
SELECT COUNT(*) as period_stats_count FROM stock_period_stats;

-- Show table structure
DESCRIBE stock_symbol;
DESCRIBE stock;
DESCRIBE stock_price_history;
DESCRIBE stock_period_stats;
DESCRIBE `order`;
DESCRIBE account;
