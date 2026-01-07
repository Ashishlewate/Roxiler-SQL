CREATE DATABASE rating_platform;
USE rating_platform;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(60) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    address VARCHAR(400),
    role ENUM('ADMIN', 'USER', 'STORE_OWNER') NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Indexes for admin filtering
    INDEX idx_users_name (name),
    INDEX idx_users_email (email),
    INDEX idx_users_role (role)
);
CREATE TABLE stores (
    id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    address VARCHAR(400) NOT NULL,
    owner_id INT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_store_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    INDEX idx_store_name (name),
    INDEX idx_store_address (address)
);
CREATE TABLE ratings (
    id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    store_id INT NOT NULL,
    rating INT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_rating_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_rating_store
        FOREIGN KEY (store_id)
        REFERENCES stores(id)
        ON DELETE CASCADE,

    -- One rating per user per store
    UNIQUE KEY unique_user_store (user_id, store_id)
);

CREATE OR REPLACE VIEW admin_dashboard_stats AS
SELECT
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM stores) AS total_stores,
    (SELECT COUNT(*) FROM ratings) AS total_ratings;
    
CREATE OR REPLACE VIEW store_listing_details AS
SELECT
    s.id AS store_id,
    s.name AS store_name,
    s.address AS store_address,
    ROUND(COALESCE(AVG(r.rating), 0), 2) AS overall_rating,
    COUNT(r.id) AS total_reviews
FROM stores s
LEFT JOIN ratings r ON s.id = r.store_id
GROUP BY s.id;

